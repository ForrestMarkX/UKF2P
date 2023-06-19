class UKFPMutator extends KFMutator
    config(UnofficialPatch);
    
var UKFPMutator StaticReference;
var array<string> IgnoreDecentMaps;
var string DefaultAllowedOutbreaks, DefaultAllowedSpecialWaves;

var transient KFGameInfo KFGI;
var transient KFGameInfo_Endless KFGIE;
var transient KFGameReplicationInfo KFGRI;
var private transient KFRealtimeTimerHelper TimerHelper;

var transient TcpNetDriver NetDriver;
var transient WorkshopTool WorkshopTool;

var transient array<KFPlayerController> PlayersDiedThisWave, PlayersDiedThisWaveOld;

var const private bool bWhitelistBypass, bIgnoreWhitelist;

var config byte ForcedMaxPlayers, MaxMonsters, FakePlayers;
var config float DoshKillMultiplier, SpawnRateMultiplier, WaveCountMultiplier;
var config int PickupLifespan, CurrentNetDriverIndex, MaxDoshSpamAmount, iConfigVersion;
var config bool bAllowDynamicMOTD, bDropAllWepsOnDeath, bServerHidden, bBroadcastPickups, bNoEDARSpawns, bNoQPSpawns, bNoGasCrawlers, bNoRageSpawns, bDisableGameConductor;
var config string AllowedBosses, AllowedOutbreaks, AllowedSpecialWaves, AllowedPerks;

var transient bool bCurrentAllowDynamicMOTD, bServerDropAllWepsOnDeath, bCleanedUp, bToBroadcastPickups, bForceDisableEDARs, bForceDisableQPs, bForceDisableGasCrawlers, bForceDisableRageSpawns, bBypassGameConductor, bForceResetInterpActors;
var transient int CurrentPickupLifespan, CurrentMaxDoshSpamAmount;
var transient float CurrentDoshKillMultiplier, CurrentSpawnRateMultiplier, CurrentWaveCountMultiplier;
var transient string CurrentAllowedBosses, CurrentAllowedOutbreaks, CurrentAllowedSpecialWaves, CurrentAllowedPerks;
var transient byte CurrentMaxPlayers, CurrentMaxMonsters, CurrentFakePlayers, SavedWaveNum;

var transient OnlineSubsystemSteamworks OnlineSub;

struct FDummyPRI
{
    var KFPlayerReplicationInfo OriginalPRI, DummyPRI;
};
var transient array<FDummyPRI> DummyPlayerPRIs;

struct FDelayedMessage
{
    var KFPlayerController PC;
    var string S;
};
var transient array<FDelayedMessage> DelayedMessages;

struct FPlayerPickups
{
    var PlayerReplicationInfo PRI;
    var string OwnerSteamID, OwnerName;
    var array<KFDroppedPickup> Pickups;
    var bool bDropProtected;
};
var transient array<FPlayerPickups> PlayerPickups;

struct strictconfig FPlayerConfig
{
    var config bool bDropProtected, bEnableLargeKills;
    var config string SteamID;
    var float NextSpectateChange, MoneyTossTime;
    var int MoneyTossCount;
};
var config array<FPlayerConfig> PlayerConfigs;

