class UKFPReplicationInfo extends ReplicationInfo
    config(UnofficialPatch);

const HelpURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=2875577642";

var UKFPReplicationInfo StaticReference;
var ProxyInfo FunctionProxy;

var config enum FOutbreakType
{
    OUTBREAK_NORMAL,
    OUTBREAK_BOOM,
    OUTBREAK_CRANIUM,
    OUTBREAK_TINY,
    OUTBREAK_BOBBLE,
    OUTBREAK_POUND,
    OUTBREAK_UPUPDECAY,
    OUTBREAK_ZEDTIME,
    OUTBREAK_BEEFCAKE,
    OUTBREAK_BLOODTHIRST,
    OUTBREAK_COLISEUM,
    OUTBREAK_ARACNOPHOBIA,
    OUTBREAK_SCAVENGER,
    OUTBREAK_WILDWEST,
    OUTBREAK_ABANDONALLHOPE,
    OUTBREAK_BOSSRUSH,
    OUTBREAK_TINYHEAD,
    OUTBREAK_ARSENALASCENT,
    OUTBREAK_PRIMARYTARGET,
    OUTBREAK_PERKROULETTE
} WeeklyIndex;
var int InitialWeeklyIndex;
var transient int CurrentWeeklyIndex;

var config enum ESeasonalEventType
{
    SET_None,
    SET_Fall2018,
    SET_Xmas2018,
    SET_Spring2019,
    SET_Summer2019,
    SET_Fall2019,
    SET_Xmas2019,
    SET_Spring2020,
    SET_Summer2020,
    SET_Fall2020,
    SET_Xmas2020,
    SET_Spring2021,
    SET_Summer2021,
    SET_Fall2021,
    SET_Xmas2021,
    SET_Summer2022,
    SET_Fall2022,
    SET_Xmas2022
} ForcedSeasonalEventDate;
var repnotify ESeasonalEventType CurrentForcedSeasonalEventDate;
var int InitialSeasonalEventDate;

var transient bool bCleanedUp;
var transient KFGameInfo_Survival MyKFGI;
var transient KFGameReplicationInfo KFGRI;
var transient OnlineSubsystemSteamworks OnlineSub;
var transient array<ReplicationHelper> ChatArray;
var transient float CurrentPickupLifespan;
var transient byte CurrentMaxMonsters, CurrentFakePlayers, SavedWaveNum, CurrentSeasonalIndex;
var transient string TravelMapName, CurrentMapName;
var transient TcpNetDriver NetDriver;
var transient WorkshopTool WorkshopTool;
var transient array<KFPlayerController> PlayersDiedThisWave, PlayersDiedThisWaveOld;
var transient xVotingHandler VotingHandler;
var transient repnotify private bool bServerEnforceVanilla;

var array<string> IgnoreDecentMaps;

struct FAchCollectibleOverride
{
    var string Map;
    var int ID;
};
var array<FAchCollectibleOverride> CollectibleAchIDForMap;

struct SeasonalMonsterArchs
{
    var class<KFPawn_Monster> MonsterClass;
    var string Regular, Summer, Winter, Fall, Spring;
};
var array<SeasonalMonsterArchs> ZEDArchList;

struct PrecachedArch
{
    var KFCharacterInfoBase Arch;
    var string ArchPath;
};
var transient array<PrecachedArch> PrecachedArchs;

struct FMapOverride
{
    var string Original, New;
};
var array<FMapOverride> MapNameOverrides;

struct FTypeSkinCache
{
    var EWeaponSkinType Type;
    var array<MaterialInterface> Skins;
};
struct FSkinCache
{
    var int ItemId;
    var array<FTypeSkinCache> Items;
};
var transient array<FSkinCache> WeaponSkinCache;

struct FPlayerPickups
{
    var PlayerReplicationInfo PRI;
    var string OwnerSteamID, OwnerName;
    var array<KFDroppedPickup> Pickups;
};
var array<FPlayerPickups> PlayerPickups;

var array< class<KFWeapon> > LoadedWeaponClasses;
var array<Object> ExternalObjs;

var config int CurrentNetDriverIndex;
var config byte ForcedMaxPlayers, MaxMonsters, FakePlayers;
var config float PickupLifespan;

var config bool bEnforceVanilla, bUseNormalSummerSCAnims, bAllowGamemodeVotes, bAttemptToLoadFHUD, bAttemptToLoadYAS, bAttemptToLoadAAL, bAttemptToLoadCVC, bServerHidden, bNoEventZEDSkins, bNoEDARSpawns, bNoPingsAllowed, bBroadcastPickups, bUseDynamicMOTD, bDisableTP, bDisallowHandChanges, bDropAllWepsOnDeath;
var transient bool CurrentNormalSummerSCAnims, bForceResetInterpActors, bDisallowHandSwap, bPlayingEmote, bHandledTravel, bServerIsHidden, bNoPings, bToBroadcastPickups, bServerDisableTP, bForceDisableEDARs, bServerDropAllWepsOnDeath;
var transient repnotify bool bNoEventSkins;
var transient byte RepMaxPlayers;

var array< class<KFWeapon> > WeaponExploitFix;

struct FDynamicMOTDInfo
{
    var bool bYASLoaded, bAALLoaded, bCVCLoaded, bFHUDLoaded, bNoEventSkins, bNoPings, bToBroadcastPickups, bDisableTP, bDisallowHandSwap, bUseNormalSummerSCAnims, bEnforceVanilla;
    var byte CurrentMaxPlayers, CurrentMaxMonsters, CurrentFakePlayers;
    var float CurrentPickupLifespan;
};
var repnotify FDynamicMOTDInfo DynamicMOTD;
var string DynamicMOTDString;

replication
{
    if( bNetInitial && Role==ROLE_Authority )
        InitialWeeklyIndex, InitialSeasonalEventDate, CurrentForcedSeasonalEventDate, bServerEnforceVanilla;
    if( Role==ROLE_Authority )
        KFGRI, bServerIsHidden, bNoEventSkins, bNoPings, DynamicMOTD, bServerDisableTP, CurrentMapName, bDisallowHandSwap;
}

