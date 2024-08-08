Class xVotingHandler extends Info
	config(xMapVote)
    dependson(xVotingReplication);

struct FGameModeOption
{
	var string GameName,GameShortName,GameClass,Mutators,Options,Prefix;
    var byte CycleIndex;
};
var config array<FGameModeOption> GameModes;
var config int LastVotedGameInfo,MaxMapsOnList;
var config float MidGameVotePct,MapChangeDelay;

var array<FMapEntry> Maps;
var array<FVotedMaps> ActiveVotes;
var array<xVotingReplication> ActiveVoters;
var int iCurrentHistory,ShowMenuDelay,iWonIndex,OldRemainingTime;
var string PendingMapURL;
var KFGameReplicationInfo KF;
var bool bMapvoteHasEnded,bMapVoteTimer,bHistorySaved;

function PostBeginPlay()
{
	local int i,j,z,n,UpV,DownV,Seq,NumPl;
	local string S,MapFile,MapName;

	MapFile = string(WorldInfo.GetPackageName());
	iCurrentHistory = class'xMapVoteHistory'.Static.GetMapHistory(MapFile,WorldInfo.Title);
	if( LastVotedGameInfo<0 || LastVotedGameInfo>=GameModes.Length )
		LastVotedGameInfo = 0;
	
	if( MapChangeDelay==0 )
		MapChangeDelay = 3;
	if( GameModes.Length==0 ) // None specified, so use current settings.
	{
		GameModes.Length = 1;
		GameModes[0].GameName = "Killing Floor";
		GameModes[0].GameShortName = "KF";
		GameModes[0].GameClass = PathName(WorldInfo.Game.Class);
		GameModes[0].Mutators = "";
		GameModes[0].Prefix = "";
		MidGameVotePct = 0.51;
		SaveConfig();
	}

	// Build maplist.
    z = 0;
    for( i=0; i<class'KFGameInfo'.default.GameMapCycles.Length; ++i )
    {
        for( j=0; j<class'KFGameInfo'.default.GameMapCycles[i].Maps.Length; ++j )
        {
            if( MaxMapsOnList>0 && class'KFGameInfo'.default.GameMapCycles[i].Maps[j]~=MapFile ) // If we limit the maps count, remove current map.
                continue;
                
            MapName = `Trim(class'KFGameInfo'.default.GameMapCycles[i].Maps[j]);
            if( Len(MapName) <= 0 )
                continue;
                
            Maps.Length = z+1;
            Maps[z].MapName = MapName;
            n = class'xMapVoteHistory'.Static.GetMapHistory(MapName,"");
            class'xMapVoteHistory'.Static.GetHistory(n,UpV,DownV,Seq,NumPl,S);
            Maps[z].UpVotes = UpV;
            Maps[z].DownVotes = DownV;
            Maps[z].Sequence = Seq;
            Maps[z].NumPlays = NumPl;
            Maps[z].History = n;
            Maps[z].MapTitle = S;
            Maps[z].CycleIndex = i;
            ++z;
        }
    }
	
	if( MaxMapsOnList>0 )
	{
		// Remove random maps from list.
		while( Maps.Length>MaxMapsOnList )
			Maps.Remove(Rand(Maps.Length),1);
	}

	SetTimer(0.15,false,'SetupBroadcast');
	SetTimer(1,true,'CheckEndGameEnded');
}

function SetupBroadcast()
{
	local xVoteBroadcast B;
	local WebServer W;
	local WebAdmin A;
	local xVoteWebApp xW;
	local byte i;
	
	B = Spawn(class'xVoteBroadcast');
	B.Handler = Self;
	B.NextBroadcaster = WorldInfo.Game.BroadcastHandler;
	WorldInfo.Game.BroadcastHandler = B;

    foreach AllActors(class'WebServer',W)
        break;
    if( W!=None )
    {
        for( i=0; (i<10 && A==None); ++i )
            A = WebAdmin(W.ApplicationObjects[i]);
        if( A!=None )
        {
            xW = new (None) class'xVoteWebApp';
            A.addQueryHandler(xW);
        }
        else `Log("X-VoteWebAdmin ERROR: No valid WebAdmin application found!");
    }
    else `Log("X-VoteWebAdmin ERROR: No WebServer object found!");
}
function int MapVoteSort(FVotedMaps A, FVotedMaps B)
{
	return A.NumVotes == B.NumVotes ? 0 : (A.NumVotes > B.NumVotes ? 1 : -1);
}
function AddVote( int Count, int MapIndex, int GameIndex )
{
	local int i,j;

	if( bMapvoteHasEnded )
		return;
	for( i=0; i<ActiveVotes.Length; ++i )
		if( ActiveVotes[i].GameIndex==GameIndex && ActiveVotes[i].MapIndex==MapIndex )
		{
			ActiveVotes[i].NumVotes += Count;
			for( j=(ActiveVoters.Length-1); j>=0; --j )
				ActiveVoters[j].ClientReceiveVote(GameIndex,MapIndex,ActiveVotes[i].NumVotes);
			if( ActiveVotes[i].NumVotes<=0 )
			{
				for( j=(ActiveVoters.Length-1); j>=0; --j )
					if( ActiveVoters[j].DownloadStage==2 && ActiveVoters[j].DownloadIndex>=i && ActiveVoters[j].DownloadIndex>0 ) // Make sure client doesn't skip a download at this point.
						--ActiveVoters[j].DownloadIndex;
				ActiveVotes.Remove(i,1);
			}
			return;
		}
	if( Count<=0 )
		return;
	ActiveVotes.Length = i+1;
	ActiveVotes[i].GameIndex = GameIndex;
	ActiveVotes[i].MapIndex = MapIndex;
	ActiveVotes[i].NumVotes = Count;
	for( j=(ActiveVoters.Length-1); j>=0; --j )
		ActiveVoters[j].ClientReceiveVote(GameIndex,MapIndex,Count);
}
function LogoutPlayer( PlayerController PC )
{
	local int i;
	
	for( i=(ActiveVoters.Length-1); i>=0; --i )
		if( ActiveVoters[i].PlayerOwner==PC )
		{
			ActiveVoters[i].Destroy();
			break;
		}
}
function LoginPlayer( PlayerController PC )
{
	local xVotingReplication R;
	local int i;
	
	for( i=(ActiveVoters.Length-1); i>=0; --i )
		if( ActiveVoters[i].PlayerOwner==PC )
			return;
	R = Spawn(class'xVotingReplication',PC);
	R.VoteHandler = Self;
	ActiveVoters.AddItem(R);
}

function NotifyLogout(Controller Exiting)
{
	if( PlayerController(Exiting)!=None )
		LogoutPlayer(PlayerController(Exiting));
}
function NotifyLogin(Controller NewPlayer)
{
	if( PlayerController(NewPlayer)!=None )
		LoginPlayer(PlayerController(NewPlayer));
}

function ClientDownloadInfo( xVotingReplication V )
{
    local int i;
    local string Options;
    
	if( bMapvoteHasEnded )
	{
		V.DownloadStage = 255;
		return;
	}
	
	switch( V.DownloadStage )
	{
	case 0: // Game modes.
		if( V.DownloadIndex>=GameModes.Length )
			break;
        Options = "?CurrentWeekly="$WorldInfo.Game.GetIntOption(GameModes[V.DownloadIndex].Options, "CurrentWeekly", KFGameEngine(class'Engine'.static.GetEngine()).GetWeeklyEventIndex())$"?Game="$WorldInfo.Game.ParseOption(GameModes[V.DownloadIndex].Options, "Game");
        V.ClientReceiveGame(V.DownloadIndex,GameModes[V.DownloadIndex].GameName,GameModes[V.DownloadIndex].GameShortName,GameModes[V.DownloadIndex].Prefix,GameModes[V.DownloadIndex].CycleIndex,Options);
		++V.DownloadIndex;
		return;
	case 1: // Maplist.
		if( V.DownloadIndex>=Maps.Length )
			break;
            
        for( i=0; i<5; i++ )
        {
            if( Maps[V.DownloadIndex].MapTitle=="" )
                V.ClientReceiveMap(V.DownloadIndex,Maps[V.DownloadIndex].MapName,Maps[V.DownloadIndex].UpVotes,Maps[V.DownloadIndex].DownVotes,Maps[V.DownloadIndex].Sequence,Maps[V.DownloadIndex].NumPlays,Maps[V.DownloadIndex].CycleIndex);
            else V.ClientReceiveMap(V.DownloadIndex,Maps[V.DownloadIndex].MapName,Maps[V.DownloadIndex].UpVotes,Maps[V.DownloadIndex].DownVotes,Maps[V.DownloadIndex].Sequence,Maps[V.DownloadIndex].NumPlays,Maps[V.DownloadIndex].CycleIndex,Maps[V.DownloadIndex].MapTitle);
            
            V.DownloadIndex++;
            if( V.DownloadIndex>=Maps.Length )
            {
                V.DownloadStage++;
                break;
            }
		}
        
		return;
	case 2: // Current votes.
		if( V.DownloadIndex>=ActiveVotes.Length )
			break;
		V.ClientReceiveVote(ActiveVotes[V.DownloadIndex].GameIndex,ActiveVotes[V.DownloadIndex].MapIndex,ActiveVotes[V.DownloadIndex].NumVotes);
		++V.DownloadIndex;
		return;
	default:
		V.ClientReady(LastVotedGameInfo);
		V.DownloadStage = 255;
		return;
	}
	++V.DownloadStage;
	V.DownloadIndex = 0;
}
static function bool BelongsToPrefix( string MN, string Prefix )
{
	return (Prefix=="" || Left(MN,Len(Prefix))~=Prefix);
}
function ClientCastVote( xVotingReplication V, int GameIndex, int MapIndex, bool bAdminForce )
{
	local int i;

	if( bMapvoteHasEnded )
		return;

	if( bAdminForce && V.PlayerOwner.PlayerReplicationInfo.bAdmin )
	{
		SwitchToLevel(GameIndex,MapIndex,true);
		return;
	}
	if( !BelongsToPrefix(Maps[MapIndex].MapName,GameModes[GameIndex].Prefix) )
	{
		V.PlayerOwner.ClientMessage("Error: Can't vote that map (wrong Prefix to that game mode)!");
		return;
	}
    if( Maps[MapIndex].CycleIndex != GameModes[GameIndex].CycleIndex )
    {
        V.PlayerOwner.ClientMessage("Error: Can't vote that map (wrong Cycle Index to that game mode)!");
        return;
    }
	if( V.CurrentVote[0]>=0 )
		AddVote(-1,V.CurrentVote[1],V.CurrentVote[0]);
	V.CurrentVote[0] = GameIndex;
	V.CurrentVote[1] = MapIndex;
	AddVote(1,MapIndex,GameIndex);
	for( i=(ActiveVoters.Length-1); i>=0; --i )
		ActiveVoters[i].ClientNotifyVote(V.PlayerOwner.PlayerReplicationInfo,GameIndex,MapIndex);
	TallyVotes();
}
function ClientRankMap( xVotingReplication V, bool bUp )
{
	class'xMapVoteHistory'.Static.AddMapKarma(iCurrentHistory,bUp);
}
function ClientDisconnect( xVotingReplication V )
{
	ActiveVoters.RemoveItem(V);
	if( V.CurrentVote[0]>=0 )
		AddVote(-1,V.CurrentVote[1],V.CurrentVote[0]);
	TallyVotes();
}

function float GetPctOf( int Nom, int Denom )
{
	local float R;
	
	R = float(Nom) / float(Denom);
	return R;
}
function TallyVotes( optional bool bForce )
{
	local int i,c,NumVotees;

	if( bMapvoteHasEnded )
		return;
		
    for( i=0; i<ActiveVoters.Length; i++ )
    {
        if( ActiveVoters[i] == None || ActiveVoters[i].PlayerOwner == None || ActiveVoters[i].PlayerOwner.PlayerReplicationInfo == None || ActiveVoters[i].PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
            continue;
        NumVotees++;
    }

	ActiveVotes.Sort(MapVoteSort);
	for( i=0; i<ActiveVotes.Length; i++ )
        c+=ActiveVotes[i].NumVotes;
		
	if( c >= NumVotees && WorldInfo.GRI.RemainingTime > 5 )
	{
		WorldInfo.GRI.RemainingTime = 5;
		WorldInfo.GRI.RemainingMinute = 5;
	}

    if( bForce )
    {
        if( ActiveVotes.Length > 0 )
            SwitchToLevel(ActiveVotes[0].GameIndex,ActiveVotes[0].MapIndex,false);
        else SwitchToLevel(0,Rand(Maps.Length),false);
    }
    
	// Check for mid-game voting timer.
	if( !bMapVoteTimer && NumVotees>0 && GetPctOf(c,NumVotees)>=MidGameVotePct )
		StartMidGameVote(true);
}
function StartMidGameVote( bool bMidGame )
{
	local int i;
    local KFGameReplicationInfo KFGRI;
    local KFGameInfo_Survival KFGI;

	if( bMapVoteTimer || bMapvoteHasEnded )
		return;
        
	bMapVoteTimer = true;
	if( bMidGame )
	{
		for( i=(ActiveVoters.Length-1); i>=0; --i )
			ActiveVoters[i].ClientNotifyVoteTime(0);
	}
	ShowMenuDelay = 5;
    
    KFGI = KFGameInfo_Survival(WorldInfo.Game);
    if( KFGI != None )
    {
        KFGI.bEnableDeadToVOIP = true;
        KFGI.bGameRestarted = true;
        KFGI.UpdateCurrentMapVoteTime( KFGI.GetEndOfMatchTime(), true);
		KFGI.ClearTimer('RestartGame');
		KFGI.ClearTimer('TryRestartGame');
		KFGI.ClearTimer('ForceChangeLevel');
        OldRemainingTime = WorldInfo.GRI.RemainingTime;
    }
    
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
    {
        KFGRI.bWaitingForAAR = false;
		KFGRI.OnOpenAfterActionReport( KFGRI.RemainingTime );
    }

	SetTimer(1,true);
}
function CheckEndGameEnded()
{
	if( KF==None )
	{
		KF = KFGameReplicationInfo(WorldInfo.GRI);
		if( KF==None )
			return;
	}
	if( KF.bMatchIsOver ) // HACK, since KFGameInfo_Survival doesn't properly notify mutators of this!
	{
		if( !bMapVoteTimer )
			StartMidGameVote(false);
		ClearTimer('CheckEndGameEnded');
		WorldInfo.Game.ClearTimer('ShowPostGameMenu');
	}
}
function bool HandleRestartGame()
{
	if( !bMapVoteTimer )
		StartMidGameVote(false);
	return true;
}
function Tick(float DT)
{
    Super.Tick(DT);
    
    if( bMapVoteTimer && OldRemainingTime != WorldInfo.GRI.RemainingTime )
    {
        if( WorldInfo.GRI.RemainingTime==0 )
            TallyVotes(true);
        OldRemainingTime = WorldInfo.GRI.RemainingTime;
    }
}
function Timer()
{
	local int i;

	if( ShowMenuDelay>0 && --ShowMenuDelay==0 )
	{
		for( i=(ActiveVoters.Length-1); i>=0; --i )
			ActiveVoters[i].ClientOpenMapvote(true);
	}
}
function SwitchToLevel( int GameIndex, int MapIndex, bool bAdminForce )
{
	local int i;
	local string S;
    
	if( bMapvoteHasEnded )
		return;
	
	Default.LastVotedGameInfo = GameIndex;
	Class.Static.StaticSaveConfig();
	bMapvoteHasEnded = true;
	if( !bAdminForce && !bHistorySaved )
	{
		class'xMapVoteHistory'.Static.UpdateMapHistory(Maps[MapIndex].History);
		class'xMapVoteHistory'.Static.StaticSaveConfig();
		bHistorySaved = true;
	}
	
	S = Maps[MapIndex].MapName$" ("$GameModes[GameIndex].GameName$")";
	for( i=(ActiveVoters.Length-1); i>=0; --i )
	{
		ActiveVoters[i].PlayerOwner.ShowConnectionProgressPopup(PMT_AdminMessage,"Switching to level:",S);
		ActiveVoters[i].ClientNotifyVoteWin(GameIndex,MapIndex,bAdminForce);
	}
	
    if( GameModes.Length <= 1 )
    {
        WorldInfo.ServerTravel(Maps[MapIndex].MapName,WorldInfo.Game.GetTravelType());
        return;
    }
    else
    {
        PendingMapURL = Maps[MapIndex].MapName$"?Game="$GameModes[GameIndex].GameClass;
        if( GameModes[GameIndex].Mutators!="" )
            PendingMapURL $= "?Mutator="$GameModes[GameIndex].Mutators;
        if( GameModes[GameIndex].Options!="" )
            PendingMapURL $= "?"$GameModes[GameIndex].Options;
    }
	`Log("Switch map to "$PendingMapURL,,'MapVote');
	SetTimer(FMax(MapChangeDelay,0.1),false,'PendingSwitch');
}
function PendingSwitch()
{
	WorldInfo.ServerTravel(PendingMapURL,false);
	SetTimer(1,true);
}

function ParseCommand( string Cmd, PlayerController PC )
{
    local ReplicationHelper CRI;
    
    CRI = `GetURI().GetPlayerChat(PC.PlayerReplicationInfo);
	if( Cmd~="Help" )
	{
		CRI.WriteToChat("MapVote commands:");
		CRI.WriteToChat("!MapVote - Show mapvote menu");
		CRI.WriteToChat("!AddMap <Mapname> - Add map to mapvote");
		CRI.WriteToChat("!RemoveMap <Mapname> - Remove map from mapvote");
	}
	else if( Cmd~="MapVote" )
		ShowMapVote(PC, true);
	else if( !PC.PlayerReplicationInfo.bAdmin && !PC.IsA('MessagingSpectator') )
		return;
	else if( Left(Cmd,7)~="AddMap " )
	{
		Cmd = Mid(Cmd,7);
		CRI.WriteToChat("Added map '"$Cmd$"'!");
		AddMap(Cmd);
	}
	else if( Left(Cmd,10)~="RemoveMap " )
	{
		Cmd = Mid(Cmd,10);
		if( RemoveMap(Cmd) )
			CRI.WriteToChat("Removed map '"$Cmd$"'!");
		else CRI.WriteToChat("Map '"$Cmd$"' not found!");
	}
}
function ShowMapVote( PlayerController PC, optional bool bFromChatCommand )
{
	local int i;

	if( bMapvoteHasEnded )
		return;
	for( i=(ActiveVoters.Length-1); i>=0; --i )
		if( ActiveVoters[i].PlayerOwner==PC )
		{
			ActiveVoters[i].ClientOpenMapvote(false, bFromChatCommand);
			return;
		}
}
function AddMap( string M )
{
	if( Class'KFGameInfo'.Default.GameMapCycles.Length==0 )
		Class'KFGameInfo'.Default.GameMapCycles.Length = 1;
	Class'KFGameInfo'.Default.GameMapCycles[0].Maps.AddItem(M);
	Class'KFGameInfo'.Static.StaticSaveConfig();
}
function bool RemoveMap( string M )
{
	local int i,j;

	for( i=(Class'KFGameInfo'.Default.GameMapCycles.Length-1); i>=0; --i )
	{
		for( j=(Class'KFGameInfo'.Default.GameMapCycles[i].Maps.Length-1); j>=0; --j )
		{
			if( Class'KFGameInfo'.Default.GameMapCycles[i].Maps[j]~=M )
			{
				Class'KFGameInfo'.Default.GameMapCycles[i].Maps.Remove(j,1);
				Class'KFGameInfo'.Static.StaticSaveConfig();
				return true;
			}
		}
	}
	return false;
}

defaultproperties
{
}