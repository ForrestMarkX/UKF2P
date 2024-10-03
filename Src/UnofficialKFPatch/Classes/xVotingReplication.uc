// Written by Marco.
// Mapvote manager client.
Class xVotingReplication extends ReplicationInfo;

struct FGameTypeEntry
{
	var string GameName,GameShortName,Prefix,Options;
    var byte CycleIndex;
};
struct FMapEntry
{
	var string MapName,MapTitle;
	var int UpVotes,DownVotes,Sequence,NumPlays,History;
    var byte CycleIndex;
};
struct FVotedMaps
{
	var int GameIndex,MapIndex,NumVotes;
};
struct FAdvancedTopVotes
{
    var int Game1Index, Game2Index, Game3Index;
};

var array<FGameTypeEntry> GameModes;
var array<FMapEntry> Maps;
var array<FVotedMaps> ActiveVotes;

var KFPlayerController PlayerOwner;
var xVotingHandler VoteHandler;
var byte DownloadStage;
var int DownloadIndex,ClientCurrentGame;
var int CurrentVote[2];
var transient float RebunchTimer,NextVoteTimer,NextReplicationTick;
var bool bClientConnected,bAllReceived,bClientRanked;
var transient bool bListDirty, bFromChatCommand, bWantsToShowRank;
var xVotingReplication StaticReference;
var FAdvancedTopVotes CurrentAdvancedTopVotes;