simulated function ReplicatedEvent(name VarName)
{
    local string S;
    local ReplicationHelper CRI;
    local KFPlayerController PC;
    
    PC = KFPlayerController(GetALocalPlayerController());
    switch( VarName )
    {
        case 'bServerEnforceVanilla':
            if( bServerEnforceVanilla )
                WorldInfo.RBPhysicsGravityScaling = 1.f;
            else WorldInfo.RBPhysicsGravityScaling = WorldInfo.default.RBPhysicsGravityScaling;
            
            CRI = `GetChatRep();
            if( CRI != None && CRI.UKFPInteraction != None )
                CRI.UKFPInteraction.SetupBobStyle();
            break;
        case 'CurrentForcedSeasonalEventDate':
            FunctionProxy.ForceSeasonalEvent(CurrentForcedSeasonalEventDate);
            if( FunctionProxy.IsReadSuccessful(PC) )
            {
                FunctionProxy.CheckSpecialEventID(PC);
                PC.UpdateSeasonalState();
            }
            else SetTimer(0.01f, true, 'WaitForStatsRead');
            break;
        case 'bNoEventSkins':
            PC.UpdateSeasonalState();
            break;
        case 'DynamicMOTD':
            S = "\n-- Unofficial Killing Floor 2 Settings --\n";
            if( DynamicMOTD.bYASLoaded )
                S $= "Yet Another Scoreboard is Loaded!\n";
            if( DynamicMOTD.bAALLoaded )
                S $= "Auto Admin Login is Loaded!\n";
            if( DynamicMOTD.bCVCLoaded )
                S $= "Controlled Vote Collector is Loaded!\n";
            if( DynamicMOTD.bFHUDLoaded )
                S $= "Friendly HUD is Loaded!\n";
            if( DynamicMOTD.bNoEventSkins )
                S $= "Event skins are disabled!\n";
            if( DynamicMOTD.bNoPings )
                S $= "Pings are disabled!\n";
            if( DynamicMOTD.bToBroadcastPickups )
                S $= "Pickups are broadcasted!\n";
            if( DynamicMOTD.CurrentMaxPlayers > 0 )
                S $= "Max Players is set to "$DynamicMOTD.CurrentMaxPlayers$"!\n";
            if( DynamicMOTD.CurrentFakePlayers > 0 )
                S $= "Fake Players is set to "$DynamicMOTD.CurrentFakePlayers$"!\n";
            if( DynamicMOTD.CurrentMaxMonsters > 0 )
                S $= "Max Monsters is set to "$DynamicMOTD.CurrentMaxMonsters$"!\n";
            S $= "Third Person is "$(DynamicMOTD.bDisableTP ? "Disabled" : "Enabled")$"!\n";
            S $= "Hand Swapping is "$(DynamicMOTD.bDisallowHandSwap ? "Disabled" : "Enabled")$"!\n";
            S $= "Summer Scrake animation fix is "$(DynamicMOTD.bUseNormalSummerSCAnims ? "Disabled" : "Enabled")$"!\n";
            S $= "Pickup Lifespan is set to "$(DynamicMOTD.CurrentPickupLifespan > 0 ? string(DynamicMOTD.CurrentPickupLifespan) : Chr(0x221E))$"!\n";
            
            if( DynamicMOTD.bEnforceVanilla )
                S $= "<b>Vanilla Mode is Enforced!</b>\n";
            
            CRI = `GetChatRep();
            if( CRI != None && CRI.bMOTDReceived )
            {
                CRI.ServerMOTD $= S;
                CRI.ShowMOTD();
            }
            else DynamicMOTDString = S;
                
            break;
        default:
            Super.ReplicatedEvent(VarName);
            break;
    }
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    RemoveCustomStatus();
    SetTimer(0.01f, false, 'RemoveCustomStatus');
}

simulated function PreBeginPlay()
{
    local int i;
	local bool bEntryFound;
    local FAchCollectibleOverride AchID;
    local KFGameInfo_WeeklySurvival WeeklyGI;
    
    WeeklyGI = KFGameInfo_WeeklySurvival(WorldInfo.Game);
    if( WeeklyGI != None )
        CurrentWeeklyIndex = KFGameEngine(class'Engine'.static.GetEngine()).GetWeeklyEventIndex();
    
    AchID.Map = "KF-BurningParis";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_ParisCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Outpost";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_OutpostCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-BioticsLab";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_BioticsCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-VolterManor";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_ManorCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-EvacuationPoint";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_EvacsCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Catacombs";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_CatacombsCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-BlackForest";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_BlackForestCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Farmhouse";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_FarmhouseCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Prison";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_PrisonCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-ContainmentStation";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_ContainmentStationCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-HostileGrounds";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_HostileGroundsCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-InfernalRealm";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_InfernalRealmCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-ZedLanding";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_ZedLandingCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-TheDescent";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_DescentCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Nuked";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_NukedCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-TragicKingdom";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_TragicKingdomCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Nightmare";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_NightmareCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-KrampusLair";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_KrampusCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-DieSector";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_ArenaCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-PowerCore_Holdout";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_PowercoreCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Airship";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_AirshipCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Lockdown";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_LockdownCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-MonsterBall";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_MonsterBallCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-SantasWorkshop";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_SantasWorkshopCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-ShoppingSpree";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_ShoppingSpreeCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Spillway";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_SpillwayCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-SteamFortress";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_SteamFortressCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-AshwoodAsylum";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_AsylumCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Sanitarium";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_SanitariumCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Biolapse";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_BiolapseCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Desolation";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_DesolationCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-HellmarkStation";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_HellmarkStationCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Dystopia2029";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_Dystopia2029Collectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Moonbase";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_MoonbaseCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Netherhold";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_NetherholdCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-CarillonHamlet";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_CarillonHamletCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-Rig";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_RigCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    AchID.Map = "KF-BarmwichTown";
    AchID.ID = class'KFOnlineStatsWrite'.const.KFACHID_BarmwichCollectibles;
    CollectibleAchIDForMap.AddItem(AchID);
    
    class'UKFPGameMessage'.default.UserAdd = "<font color=\"#438DFF\" face=\"MIcon\">"$`GetMIconChar("account-plus")$"</font>";
    class'UKFPGameMessage'.default.UserDelete = "<font color=\"#FF0000\" face=\"MIcon\">"$`GetMIconChar("account-minus")$"</font>";
    class'UKFPGameMessage'.default.UserGo = "<font color=\"#438DFF\" face=\"MIcon\">"$`GetMIconChar("account-check")$"</font>";
    class'UKFPGameMessage'.default.UserEdit = "<font color=\"#FFFF00\" face=\"MIcon\">"$`GetMIconChar("account-alert")$"</font>";

    MyKFGI = KFGameInfo_Survival(WorldInfo.Game);

    `Log("Loaded!",,'Unofficial KF2 Patch');

    Super.PreBeginPlay();
    
    default.StaticReference = self;
    
    if( Role < ROLE_Authority && `GetChatRep() != None && `GetChatRep().FunctionProxy != None )
        FunctionProxy = `GetChatRep().FunctionProxy;
    else
    {
        FunctionProxy = New class<ProxyInfo>(SafeLoadObject("UnofficialKFPatch.FunctionProxy", Class'Class'));
        FunctionProxy.WorldInfo = WorldInfo;
        FunctionProxy.Init();
    }

    OnlineSub = OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem());
    
	if( WorldInfo.NetMode == NM_DedicatedServer )
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
		
		for( i=0; i<NetDriver.DownloadManagers.Length; i++ )
		{
			if( Caps(NetDriver.DownloadManagers[i]) == "ONLINESUBSYSTEMSTEAMWORKS.STEAMWORKSHOPDOWNLOAD" )
				bEntryFound = true;
		}
		
		if( !bEntryFound )
		{
			NetDriver.DownloadManagers.Insert(0, 1);
			NetDriver.DownloadManagers[0] = "OnlineSubsystemSteamworks.SteamWorkshopDownload";
			NetDriver.SaveConfig();
		}
        
        WorkshopTool = Spawn(class'WorkshopTool', self);
    }
}

