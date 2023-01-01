class UKFPMutator extends KFMutator;

var transient KFGameInfo KFGI;
var private transient UKFPReplicationInfo RepInfo;
var private transient KFRealtimeTimerHelper TimerHelper;

var const private string FHUDClassLocation, YASClassLocation, AALClassLocation, CVCClassLocation;
var const private string FHUDCommandName, YASCommandName, AALCommandName, CVCCommandName, HideCommandName, NoEventCommandName, NoEDARCommandName, NoPingCommandName, BroadcastPickupsCommandName, UseDynamicMOTDCommandName, NoThirdPersonCommandName, HandCommandName, MapVoteCommandName;

function PreBeginPlay()
{
	TimerHelper = Spawn(class'KFRealtimeTimerHelper');
	
    GenerateMutatorEntry(Class.Name, PathName(Class));
    
	ConsoleCommand("SUPPRESS Log");
    ConsoleCommand("SUPPRESS DevNet");
    ConsoleCommand("SUPPRESS DevOnline");
    
    Super(Info).PreBeginPlay();
	
    KFGI = KFGameInfo(WorldInfo.Game);
	
	RepInfo = Spawn(class'UKFPReplicationInfo', self);
	RepInfo.XPMultiplier = KFGI.XPMultiplier;
	
    KFGI.bLogReservations = false;
    
    if( KFGI.bEnableGameAnalytics || KFGI.bRecordGameStatsFile )
    {
        KFGI.bEnableGameAnalytics = false;
        KFGI.bRecordGameStatsFile = false;
    }

    if( KFGI.GameplayEventsWriter != None )
    {
        KFGI.GameplayEventsWriter.EndLogging();
        KFGI.GameplayEventsWriter = None;
    }
}

final function GenerateMutatorEntry(name ClassName, string ClassPath)
{
    local KFMutatorSummary MutatorSummary;
    local array<string> Names, Groups;
    local int i;
    local bool bFoundConfig;
    
    GetPerObjectConfigSections(class'KFMutatorSummary', Names);
    for (i = 0; i < Names.Length; i++)
    {
        if( InStr(Names[i], string(ClassName),, true) != INDEX_NONE )
        {
            bFoundConfig = true;
            break;
        }
    }
    
    if( !bFoundConfig )
    {
        Groups.AddItem("Mutators");
        
        MutatorSummary = New(None, string(ClassName)) class'KFMutatorSummary';
        MutatorSummary.ClassName = ClassPath;
        MutatorSummary.GroupNames = Groups;
        MutatorSummary.SaveConfig();
    }
}