function PreBeginPlay()
{
    local DummyMoviePlayer MoviePlayer;
    
    if( iConfigVersion <= 0 )
    {
        DoshKillMultiplier = 1.f;
        SpawnRateMultiplier = 1.f;
        WaveCountMultiplier = 1.f;
        AllowedOutbreaks = default.DefaultAllowedOutbreaks;
        AllowedSpecialWaves = default.DefaultAllowedSpecialWaves;
        AllowedPerks = "BZ,CO,SU,FM,DO,FB,GS,SS,SW,SV";
        iConfigVersion++;
    }
	
	SaveConfig();
    
    default.StaticReference = self;
    UKFPMutator(`FindDefaultObject(class'UKFPMutator')).StaticReference = self;
    
    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
		MoviePlayer = New class'DummyMoviePlayer';
		MoviePlayer.Init();
		MoviePlayer.SetVisibility(false);
		MoviePlayer.SetMenuVisibility(false);
		MoviePlayer.SetWidgetsVisible(false);
		MoviePlayer.SetMovieCanReceiveInput(false);
		MoviePlayer.SetMovieCanReceiveFocus(false);
		MoviePlayer.ClearCaptureKeys();
		MoviePlayer.ClearFocusIgnoreKeys();
    }
    
    OrgFunctions.PickupDestroyed = KFDroppedPickup.Destroyed;
    KFDroppedPickup.Destroyed = Functions.PickupDestroyed;
    OrgFunctions.SetPickupMesh = KFDroppedPickup.SetPickupMesh;
    KFDroppedPickup.SetPickupMesh = Functions.SetPickupMesh;
    OrgFunctions.GetAIPawnClassToSpawn = KFPawn_Monster.GetAIPawnClassToSpawn;
    KFPawn_Monster.GetAIPawnClassToSpawn = Functions.GetAIPawnClassToSpawn;
    OrgFunctions.SpawnEnraged = KFAIController_ZedFleshpound.SpawnEnraged;
    KFAIController_ZedFleshpound.SpawnEnraged = Functions.SpawnEnraged;
    OrgFunctions.GetMaxMonsters = KFAISpawnManager.GetMaxMonsters;
    KFAISpawnManager.GetMaxMonsters = Functions.GetMaxMonsters;
    OrgFunctions.GetNumPlayersModifier = KFGameDifficultyInfo.GetNumPlayersModifier;
    KFGameDifficultyInfo.GetNumPlayersModifier = Functions.GetNumPlayersModifier;
    OrgFunctions.ModifyAIDoshValueForPlayerCount = KFGameInfo.ModifyAIDoshValueForPlayerCount;
    KFGameInfo.ModifyAIDoshValueForPlayerCount = Functions.ModifyAIDoshValueForPlayerCount;
    OrgFunctions.GetAdjustedAIDoshValue = KFGameInfo.GetAdjustedAIDoshValue;
    KFGameInfo.GetAdjustedAIDoshValue = Functions.GetAdjustedAIDoshValue;
    OrgFunctions.GetGameInfoSpawnRateMod = KFGameInfo.GetGameInfoSpawnRateMod;
    KFGameInfo.GetGameInfoSpawnRateMod = Functions.GetGameInfoSpawnRateMod;
    OrgFunctions.GetTotalWaveCountScale = KFGameInfo.GetTotalWaveCountScale;
    KFGameInfo.GetTotalWaveCountScale = Functions.GetTotalWaveCountScale;
    OrgFunctions.GameTimer = KFGameInfo_Survival.Timer;
    KFGameInfo_Survival.Timer = Functions.GameTimer;
    OrgFunctions.SetMonsterDefaults = KFGameInfo.SetMonsterDefaults;
    KFGameInfo.SetMonsterDefaults = Functions.SetMonsterDefaults;
    OrgFunctions.GetSpecificBossClass = KFGameInfo.GetSpecificBossClass;
    KFGameInfo.GetSpecificBossClass = Functions.GetSpecificBossClass;
    OrgFunctions.GameTrySetNextWaveSpecial = KFGameInfo_Endless.TrySetNextWaveSpecial;
    KFGameInfo_Endless.TrySetNextWaveSpecial = Functions.GameTrySetNextWaveSpecial;
    OrgFunctions.GRIPostBeginPlay = KFGameReplicationInfo.PostBeginPlay;
    KFGameReplicationInfo.PostBeginPlay = Functions.GRIPostBeginPlay;
    OrgFunctions.NotifyTraderOpened = KFGameInfo_Survival.NotifyTraderOpened;
    KFGameInfo_Survival.NotifyTraderOpened = Functions.NotifyTraderOpened;
    OrgFunctions.NotifyTraderClosed = KFGameInfo_Survival.NotifyTraderClosed;
    KFGameInfo_Survival.NotifyTraderClosed = Functions.NotifyTraderClosed;
    OrgFunctions.ServerSay = PlayerController.ServerSay;
    PlayerController.ServerSay = Functions.ServerSay;
    OrgFunctions.ServerTeamSay = PlayerController.ServerTeamSay;
    PlayerController.ServerTeamSay = Functions.ServerTeamSay;
    OrgFunctions.StartMatch = KFGameInfo_Survival.StartMatch;
    KFGameInfo_Survival.StartMatch = Functions.StartMatch;
    OrgFunctions.ActorFellOutOfWorld = Actor.FellOutOfWorld;
    Actor.FellOutOfWorld = Functions.ActorFellOutOfWorld;
    OrgFunctions.PickupLanded = DroppedPickup.Landed;
    DroppedPickup.Landed = Functions.PickupLanded;
    OrgFunctions.MixerGiveAmmo = KFPlayerController.MixerGiveAmmo;
    KFPlayerController.MixerGiveAmmo = Functions.MixerGiveAmmo;
    OrgFunctions.MixerGiveArmor = KFPlayerController.MixerGiveArmor;
    KFPlayerController.MixerGiveArmor = Functions.MixerGiveArmor;
    OrgFunctions.MixerGiveDosh = KFPlayerController.MixerGiveDosh;
    KFPlayerController.MixerGiveDosh = Functions.MixerGiveDosh;
    OrgFunctions.MixerGiveGrenades = KFPlayerController.MixerGiveGrenades;
    KFPlayerController.MixerGiveGrenades = Functions.MixerGiveGrenades;
    OrgFunctions.MixerHealUser = KFPlayerController.MixerHealUser;
    KFPlayerController.MixerHealUser = Functions.MixerHealUser;
    OrgFunctions.MixerCauseZedTime = KFPlayerController.MixerCauseZedTime;
    KFPlayerController.MixerCauseZedTime = Functions.MixerCauseZedTime;
    OrgFunctions.MixerEnrageZeds = KFPlayerController.MixerEnrageZeds;
    KFPlayerController.MixerEnrageZeds = Functions.MixerEnrageZeds;
    OrgFunctions.MixerPukeUser = KFPlayerController.MixerPukeUser;
    KFPlayerController.MixerPukeUser = Functions.MixerPukeUser;
    OrgFunctions.MixerSpawnZed = KFPlayerController.MixerSpawnZed;
    KFPlayerController.MixerSpawnZed = Functions.MixerSpawnZed;
    OrgFunctions.SkipLobby = KFPlayerController.SkipLobby;
    KFPlayerController.SkipLobby = Functions.SkipLobby;
    OrgFunctions.ServerSetEnablePurchases = KFPlayerController.ServerSetEnablePurchases;
    KFPlayerController.ServerSetEnablePurchases = Functions.ServerSetEnablePurchases;
    OrgFunctions.PRIPostBeginPlay = KFPlayerReplicationInfo.PostBeginPlay;
    KFPlayerReplicationInfo.PostBeginPlay = Functions.PRIPostBeginPlay;
    OrgFunctions.ServerStartKickVote = KFPlayerReplicationInfo.ServerStartKickVote;
    KFPlayerReplicationInfo.ServerStartKickVote = Functions.ServerStartKickVote;
    OrgFunctions.ServerCastKickVote = KFPlayerReplicationInfo.ServerCastKickVote;
    KFPlayerReplicationInfo.ServerCastKickVote = Functions.ServerCastKickVote;
    OrgFunctions.ServerRequestSkipTraderVote = KFPlayerReplicationInfo.ServerRequestSkipTraderVote;
    KFPlayerReplicationInfo.ServerRequestSkipTraderVote = Functions.ServerRequestSkipTraderVote;
    OrgFunctions.ServerCastSkipTraderVote = KFPlayerReplicationInfo.ServerCastSkipTraderVote;
    KFPlayerReplicationInfo.ServerCastSkipTraderVote = Functions.ServerCastSkipTraderVote;
    OrgFunctions.JumpOffPawn = KFPawn.JumpOffPawn;
    KFPawn.JumpOffPawn = Functions.JumpOffPawn;
    OrgFunctions.FindNewEnemy = KFAIController.FindNewEnemy;
    KFAIController.FindNewEnemy = Functions.FindNewEnemy;
    OrgFunctions.DiscardInventory = KFInventoryManager.DiscardInventory;
    KFInventoryManager.DiscardInventory = Functions.DiscardInventory;
    OrgFunctions.ServerThrowMoney = KFInventoryManager.ServerThrowMoney;
    KFInventoryManager.ServerThrowMoney = Functions.ServerThrowMoney;
    OrgFunctions.GetFriendlyNameForCurrentGameMode = KFGameInfo.GetFriendlyNameForCurrentGameMode;
    KFGameInfo.GetFriendlyNameForCurrentGameMode = Functions.GetFriendlyNameForCurrentGameMode;
    OrgFunctions.GetGameModeNumFromClass = KFGameInfo.GetGameModeNumFromClass;
    KFGameInfo.GetGameModeNumFromClass = Functions.GetGameModeNumFromClass;
    OrgFunctions.GetGameModeFriendlyNameFromClass = KFGameInfo.GetGameModeFriendlyNameFromClass;
    KFGameInfo.GetGameModeFriendlyNameFromClass = Functions.GetGameModeFriendlyNameFromClass;
    OrgFunctions.CreateOutbreakEvent = KFGameInfo.CreateOutbreakEvent;
    KFGameInfo.CreateOutbreakEvent = Functions.CreateOutbreakEvent;
    OrgFunctions.MutPreBeginPlay = Mutator.PreBeginPlay;
    Mutator.PreBeginPlay = Functions.MutPreBeginPlay;

    OnlineSub = OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem());
    
    TimerHelper = Spawn(class'KFRealtimeTimerHelper');
    TimerHelper.SetTimer(0.1f, false, 'DoTick', self);
    
	ConsoleCommand("SUPPRESS Log");
    ConsoleCommand("SUPPRESS DevNet");
    ConsoleCommand("SUPPRESS DevOnline");
    
    Super.PreBeginPlay();
	
    KFGI = KFGameInfo(WorldInfo.Game);
    KFGIE = KFGameInfo_Endless(KFGI);
    KFGI.MaxGameDifficulty = 3;
	
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
	Super.PostBeginPlay();
	SetupMutator(Repl(WorldInfo.GetLocalURL(), WorldInfo.GetMapName(true), ""));
    `Log("Loaded!",,'Unofficial KF2 Patch Lite');
}

final function SetupMutator(const string Options)
{
    local int Index;
	local string InOpt;

    CurrentPickupLifespan = KFGI.GetIntOption(Options, "PickupLifespan", PickupLifespan);
	CurrentMaxPlayers = KFGI.GetIntOption(Options, "MaxPlayers", ForcedMaxPlayers);
	
    if( CurrentMaxPlayers > 0 )
    {
        KFGI.MaxPlayers = CurrentMaxPlayers;
        KFGI.MaxPlayersAllowed = CurrentMaxPlayers;
        if( CurrentMaxPlayers > 6 )
            KFGI.KFGFxManagerClass = class'KFGFxMoviePlayer_Manager_Versus';
    }
		
    InOpt = KFGI.ParseOption(Options, "ServerName");
    if( InOpt != "" )
        class'GameReplicationInfo'.default.ServerName = InOpt;
        
    if( bool(KFGI.GetIntOption(Options, "HideServer", int(bServerHidden))) )
    {
        `Log("Verifing session before hiding...",,'Private Game');
		OnlineSub.GameInterface.AddUpdateOnlineGameCompleteDelegate(CheckPrivateGameWorkshop);
    }
        
    bToBroadcastPickups = bool(KFGI.GetIntOption(Options, "BroadcastPickups", int(bBroadcastPickups)));
    bForceDisableEDARs = bool(KFGI.GetIntOption(Options, "NoEDARs", int(bNoEDARSpawns)));
    bForceDisableQPs = bool(KFGI.GetIntOption(Options, "NoQPs", int(bNoQPSpawns)));
    bForceDisableGasCrawlers = bool(KFGI.GetIntOption(Options, "NoGasCrawlers", int(bNoGasCrawlers)));
    bForceDisableRageSpawns = bool(KFGI.GetIntOption(Options, "NoRageSpawns", int(bNoRageSpawns)));
    CurrentMaxMonsters = KFGI.GetIntOption(Options, "MaxMonsters", MaxMonsters);
    CurrentFakePlayers = KFGI.GetIntOption(Options, "FakePlayers", FakePlayers);
    CurrentDoshKillMultiplier = RoundFloatPrecision(KFGI.GetFloatOption(Options, "DoshKillMultiplier", DoshKillMultiplier));
    CurrentSpawnRateMultiplier = RoundFloatPrecision(KFGI.GetFloatOption(Options, "SpawnRateMultiplier", SpawnRateMultiplier));
    CurrentWaveCountMultiplier = RoundFloatPrecision(KFGI.GetFloatOption(Options, "WaveCountMultiplier", WaveCountMultiplier));
    bBypassGameConductor = bool(KFGI.GetIntOption(Options, "DisableGameConductor", int(bDisableGameConductor)));
    bServerDropAllWepsOnDeath = bool(KFGI.GetIntOption(Options, "DropAllWepsOnDeath", int(bDropAllWepsOnDeath)));
    CurrentMaxDoshSpamAmount = KFGI.GetIntOption(Options, "MaxDoshSpam", MaxDoshSpamAmount);
    bCurrentAllowDynamicMOTD = bool(KFGI.GetIntOption(Options, "UseDynamicMOTD", int(bAllowDynamicMOTD)));
    
    CurrentAllowedBosses = KFGI.ParseOption(Options, "BossList");
    if( CurrentAllowedBosses == "" )
        CurrentAllowedBosses = AllowedBosses;
        
    CurrentAllowedOutbreaks = KFGI.ParseOption(Options, "Outbreaks");
    if( CurrentAllowedOutbreaks == "" )
        CurrentAllowedOutbreaks = AllowedOutbreaks;
        
    CurrentAllowedSpecialWaves = KFGI.ParseOption(Options, "SpecialWaves");
    if( CurrentAllowedSpecialWaves == "" )
        CurrentAllowedSpecialWaves = AllowedSpecialWaves;
        
    CurrentAllowedPerks = KFGI.ParseOption(Options, "Perks");
    if( CurrentAllowedPerks == "" )
        CurrentAllowedPerks = AllowedPerks;
	
	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer )
	{
		NetDriver = TcpNetDriver(FindObject("Transient.TcpNetDriver_"$CurrentNetDriverIndex, class'TcpNetDriver'));
		if( NetDriver == None )
		{
			CurrentNetDriverIndex = 0;
			while( NetDriver == None )
			{
				NetDriver = TcpNetDriver(FindObject("Transient.TcpNetDriver_"$CurrentNetDriverIndex, class'TcpNetDriver'));
				CurrentNetDriverIndex++;
			}
			
			if( CurrentNetDriverIndex != default.CurrentNetDriverIndex )
				SaveConfig();
		}
		
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
		
        Index = NetDriver.DownloadManagers.Find("OnlineSubsystemSteamworks.SteamWorkshopDownload");
		if( Index == INDEX_NONE )
		{
			NetDriver.DownloadManagers.InsertItem(0, "OnlineSubsystemSteamworks.SteamWorkshopDownload");
			NetDriver.SaveConfig();
		}
        
        WorkshopTool = Spawn(class'UnofficialKFPatch_Lite.WorkshopTool', self);
    }
    
    TimerHelper.SetTimer(WorldInfo.DeltaSeconds*2.f, false, 'CheckForMapFixes', self);

    if( bool(KFGI.GetIntOption(Options, "UnsuppressLogs", 0)) )
    {
        ConsoleCommand("UNSUPPRESS DevNet");
        ConsoleCommand("UNSUPPRESS DevOnline");
        ConsoleCommand("UNSUPPRESS Log");
    }
}

final function CheckForMapFixes()
{
    local StaticMeshActor MA;
    
    if( InStr(WorldInfo.GetMapName(true), "KF-HellmarkStation", false, true) != INDEX_NONE )
    {
        MA = StaticMeshActor(FindObject("ART_Halloween2020.TheWorld:PersistentLevel.StaticMeshActor_14829", class'StaticMeshActor'));
        if( MA != None )
            MA.SetCollisionType(COLLIDE_BlockWeapons);
            
        MA = StaticMeshActor(FindObject("ART_Halloween2020.TheWorld:PersistentLevel.StaticMeshActor_14993", class'StaticMeshActor'));
        if( MA != None )
            MA.SetCollisionType(COLLIDE_BlockWeapons);
    }
}

final function CheckPrivateGameWorkshop(name SessionName,bool bWasSuccessful)
{
    if( bWasSuccessful && SessionName == KFGI.PlayerReplicationInfoClass.default.SessionName )
    {
        `Log("Session verified, attempting to hide game...",,'Private Game');
        
        OnlineSub.GameInterface.ClearUpdateOnlineGameCompleteDelegate(CheckPrivateGameWorkshop);
        if( OnlineSub.GameInterface.GetGameSettings(KFGI.PlayerReplicationInfoClass.default.SessionName) != None )
        {
            OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(DestroySuccess);
            OnlineSub.GameInterface.DestroyOnlineGame(KFGI.PlayerReplicationInfoClass.default.SessionName);
        }
        else `Log("Session already hidden, skipping destroy.",,'Private Game');
    }
}

final function DestroySuccess(name SessionName,bool bWasSuccessful)
{
    if( bWasSuccessful && SessionName == KFGI.PlayerReplicationInfoClass.default.SessionName )
    {
        `Log("Session succesfully hidden from master server.",,'Private Game');
        OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(DestroySuccess);
    }
}

final function PlayerReplicationInfo FindPRIFromDrop(KFDroppedPickup Drop, out int Index)
{
    local int i, j;
    
    for( i=0; i<PlayerPickups.Length; i++ )
    {
        if( PlayerPickups[i].PRI == None )
        {
            PlayerPickups.Remove(i, 1);
            continue;
        }
        
        for( j=0; j<PlayerPickups[i].Pickups.Length; j++ )
        {
            if( PlayerPickups[i].Pickups[j] == Drop )
            {
                Index = i;
                return PlayerPickups[i].PRI;
            }
        }
    }
    
    return None;
}

final function bool GetPlayerConfig(PlayerReplicationInfo PRI, optional out FPlayerConfig Info, optional out int Index)
{
    Index = PlayerConfigs.Find('SteamID', OnlineSub.UniqueNetIdToInt64(PRI.UniqueId));
    if( Index != INDEX_NONE )
    {
        Info = PlayerConfigs[Index];
        return true;
    }
    
    return false;
}

function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup)
{
    local string WeaponName, SteamID, OwnerName, S;
    local int SellPrice, Index, i;
    local byte ItemIndex;
    local KFGameReplicationInfo GRI;
    local class<KFWeapon> Weapon;
    local class<KFWeaponDefinition> WeaponDef;
    local KFInventoryManager InvMan;
    local STraderItem Item;
    local KFDroppedPickup Drop;
    local PlayerReplicationInfo PRI;
	local array<KFPlayerReplicationInfo> KFPRIArray;
    local FPlayerConfig Info;
    local bool Ret;

    Ret = Super.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup);
    
    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( GRI == None )
        return Ret;
    
    Drop = KFDroppedPickup(Pickup);
    if( Drop == None || Drop.Instigator == Other || KFDroppedPickup_Cash(Drop) != None )
        return Ret;
    
    PRI = FindPRIFromDrop(Drop, Index);
    SteamID = PlayerPickups[Index].OwnerSteamID;
    OwnerName = PlayerPickups[Index].OwnerName;
    if( PRI == None )
    {
        GRI.GetKFPRIArray(KFPRIArray);
        for( i=0; i<KFPRIArray.Length; i++ )
        {
            if( SteamID == OnlineSub.UniqueNetIdToInt64(KFPRIArray[i].UniqueId) )
            {
                PRI = KFPRIArray[i];
                break;
            }
        }
    }
    
    if( PRI == None || PRI == Other.PlayerReplicationInfo || SteamID == OnlineSub.UniqueNetIdToInt64(Other.PlayerReplicationInfo.UniqueId) )
        return Ret;
    
    if( class<KFCarryableObject>(ItemClass) == None && GetPlayerConfig(PRI, Info) && Info.bDropProtected )
    {
        bAllowPickup = 0;
        return true;
    }
    
    if( !bToBroadcastPickups || !Other.InvManager.HandlePickupQuery(ItemClass, Pickup) )
        return Ret;

    Weapon = class<KFWeapon>(ItemClass);
    if( Weapon == None )
        return Ret;
    
    if( GRI.TraderItems.GetItemIndicesFromArche(ItemIndex, Weapon.Name) )
    {
        WeaponDef = GRI.TraderItems.SaleItems[ItemIndex].WeaponDef;
        Item = GRI.TraderItems.SaleItems[ItemIndex];
    }
    else return Ret;
        
    if( WeaponDef == None )
        return Ret;
        
    InvMan = KFInventoryManager( Other.InvManager );
    if( InvMan == None || !InvMan.CanCarryWeapon(Weapon, KFWeapon(Drop.Inventory).CurrentWeaponUpgradeIndex) )
        return Ret;
        
    WeaponName = WeaponDef.static.GetItemName();
    SellPrice = InvMan.GetAdjustedSellPriceFor(Item);

    S = "%p picked up %o's %w("$Chr(208)$"%$).";
    S = Repl(S, "%p", Other.PlayerReplicationInfo.PlayerName);
    S = Repl(S, "%o", OwnerName);
    S = Repl(S, "%w", WeaponName);
    S = Repl(S, "%$", SellPrice);
    KFGI.Broadcast(Other, S);
    
    return Ret;
}

