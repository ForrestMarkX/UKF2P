class UKFPMutator extends KFMutator;

var KFGameReplicationInfo KFGRI;
var UKFPReplicationInfo RepInfo;
var byte MaxPlayers;

var const private string FHUDClassLocation, YASClassLocation, AALClassLocation, CVCClassLocation;
var const private string FHUDCommandName, YASCommandName, AALCommandName, CVCCommandName, HideCommandName, NoEventCommandName, NoEDARCommandName, NoPingCommandName, BroadcastPickupsCommandName, UseDynamicMOTDCommandName, NoThirdPersonCommandName, HandCommandName, MapVoteCommandName;

function PreBeginPlay()
{
    GenerateMutatorEntry(Class.Name, PathName(Class));
    
    ConsoleCommand("SUPPRESS DevNet");
    ConsoleCommand("SUPPRESS DevOnline");
    ConsoleCommand("SUPPRESS Log");
    
    Super(Info).PreBeginPlay();

    MyKFGI = KFGameInfo(WorldInfo.Game);
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	RepInfo = Spawn(class'UKFPReplicationInfo', self);
}

function PostBeginPlay()
{
	local string Options;
	
	Options = Repl(WorldInfo.GetLocalURL(), WorldInfo.GetMapName(), "");
	MaxPlayers = MyKFGI.GetIntOption(Options, "MaxPlayers", RepInfo.ForcedMaxPlayers);
	
    if( bool(MyKFGI.GetIntOption(Options, FHUDCommandName, int(RepInfo.bAttemptToLoadFHUD))) )
		MyKFGI.AddMutator(FHUDClassLocation, true);
    if( bool(MyKFGI.GetIntOption(Options, YASCommandName, int(RepInfo.bAttemptToLoadYAS))) || MaxPlayers > 6 )
		MyKFGI.AddMutator(YASClassLocation, true);
    if( bool(MyKFGI.GetIntOption(Options, AALCommandName, int(RepInfo.bAttemptToLoadAAL))) )
		MyKFGI.AddMutator(AALClassLocation, true);
    if( bool(MyKFGI.GetIntOption(Options, CVCCommandName, int(RepInfo.bAttemptToLoadCVC))) )
		MyKFGI.AddMutator(CVCClassLocation, true);
		
	Super.PostBeginPlay();
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
    
	Super.InitMutator(Options, ErrorMessage);
    
    if( RepInfo == None )
        return;
    
    RepInfo.AddLoadPackage(SwfMovie'UKFP_UI_Shared.AssetLib');
    RepInfo.AddLoadPackage(SwfMovie'UKFP_UI_HUD.InGameHUD_SWF');
    
    RepInfo.KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( MaxPlayers > 0 )
    {
        MyKFGI.MaxPlayers = MaxPlayers;
        MyKFGI.MaxPlayersAllowed = MaxPlayers;
        RepInfo.RepMaxPlayers = MaxPlayers;
    }
    
    RepInfo.CurrentPickupLifespan = MyKFGI.GetFloatOption(Options, "PickupLifespan", RepInfo.PickupLifespan);
        
    if( bool(MyKFGI.GetIntOption(Options, HideCommandName, int(RepInfo.bServerHidden))) )
    {
        RepInfo.bServerIsHidden = true;

        `Log("Verifing session before hiding...",,'Private Game');
		RepInfo.OnlineSub.GameInterface.AddUpdateOnlineGameCompleteDelegate(RepInfo.CheckPrivateGameWorkshop);
    }
        
    if( bool(MyKFGI.GetIntOption(Options, NoEventCommandName, int(RepInfo.bNoEventZEDSkins))) )
        RepInfo.bNoEventSkins = true;
        
    if( bool(MyKFGI.GetIntOption(Options, NoPingCommandName, int(RepInfo.bNoPingsAllowed))) )
        RepInfo.bNoPings = true;
        
    if( bool(MyKFGI.GetIntOption(Options, NoThirdPersonCommandName, int(RepInfo.bDisableTP))) )
        RepInfo.bServerDisableTP = true;
        
    if( bool(MyKFGI.GetIntOption(Options, BroadcastPickupsCommandName, int(RepInfo.bBroadcastPickups))) )
        RepInfo.bToBroadcastPickups = true;
        
    if( bool(MyKFGI.GetIntOption(Options, NoEDARCommandName, int(RepInfo.bNoEDARSpawns))) )
        RepInfo.bForceDisableEDARs = true;
        
    if( bool(MyKFGI.GetIntOption(Options, HandCommandName, int(RepInfo.bDisallowHandChanges))) )
        RepInfo.bDisallowHandSwap = true;
        
    if( bool(MyKFGI.GetIntOption(Options, MapVoteCommandName, int(RepInfo.bAllowGamemodeVotes))) )
        RepInfo.VotingHandler = Spawn(class'xVotingHandler');
        
    CurrentActiveEventIdx = MyKFGI.GetIntOption(Options, "CurrentWeekly", int(RepInfo.WeeklyIndex));
    RepInfo.CurrentMaxMonsters = MyKFGI.GetIntOption(Options, "MaxMonsters", RepInfo.MaxMonsters);
    RepInfo.CurrentFakePlayers = MyKFGI.GetIntOption(Options, "FakePlayers", RepInfo.FakePlayers);
    RepInfo.CurrentForcedSeasonalEventDate = ESeasonalEventType(MyKFGI.GetIntOption(Options, "CurrentSeasonalEvent", RepInfo.ForcedSeasonalEventDate));
    RepInfo.CurrentNormalSummerSCAnims = bool(MyKFGI.GetIntOption(Options, "UseNormalSummerSCAnims", int(RepInfo.bUseNormalSummerSCAnims)));
    RepInfo.bServerEnforceVanilla = bool(MyKFGI.GetIntOption(Options, "EnforceVanilla", int(RepInfo.bEnforceVanilla)));
    RepInfo.bServerDropAllWepsOnDeath = bool(MyKFGI.GetIntOption(Options, "DropAllWepsOnDeath", int(RepInfo.bDropAllWepsOnDeath)));

    if( bool(MyKFGI.GetIntOption(Options, UseDynamicMOTDCommandName, int(RepInfo.bUseDynamicMOTD))) )
    {
		foreach DynamicActors(class'Mutator', Mut)
		{
			if( !RepInfo.DynamicMOTD.bYASLoaded && Mut.GetPackageName() == 'YAS' )
				RepInfo.DynamicMOTD.bYASLoaded = Mut.IsA('YASMut');
			if( !RepInfo.DynamicMOTD.bAALLoaded && Mut.GetPackageName() == 'AAL' )
				RepInfo.DynamicMOTD.bAALLoaded = Mut.IsA('AALMut');
			if( !RepInfo.DynamicMOTD.bCVCLoaded  && Mut.GetPackageName() == 'CVC' )
				RepInfo.DynamicMOTD.bCVCLoaded = Mut.IsA('CVCMut');
			if( !RepInfo.DynamicMOTD.bFHUDLoaded  && Mut.GetPackageName() == 'FriendlyHUD' )
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
    }
    
    RepInfo.CurrentMapName = RepInfo.ConvertMapName(WorldInfo.GetMapName(true));
    RepInfo.SetTimer(WorldInfo.DeltaSeconds*2.f, false, 'CheckForMapFixes');

    WeeklyGI = KFGameInfo_WeeklySurvival(MyKFGI);
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
    
    MyKFGI.UpdateGameSettings();
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