function InitMutator(string Options, out string ErrorMessage)
{
    local KFGameInfo_WeeklySurvival WeeklyGI;
    local int CurrentActiveEventIdx, ActiveEventIdx;
	local Mutator Mut;
	local byte MaxPlayers;
	local string InOpt;
    
	Super.InitMutator(Options, ErrorMessage);
    
    if( RepInfo == None )
        return;
		
    RepInfo.AddLoadPackage(SwfMovie'UKFP_UI_Shared.AssetLib');
    RepInfo.AddLoadPackage(SwfMovie'UKFP_UI_HUD.InGameHUD_SWF');
    
    RepInfo.CurrentPickupLifespan = KFGI.GetFloatOption(Options, "PickupLifespan", RepInfo.PickupLifespan);
	
	MaxPlayers = KFGI.GetIntOption(Options, "MaxPlayers", RepInfo.ForcedMaxPlayers);
	
    if( MaxPlayers > 0 )
    {
        KFGI.MaxPlayers = MaxPlayers;
        KFGI.MaxPlayersAllowed = MaxPlayers;
        RepInfo.RepMaxPlayers = MaxPlayers;
    }
	
    if( bool(KFGI.GetIntOption(Options, FHUDCommandName, int(RepInfo.bAttemptToLoadFHUD))) )
		KFGI.AddMutator(FHUDClassLocation, true);
    if( bool(KFGI.GetIntOption(Options, YASCommandName, int(RepInfo.bAttemptToLoadYAS))) || MaxPlayers > 6 )
		KFGI.AddMutator(YASClassLocation, true);
    if( bool(KFGI.GetIntOption(Options, AALCommandName, int(RepInfo.bAttemptToLoadAAL))) )
		KFGI.AddMutator(AALClassLocation, true);
    if( bool(KFGI.GetIntOption(Options, CVCCommandName, int(RepInfo.bAttemptToLoadCVC))) )
		KFGI.AddMutator(CVCClassLocation, true);
		
    InOpt = KFGI.ParseOption(Options, "ServerName");
    if( InOpt != "" )
        class'GameReplicationInfo'.default.ServerName = InOpt;
        
    if( bool(KFGI.GetIntOption(Options, HideCommandName, int(RepInfo.bServerHidden))) )
    {
        RepInfo.bServerIsHidden = true;

        `Log("Verifing session before hiding...",,'Private Game');
		RepInfo.OnlineSub.GameInterface.AddUpdateOnlineGameCompleteDelegate(RepInfo.CheckPrivateGameWorkshop);
    }
        
    if( bool(KFGI.GetIntOption(Options, MapVoteCommandName, int(RepInfo.bAllowGamemodeVotes))) )
        RepInfo.VotingHandler = Spawn(class'xVotingHandler');
        
    CurrentActiveEventIdx = KFGI.GetIntOption(Options, "CurrentWeekly", int(RepInfo.WeeklyIndex));
    RepInfo.bToBroadcastPickups = bool(KFGI.GetIntOption(Options, BroadcastPickupsCommandName, int(RepInfo.bBroadcastPickups)));
    RepInfo.bForceDisableEDARs = bool(KFGI.GetIntOption(Options, NoEDARCommandName, int(RepInfo.bNoEDARSpawns)));
    RepInfo.bDisallowHandSwap = bool(KFGI.GetIntOption(Options, HandCommandName, int(RepInfo.bDisallowHandChanges)));
    RepInfo.CurrentMaxMonsters = KFGI.GetIntOption(Options, "MaxMonsters", RepInfo.MaxMonsters);
    RepInfo.CurrentFakePlayers = KFGI.GetIntOption(Options, "FakePlayers", RepInfo.FakePlayers);
    RepInfo.CurrentForcedSeasonalEventDate = ESeasonalEventType(KFGI.GetIntOption(Options, "CurrentSeasonalEvent", RepInfo.ForcedSeasonalEventDate));
    RepInfo.bServerEnforceVanilla = bool(KFGI.GetIntOption(Options, "EnforceVanilla", int(RepInfo.bEnforceVanilla)));
	if( RepInfo.bServerEnforceVanilla )
	{
		RepInfo.bNoEventSkins = true;
		RepInfo.bNoPings = true;
		RepInfo.bServerDisableTP = true;
		RepInfo.CurrentNormalSummerSCAnims = true;
		RepInfo.bServerDropAllWepsOnDeath = false;
	}
	else
	{
		RepInfo.bNoEventSkins = bool(KFGI.GetIntOption(Options, NoEventCommandName, int(RepInfo.bNoEventZEDSkins)));
		RepInfo.bNoPings = bool(KFGI.GetIntOption(Options, NoPingCommandName, int(RepInfo.bNoPingsAllowed)));
		RepInfo.bServerDisableTP = bool(KFGI.GetIntOption(Options, NoThirdPersonCommandName, int(RepInfo.bDisableTP)));
		RepInfo.CurrentNormalSummerSCAnims = bool(KFGI.GetIntOption(Options, "UseNormalSummerSCAnims", int(RepInfo.bUseNormalSummerSCAnims)));
		RepInfo.bServerDropAllWepsOnDeath = bool(KFGI.GetIntOption(Options, "DropAllWepsOnDeath", int(RepInfo.bDropAllWepsOnDeath)));
	}
    RepInfo.PingSpamTime = KFGI.GetFloatOption(Options, "PingSpamTime", RepInfo.PingSpamTime);

    if( bool(KFGI.GetIntOption(Options, UseDynamicMOTDCommandName, int(RepInfo.bUseDynamicMOTD))) )
    {
		foreach DynamicActors(class'Mutator', Mut)
		{
			if( !RepInfo.DynamicMOTD.bYASLoaded && Mut.Class.GetPackageName() == 'YAS' )
				RepInfo.DynamicMOTD.bYASLoaded = Mut.IsA('YASMut');
			if( !RepInfo.DynamicMOTD.bAALLoaded && Mut.Class.GetPackageName() == 'AAL' )
				RepInfo.DynamicMOTD.bAALLoaded = Mut.IsA('AALMut');
			if( !RepInfo.DynamicMOTD.bCVCLoaded  && Mut.Class.GetPackageName() == 'CVC' )
				RepInfo.DynamicMOTD.bCVCLoaded = Mut.IsA('CVCMut');
			if( !RepInfo.DynamicMOTD.bFHUDLoaded  && Mut.Class.GetPackageName() == 'FriendlyHUD' )
				RepInfo.DynamicMOTD.bFHUDLoaded = Mut.IsA('FriendlyHUDMutator');
		}
        RepInfo.DynamicMOTD.bNoEventSkins = RepInfo.bNoEventSkins;
        RepInfo.DynamicMOTD.bNoPings = RepInfo.bNoPings;
        RepInfo.DynamicMOTD.bToBroadcastPickups = RepInfo.bToBroadcastPickups;
        RepInfo.DynamicMOTD.CurrentMaxPlayers = MaxPlayers;
        RepInfo.DynamicMOTD.CurrentMaxMonsters = RepInfo.CurrentMaxMonsters;
        RepInfo.DynamicMOTD.CurrentFakePlayers = RepInfo.CurrentFakePlayers;
        RepInfo.DynamicMOTD.CurrentPickupLifespan = RepInfo.CurrentPickupLifespan;
        RepInfo.DynamicMOTD.bDisableTP = RepInfo.bServerDisableTP;
        RepInfo.DynamicMOTD.bDisallowHandSwap = RepInfo.bDisallowHandSwap;
        RepInfo.DynamicMOTD.bUseNormalSummerSCAnims = RepInfo.bUseNormalSummerSCAnims;
        RepInfo.DynamicMOTD.bDropAllWepsOnDeath = RepInfo.bServerDropAllWepsOnDeath;
        RepInfo.DynamicMOTD.bNoEDARs = RepInfo.bForceDisableEDARs;
    }

    RepInfo.CurrentMapName = RepInfo.ConvertMapName(WorldInfo.GetMapName(true));
    RepInfo.SetTimer(WorldInfo.DeltaSeconds*2.f, false, 'CheckForMapFixes');

    WeeklyGI = KFGameInfo_WeeklySurvival(KFGI);
    if( WeeklyGI != None )
    {
        if( WeeklyGI.OutbreakEvent == None )
            WeeklyGI.CreateOutbreakEvent();
    
        RepInfo.InitialWeeklyIndex = WeeklyGI.ActiveEventIdx;
        
        if( CurrentActiveEventIdx == OUTBREAK_NORMAL )
            ActiveEventIdx = RepInfo.InitialWeeklyIndex;
        else ActiveEventIdx = CurrentActiveEventIdx-1;
        
        WeeklyGI.ActiveEventIdx = ActiveEventIdx;
        WeeklyGI.OutbreakEvent.SetActiveEvent(WeeklyGI.ActiveEventIdx);
        
        RepInfo.FunctionProxy.ForceUpdateWeeklyIndex(WeeklyGI.ActiveEventIdx);
    }
    
    RepInfo.InitialSeasonalEventDate = RepInfo.FunctionProxy.GetSeasonalEventID(KFGameEngine(class'Engine'.static.GetEngine()));
    if( RepInfo.CurrentForcedSeasonalEventDate != SET_None )
    {
        RepInfo.FunctionProxy.ForceSeasonalEvent(RepInfo.CurrentForcedSeasonalEventDate);
        RepInfo.CurrentSeasonalIndex = int(RepInfo.CurrentForcedSeasonalEventDate);
        RepInfo.bForceNetUpdate = true;
    }
    
    TimerHelper.SetTimer(0.01f, false, 'CheckCustomStatus', self);
}

final function bool IsStandardGame()
{
	local name GamePackage;
	GamePackage = KFGI.GetPackageName();
	return GamePackage == 'KFGame' || GamePackage == 'KFGameContent';
}

final function CheckCustomStatus()
{
	local KFGameEngine KFGE;

	KFGI.XPMultiplier = RepInfo.XPMultiplier;
    KFGI.bIsCustomGame = !IsStandardGame() || KFGI.bIsUnrankedGame || KFGI.MaxPlayers != KFGI.MaxPlayersAllowed || KFGI.FriendlyFireScale > 0.f;
	
	KFGE = KFGameEngine(class'Engine'.static.GetEngine());
	KFGE.bUsedForTakeover = KFGI.bIsCustomGame ? false : KFGE.default.bUsedForTakeover;
	KFGE.bAvailableForTakeover = !KFGI.bIsCustomGame;
	
	KFGI.UpdateGameSettings();
	
	TimerHelper.Destroy();
}

defaultproperties
{
    FHUDClassLocation="FriendlyHUD.FriendlyHUDMutator"
    YASClassLocation="YAS.YASMut"
    AALClassLocation="AAL.AALMut"
    CVCClassLocation="CVC.CVCMut"
    FHUDCommandName="LoadFHUD"
    YASCommandName="LoadYAS"
    AALCommandName="LoadAAL"
    CVCCommandName="LoadCVC"
    HideCommandName="HideServer"
    NoEventCommandName="NoEventSkins"
    NoEDARCommandName="NoEDARs"
    NoPingCommandName="NoPings"
    BroadcastPickupsCommandName="BroadcastPickups"
    UseDynamicMOTDCommandName="UseDynamicMOTD"
    NoThirdPersonCommandName="NoThirdperson"
    HandCommandName="NoHandChanges"
    MapVoteCommandName="AllowGamemodeVotes"
}