final simulated function CheckForMapFixes()
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
    if( bWasSuccessful && SessionName == MyKFGI.PlayerReplicationInfoClass.default.SessionName )
    {
        `Log("Session verified, attempting to hide game...",,'Private Game');
        
        OnlineSub.GameInterface.ClearUpdateOnlineGameCompleteDelegate(CheckPrivateGameWorkshop);
        if( OnlineSub.GameInterface.GetGameSettings(MyKFGI.PlayerReplicationInfoClass.default.SessionName) != None )
        {
            OnlineSub.GameInterface.AddDestroyOnlineGameCompleteDelegate(DestroySuccess);
            OnlineSub.GameInterface.DestroyOnlineGame(MyKFGI.PlayerReplicationInfoClass.default.SessionName);
        }
        else `Log("Session already hidden, skipping destroy.",,'Private Game');
    }
}

final function DestroySuccess(name SessionName,bool bWasSuccessful)
{
    if( bWasSuccessful && SessionName == MyKFGI.PlayerReplicationInfoClass.default.SessionName )
    {
        `Log("Session succesfully hidden from master server.",,'Private Game');
        OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(DestroySuccess);
    }
}

simulated function Tick(float DT)
{
    if( !bCleanedUp && WorldInfo.NextSwitchCountdown > 0.f && (WorldInfo.NextSwitchCountdown-DT)<=0.f )
        Cleanup();
	Super.Tick(DT);
    if( KFGRI == None )
        KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( bServerEnforceVanilla && WorldInfo.RBPhysicsGravityScaling != 1.f )
        WorldInfo.RBPhysicsGravityScaling = 1.f;
}

final simulated function Cleanup()
{
    local int i;
    
    if( bCleanedUp )
        return;
      
    FunctionProxy.Cleanup();
    FunctionProxy = None;

    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        NetDriver = None;
        
        CurrentNetDriverIndex++;
        if( CurrentNetDriverIndex != default.CurrentNetDriverIndex )
            SaveConfig();
    }
    
    for( i=0; i<ChatArray.Length; i++ )
        ChatArray[i].Destroy();
    Destroy();

    bCleanedUp = true;
}

function bool ProcessChatMessage(string Msg, PlayerController Sender, optional bool bTeamMessage)
{
    local KFPlayerController KFPC;
    
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
            WriteToClient(KFPC, KFGRI.bWaveIsActive ? "Can't do that during a wave!" : "Say !join to unspectate", "FF0000");
            return false;
        }
        PlayerChangeSpec(KFPC, true);
        return true;
    }
    
    return false;
}

simulated function bool ClientProcessChatMessage(string Msg, PlayerController Sender, optional bool bTeamMessage)
{
    local ReplicationHelper CRI;
    local KFPlayerController KFPC;
    
    KFPC = KFPlayerController(Sender);
    if( KFPC == None )
        return false;
    
    CRI = GetPlayerChat(KFPC.PlayerReplicationInfo);
    if( CRI == None )
        return false;
        
    if( Msg ~= "toggleforcecrosshair" || Msg ~= "tfc" )
    {
        KFHudBase(KFPC.MyHud).bForceDrawCrosshair = !KFHudBase(KFPC.MyHud).bForceDrawCrosshair;
        return true;
    }
    else if( Msg ~= "togglecrosshair" || Msg ~= "tc" )
    {
        KFHudBase(KFPC.MyHud).bDrawCrosshair = !KFHudBase(KFPC.MyHud).bDrawCrosshair;
        return true;
    }
    else if( Msg ~= "ukfphelp" )
    {
        OnlineSub.OpenURL(HelpURL);
        return true;
    }
    else if( Left(Msg, 10) ~= "tossmoney " || Left(Msg, 3) ~= "tm " )
    {
        Msg = Repl(Msg, "tm", "tossmoney");
        CRI.ExecuteCommand(Msg);
        return true;
    }
    else if( Msg ~= "fav" || Msg ~= "favorite" )
    {
        CRI.AddServerToFavorites();
        return true;
    }
    else if( Msg ~= "dp" )
    {
        CRI.UKFPInteraction.bDropProtection = !CRI.UKFPInteraction.bDropProtection;
        CRI.WriteToChat(CRI.UKFPInteraction.bDropProtection ? "Players can no longer pickup your weapons!" : "Players can pickup your weapons again!", CRI.UKFPInteraction.bDropProtection ? "00FF00" : "FF0000");
        CRI.UKFPInteraction.SaveConfig();
        CRI.ServerSetDropProtection(CRI.UKFPInteraction.bDropProtection);
        return true;
    }
    
    return false;
}

final function PlayerChangeSpec( KFPlayerController PC, bool bSpectator )
{
    local ReplicationHelper CRI;
    
    CRI = GetPlayerChat(PC.PlayerReplicationInfo);
    if( CRI == None )
        return;
        
	if( bSpectator==PC.PlayerReplicationInfo.bOnlySpectator || CRI.NextSpectateChange>WorldInfo.TimeSeconds )
    {
        WriteToClient(PC, "Can't change spectate mode."@((bSpectator==PC.PlayerReplicationInfo.bOnlySpectator) ? "Already a spectator!" : "You must wait before trying to change again!"), "FF0000");
		return;
    }
        
	CRI.NextSpectateChange = WorldInfo.TimeSeconds+0.5;

	if( WorldInfo.Game.bGameEnded )
		WriteToClient(PC, "Can't change spectate mode after end-game.", "FF0000");
	else if( WorldInfo.Game.bWaitingToStartMatch )
		WriteToClient(PC, "Can't change spectate mode before game has started.", "FF0000");
	else if( WorldInfo.Game.AtCapacity(bSpectator,PC.PlayerReplicationInfo.UniqueId) )
		WriteToClient(PC, "Can't change spectate mode because game is at its maximum capacity.", "FF0000");
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
        if( MyKFGI.bWaitingToStartMatch )
        {
            CRI.ForceCloseMenus(true);
            CRI.ForceLobbySpectate();
        }
        else PC.StartSpectate();
        if( PlayersDiedThisWave.Find(PC) == INDEX_NONE )
            PlayersDiedThisWave.AddItem(PC);
	}
	else
	{
		PC.PlayerReplicationInfo.bOnlySpectator = false;
		if( !WorldInfo.Game.ChangeTeam(PC,WorldInfo.Game.PickTeam(0,PC,PC.PlayerReplicationInfo.UniqueId),false) )
		{
			PC.PlayerReplicationInfo.bOnlySpectator = true;
			WriteToClient(PC, "Can't become an active player, failed to set a team.", "FF0000");
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
        
        CRI.ForceUpdateSharedContent();
	}
}

function NotifyLogin(Controller NewPlayer)
{
    local ReplicationHelper CRI;
    local KFPlayerController PC;
    
    PC = KFPlayerController(NewPlayer);
    if( PC != None )
    {
        `Log("Player"@PC.PlayerReplicationInfo.PlayerName@"("$`ConvertUIDToSteamID(PC.PlayerReplicationInfo.UniqueId)$") has entered the server!",, 'Join Log');
        
        if( VotingHandler != None )
            VotingHandler.NotifyLogin(PC);
        
        CRI = Spawn(class'ReplicationHelper', PC);
        CRI.ClientSpawnFunctionProxy();
        CRI.ClientSetMaxPlayers(RepMaxPlayers);
        if( KFGameInfo_WeeklySurvival(MyKFGI) != None )
            CRI.ClientSetWeeklyIndex(KFGameInfo_WeeklySurvival(MyKFGI).ActiveEventIdx);
        CRI.KFPC = PC;
        CRI.PRI = PC.PlayerReplicationInfo;
        CRI.MainRepInfo = self;
        ChatArray.AddItem(CRI);

        if( CurrentSeasonalIndex > 0 )
        {
            if( WorldInfo.NetMode == NM_StandAlone )
            {
                if( FunctionProxy.IsReadSuccessful(PC) )
                {
                    FunctionProxy.CheckSpecialEventID(PC);
                    PC.UpdateSeasonalState();
                }
                else SetTimer(0.01f, true, 'WaitForStatsRead');
            }
            
            CRI.SeasonalObjectiveStats = Spawn(class'SeasonalObjectiveStats', PC);
            CRI.SeasonalObjectiveStats.LoadObjectiveData(CurrentSeasonalIndex-1);
            CRI.bForceNetUpdate = true;
        }
            
        PC.bShortConnectTimeOut = true;
    }
    
	if( NetDriver != None && MyKFGI.bWaitingToStartMatch && NetDriver.NetServerLobbyTickRate == NetDriver.default.NetServerLobbyTickRate )
		NetDriver.NetServerLobbyTickRate = NetDriver.default.NetServerMaxTickRate;
}

function NotifyLogout(Controller Exiting)
{
    local KFPlayerController PC;
    local ReplicationHelper CRI;
    
    PC = KFPlayerController(Exiting);
    if( PC != None )
    {
        CRI = GetPlayerChat(PC.PlayerReplicationInfo);
        if( CRI != None )
        {
            ChatArray.RemoveItem(CRI);
            CRI.Destroy();
        }
    
        if( VotingHandler != None )
            VotingHandler.NotifyLogout(PC);
            
        `Log("Player"@PC.PlayerReplicationInfo.PlayerName@"("$`ConvertUIDToSteamID(PC.PlayerReplicationInfo.UniqueId)$") has left the server!",, 'Join Log');
    }
    
	if( NetDriver != None && MyKFGI.NumPlayers <= 0 && NetDriver.NetServerLobbyTickRate == NetDriver.default.NetServerMaxTickRate && MyKFGI.bWaitingToStartMatch )
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
}

final function NotifyPlayerDied(KFPawn_Human P, KFPlayerController PC, Controller Killer, class<DamageType> DamageType)
{
    if( PC != None && (KFAIController(Killer) != None || class<DmgType_Suicided>(DamageType) == None) )
        PlayersDiedThisWave.AddItem(PC);
}

final simulated function ReplicationHelper GetPlayerChat(PlayerReplicationInfo PRI)
{
    local int i;
    
    if( Role < ROLE_Authority )
        return `GetChatRep();
    
    for( i=0; i<ChatArray.Length; i++ )
    {
        if( ChatArray[i].PRI == PRI )
            return ChatArray[i];
    }
    
    return None;
}

final function WriteToClient(Controller C, string Message, optional string HexColor="0099FF")
{
    local int i;
    
    for( i=0; i<ChatArray.Length; i++ )
    {
        if( ChatArray[i].KFPC == C )
        {
            ChatArray[i].WriteLargeStringToChat(Message, HexColor);
            break;
        }
    }
}

final function Broadcast(string Message, optional string HexColor="0099FF")
{
    local int i;
    
    for( i=0; i<ChatArray.Length; i++ )
    {
        if( ChatArray[i].KFPC != None )
            ChatArray[i].WriteLargeStringToChat(Message, HexColor);
    }
}

final function NotifyMatchStarted()
{
	if( NetDriver != None && NetDriver.NetServerLobbyTickRate != NetDriver.default.NetServerLobbyTickRate )
	{
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
		NetDriver.SaveConfig();
	}
}

final simulated function LoadAllWeaponAssets(KFWeapon W)
{
    local int i;
    local SkeletalMesh SM;
    local array<AnimSet> AS;
    local AnimTree AT;
    local StaticMesh DPM;
    local KFWeaponAttachment KFWA;
    local KFMuzzleFlash KFMF;
    local SkeletalMeshComponent MyMesh;
    
    MyMesh = SkeletalMeshComponent(W.Mesh);
    if( MyMesh == None )
        return;
    
    if( W.FirstPersonMeshName != "" )
    {
        SM = SkeletalMesh(SafeLoadObject(W.FirstPersonMeshName, class'SkeletalMesh'));
        if( SM != None )
            MyMesh.SetSkeletalMesh(SM);
    }
        
    if( W.FirstPersonAnimSetNames.Length > 0 )
    {
        AS.Length = W.FirstPersonAnimSetNames.Length;
        for( i=0; i<W.FirstPersonAnimSetNames.Length; i++ )
        {
            if( W.FirstPersonAnimSetNames[i] != "" )
                AS[i] = AnimSet(SafeLoadObject(W.FirstPersonAnimSetNames[i], class'AnimSet'));
        }
        MyMesh.AnimSets = AS;
    }
    
    if( W.FirstPersonAnimTree != "" )
    {
        AT = AnimTree(SafeLoadObject(W.FirstPersonAnimTree, class'AnimTree'));
        if( AT != None )
            MyMesh.SetAnimTreeTemplate(AT);
    }

    if( W.PickupMeshName != "" )
    {
        DPM = StaticMesh(SafeLoadObject(W.PickupMeshName, class'StaticMesh'));
        if( DPM != None )
            StaticMeshComponent(W.DroppedPickupMesh).SetStaticMesh(DPM);
    }
    
    if( W.AttachmentArchetypeName != "" )
    {
        KFWA = KFWeaponAttachment(SafeLoadObject(W.AttachmentArchetypeName, class'KFWeaponAttachment'));
        if( KFWA != None )
            W.AttachmentArchetype = KFWA;
    }
        
    if( W.MuzzleFlashTemplateName != "" )
    {
        KFMF = KFMuzzleFlash(SafeLoadObject(W.MuzzleFlashTemplateName, class'KFMuzzleFlash'));
        if( KFMF != None )
            W.MuzzleFlashTemplate = KFMF;
    }

    W.WeaponContentLoaded = true;
    W.InitializeEquipTime();
}

final simulated static function StaticLoadWeaponAssets(class<KFWeapon> WeaponClass)
{
    local int i, Index;
    local SkeletalMesh SM;
    local array<AnimSet> AS;
    local AnimTree AT;
    local StaticMesh DPM;
    local KFWeaponAttachment KFWA;
    local SkeletalMeshComponent MyMesh;
    local KFMuzzleFlash KFMF;

    MyMesh = SkeletalMeshComponent(WeaponClass.default.Mesh);
    
    if( WeaponClass.default.FirstPersonMeshName != "" )
    {
        SM = SkeletalMesh(SafeLoadObject(WeaponClass.default.FirstPersonMeshName, class'SkeletalMesh'));
        if( SM != None && MyMesh != None )
            MyMesh.SetSkeletalMesh(SM);
    }
        
    if( MyMesh != None && WeaponClass.default.FirstPersonAnimSetNames.Length > 0 )
    {
        AS.Length = WeaponClass.default.FirstPersonAnimSetNames.Length;
        for( i=0; i<WeaponClass.default.FirstPersonAnimSetNames.Length; i++ )
        {
            if( WeaponClass.default.FirstPersonAnimSetNames[i] != "" )
                AS[i] = AnimSet(SafeLoadObject(WeaponClass.default.FirstPersonAnimSetNames[i], class'AnimSet'));
        }
        MyMesh.AnimSets = AS;
    }
    
    if( WeaponClass.default.FirstPersonAnimTree != "" )
    {
        AT = AnimTree(SafeLoadObject(WeaponClass.default.FirstPersonAnimTree, class'AnimTree'));
        if( AT != None && MyMesh != None )
            MyMesh.SetAnimTreeTemplate(AT);
    }
        
    if( WeaponClass.default.PickupMeshName != "" )
    {
        DPM = StaticMesh(SafeLoadObject(WeaponClass.default.PickupMeshName, class'StaticMesh'));
        if( DPM != None )
            StaticMeshComponent(WeaponClass.default.DroppedPickupMesh).SetStaticMesh(DPM);
    }
    
    if( WeaponClass.default.AttachmentArchetypeName != "" )
    {
        KFWA = KFWeaponAttachment(SafeLoadObject(WeaponClass.default.AttachmentArchetypeName, class'KFWeaponAttachment'));
        if( KFWA != None )
            WeaponClass.default.AttachmentArchetype = KFWA;
    }
    
    if( WeaponClass.default.MuzzleFlashTemplateName != "" )
    {
        KFMF = KFMuzzleFlash(SafeLoadObject(WeaponClass.default.MuzzleFlashTemplateName, class'KFMuzzleFlash'));
        if( KFMF != None )
            WeaponClass.default.MuzzleFlashTemplate = KFMF;
    }
    
    Index = default.LoadedWeaponClasses.Find(WeaponClass);
    if( Index != INDEX_NONE )
        default.LoadedWeaponClasses.AddItem(WeaponClass);
}

final simulated function array<MaterialInterface> LoadWeaponSkin(int ItemId, EWeaponSkinType Type)
{
    local array<string> SkinList;
    local int i, Index, TypeIndex;
    local FSkinCache Info;
    local FTypeSkinCache SkinInfo;

    Index = WeaponSkinCache.Find('ItemId', ItemId);
    if( Index != INDEX_NONE )
    {
        TypeIndex = WeaponSkinCache[Index].Items.Find('Type', Type);
        if( TypeIndex != INDEX_NONE )
            return WeaponSkinCache[Index].Items[TypeIndex].Skins;
        else
        {
            SkinInfo.Type = Type;
            TypeIndex = WeaponSkinCache[Index].Items.AddItem(SkinInfo);
        }
    }
    else
    {
        Info.ItemId = ItemId;
        Index = WeaponSkinCache.AddItem(Info);
        SkinInfo.Type = Type;
        TypeIndex = WeaponSkinCache[Index].Items.AddItem(SkinInfo);
    }
    
    SkinList = class'KFWeaponSkinList'.static.GetWeaponSkinPaths(ItemId, Type);
    for( i=0; i<SkinList.Length; i++ )
        WeaponSkinCache[Index].Items[TypeIndex].Skins.AddItem(MaterialInterface(SafeLoadObject(SkinList[i], class'MaterialInterface')));
        
    return WeaponSkinCache[Index].Items[TypeIndex].Skins;
}

static final function Object SafeLoadObject( string S, Class ObjClass )
{
    local Object O;
    
    O = FindObject(S,ObjClass);
    return O!=None ? O : DynamicLoadObject(S,ObjClass);
}

final simulated function PlayEmoteAnimation(KFPawn_Human P)
{
	local name AnimName;

	if( bPlayingEmote || P == None )
		return;

	AnimName = class'KFEmoteList'.static.GetUnlockedEmote( class'KFEmoteList'.static.GetEquippedEmoteId() );

	P.BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( FALSE );

	P.BodyStanceNodes[EAS_FullBody].PlayCustomAnim(AnimName, 1.f, 0.4f, 0.4f, false, true);
	P.BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( TRUE );
    
    P.SetWeaponAttachmentVisibility(false);
    bPlayingEmote = true;
}

final simulated function PawnAnimEnd(KFPawn P, AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
    if( P != None && bPlayingEmote )
    {
        P.SetWeaponAttachmentVisibility(true);
        bPlayingEmote = false;
    }
}

final simulated function PreClientTravel(KFPlayerController PC, string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel)
{
    if( WorldInfo.NetMode == NM_DedicatedServer )
        return;
        
    if( !bHandledTravel )
    {
        bHandledTravel = true;
        SetTimer(0.5f,false,'PendingMapSwitch');
        TravelMapName = StripOptionsFromURL(PendingURL);
    }
}

final static function string StripOptionsFromURL( string URL )
{
    local int Index;
    
    Index = InStr(URL, "?");
    if( Index != INDEX_NONE )
        return Left(URL, Index);
        
	return URL;
}

final simulated function PendingMapSwitch()
{
    local string URL;
    local array<string> S;
    
    if( WorldInfo.NetMode == NM_DedicatedServer )
        return;

    URL = WorldInfo.GetAddressURL();
    S = SplitString(URL, ":");
    
    GetALocalPlayerController().ConsoleCommand("Open KFMainMenu?Game=UnofficialKFPatch_LevelTransition.MS_Game?MapName="$TravelMapName$"?SpectatorInfo="$(GetALocalPlayerController().PlayerReplicationInfo.bOnlySpectator ? "1" : "0")$"?URL="$S[0]$"?Port="$S[1]$"?bServerHidden="$(bServerIsHidden ? 1 : 0));
}

final simulated function KFCharacterInfoBase GetSeasonalCharacterArch(class<KFPawn_Monster> Monster)
{
    local SeasonalMonsterArchs ZEDArch;
    local string ToLoad;
    local KFCharacterInfoBase LoadedInfo;
    local PrecachedArch PrecacheInfo;
    local int Index;
    
    foreach default.ZEDArchList(ZEDArch)
    {
        if( ClassIsChildOf(Monster, ZEDArch.MonsterClass) )
        {
            if( bNoEventSkins || bServerEnforceVanilla )
                ToLoad = ZEDArch.Regular;
            else
            {
                switch( class'KFGameEngine'.static.GetSeasonalEventID() % 10 )
                {
                    case SEI_Summer:
                        ToLoad = ZEDArch.Summer;
                        break;
                    case SEI_Winter:
                        ToLoad = ZEDArch.Winter;
                        break;
                    case SEI_Fall:
                        ToLoad = ZEDArch.Fall;
                        break;
                    case SEI_Spring:
                        ToLoad = ZEDArch.Spring;
                        break;
                    default:
                        ToLoad = ZEDArch.Regular;
                        break;
                }
                
                if( ToLoad == "" )
                    ToLoad = ZEDArch.Regular;
            }
            
            break;
        }
    }
    
    Index = PrecachedArchs.Find('ArchPath', ToLoad);
    if( Index != INDEX_NONE )
        return PrecachedArchs[Index].Arch;

    LoadedInfo = KFCharacterInfoBase(SafeLoadObject(ToLoad, class'KFCharacterInfoBase'));
    if( LoadedInfo != None )
    {
        PrecacheInfo.ArchPath = ToLoad;
        PrecacheInfo.Arch = LoadedInfo;
        PrecachedArchs.AddItem(PrecacheInfo);
    }

    return LoadedInfo;
}

final function ScoreKill(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
    local ReplicationHelper CRI;
    local KFPawn_Monster P;
    
    if( Killed == None || Killer == None )
        return;

    if( Killer.bIsPlayer )
    {
        P = KFPawn_Monster(Killed.Pawn);
        if( P != None && P.MyKFAIC != None && P.MyKFAIC.GetTeamNum()!=0 && (P.bLargeZed || KFInterface_MonsterBoss(P) != None) )
        {
            foreach ChatArray(CRI)
                CRI.ReceiveKillMessage(P.Class,true,Killer.PlayerReplicationInfo,class<KFDamageType>(damageType));
        }
    }
}

final function int GetEffectivePlayerCount(byte NumLivingPlayers)
{
    return 0 < CurrentFakePlayers ? byte(Max(CurrentFakePlayers, NumLivingPlayers)) : NumLivingPlayers;
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

final function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup)
{
    local string WeaponName, SteamID, OwnerName, S;
    local int SellPrice, Index, i;
    local byte ItemIndex;
    local KFGameReplicationInfo GRI;
    local class<KFWeapon> Weapon;
    local class<KFWeaponDefinition> WeaponDef;
    local KFInventoryManager InvMan;
    local ReplicationHelper CRI;
    local STraderItem Item;
    local KFDroppedPickup Drop;
    local PlayerReplicationInfo PRI;
	local array<KFPlayerReplicationInfo> KFPRIArray;

    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( GRI == None )
        return false;
    
    Drop = KFDroppedPickup(Pickup);
    if( Drop == None || Drop.Instigator == Other || KFDroppedPickup_Cash(Drop) != None )
        return false;
    
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
        return false;
    
    CRI = GetPlayerChat(PRI);
    if( CRI != None && CRI.bDropProtection && class<KFCarryableObject>(ItemClass) == None )
    {
        bAllowPickup = 0;
        return true;
    }
    
    if( !bToBroadcastPickups || !Other.InvManager.HandlePickupQuery(ItemClass, Pickup) )
        return false;

    Weapon = class<KFWeapon>(ItemClass);
    if( Weapon == None )
        return false;
    
    if( GRI.TraderItems.GetItemIndicesFromArche(ItemIndex, Weapon.Name) )
    {
        WeaponDef = GRI.TraderItems.SaleItems[ItemIndex].WeaponDef;
        Item = GRI.TraderItems.SaleItems[ItemIndex];
    }
    else return false;
        
    if( WeaponDef == None )
        return false;
        
    InvMan = KFInventoryManager( Other.InvManager );
    if( InvMan == None || !InvMan.CanCarryWeapon(Weapon, KFWeapon(Drop.Inventory).CurrentWeaponUpgradeIndex) )
        return false;
        
    WeaponName = WeaponDef.static.GetItemName();
    SellPrice = InvMan.GetAdjustedSellPriceFor(Item);

    S = "<font color=\"#FFFF00\" face=\"MIcon\">"$`GetMIconChar("alert-box")@"</font> %p picked up %o's %w("$Chr(208)$"%$).";
    S = Repl(S, "%p", "<font color=\"#C00101\">"$Other.PlayerReplicationInfo.PlayerName)$"</font>";
    S = Repl(S, "%o", "<font color=\"#01C001\">"$OwnerName)$"</font>";
    S = Repl(S, "%w", "<font color=\"#0160C0\">"$WeaponName)$"</font>";
    S = Repl(S, "%$", "<font color=\"#C0C001\">"$SellPrice)$"</font>";
    Broadcast(S, "FFFF00");
    
    return false;
}

final simulated function class<KFPerk> GetPerkTypeCastFromClass( class<KFPerk> InPerkClass )
{
    local int i;
    local KFPlayerController PC;
    
    foreach WorldInfo.AllControllers( class'KFPlayerController', PC )
        break;
        
    if( PC == None )
        return InPerkClass;
    
    for( i=0; i<PC.PerkList.Length; i++ )
    {
        if( ClassIsChildOf(PC.PerkList[i].PerkClass, InPerkClass) )
            return PC.PerkList[i].PerkClass;
    }
    
	return InPerkClass;
}

final function AddLoadPackage( Object O )
{
    if( ExternalObjs.Find(O)==-1 )
        ExternalObjs.AddItem(O);
}

final function PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string OutError, bool bSpectator)
{
    Broadcast("<font color=\"#438DFF\" face=\"MIcon\">"$`GetMIconChar("account-network")$"</font> <font color=\"#FFFFFF\" face=\"MIcon\">"$(Len(OnlineSub.UniqueNetIdToInt64(UniqueId)) == 17 ? `GetMIconChar("steam") : `GetMIconChar("google-controller"))$"</font> <font color=\"#0099FF\">"$WorldInfo.Game.ParseOption( Options, "Name" )@"is connecting</font>.");
}

final function string ConvertMapName(string MapName)
{
    local int i;
    
    for( i=0; i<MapNameOverrides.Length; i++ )
    {
        if( MapNameOverrides[i].Original ~= MapName )
        {
            MapName = Caps(MapNameOverrides[i].New);
            break;
        }
    }
    
    return Caps(MapName);
}

final function bool ShouldMapBeIgnored()
{
    return IgnoreDecentMaps.Find(CurrentMapName) != INDEX_NONE;
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
    local KFGameInfo_Endless KFGIE;
    
    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    KFGIE = KFGameInfo_Endless(MyKFGI);
    
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
    local int i;
    
    PlayersDiedThisWaveOld = PlayersDiedThisWave;
    PlayersDiedThisWave.Length = 0;
    
    ForceUpdateEndlessDecent();
    
    if( CurrentSeasonalIndex > 0 )
    {
        for( i=0; i<ChatArray.Length; i++ )
        {
            if( ChatArray[i].SeasonalObjectiveStats != None )
                ChatArray[i].SeasonalObjectiveStats.SaveObjectiveData();
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

final simulated function GetYearAndMonthFromEvent(out int Year, out int Month)
{
    switch( CurrentForcedSeasonalEventDate )
    {
        case SET_Fall2018:
            Month = 10;
            Year = 2018;
            break;
        case SET_Xmas2018:
            Month = 12;
            Year = 2018;
            break;
        case SET_Xmas2019:
            Month = 12;
            Year = 2019;
            break;
        case SET_Xmas2020:
            Month = 12;
            Year = 2020;
            break;
        case SET_Xmas2021:
            Month = 12;
            Year = 2021;
            break;
        case SET_Spring2019:
            Month = 3;
            Year = 2019;
            break;
        case SET_Spring2020:
            Month = 3;
            Year = 2020;
            break;
        case SET_Spring2021:
            Month = 3;
            Year = 2021;
            break;
        case SET_Summer2019:
            Month = 7;
            Year = 2019;
            break;
        case SET_Summer2020:
            Month = 7;
            Year = 2020;
            break;
        case SET_Summer2021:
            Month = 7;
            Year = 2021;
            break;
        case SET_Summer2022:
            Month = 7;
            Year = 2022;
            break; 
        case SET_Fall2019:
            Month = 10;
            Year = 2019;
            break;
        case SET_Fall2020:
            Month = 10;
            Year = 2020;
            break;
        case SET_Fall2021:
            Month = 10;
            Year = 2021;
            break;
        case SET_Fall2022:
            Month = 10;
            Year = 2022;
            break;
    }
}

final function NotifyServerTravel(bool bSeamless)
{
    local int i;
    
    if( CurrentSeasonalIndex > 0 )
    {
        for( i=0; i<ChatArray.Length; i++ )
        {
            if( ChatArray[i].SeasonalObjectiveStats != None )
                ChatArray[i].SeasonalObjectiveStats.SaveObjectiveData();
        }
    }
}

final simulated function WaitForStatsRead()
{
    local KFPlayerController KFPC;
    
    KFPC = KFPlayerController(GetALocalPlayerController());
    if( FunctionProxy.IsReadSuccessful(KFPC) )
    {
        FunctionProxy.CheckSpecialEventID(KFPC);
        KFPC.UpdateSeasonalState();
        ClearTimer('WaitForStatsRead');
    }
}

final simulated function bool GetEnforceVanilla()
{
    return bServerEnforceVanilla;
}

final function RemoveCustomStatus()
{
    MyKFGI.bIsCustomGame = false;
    MyKFGI.UpdateGameSettings();
}

defaultproperties
{
	bAlwaysTick=true
	bTickIsDisabled=false
    
    NetUpdateFrequency=8
    
    IgnoreDecentMaps.Add("KF-Elysium")
    
    MapNameOverrides.Add((Original="KF-DesolationOriginal",New="KF-Desolation"))
    MapNameOverrides.Add((Original="KF-Nuked-Beta",New="KF-Nuked"))
    MapNameOverrides.Add((Original="KF-ShoppingSpreeOriginal",New="KF-ShoppingSpree"))
    MapNameOverrides.Add((Original="KF-Sanitarium-classic",New="KF-Sanitarium"))
    MapNameOverrides.Add((Original="KF-Rig_zfix",New="KF-Rig"))
    MapNameOverrides.Add((Original="KF-CarillonHamletB1",New="KF-CarillonHamlet"))
    
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedBloatKingSubSpawn', Regular="ZED_ARCH.ZED_KingBloatSubSpawn_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_AlphaKing', Regular="ZED_ARCH.ZED_Clot_AlphaKing_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Clot_AlphaKing_Archetype", Winter="XMAS_ZED_ARCH.ZED_Clot_AlphaKing_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Clot_AlphaKing_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedCrawlerKing', Regular="ZED_ARCH.ZED_CrawlerKing_Archetype", Summer="SUMMER_ZED_ARCH.ZED_CrawlerKing_Archetype", Winter="XMAS_ZED_ARCH.ZED_CrawlerKing_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_CrawlerKing_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedFleshpoundMini', Regular="ZED_ARCH.ZED_FleshpoundMini_Archetype", Summer="SUMMER_ZED_ARCH.ZED_FleshpoundMini_Archetype", Winter="XMAS_ZED_ARCH.ZED_FleshpoundMini_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_FleshpoundMini_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedGorefastDualBlade', Regular="ZED_ARCH.ZED_Gorefast2_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Gorefast2_Archetype", Winter="XMAS_ZED_ARCH.ZED_Gorefast2_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Gorefast2_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedBloatKing', Regular="ZED_ARCH.ZED_BloatKing_Archetype", Summer="SUMMER_ZED_ARCH.ZED_BloatKing_Archetype", Winter="XMAS_ZED_ARCH.ZED_BloatKing_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_BloatKing_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedFleshpoundKing', Regular="ZED_ARCH.ZED_FleshpoundKing_Archetype", Summer="SUMMER_ZED_ARCH.ZED_FleshpoundKing_Archetype", Winter="XMAS_ZED_ARCH.ZED_FleshpoundKing_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_FleshpoundKing_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedDAR_EMP', Regular="ZED_ARCH.ZED_DAR_EMP_Archetype", Summer="SUMMER_ZED_ARCH.ZED_DAR_EMP_Archetype", Winter="XMAS_ZED_ARCH.ZED_DAR_EMP_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_DAR_EMP_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedDAR_Laser', Regular="ZED_ARCH.ZED_DAR_Laser_Archetype", Summer="SUMMER_ZED_ARCH.ZED_DAR_Laser_Archetype", Winter="XMAS_ZED_ARCH.ZED_DAR_Laser_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_DAR_Laser_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedDAR_Rocket', Regular="ZED_ARCH.ZED_DAR_Rocket_Archetype", Summer="SUMMER_ZED_ARCH.ZED_DAR_Rocket_Archetype", Winter="XMAS_ZED_ARCH.ZED_DAR_Rocket_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_DAR_Rocket_Archetype"))
    
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedBloat', Regular="ZED_ARCH.ZED_Bloat_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Bloat_Archetype", Winter="XMAS_ZED_ARCH.ZED_Bloat_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Bloat_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_Cyst', Regular="ZED_ARCH.ZED_Clot_Undev_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Clot_Undev_Archetype", Winter="XMAS_ZED_ARCH.ZED_Clot_Undev_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Clot_Undev_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_Alpha', Regular="ZED_ARCH.ZED_Clot_Alpha_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Clot_Slasher_Archetype", Winter="XMAS_ZED_ARCH.ZED_Clot_Alpha_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Clot_Alpha_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedClot_Slasher', Regular="ZED_ARCH.ZED_Clot_Slasher_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Clot_Slasher_Archetype", Winter="XMAS_ZED_ARCH.ZED_Clot_Slasher_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Clot_Slasher_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedCrawler', Regular="ZED_ARCH.ZED_Crawler_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Crawler_Archetype", Winter="XMAS_ZED_ARCH.ZED_Crawler_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Crawler_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedFleshpound', Regular="ZED_ARCH.ZED_Fleshpound_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Fleshpound_Archetype", Winter="XMAS_ZED_ARCH.ZED_Fleshpound_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Fleshpound_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedGorefast', Regular="ZED_ARCH.ZED_Gorefast_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Gorefast_Archetype", Winter="XMAS_ZED_ARCH.ZED_Gorefast_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Gorefast_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedHusk', Regular="ZED_ARCH.ZED_Husk_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Husk_Archetype", Winter="XMAS_ZED_ARCH.ZED_Husk_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Husk_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedPatriarch', Regular="ZED_ARCH.ZED_Patriarch_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Patriarch_Archetype", Winter="XMAS_ZED_ARCH.ZED_Patriarch_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Patriarch_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedHans', Regular="ZED_ARCH.ZED_Hans_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Hans_Archetype", Winter="XMAS_ZED_ARCH.ZED_Hans_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Hans_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedMatriarch', Regular="ZED_ARCH.ZED_Matriarch_Archetype", Winter="XMAS_ZED_ARCH.ZED_Matriarch_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Matriarch_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedScrake', Regular="ZED_ARCH.ZED_Scrake_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Scrake_Archetype", Winter="XMAS_ZED_ARCH.ZED_Scrake_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Scrake_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedSiren', Regular="ZED_ARCH.ZED_Siren_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Siren_Archetype", Winter="XMAS_ZED_ARCH.ZED_Siren_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Siren_Archetype"))
    ZEDArchList.Add((MonsterClass=class'KFPawn_ZedStalker', Regular="ZED_ARCH.ZED_Stalker_Archetype", Summer="SUMMER_ZED_ARCH.ZED_Stalker_Archetype", Winter="XMAS_ZED_ARCH.ZED_Stalker_Archetype", Fall="HALLOWEEN_ZED_ARCH.ZED_Stalker_Archetype"))

    WeaponExploitFix.Add(class'KFGameContent.KFWeap_HRG_Vampire')
    WeaponExploitFix.Add(class'KFGameContent.KFWeap_HRG_BlastBrawlers')
    WeaponExploitFix.Add(class'KFGameContent.KFWeap_Blunt_MedicBat')
    WeaponExploitFix.Add(class'KFGameContent.KFWeap_AssaultRifle_LazerCutter')
}