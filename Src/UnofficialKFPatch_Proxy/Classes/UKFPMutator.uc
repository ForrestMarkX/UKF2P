class UKFPMutator extends KFMutator;

var transient KFGameInfo KFGI;
var private transient UKFPReplicationInfo RepInfo;
var private transient KFRealtimeTimerHelper TimerHelper;

var const private bool bVerify;
var const private string FHUDClassLocation, FHUDExtClassLocation, YASClassLocation, AALClassLocation, CVCClassLocation, LTIClassLocation;
var const private string FHUDCommandName, FHUDExtCommandName, YASCommandName, AALCommandName, CVCCommandName, LTICommandName, HideCommandName, NoEventCommandName, NoEDARCommandName, NoQPCommandName, NoGasCrawlerCommandName, NoPingCommandName, BroadcastPickupsCommandName, UseDynamicMOTDCommandName, NoThirdPersonCommandName, HandCommandName, MapVoteCommandName, UnSuppressCommandName, NoRageSpawnCommandName;

function PreBeginPlay()
{
    bVerify = true;
    TimerHelper = Spawn(class'KFRealtimeTimerHelper');
	
    GenerateMutatorEntry(Class.Name, PathName(Class));
    
	ConsoleCommand("SUPPRESS Log");
    ConsoleCommand("SUPPRESS DevNet");
    ConsoleCommand("SUPPRESS DevOnline");
    
    Super(Info).PreBeginPlay();
	
    KFGI = KFGameInfo(WorldInfo.Game);
    KFGI.MaxGameDifficulty = 3;
	
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

function PostBeginPlay()
{
    if( !bVerify )
        return;
	Super.PostBeginPlay();
	SetupMutator(Repl(WorldInfo.GetLocalURL(), WorldInfo.GetMapName(true), ""));
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

function Mutate(string MutateString, PlayerController Sender)
{
    local array<string> Args;
    local string Msg;
    local byte MaxPlayers;
    local ReplicationHelper CRI;
    
    Super.Mutate(MutateString, Sender);
    
    Args = SplitString(MutateString, " ");
    Msg = Args[0];
    Args.Remove(0, 1);

    if( (Msg ~= "changeslots" || Msg ~= "cs") && Args.Length > 0 && Sender.PlayerReplicationInfo.bAdmin )
    {
        MaxPlayers = Max(int(Args[0]), 1);
        
        KFGI.MaxPlayers = MaxPlayers;
        KFGI.MaxPlayersAllowed = MaxPlayers;
        
        RepInfo.RepMaxPlayers = MaxPlayers;
        RepInfo.DynamicMOTD.CurrentMaxPlayers = MaxPlayers;
        RepInfo.bForceNetUpdate = true;
        RepInfo.bNetDirty = true;
        
        foreach RepInfo.ChatArray(CRI)
            CRI.OnMaxPlayersUpdated(Sender.PlayerReplicationInfo, MaxPlayers);
    }
}

final function SetupMutator(const string Options)
{
    local KFGameInfo_WeeklySurvival WeeklyGI;
    local int i, CurrentActiveEventIdx, ActiveEventIdx;
	local Mutator Mut;
	local byte MaxPlayers;
    local array<byte> IDs, PerkList;
	local string InOpt;
    local array< class<KFPawn_Monster> > BossList;
    local class<KFPlayerController> PCC;
    local KFGameInfo_Endless KFGIE;

    if( RepInfo == None )
        return;

    RepInfo.CurrentPickupLifespan = KFGI.GetIntOption(Options, "PickupLifespan", RepInfo.PickupLifespan);
	
	MaxPlayers = KFGI.GetIntOption(Options, "MaxPlayers", RepInfo.ForcedMaxPlayers);
	
    if( MaxPlayers > 0 )
    {
        KFGI.MaxPlayers = MaxPlayers;
        KFGI.MaxPlayersAllowed = MaxPlayers;
        RepInfo.RepMaxPlayers = MaxPlayers;
    }
	
    if( bool(KFGI.GetIntOption(Options, FHUDExtCommandName, int(RepInfo.bAttemptToLoadFHUDExt))) )
        KFGI.AddMutator(FHUDExtClassLocation, true);
    else if( bool(KFGI.GetIntOption(Options, FHUDCommandName, int(RepInfo.bAttemptToLoadFHUD))) )
		KFGI.AddMutator(FHUDClassLocation, true);
        
    if( bool(KFGI.GetIntOption(Options, YASCommandName, int(RepInfo.bAttemptToLoadYAS))) )
		KFGI.AddMutator(YASClassLocation, true);
    if( bool(KFGI.GetIntOption(Options, AALCommandName, int(RepInfo.bAttemptToLoadAAL))) )
		KFGI.AddMutator(AALClassLocation, true);
    if( bool(KFGI.GetIntOption(Options, CVCCommandName, int(RepInfo.bAttemptToLoadCVC))) )
		KFGI.AddMutator(CVCClassLocation, true);
    if( bool(KFGI.GetIntOption(Options, LTICommandName, int(RepInfo.bAttemptToLoadLTI))) )
		KFGI.AddMutator(LTIClassLocation, true);
		
    InOpt = KFGI.ParseOption(Options, "ServerName");
    if( InOpt != "" )
        class'GameReplicationInfo'.default.ServerName = InOpt;
        
    if( bool(KFGI.GetIntOption(Options, "AllowMapSpecificSeasonalZEDs", 0)) )
    {
        i = RepInfo.MapTypes.Find('MapName', WorldInfo.GetMapName(true));
        if( i != INDEX_NONE )
        {
            if( KFGI.ParseOption(Options, "SeasonalSkinsIndex") != "" )
                KFGI.SeasonalSkinsIndex = GetSeasonalID(RepInfo.MapTypes[i].Type);
            else RepInfo.ForcedSeasonalID = GetSeasonalID(RepInfo.MapTypes[i].Type);
        }
    }

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
    RepInfo.bForceDisableQPs = bool(KFGI.GetIntOption(Options, NoQPCommandName, int(RepInfo.bNoQPSpawns)));
    RepInfo.bForceDisableGasCrawlers = bool(KFGI.GetIntOption(Options, NoGasCrawlerCommandName, int(RepInfo.bNoGasCrawlers)));
    RepInfo.bForceDisableRageSpawns = bool(KFGI.GetIntOption(Options, NoRageSpawnCommandName, int(RepInfo.bNoRageSpawns)));
    RepInfo.bDisallowHandSwap = bool(KFGI.GetIntOption(Options, HandCommandName, int(RepInfo.bDisallowHandChanges)));
    RepInfo.bShouldUseEnhancedTraderMenu = bool(KFGI.GetIntOption(Options, "UseEnhancedTraderMenu", int(RepInfo.bUseEnhancedTraderMenu)));
    RepInfo.CurrentMaxMonsters = KFGI.GetIntOption(Options, "MaxMonsters", RepInfo.MaxMonsters);
    RepInfo.CurrentFakePlayers = KFGI.GetIntOption(Options, "FakePlayers", RepInfo.FakePlayers);
    RepInfo.CurrentMaxDoshSpamAmount = KFGI.GetIntOption(Options, "MaxDoshSpam", RepInfo.MaxDoshSpamAmount);
    RepInfo.CurrentForcedSeasonalEventDate = ESeasonalEventType(KFGI.GetIntOption(Options, "CurrentSeasonalEvent", RepInfo.ForcedSeasonalEventDate));
    RepInfo.CurrentDoshKillMultiplier = `RoundFloatPrecision(FClamp(KFGI.GetFloatOption(Options, "DoshKillMultiplier", RepInfo.DoshKillMultiplier), 0.f, 1.f));
    RepInfo.CurrentSpawnRateMultiplier = `RoundFloatPrecision(FClamp(KFGI.GetFloatOption(Options, "SpawnRateMultiplier", RepInfo.SpawnRateMultiplier), 0.f, 1.f));
    RepInfo.CurrentWaveCountMultiplier = `RoundFloatPrecision(FMax(KFGI.GetFloatOption(Options, "WaveCountMultiplier", RepInfo.WaveCountMultiplier), 1.f));
    RepInfo.CurrentAmmoCostMultiplier = `RoundFloatPrecision(FMax(KFGI.GetFloatOption(Options, "AmmoCostMultiplier", RepInfo.AmmoCostMultiplier), 1.f));
    RepInfo.bBypassGameConductor = bool(KFGI.GetIntOption(Options, "DisableGameConductor", int(RepInfo.bDisableGameConductor)));
    RepInfo.bShouldAllowDamagePopups = bool(KFGI.GetIntOption(Options, "AllowDamagePopups", int(RepInfo.bAllowDamagePopups)));
    RepInfo.bShouldDisableCustomLoadingScreen = bool(KFGI.GetIntOption(Options, "DisableCustomLoadingScreen", int(RepInfo.bDisableCustomLoadingScreen)));
    RepInfo.bShouldDisableTraderLocking = bool(KFGI.GetIntOption(Options, "DisableTraderLocking", int(RepInfo.bDisableTraderLocking)));
    RepInfo.bHasDisabledRanking = bool(KFGI.GetIntOption(Options, "DisableMapRanking", int(RepInfo.bDisableMapRanking)));
    RepInfo.bHasDisabledZEDTime = bool(KFGI.GetIntOption(Options, "DisableZEDTime", int(RepInfo.bDisableZEDTime)));
    RepInfo.bUsingOpenTraderCommand = bool(KFGI.GetIntOption(Options, "AllowOpenTraderCommand", int(RepInfo.bAllowOpenTraderCommand)));
    RepInfo.XPMultiplier = FClamp(KFGI.GetFloatOption(Options, "XPMultiplier", KFGI.XPMultiplier), 0.1f, 2.f);
    RepInfo.bShouldDisableCrossPerk = bool(KFGI.GetIntOption(Options, "DisableCrossPerk", int(RepInfo.bDisableCrossPerk)));
    RepInfo.bShouldDisableUpgrades = bool(KFGI.GetIntOption(Options, "DisableWeaponUpgrades", int(RepInfo.bDisableWeaponUpgrades)));
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
    RepInfo.bShouldDisableTraderDLCLocking = bool(KFGI.GetIntOption(Options, "DisableTraderDLCLock", int(RepInfo.bDisableTraderDLCLocking)));
    
    RepInfo.CurrentAllowedBosses = KFGI.ParseOption(Options, "BossList");
    if( RepInfo.CurrentAllowedBosses == "" )
        RepInfo.CurrentAllowedBosses = RepInfo.AllowedBosses;
        
    RepInfo.CurrentAllowedOutbreaks = KFGI.ParseOption(Options, "Outbreaks");
    if( RepInfo.CurrentAllowedOutbreaks == "" )
        RepInfo.CurrentAllowedOutbreaks = RepInfo.AllowedOutbreaks;
        
    RepInfo.CurrentAllowedSpecialWaves = KFGI.ParseOption(Options, "SpecialWaves");
    if( RepInfo.CurrentAllowedSpecialWaves == "" )
        RepInfo.CurrentAllowedSpecialWaves = RepInfo.AllowedSpecialWaves;
        
    RepInfo.CurrentAllowedPerks = KFGI.ParseOption(Options, "Perks");
    if( RepInfo.CurrentAllowedPerks == "" )
        RepInfo.CurrentAllowedPerks = RepInfo.AllowedPerks;
        
    if( bool(KFGI.GetIntOption(Options, UseDynamicMOTDCommandName, int(RepInfo.bUseDynamicMOTD))) )
    {
        RepInfo.bShouldUseDynamicMOTD = true;
        
		foreach DynamicActors(class'Mutator', Mut)
		{
			if( !RepInfo.DynamicMOTD.bYASLoaded && Mut.Class.GetPackageName() == 'YAS' )
				RepInfo.DynamicMOTD.bYASLoaded = Mut.IsA('YASMut');
			if( !RepInfo.DynamicMOTD.bAALLoaded && Mut.Class.GetPackageName() == 'AAL' )
				RepInfo.DynamicMOTD.bAALLoaded = Mut.IsA('AALMut');
			if( !RepInfo.DynamicMOTD.bCVCLoaded && Mut.Class.GetPackageName() == 'CVC' )
				RepInfo.DynamicMOTD.bCVCLoaded = Mut.IsA('CVCMut');
			if( !RepInfo.DynamicMOTD.bFHUDLoaded && (Mut.Class.GetPackageName() == 'FriendlyHUD' || Mut.Class.GetPackageName() == 'FriendlyHudExt') )
				RepInfo.DynamicMOTD.bFHUDLoaded = Mut.IsA('FriendlyHUDMutator');
			if( !RepInfo.DynamicMOTD.bLTILoaded && Mut.Class.GetPackageName() == 'LTI' )
				RepInfo.DynamicMOTD.bLTILoaded = Mut.IsA('LTIMut');
		}
        RepInfo.DynamicMOTD.bNoEventSkins = RepInfo.bNoEventSkins;
        RepInfo.DynamicMOTD.bNoPings = RepInfo.bNoPings;
        RepInfo.DynamicMOTD.bToBroadcastPickups = RepInfo.bToBroadcastPickups;
        RepInfo.DynamicMOTD.CurrentMaxPlayers = MaxPlayers;
        RepInfo.DynamicMOTD.CurrentMaxMonsters = RepInfo.CurrentMaxMonsters;
        RepInfo.DynamicMOTD.CurrentFakePlayers = RepInfo.CurrentFakePlayers;
        RepInfo.DynamicMOTD.MaxDoshSpamAmount = RepInfo.CurrentMaxDoshSpamAmount;
        RepInfo.DynamicMOTD.CurrentPickupLifespan = RepInfo.CurrentPickupLifespan;
        RepInfo.DynamicMOTD.bDisableTP = RepInfo.bServerDisableTP;
        RepInfo.DynamicMOTD.bDisallowHandSwap = RepInfo.bDisallowHandSwap;
        RepInfo.DynamicMOTD.bUseNormalSummerSCAnims = RepInfo.bUseNormalSummerSCAnims;
        RepInfo.DynamicMOTD.bDropAllWepsOnDeath = RepInfo.bServerDropAllWepsOnDeath;
        RepInfo.DynamicMOTD.bNoEDARs = RepInfo.bForceDisableEDARs;
        RepInfo.DynamicMOTD.bNoRageSpawns = RepInfo.bForceDisableRageSpawns;
        RepInfo.DynamicMOTD.bBypassGameConductor = RepInfo.bBypassGameConductor;
        RepInfo.DynamicMOTD.bShouldUseEnhancedTraderMenu = RepInfo.bShouldUseEnhancedTraderMenu;
        RepInfo.DynamicMOTD.bShouldAllowDamagePopups = RepInfo.bShouldAllowDamagePopups;
        RepInfo.DynamicMOTD.bNoQPSpawns = RepInfo.bForceDisableQPs;
        RepInfo.DynamicMOTD.bNoGasCrawlers = RepInfo.bForceDisableGasCrawlers;
        RepInfo.DynamicMOTD.bUsingOpenTraderCommand = RepInfo.bUsingOpenTraderCommand;
        RepInfo.DynamicMOTD.bHasDisabledZEDTime = RepInfo.bHasDisabledZEDTime;
        RepInfo.DynamicMOTD.bEnforceVanilla = RepInfo.bServerEnforceVanilla;
        RepInfo.DynamicMOTD.XPMultiplier = RepInfo.XPMultiplier;
        RepInfo.DynamicMOTD.bShouldDisableCrossPerk = RepInfo.bShouldDisableCrossPerk;
        RepInfo.DynamicMOTD.bShouldDisableUpgrades = RepInfo.bShouldDisableUpgrades;
        RepInfo.DynamicMOTD.CurrentDoshKillMultiplier = RepInfo.CurrentDoshKillMultiplier;
        RepInfo.DynamicMOTD.CurrentSpawnRateMultiplier = RepInfo.CurrentSpawnRateMultiplier;
        RepInfo.DynamicMOTD.CurrentWaveCountMultiplier = RepInfo.CurrentWaveCountMultiplier;
        RepInfo.DynamicMOTD.CurrentAmmoCostMultiplier = RepInfo.CurrentAmmoCostMultiplier;
        RepInfo.DynamicMOTD.bShouldDisableTraderDLCLocking = RepInfo.bShouldDisableTraderDLCLocking;

        PCC = class<KFPlayerController>(KFGI.PlayerControllerClass);
        
        RepInfo.GetAllowedBossList(BossList);
        if( BossList.Length > 0 )
        {
            for( i=0; i<KFGI.default.AIBossClassList.Length && i<8; i++ )
            {
                if( BossList.Find(KFGI.default.AIBossClassList[i]) != INDEX_NONE )
                    RepInfo.DynamicMOTD.BossData = RepInfo.DynamicMOTD.BossData | (1 << (i+1));
            }
        }
        
        RepInfo.GetAllowedPerkList(PerkList);
        if( PerkList.Length > 0 )
        {
            for( i=0; i<PCC.default.PerkList.Length && i<32; i++ )
            {
                if( PerkList.Find(i) != INDEX_NONE )
                    RepInfo.DynamicMOTD.PerkData = RepInfo.DynamicMOTD.PerkData | (1 << (i+1));
            }
        }

        KFGIE = KFGameInfo_Endless(KFGI);
        if( KFGIE != None )
        {
            RepInfo.GetRandomEnabledOutbreak(IDs);
            if( IDs.Length > 0 )
            {
                for( i=0; i<KFGIE.default.OutbreakEventClass.default.SetEvents.Length && i<8; i++ )
                {
                    if( IDs.Find(i) != INDEX_NONE )
                        RepInfo.DynamicMOTD.OutbreakData = RepInfo.DynamicMOTD.OutbreakData | (1 << (i+1));
                }
            }
                
            IDs.Length = 0;
            
            RepInfo.GetRandomEnabledSpecialWave(IDs);
            if( IDs.Length > 0 )
            {
                for( i=0; i<AT_MAX && i<32; i++ )
                {
                    if( IDs.Find(i) != INDEX_NONE )
                        RepInfo.DynamicMOTD.SpecialWaveData = RepInfo.DynamicMOTD.SpecialWaveData | (1 << (i+1));
                }
            }
        }
    }
    
    foreach DynamicActors(class'Mutator', Mut)
    {
        if( !RepInfo.bLTILoaded && Mut.Class.GetPackageName() == 'LTI' )
        {
            RepInfo.bLTILoaded = Mut.IsA('LTIMut');
            break;
        }
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
        WeeklyGI.OutbreakEvent.SetActiveEvent(WeeklyGI.ActiveEventIdx, WeeklyGI);
        
        RepInfo.FunctionProxy.ForceUpdateWeeklyIndex(WeeklyGI.ActiveEventIdx);
    }
    
    RepInfo.InitialSeasonalEventDate = RepInfo.FunctionProxy.GetSeasonalEventID(KFGameEngine(class'Engine'.static.GetEngine()));
    if( RepInfo.CurrentForcedSeasonalEventDate != SET_None )
    {
        RepInfo.FunctionProxy.ForceSeasonalEvent(RepInfo.CurrentForcedSeasonalEventDate);
        RepInfo.CurrentSeasonalIndex = int(RepInfo.CurrentForcedSeasonalEventDate);
        RepInfo.bForceNetUpdate = true;
    }
    
    if( bool(KFGI.GetIntOption(Options, UnSuppressCommandName, 0)) )
    {
        ConsoleCommand("UNSUPPRESS DevNet");
        ConsoleCommand("UNSUPPRESS DevOnline");
        ConsoleCommand("UNSUPPRESS Log");
    }
    
    if( WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_ListenServer )
    {
        RepInfo.ReplicatedEvent('bServerEnforceVanilla');
        RepInfo.ReplicatedEvent('CurrentForcedSeasonalEventDate');
        RepInfo.ReplicatedEvent('bNoEventSkins');
        RepInfo.ReplicatedEvent('DynamicMOTD');
    }
}

final function SeasonalEventIndex GetSeasonalID(string ID)
{
    switch(Caps(ID))
    {
        case "NONE":
        case "REGULAR":
        case "DEFAULT":
            return SEI_None;
        case "SPRING":
            return SEI_Spring;
        case "SLIDESHOW":
        case "SUMMERSLIDESHOW":
        case "SUMMER SLIDESHOW":
        case "SUMMER":
            return SEI_Summer;
        case "HALLOWEEN":
        case "FALL":
            return SEI_Fall;
        case "XMAS":
        case "CHRISTMAS":
        case "WINTER":
            return SEI_Winter;
    }
    
    return SEI_None;
}

function ModifyZedTime( out float out_TimeSinceLastEvent, out float out_ZedTimeChance, out float out_Duration )
{
    Super.ModifyZedTime(out_TimeSinceLastEvent, out_ZedTimeChance, out_Duration);
    
    if( RepInfo.bHasDisabledZEDTime )
    {
        out_TimeSinceLastEvent = WorldInfo.TimeSeconds;
        out_ZedTimeChance = 0.f;
        out_Duration = 0.f;
    }
}

defaultproperties
{
    FHUDClassLocation="FriendlyHUD.FriendlyHUDMutator"
    FHUDExtClassLocation="FriendlyHudExt.FriendlyHUDMutator"
    YASClassLocation="YAS.YASMut"
    AALClassLocation="AAL.AALMut"
    CVCClassLocation="CVC.CVCMut"
    LTIClassLocation="LTI.LTIMut"
    FHUDCommandName="LoadFHUD"
    FHUDExtCommandName="LoadFHUDExt"
    YASCommandName="LoadYAS"
    AALCommandName="LoadAAL"
    CVCCommandName="LoadCVC"
    LTICommandName="LoadLTI"
    HideCommandName="HideServer"
    NoEventCommandName="NoEventSkins"
    NoEDARCommandName="NoEDARs"
    NoQPCommandName="NoQPs"
    NoGasCrawlerCommandName="NoGasCrawlers"
    NoRageSpawnCommandName="NoRageSpawns"
    NoPingCommandName="NoPings"
    BroadcastPickupsCommandName="BroadcastPickups"
    UseDynamicMOTDCommandName="UseDynamicMOTD"
    NoThirdPersonCommandName="NoThirdperson"
    HandCommandName="NoHandChanges"
    MapVoteCommandName="AllowGamemodeVotes"
    UnSuppressCommandName="UnsuppressLogs"
}