final function GetAllowedBossList(out array< class<KFPawn_Monster> > BossList)
{
    local array<string> BossStringList;
    local int i;
    
    BossStringList = SplitString(CurrentAllowedBosses, ",", true);
    if( BossStringList.Length <= 0 )
        return;
        
    BossList.Length = 0;
    for( i=0; i<BossStringList.Length; i++ )
    {
        switch( name(BossStringList[i]) )
        {
            case 'H':
                BossList.AddItem(KFGI.AIBossClassList[BAT_Hans]);
                break;
            case 'P':
                BossList.AddItem(KFGI.AIBossClassList[BAT_Patriarch]);
                break;
            case 'K':
                BossList.AddItem(KFGI.AIBossClassList[BAT_KingFleshpound]);
                break;
            case 'A':
                BossList.AddItem(KFGI.AIBossClassList[BAT_KingBloat]);
                break;
            case 'M':
                BossList.AddItem(KFGI.AIBossClassList[BAT_Matriarch]);
                break;
        }
    }
}

final function bool TrySetNextWaveSpecial()
{
    local int SpecialWaveType;
    local float OutbreakPct, SpecialWavePct;
    local KFGameReplicationInfo_Endless KFGRIE;

    KFGRIE = KFGameReplicationInfo_Endless(WorldInfo.GRI);
    if( KFGRIE.IsBossWave() || KFGRIE.IsBossWaveNext() )
        return false;
        
    KFGRIE.CurrentWeeklyMode = INDEX_NONE;
    KFGRIE.CurrentSpecialMode = INDEX_NONE;
    KFGIE.bUseSpecialWave = false;

	OutbreakPct = KFGIE.EndlessDifficulty.GetOutbreakPctChance();
	SpecialWavePct = KFGIE.EndlessDifficulty.GetSpeicalWavePctChance();
	if( KFGIE.WaveNum >= (KFGIE.OutbreakWaveStart-1) && OutbreakPct > 0.f && (FRand() <= OutbreakPct || OutbreakPct >= 1.f) )
    {
		KFGRIE.CurrentWeeklyMode = GetRandomEnabledOutbreak();
        return true;
    }
	else if( KFGIE.WaveNum >= (KFGIE.SpecialWaveStart-1) && SpecialWavePct > 0.f && (FRand() <= SpecialWavePct || SpecialWavePct >= 1.f) )
	{
        SpecialWaveType = GetRandomEnabledSpecialWave();
        if( SpecialWaveType == INDEX_NONE )
        {
            KFGRIE.CurrentWeeklyMode = GetRandomEnabledOutbreak();
            return true;
        }
            
		KFGIE.bUseSpecialWave = true;
		KFGIE.SpecialWaveType = EAIType(SpecialWaveType);
		KFGRIE.CurrentSpecialMode = KFGIE.SpecialWaveType;
        
        return true;
	}
    
    return false;
}