simulated function PostBeginPlay()
{
    default.StaticReference = self;
    xVotingReplication(`FindDefaultObject(class'xVotingReplication')).StaticReference = self;
	PlayerOwner = KFPlayerController(Owner);
	RebunchTimer = WorldInfo.TimeSeconds+5.f;
}
function Tick( float Delta )
{
	if( PlayerOwner==None || PlayerOwner.Player==None )
	{
		Destroy();
		return;
	}
	if( !bClientConnected )
	{
		if( RebunchTimer<WorldInfo.TimeSeconds )
		{
			RebunchTimer = WorldInfo.TimeSeconds+0.75;
			ClientVerify();
		}
	}
    else if( DownloadStage<255 && WorldInfo.RealTimeSeconds >= NextReplicationTick )
    {
        VoteHandler.ClientDownloadInfo(Self);
        NextReplicationTick = WorldInfo.RealTimeSeconds + (Delta*2.f);
    }
}

reliable server function ServerNotifyReady()
{
	bClientConnected = true;
}
unreliable client simulated function ClientVerify()
{
	SetOwner(GetPlayer());
	ServerNotifyReady();
}

simulated function PlayerController GetPlayer()
{
	if( PlayerOwner==None )
		PlayerOwner = KFPlayerController(GetALocalPlayerController());
	return PlayerOwner;
}
reliable client simulated function ClientReceiveGame( int Index, string GameName, string GameSName, string Prefix, byte CycleIndex, string Options )
{
	if( GameModes.Length<=Index )
		GameModes.Length = Index+1;
	GameModes[Index].GameName = GameName;
	GameModes[Index].GameShortName = GameSName;
	GameModes[Index].Prefix = Prefix;
	GameModes[Index].CycleIndex = CycleIndex;
	GameModes[Index].Options = Options;
	bListDirty = true;
}
reliable client simulated function ClientReceiveMap( int Index, string MapName, int UpVote, int DownVote, int Sequence, int NumPlays, int CycleIndex, optional string MapTitle )
{
	if( Maps.Length<=Index )
		Maps.Length = Index+1;
	Maps[Index].MapName = MapName;
	Maps[Index].MapTitle = (MapTitle!="" ? MapTitle : MapName);
	Maps[Index].UpVotes = UpVote;
	Maps[Index].DownVotes = DownVote;
	Maps[Index].Sequence = Sequence;
	Maps[Index].NumPlays = NumPlays;
    Maps[Index].CycleIndex = CycleIndex;
	bListDirty = true;
}
function int MapVoteSort(FVotedMaps A, FVotedMaps B)
{
	local int Result;

	if( A.NumVotes == B.NumVotes )
		Result = 0;
	else  Result = A.NumVotes > B.NumVotes ? 1 : -1;

	return Result;
}
reliable client simulated function ClientReceiveVote( int GameIndex, int MapIndex, int VoteCount )
{
	local int i;

	for( i=0; i<ActiveVotes.Length; ++i )
		if( ActiveVotes[i].GameIndex==GameIndex && ActiveVotes[i].MapIndex==MapIndex )
		{
			if( VoteCount==0 )
				ActiveVotes.Remove(i,1);
			else ActiveVotes[i].NumVotes = VoteCount;
			bListDirty = true;
            UpdateTopVotes();
			return;
		}
        
	if( VoteCount==0 )
    {
        UpdateTopVotes();
		return;
    }
        
	ActiveVotes.Length = i+1;
	ActiveVotes[i].GameIndex = GameIndex;
	ActiveVotes[i].MapIndex = MapIndex;
	ActiveVotes[i].NumVotes = VoteCount;
    ActiveVotes.Sort(MapVoteSort);
	bListDirty = true;
    
    UpdateTopVotes();
}
simulated function UpdateTopVotes()
{
    local TopVotes TopVotesObject;
    
    if( ActiveVotes.Length >= 1 )
    {
        TopVotesObject.Map1Name = Maps[ActiveVotes[0].MapIndex].MapName;
        TopVotesObject.Map1Votes = ActiveVotes[0].NumVotes;
        CurrentAdvancedTopVotes.Game1Index = ActiveVotes[0].GameIndex;
    }
    if( ActiveVotes.Length >= 2 )
    {
        TopVotesObject.Map2Name = Maps[ActiveVotes[1].MapIndex].MapName;
        TopVotesObject.Map2Votes = ActiveVotes[1].NumVotes;
        CurrentAdvancedTopVotes.Game2Index = ActiveVotes[1].GameIndex;
    }
    if( ActiveVotes.Length >= 3 )
    {
        TopVotesObject.Map3Name = Maps[ActiveVotes[2].MapIndex].MapName;
        TopVotesObject.Map3Votes = ActiveVotes[2].NumVotes;
        CurrentAdvancedTopVotes.Game3Index = ActiveVotes[2].GameIndex;
    }
    
    KFPlayerReplicationInfo(GetPlayer().PlayerReplicationInfo).RecieveTopMaps(TopVotesObject);
}
reliable client simulated function ClientReady( int CurGame )
{
	ClientCurrentGame = CurGame;
	bAllReceived = true;
	MapVoteMsg("Maplist successfully received.");
}

simulated function MapVoteMsg( string S )
{
	if( S!="" )
		`GetURI().GetPlayerChat(GetPlayer().PlayerReplicationInfo).WriteToChat("<font color=\"#22B14C\" face=\"MIcon\">"$`GetMIconChar("vote")$"</font> <font color=\"#22B14C\">MapVote</font><font color=\"#FFFFFF\">: "$S$"</font>");
}
reliable client simulated function ClientNotifyVote( PlayerReplicationInfo PRI, int GameIndex, int MapIndex )
{
	if( bAllReceived )
		MapVoteMsg((PRI!=None ? PRI.PlayerName : "Someone")$" has voted for "$Maps[MapIndex].MapTitle$" ("$GameModes[GameIndex].GameShortName$").");
	else MapVoteMsg((PRI!=None ? PRI.PlayerName : "Someone")$" has voted for a map.");
}

reliable client simulated function ClientNotifyVoteTime( int Time )
{
	if( Time==0 )
		MapVoteMsg("Initializing mid-game mapvote...");
	if( Time<=10 )
		MapVoteMsg(string(Time)$"...");
	else if( Time<60 )
		MapVoteMsg(string(Time)$" seconds...");
	else if( Time==60 )
		MapVoteMsg("1 minute remains...");
	else if( Time==120 )
		MapVoteMsg("2 minutes remain...");
}
reliable client simulated function ClientNotifyVoteWin( int GameIndex, int MapIndex, bool bAdminForce )
{
	if( bAdminForce )
	{
		if( bAllReceived )
			MapVoteMsg("An admin has forced mapswitch to "$Maps[MapIndex].MapTitle$" ("$GameModes[GameIndex].GameShortName$").");
		else MapVoteMsg("An admin has forced a mapswitch.");
	}
	else if( bAllReceived )
		MapVoteMsg(Maps[MapIndex].MapTitle$" ("$GameModes[GameIndex].GameShortName$") has won mapvote, switching map...");
	else MapVoteMsg("A map has won mapvote, switching map...");
}
reliable client simulated function ClientOpenMapvote( optional bool bShowRank, optional bool bChatCommand )
{
    bFromChatCommand = bChatCommand;
    bWantsToShowRank = bShowRank;
    if( bAllReceived )
        SetTimer(0.01f,false,'DelayedOpenMapvote'); // To prevent no-mouse issue when local server host opens it from chat.
    else SetTimer(0.1f,true,'WaitForMaps');
    
    if( KFGameReplicationInfo(WorldInfo.GRI)!=none )
        KFGameReplicationInfo(WorldInfo.GRI).ProcessChanceDrop();
}
simulated function WaitForMaps()
{
    if( bAllReceived )
    {
        SetTimer(0.01f,false,'DelayedOpenMapvote');
        ClearTimer('WaitForMaps');
    }
}
simulated function DelayedOpenMapvote()
{
    if( bFromChatCommand )
    {
        PlayerOwner.MyGFxManager.OpenMenu(UI_PostGame, true);
        PlayerOwner.MyHUD.bShowHUD = false;

        HideUIElements();
        `TimerHelper.SetTimer(0.1f, false, 'HideUIElements', self);
        `TimerHelper.SetTimer(0.25f, false, 'HideUIElements', self);
        `TimerHelper.SetTimer(1.f, false, 'HideUIElements', self);
        
        `TimerHelper.SetTimer(WorldInfo.DeltaSeconds, false, 'WaitForMenuClose', self);
        
        bFromChatCommand = false;
    }
    else PlayerOwner.ClientShowPostGameMenu();
    
    if( bWantsToShowRank )
    {
        if( `GetURI().bHasDisabledRanking )
            return;
        PlayerOwner.MyGFxManager.DelayedOpenPopup(EConfirmation, EDPPID_Misc, "Map Review", "Did you like this map?", "Like", "Dislike", LikeMapCallback, DislikeMapCallback);
        bWantsToShowRank = false;
    }
}
simulated function WaitForMenuClose()
{
    if( PlayerOwner.MyGFxManager.CurrentMenuIndex != UI_PostGame )
        ResetUIElements();
    else `TimerHelper.SetTimer(WorldInfo.DeltaSeconds, false, 'WaitForMenuClose', self);
}
simulated function ResetUIElements()
{
    PlayerOwner.MyGFxManager.PartyWidget.SetVisible(true);
    PlayerOwner.MyGFxManager.BackendStatusIndicatorWidget.SetVisible(true);
    
    `TimerHelper.ClearTimer('HideUIElements', self);
    `TimerHelper.SetTimer(1.f, false, 'ResetMapText', self);
}
simulated function HideUIElements()
{
    PlayerOwner.MyGFxManager.PartyWidget.SetVisible(false);
    PlayerOwner.MyGFxManager.BackendStatusIndicatorWidget.SetVisible(false);
    
    `TimerHelper.ClearTimer('ResetMapText', self);
    
    PlayerOwner.MyGFxManager.PostGameMenu.GetObject("nextMapText").SetVisible(false);
    PlayerOwner.MyGFxManager.PostGameMenu.GetObject("nextMapTimerText").SetVisible(false);
}
simulated function ResetMapText()
{
    PlayerOwner.MyGFxManager.PostGameMenu.GetObject("nextMapText").SetVisible(true);
    PlayerOwner.MyGFxManager.PostGameMenu.GetObject("nextMapTimerText").SetVisible(true);
}

function LikeMapCallback()
{
    ServerRankMap(true);
}

function DislikeMapCallback()
{
    ServerRankMap(false);
}

reliable server simulated function ServerCastVote( int GameIndex, int MapIndex, bool bAdminForce )
{
    if( PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
        return;
        
	if( NextVoteTimer<WorldInfo.TimeSeconds && Left(VoteHandler.Maps[MapIndex].MapName, 3) ~= "KF-" )
	{
		NextVoteTimer = WorldInfo.TimeSeconds+1.f;
		VoteHandler.ClientCastVote(Self,GameIndex,MapIndex,bAdminForce);
	}
}
reliable server simulated function ServerRankMap( bool bUp )
{
    if( PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
        return;
        
	if( !bClientRanked )
	{
		bClientRanked = true;
		VoteHandler.ClientRankMap(Self,bUp);
	}
}

function Destroyed()
{
	VoteHandler.ClientDisconnect(Self);
}

defaultproperties
{
	bAlwaysRelevant=false
	bOnlyRelevantToOwner=true
	CurrentVote(0)=-1
	CurrentVote(1)=-1
}