final function int GetRandomEnabledSpecialWave(optional out array<byte> IDs)
{
    local array<string> SpecialWaveList;
    local int i;
    
    SpecialWaveList = SplitString(CurrentAllowedSpecialWaves, ",", true);
    if( SpecialWaveList.Length <= 0 )
        return INDEX_NONE;
    
    for( i=0; i<SpecialWaveList.Length; i++ )
    {
        switch( name(SpecialWaveList[i]) )
        {
            case 'CL':
                IDs.AddItem(AT_Clot);
                break;
            case 'CS':
                IDs.AddItem(AT_SlasherClot);
                break;
            case 'CA':
                IDs.AddItem(AT_AlphaClot);
                break;
            case 'C':
                IDs.AddItem(AT_Crawler);
                break;
            case 'GF':
                IDs.AddItem(AT_GoreFast);
                break;
            case 'S':
                IDs.AddItem(AT_Stalker);
                break;
            case 'SC':
                IDs.AddItem(AT_Scrake);
                break;
            case 'FP':
                IDs.AddItem(AT_FleshPound);
                break;
            case 'QP':
                IDs.AddItem(AT_FleshpoundMini);
                break;
            case 'B':
                IDs.AddItem(AT_Bloat);
                break;
            case 'SR':
                IDs.AddItem(AT_Siren);
                break;
            case 'H':
                IDs.AddItem(AT_Husk);
                break;
            case 'CR':
                IDs.AddItem(AT_EliteClot);
                break;
            case 'GC':
                IDs.AddItem(AT_EliteCrawler);
                break;
            case 'GFI':
                IDs.AddItem(AT_EliteGoreFast);
                break;
            case 'EMP':
                IDs.AddItem(AT_EDAR_EMP);
                break;
            case 'LSR':
                IDs.AddItem(AT_EDAR_Laser);
                break;
            case 'RCT':
                IDs.AddItem(AT_EDAR_Rocket);
                break;
        }
    }
    
    if( IDs.Length > 0 )
        return IDs[Rand(IDs.Length)];
    
    return INDEX_NONE;
}

final function int GetRandomEnabledOutbreak(optional out array<byte> IDs)
{
    local array<string> OutbreakList;
    local int i;
    
    OutbreakList = SplitString(CurrentAllowedOutbreaks, ",", true);
    if( OutbreakList.Length <= 0 )
        return INDEX_NONE;
        
    for( i=0; i<OutbreakList.Length; i++ )
    {
        switch( name(OutbreakList[i]) )
        {
            case 'B':
                IDs.AddItem(0);
                break;
            case 'TT':
                IDs.AddItem(1);
                break;
            case 'BZ':
                IDs.AddItem(2);
                break;
            case 'P':
                IDs.AddItem(3);
                break;
            case 'UU':
                IDs.AddItem(4);
                break;
            case 'BK':
                IDs.AddItem(5);
                break;
        }
    }
    
    if( IDs.Length > 0 )
        return IDs[Rand(IDs.Length)];
    
    return INDEX_NONE;
}

final function int GetPerkIndexFromClass( class<KFPlayerController> PCC, class<KFPerk> InPerkClass )
{
    local int i;
    
    for( i=0; i<PCC.default.PerkList.Length; i++ )
    {
        if( ClassIsChildOf(PCC.default.PerkList[i].PerkClass, InPerkClass) )
            return i;
    }
    
	return INDEX_NONE;
}

final function PerkAvailableData GetAllowedPerkList(optional out array<byte> IDs)
{
    local array<string> PerkList;
    local int i, Index;
    local class<KFPerk> PerkClass;
    local class<KFPlayerController> PCC;
    local PerkAvailableData PerkData;
    
    PerkList = SplitString(CurrentAllowedPerks, ",", true);
    if( PerkList.Length <= 0 )
        return KFGRI.PerksAvailableData;
        
    PCC = class<KFPlayerController>(KFGI.PlayerControllerClass);
    for( i=0; i<PerkList.Length; i++ )
    {
        switch( name(PerkList[i]) )
        {
            case 'BZ':
                PerkClass = class'KFPerk_Berserker';
                break;
            case 'CO':
                PerkClass = class'KFPerk_Commando';
                break;
            case 'SU':
                PerkClass = class'KFPerk_Support';
                break;
            case 'FM':
                PerkClass = class'KFPerk_FieldMedic';
                break;
            case 'DO':
                PerkClass = class'KFPerk_Demolitionist';
                break;
            case 'FB':
                PerkClass = class'KFPerk_Firebug';
                break;
            case 'GS':
                PerkClass = class'KFPerk_Gunslinger';
                break;
            case 'SS':
                PerkClass = class'KFPerk_Sharpshooter';
                break;
            case 'SW':
                PerkClass = class'KFPerk_SWAT';
                break;
            case 'SV':
                PerkClass = class'KFPerk_Survivalist';
                break;
        }
        
        Index = GetPerkIndexFromClass(PCC, PerkClass);
        if( Index != INDEX_NONE )
        {
            PerkData.bPerksAvailableLimited = true;
            switch( PerkClass.Name )
            {
                case 'KFPerk_Berserker':
                    PerkData.bBerserkerAvailable = true;
                    break;
                case 'KFPerk_Commando':
                    PerkData.bCommandoAvailable = true;
                    break;
                case 'KFPerk_Support':
                    PerkData.bSupportAvailable = true;
                    break;
                case 'KFPerk_FieldMedic':
                    PerkData.bFieldMedicAvailable = true;
                    break;
                case 'KFPerk_Demolitionist':
                    PerkData.bDemolitionistAvailable = true;
                    break;
                case 'KFPerk_Firebug':
                    PerkData.bFirebugAvailable = true;
                    break;
                case 'KFPerk_Gunslinger':
                    PerkData.bGunslingerAvailable = true;
                    break;
                case 'KFPerk_Sharpshooter':
                    PerkData.bSharpshooterAvailable = true;
                    break;
                case 'KFPerk_SWAT':
                    PerkData.bSwatAvailable = true;
                    break;
                case 'KFPerk_Survivalist':
                    PerkData.bSurvivalistAvailable = true;
                    break;
            }

            IDs.AddItem(Index);
        }
    }
    
    return PerkData;
}

final function string GetServerMOTD(string MOTD)
{
    local string S;
    
    if( !bCurrentAllowDynamicMOTD )
        return MOTD;
    
    if( MOTD == "" )
    {
        S = "-- Lite Unofficial KF2 Settings --\n\n";
        if( bToBroadcastPickups )
            S $= "Pickups are broadcasted!\n";
        if( CurrentMaxPlayers > 0 )
            S $= "Max Players = "$CurrentMaxPlayers$"!\n";
        if( CurrentFakePlayers > 0 )
            S $= "Fake Players = "$CurrentFakePlayers$"!\n";
        if( CurrentMaxMonsters > 0 )
            S $= "Max Monsters = "$CurrentMaxMonsters$"!\n";
        if( MaxDoshSpamAmount > 0 )
            S $= "Max Dosh Spam Amount = "$MaxDoshSpamAmount$"!\n";
        if( bServerDropAllWepsOnDeath )
            S $= "Drop All Weapons on Death is Enabled!\n";
        if( bForceDisableEDARs )
            S $= "EDARs are Disabled!\n";
        if( bForceDisableRageSpawns )
            S $= "Rage Spawns are Disabled!\n";
        if( bForceDisableQPs )
            S $= "Quarterpounds are Disabled!\n";
        if( bForceDisableGasCrawlers )
            S $= "Gas Crawlers are Disabled!\n";
        if( bBypassGameConductor )
            S $= "Game Conductor is Disabled!\n";
        S $= "Dosh Kill Scale = "$FormatFloat(CurrentDoshKillMultiplier)$"!\n";
        S $= "Spawn Rate Scale = "$FormatFloat(CurrentSpawnRateMultiplier)$"!\n";
        S $= "Wave Count Scale = "$FormatFloat(CurrentWaveCountMultiplier)$"!\n";
        
        if( Len(S) < 512 )
            return S;
    }
    
    return MOTD;
}

final function InitGameReplicationInfo(KFGameReplicationInfo GRI)
{
    KFGRI = GRI;
    GRI.bNetInitial = true;
    if( KFGameInfo_WeeklySurvival(KFGI) == None )
        GRI.PerksAvailableData = GetAllowedPerkList();
}

final function string FormatFloat( float F, optional int Points=2 )
{
	local int Index;
	local string S;	

	S = string(F);
	Index = InStr(S, ".") + 1;
    
	return Mid(S, 0, Index+Points);
}

final function float RoundFloatPrecision(float Val, optional byte N=2)
{
    return float(FCeil((Val * (10 ** N)) - 0.49f)) / (10 ** N);
}

final function DelayedMessage(KFPlayerController PC, string Msg)
{
    local FDelayedMessage Info;
    
    Info.PC = PC;
    Info.S = Msg;

    DelayedMessages.AddItem(Info);
}

function NotifyLogin(Controller NewPlayer)
{
    local KFPlayerController PC;
    local int Index;
    local KFPlayerReplicationInfo MRI;
    
    PC = KFPlayerController(NewPlayer);
    if( PC != None )
    {
        `Log("Player"@PC.PlayerReplicationInfo.PlayerName@"("$OnlineSub.UniqueNetIdToInt64(PC.PlayerReplicationInfo.UniqueId)$") has entered the server!",, 'Join Log');
        PC.bShortConnectTimeOut = true;
        DelayedMessage(PC, "[UKFP] This server is running Unofficial KF2 Patch [Lite] by Forrest Mark X");
    }
    
	if( NetDriver != None && MyKFGI.bWaitingToStartMatch && NetDriver.NetServerLobbyTickRate == NetDriver.default.NetServerLobbyTickRate )
		NetDriver.NetServerLobbyTickRate = NetDriver.default.NetServerMaxTickRate;
        
    if( !GetPlayerConfig(PC.PlayerReplicationInfo) )
    {
        Index = PlayerConfigs.Add(1);
        PlayerConfigs[Index].SteamID = OnlineSub.UniqueNetIdToInt64(PC.PlayerReplicationInfo.UniqueId);
        SaveConfig();
    }
    
    MRI = WorldInfo.Spawn(class'KFPlayerReplicationInfo');
    MRI.bIsInactive = true;
    MRI.bOnlySpectator = true;
    MRI.PlayerName = PC.PlayerReplicationInfo.PlayerName;
    MRI.CurrentPerkClass = KFPlayerReplicationInfo(PC.PlayerReplicationInfo).CurrentPerkClass;
    
    WorldInfo.GRI.RemovePRI(MRI);
    WorldInfo.GRI.AddPRI(MRI);
    
    MRI.bNetInitial = true;
    
    if( DummyPlayerPRIs.Find('OriginalPRI', KFPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo)) == INDEX_NONE )
    {
        Index = DummyPlayerPRIs.Add(1);
        DummyPlayerPRIs[Index].OriginalPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
        DummyPlayerPRIs[Index].DummyPRI = MRI;
    }

    Super.NotifyLogin(NewPlayer);
}

function NotifyLogout(Controller Exiting)
{
    local int Index;
    local KFPlayerController PC;

    PC = KFPlayerController(Exiting);
    if( PC != None )
        `Log("Player"@PC.PlayerReplicationInfo.PlayerName@"("$OnlineSub.UniqueNetIdToInt64(PC.PlayerReplicationInfo.UniqueId)$") has left the server!",, 'Join Log');
    
	if( NetDriver != None && MyKFGI.NumPlayers <= 0 && NetDriver.NetServerLobbyTickRate == NetDriver.default.NetServerMaxTickRate && MyKFGI.bWaitingToStartMatch )
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
        
    if( KFGI.NumPlayers <= 0 && !KFGI.bWaitingToStartMatch && KFGI.MyKFGRI.bTraderIsOpen )
        KFGameInfo_Survival(KFGI).EndOfMatch(false);
        
    Index = DummyPlayerPRIs.Find('OriginalPRI', KFPlayerReplicationInfo(Exiting.PlayerReplicationInfo));
    if( Index != INDEX_NONE )
    {
        DummyPlayerPRIs[Index].DummyPRI.Destroy();
        DummyPlayerPRIs.Remove(Index, 1);
    }
        
    Super.NotifyLogout(Exiting);
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local KFPawn_Human P;
    local KFPlayerController PC;
    
    P = KFPawn_Human(Killed);
    if( P != None )
    {
        PC = KFPlayerController(P.Controller);
        if( PC != None && (KFAIController(Killer) != None || class<DmgType_Suicided>(DamageType) == None) )
            PlayersDiedThisWave.AddItem(PC);
    }
        
	return Super.PreventDeath(Killed, Killer, damageType, HitLocation);
}

final function PlayerChangeSpec( KFPlayerController PC, bool bSpectator )
{
    local FPlayerConfig Info;
    
    if( GetPlayerConfig(PC.PlayerReplicationInfo, Info) )
        return;
        
	if( bSpectator==PC.PlayerReplicationInfo.bOnlySpectator || Info.NextSpectateChange>WorldInfo.TimeSeconds )
    {
        KFGI.BroadcastHandler.BroadcastText(PC.PlayerReplicationInfo, PC, "Can't change spectate mode."@((bSpectator==PC.PlayerReplicationInfo.bOnlySpectator) ? "Already a spectator!" : "You must wait before trying to change again!"));
		return;
    }
        
	Info.NextSpectateChange = WorldInfo.TimeSeconds+0.5;

	if( WorldInfo.Game.bGameEnded )
		KFGI.BroadcastHandler.BroadcastText(PC.PlayerReplicationInfo, PC, "Can't change spectate mode after end-game.");
	else if( WorldInfo.Game.bWaitingToStartMatch )
		KFGI.BroadcastHandler.BroadcastText(PC.PlayerReplicationInfo, PC, "Can't change spectate mode before game has started.");
	else if( WorldInfo.Game.AtCapacity(bSpectator,PC.PlayerReplicationInfo.UniqueId) )
		KFGI.BroadcastHandler.BroadcastText(PC.PlayerReplicationInfo, PC, "Can't change spectate mode because game is at its maximum capacity.");
	else if( bSpectator )
	{
		if( PC.PlayerReplicationInfo.Team!=None )
			PC.PlayerReplicationInfo.Team.RemoveFromTeam(PC);
		PC.PlayerReplicationInfo.bOnlySpectator = true;
		if( PC.Pawn!=None )
			PC.Pawn.KilledBy(None);
		PC.Reset();
		--WorldInfo.Game.NumPlayers;
		++WorldInfo.Game.NumSpectators;
		WorldInfo.Game.Broadcast(PC,PC.PlayerReplicationInfo.GetHumanReadableName()@"became a spectator");
        PC.StartSpectate();
        if( PlayersDiedThisWave.Find(PC) == INDEX_NONE )
            PlayersDiedThisWave.AddItem(PC);
	}
	else
	{
		PC.PlayerReplicationInfo.bOnlySpectator = false;
		if( !WorldInfo.Game.ChangeTeam(PC,WorldInfo.Game.PickTeam(0,PC,PC.PlayerReplicationInfo.UniqueId),false) )
		{
			PC.PlayerReplicationInfo.bOnlySpectator = true;
			KFGI.BroadcastHandler.BroadcastText(PC.PlayerReplicationInfo, PC, "Can't become an active player, failed to set a team.");
			return;
		}
		++WorldInfo.Game.NumPlayers;
		--WorldInfo.Game.NumSpectators;
		PC.Reset();
		WorldInfo.Game.Broadcast(PC,PC.PlayerReplicationInfo.GetHumanReadableName()@"became an active player");
        PC.PlayerReplicationInfo.bReadyToPlay = true;
        if( PlayersDiedThisWave.Find(PC) == INDEX_NONE )
        {
            if( PC.Pawn == None || KFPawn_Customization(PC.Pawn) != None )
            {
                if( PC.GetTeamNum() != 255 )
                {
                    if( PC.CanRestartPlayer() && KFGRI.bMatchHasBegun )
                        MyKFGI.RestartPlayer(PC);
                    else if( !KFGRI.bMatchHasBegun )
                        PC.CreateCustomizationPawn();
                }
            }
        }
	}
}

final function NotifyWaveStarted()
{
    PlayersDiedThisWaveOld.Length = 0;
    
    SavedWaveNum += 1;
    if( KFGameReplicationInfo(WorldInfo.GRI).IsBossWave() )
        SavedWaveNum = 1;
        
    ForceUpdateEndlessDecent();
}

final function NotifyWaveEnded()
{
    if( KFGIE != None && KFGRI.WaveNum == 1 && !KFGIE.bIsInHoePlus && (Caps(CurrentAllowedOutbreaks) != default.DefaultAllowedOutbreaks || Caps(CurrentAllowedSpecialWaves) != default.DefaultAllowedSpecialWaves) )
    {
        KFGIE.SpecialWaveStart = 2;
        KFGIE.OutbreakWaveStart = 2;
        while( !KFGIE.bIsInHoePlus )
            KFGIE.IncrementDifficulty();
    }
    
    PlayersDiedThisWaveOld = PlayersDiedThisWave;
    PlayersDiedThisWave.Length = 0;
    
    ForceUpdateEndlessDecent();
}

final function bool ShouldMapBeIgnored()
{
    return IgnoreDecentMaps.Find(WorldInfo.GetMapName(true)) != INDEX_NONE;
}

final function CheckBossTeleport()
{
    local KFTraderTrigger CurrentTrader;
    local PlayerStart PlayerStart, SelectedPlayerStart;
    local array<PlayerStart> ClosestPlayerStarts;
    local KFPlayerController PC;

    CurrentTrader = KFGRI.OpenedTrader;
    if( CurrentTrader == None )
        return;
        
    foreach WorldInfo.RadiusNavigationPoints(class'PlayerStart', PlayerStart, CurrentTrader.Location, 2048)
        ClosestPlayerStarts.AddItem(PlayerStart);
    
    if( ClosestPlayerStarts.Length > 0 )
    {
        foreach PlayersDiedThisWaveOld(PC)
        {
            SelectedPlayerStart = ClosestPlayerStarts[Rand(ClosestPlayerStarts.Length-1)];
            if( SelectedPlayerStart == None || PC.Pawn == None )
                continue;
                
            if( PC.PlayerReplicationInfo.bOnlySpectator )
            {
                PlayersDiedThisWaveOld.RemoveItem(PC);
                continue;
            }
            
            PC.Pawn.SetLocation(SelectedPlayerStart.Location);
            PC.MoveTimer = -1.0;
            PC.Pawn.SetAnchor(SelectedPlayerStart);
            PC.Pawn.SetMoveTarget(SelectedPlayerStart);
            
            PlayersDiedThisWaveOld.RemoveItem(PC);
        }
    }
    
    if( PlayersDiedThisWaveOld.Length <= 0 )
        ClearTimer('CheckBossTeleport');
}

final function UpdateWaveEndKismet(Sequence GameSeq, optional bool bBossWave)
{
	local array<SequenceObject> AllWaveEndEvents, AllWaveEnd2Events;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_TraderOpened WaveEndEvt;
	local KFSeqEvent_WaveEnd WaveEnd2Evt;
    local int i;

    GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderOpened', true, AllWaveEndEvents);
    GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveEnd', true, AllWaveEnd2Events);
    
    for( i=0; i<AllWaveEndEvents.Length; ++i )
    {
        WaveEndEvt = KFSeqEvent_TraderOpened(AllWaveEndEvents[i]);
        if( WaveEndEvt != None )
        {
            WaveEndEvt.Reset();
            WaveEndEvt.SetWaveNum(SavedWaveNum, bBossWave ? SavedWaveNum+1 : 254);
            
            if( bBossWave )
                OutputLinksToActivate.AddItem(1);
            else OutputLinksToActivate.AddItem(0);
            
            if( WaveEndEvt.CheckActivate( KFGRI, KFGRI,, OutputLinksToActivate ) )
                WaveEndEvt.PopulateLinkedVariableValues();
        }
    }

    for( i=0; i<AllWaveEnd2Events.Length; ++i )
    {
        WaveEnd2Evt = KFSeqEvent_WaveEnd(AllWaveEnd2Events[i]);
        if( WaveEnd2Evt != None )
        {
            WaveEnd2Evt.Reset();
            WaveEnd2Evt.SetWaveNum(SavedWaveNum, bBossWave ? SavedWaveNum+1 : 254);
            
            if( bBossWave )
                OutputLinksToActivate.AddItem(1);
            else OutputLinksToActivate.AddItem(0);
            
            if( WaveEnd2Evt.CheckActivate( KFGRI, KFGRI,, OutputLinksToActivate ) )
                WaveEnd2Evt.PopulateLinkedVariableValues();
        }
    }
}

final function ForceUpdateEndlessDecent()
{
	local array<SequenceObject> AllWaveStartEvents, AllInterpActions, AllRandomSwitchEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_WaveStart WaveStartEvt;
    local SeqAct_RandomSwitch RandomSwitchEvt;
	local SeqAct_Interp SeqInterp;
	local Sequence GameSeq;
    local int i, j;
    local byte MaxDecentWave;
    local KFMapInfo KFMI;
    
    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    
    if( KFMI != None && KFMI.SubGameType == ESGT_Descent && KFGIE != None )
    {
        if( !ShouldMapBeIgnored() )
        {
            GameSeq = WorldInfo.GetGameSequence();
            if( GameSeq != None )
            {
                FixDecentEndless(true);
                
                if( KFGRI.bWaveIsActive )
                {
                    if( KFGRI.IsBossWave() || bForceResetInterpActors )
                    {
                        GameSeq.FindSeqObjectsByClass(class'SeqAct_Interp', true, AllInterpActions);
                        for (i = 0; i < AllInterpActions.Length; i++)
                        {
                            SeqInterp = SeqAct_Interp(AllInterpActions[i]);
                            if( SeqInterp != None )
                                SeqInterp.Reset();
                        }

                        bForceResetInterpActors = false;
                    }
                    
                    GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveStart', true, AllWaveStartEvents);
                    for( i=0; i<AllWaveStartEvents.Length; ++i )
                    {
                        WaveStartEvt = KFSeqEvent_WaveStart(AllWaveStartEvents[i]);
                        if( WaveStartEvt != None )
                        {
                            if( KFGRI.IsBossWaveNext() )
                                MaxDecentWave = SavedWaveNum+1;
                            else MaxDecentWave = 254;
                            
                            WaveStartEvt.Reset();
                            WaveStartEvt.SetWaveNum(KFGRI.IsBossWave() ? MaxDecentWave : SavedWaveNum, MaxDecentWave);
                            
                            if( KFGRI.IsBossWave() )
                                OutputLinksToActivate.AddItem(1);
                            else OutputLinksToActivate.AddItem(0);
                            
                            if( WaveStartEvt.CheckActivate( KFGRI, KFGRI,, OutputLinksToActivate ) )
                                WaveStartEvt.PopulateLinkedVariableValues();
                        }
                    }
                }
                else 
                {
                    if( KFGRI.IsBossWave() )
                        SetTimer(0.5f, true, 'CheckBossTeleport');
                    UpdateWaveEndKismet(GameSeq, KFGRI.IsBossWaveNext());
                    
                    if( KFGRI.IsBossWaveNext() )
                    {
                        GameSeq.FindSeqObjectsByClass(class'SeqAct_RandomSwitch', true, AllRandomSwitchEvents);
                        for( i=0; i<AllRandomSwitchEvents.Length; ++i )
                        {
                            RandomSwitchEvt = SeqAct_RandomSwitch(AllRandomSwitchEvents[i]);
                            if( RandomSwitchEvt != None && RandomSwitchEvt.bAutoDisableLinks )
                            {
                                for( j = 0; j < RandomSwitchEvt.OutputLinks.Length; ++j )
                                    RandomSwitchEvt.OutputLinks[j].bDisabled = false;
                            }
                        }
                    }
                }
                
                FixDecentEndless(false);
            }
        }
    }
}

final function FixDecentEndless(bool bEnabled)
{
	local array<SequenceObject> AllWaveStartEvents, AllWaveEndEvents, AllWaveEnd2Events;
	local KFSeqEvent_WaveStart WaveStartEvt;
	local KFSeqEvent_TraderOpened WaveEndEvt;
	local KFSeqEvent_WaveEnd WaveEnd2Evt;
	local Sequence GameSeq;
	local int i;
    local KFMapInfo KFMI;
    
    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    if( KFMI.SubGameType == ESGT_Descent && KFGameInfo_Endless(MyKFGI) != None && !ShouldMapBeIgnored() )
    {
        GameSeq = WorldInfo.GetGameSequence();
        if( GameSeq != None )
        {
            GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveStart', true, AllWaveStartEvents);
            for( i = 0; i < AllWaveStartEvents.Length; ++i )
            {
                WaveStartEvt = KFSeqEvent_WaveStart(AllWaveStartEvents[i]);
                if( WaveStartEvt != None )
                {
                    WaveStartEvt.bEnabled = bEnabled;
                    WaveStartEvt.MaxTriggerCount = 255;
                    WaveStartEvt.TriggerCount = 0;
                }
            }

            GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderOpened', true, AllWaveEndEvents);
            for( i = 0; i < AllWaveEndEvents.Length; ++i )
            {
                WaveEndEvt = KFSeqEvent_TraderOpened(AllWaveEndEvents[i]);
                if( WaveEndEvt != None )
                {
                    WaveEndEvt.bEnabled = bEnabled;
                    WaveEndEvt.MaxTriggerCount = 255;
                    WaveEndEvt.TriggerCount = 0;
                }
            }
            
            GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveEnd', true, AllWaveEnd2Events);
            for( i = 0; i < AllWaveEnd2Events.Length; ++i )
            {
                WaveEnd2Evt = KFSeqEvent_WaveEnd(AllWaveEnd2Events[i]);
                if( WaveEnd2Evt != None )
                {
                    WaveEnd2Evt.bEnabled = bEnabled;
                    WaveEnd2Evt.MaxTriggerCount = 255;
                    WaveEnd2Evt.TriggerCount = 0;
                }
            }
        }
    }
}

final function bool ProcessChatMessage(string Msg, PlayerController Sender, optional bool bTeamMessage)
{
    local KFPlayerController KFPC;
    local int Index;
    local FPlayerConfig Info;
    
    KFPC = KFPlayerController(Sender);
    if( KFPC == None )
        return false;

    if( Msg ~= "join" )
    {
        PlayerChangeSpec(KFPC, false);
        return true;
    }
    else if( Msg ~= "spec" )
    {
        if( !KFPC.PlayerReplicationInfo.bAdmin && (KFPC.PlayerReplicationInfo.bOnlySpectator || KFGRI.bWaveIsActive) )
        {
            KFGI.BroadcastHandler.BroadcastText(KFPC.PlayerReplicationInfo, KFPC, KFGRI.bWaveIsActive ? "Can't do that during a wave!" : "Say !join to unspectate");
            return false;
        }
        PlayerChangeSpec(KFPC, true);
        return true;
    }
    else if( Msg ~= "dp" && GetPlayerConfig(KFPC.PlayerReplicationInfo, Info, Index) )
    {
        PlayerConfigs[Index].bDropProtected = !PlayerConfigs[Index].bDropProtected;
        if( !TimerHelper.IsTimerActive('SaveConfig', self) )
            TimerHelper.SetTimer(0.5f, false, 'SaveConfig', self);
        KFGI.BroadcastHandler.BroadcastText(KFPC.PlayerReplicationInfo, KFPC, PlayerConfigs[Index].bDropProtected ? "Players can no longer pickup your weapons!" : "Players can pickup your weapons again!");
        return true;
    }
    else if( Msg ~= "dlk" && GetPlayerConfig(KFPC.PlayerReplicationInfo, Info, Index) )
    {
        PlayerConfigs[Index].bEnableLargeKills = !PlayerConfigs[Index].bEnableLargeKills;
        if( !TimerHelper.IsTimerActive('SaveConfig', self) )
            TimerHelper.SetTimer(0.5f, false, 'SaveConfig', self);
        KFGI.BroadcastHandler.BroadcastText(KFPC.PlayerReplicationInfo, KFPC, "Showing Large Kills in the kill feed was set to"@(PlayerConfigs[Index].bEnableLargeKills ? "true" : "false")$".");
        return true;
    }
    
    return false;
}

final function NotifyMatchStarted()
{
	if( NetDriver != None && NetDriver.NetServerLobbyTickRate != NetDriver.default.NetServerLobbyTickRate )
	{
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
		NetDriver.SaveConfig();
	}
}

final function DoTick()
{
    local float DT;
    
    DT = WorldInfo.DeltaSeconds;
    if( !bCleanedUp && WorldInfo.NextSwitchCountdown > 0.f && (WorldInfo.NextSwitchCountdown-(DT*4.f))<=0.f )
        Cleanup();
    if( DelayedMessages.Length > 0 )
    {
        if( DelayedMessages[0].PC != None )
            KFGI.BroadcastHandler.BroadcastText(DelayedMessages[0].PC.PlayerReplicationInfo, DelayedMessages[0].PC, DelayedMessages[0].S);
        DelayedMessages.Remove(0, 1);
    }
    TimerHelper.SetTimer(DT, false, 'DoTick', self);
}

final function Cleanup()
{
    KFDroppedPickup.Destroyed = OrgFunctions.PickupDestroyed;
    KFDroppedPickup.SetPickupMesh = OrgFunctions.SetPickupMesh;
    KFPawn_Monster.GetAIPawnClassToSpawn = OrgFunctions.GetAIPawnClassToSpawn;
    KFAIController_ZedFleshpound.SpawnEnraged = OrgFunctions.SpawnEnraged;
    KFAISpawnManager.GetMaxMonsters = OrgFunctions.GetMaxMonsters;
    KFGameDifficultyInfo.GetNumPlayersModifier = OrgFunctions.GetNumPlayersModifier;
    KFGameInfo.ModifyAIDoshValueForPlayerCount = OrgFunctions.ModifyAIDoshValueForPlayerCount;
    KFGameInfo.GetAdjustedAIDoshValue = OrgFunctions.GetAdjustedAIDoshValue;
    KFGameInfo.GetGameInfoSpawnRateMod = OrgFunctions.GetGameInfoSpawnRateMod;
    KFGameInfo.GetTotalWaveCountScale = OrgFunctions.GetTotalWaveCountScale;
    KFGameInfo_Survival.Timer = OrgFunctions.GameTimer;
    KFGameInfo.SetMonsterDefaults = OrgFunctions.SetMonsterDefaults;
    KFGameInfo.GetSpecificBossClass = OrgFunctions.GetSpecificBossClass;
    KFGameInfo_Endless.TrySetNextWaveSpecial = OrgFunctions.GameTrySetNextWaveSpecial;
    KFGameReplicationInfo.PostBeginPlay = OrgFunctions.GRIPostBeginPlay;
    KFGameInfo_Survival.NotifyTraderOpened = OrgFunctions.NotifyTraderOpened;
    KFGameInfo_Survival.NotifyTraderClosed = OrgFunctions.NotifyTraderClosed;
    PlayerController.ServerSay = OrgFunctions.ServerSay;
    PlayerController.ServerTeamSay = OrgFunctions.ServerTeamSay;
    KFGameInfo_Survival.StartMatch = OrgFunctions.StartMatch;
    Actor.FellOutOfWorld = OrgFunctions.ActorFellOutOfWorld;
    DroppedPickup.Landed = OrgFunctions.PickupLanded;
    KFPlayerReplicationInfo.PostBeginPlay = OrgFunctions.PRIPostBeginPlay;
    KFPawn.JumpOffPawn = OrgFunctions.JumpOffPawn;
    KFAIController.FindNewEnemy = OrgFunctions.FindNewEnemy;
    KFInventoryManager.DiscardInventory = OrgFunctions.DiscardInventory;
    KFInventoryManager.ServerThrowMoney = OrgFunctions.ServerThrowMoney;
    KFGameInfo.GetFriendlyNameForCurrentGameMode = OrgFunctions.GetFriendlyNameForCurrentGameMode;
    KFGameInfo.GetGameModeNumFromClass = OrgFunctions.GetGameModeNumFromClass;
    KFGameInfo.GetGameModeFriendlyNameFromClass = OrgFunctions.GetGameModeFriendlyNameFromClass;
    KFGameInfo.CreateOutbreakEvent = OrgFunctions.CreateOutbreakEvent;
    Mutator.PreBeginPlay = OrgFunctions.MutPreBeginPlay;

    NetDriver = None;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    local int Index;
    local KFPlayerController PC, KillerPC;
    local FPlayerConfig Info;
    local KFAIController_Monster MAI;
    local KFPlayerReplicationInfo DummyPRI;
    
    KillerPC = KFPlayerController(Killer);
    MAI = KFAIController_Monster(Killed);
    
    if( KillerPC != None && MAI != None && KFPawn_Monster(MAI.Pawn).bLargeZED )
    {
        Index = DummyPlayerPRIs.Find('OriginalPRI', KFPlayerReplicationInfo(KillerPC.PlayerReplicationInfo));
        if( Index != INDEX_NONE )
        {
            DummyPRI = DummyPlayerPRIs[Index].DummyPRI;
            DummyPRI.CurrentPerkClass = KFPlayerReplicationInfo(KillerPC.PlayerReplicationInfo).CurrentPerkClass;
            DummyPRI.bForceNetUpdate = true;
            DummyPRI.bNetDirty = true;
            
            foreach WorldInfo.AllControllers(class'KFPlayerController', PC)
            {
                if( PC != KillerPC && GetPlayerConfig(PC.PlayerReplicationInfo, Info) && Info.bEnableLargeKills )
                    PC.ReceiveLocalizedMessage(class'KFLocalMessage_Game', KMT_Killed, MAI.PlayerReplicationInfo, DummyPRI, MAI.Pawn.Class);
            }
        }
    }
    
    Super.ScoreKill(Killer, Killed);
}

final function SetMonsterDefaults(KFPawn_Monster P)
{
    local PlayerReplicationInfo MRI;

    MRI = WorldInfo.Spawn(class'PlayerReplicationInfo');
    MRI.bIsInactive = true;
    MRI.PlayerName = P.GetLocalizedName();
    P.PlayerReplicationInfo = MRI;
    if( P.Controller != None )
        P.Controller.PlayerReplicationInfo = MRI;
}

defaultproperties
{
    IgnoreDecentMaps.Add("KF-Elysium")
    
    DefaultAllowedOutbreaks="B,TT,BZ,P,UU,BK"
    DefaultAllowedSpecialWaves="CL,CS,C,S,SR,H,SC,CA,GF,B,FP"
}