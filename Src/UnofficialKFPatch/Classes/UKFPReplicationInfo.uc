class UKFPReplicationInfo extends ReplicationInfo
    config(UnofficialPatch);

const HelpURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=2875577642";
const MaxLocalizedMOTDStrings = 39;

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
    OUTBREAK_PERKROULETTE,
    OUTBREAK_CONTAMINATIONZONE,
    OUTBREAK_BOUNTYHUNT
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
    SET_Summer2023,
    SET_Fall2022,
    SET_Fall2023,
    SET_Xmas2022
} ForcedSeasonalEventDate;
var repnotify ESeasonalEventType CurrentForcedSeasonalEventDate;
var int InitialSeasonalEventDate;

var transient bool bCleanedUp;
var transient KFGameInfo_Survival MyKFGI;
var transient KFGameReplicationInfo KFGRI;
var transient KFGameInfo_Endless KFGIE;
var transient KFGameReplicationInfo_Endless KFGRIE;
var transient OnlineSubsystemSteamworks OnlineSub;
var transient array<ReplicationHelper> ChatArray;
var transient float CurrentDoshKillMultiplier, CurrentSpawnRateMultiplier, CurrentWaveCountMultiplier, CurrentAmmoCostMultiplier;
var transient int CurrentPickupLifespan, CurrentStickyProjectileLifespan, CurrentDoshPickupLifespan;
var const private transient float XPMultiplier;
var transient byte CurrentMaxMonsters, CurrentFakePlayers, SavedWaveNum, CurrentSeasonalIndex, CurrentMaxDoshSpamAmount;
var transient string TravelMapName, CurrentMapName;
var transient TcpNetDriver NetDriver;
var transient WorkshopTool WorkshopTool;
var transient array<KFPlayerController> PlayersDiedThisWave, PlayersDiedThisWaveOld;
var transient xVotingHandler VotingHandler;
var transient KFGFxObject_TraderItems OriginalTraderItems;
var transient int LastHitHP;
var transient KFPawn_Monster LastHitZed;
var transient ReplicationHelper LastDamageDealer;
var transient vector LastDamagePosition;
var transient class<KFDamageType> LastDamageDMGType;

var array<string> IgnoreDecentMaps;

struct FAchCollectibleOverride
{
    var string Map;
    var int ID;
};
var array<FAchCollectibleOverride> CollectibleAchIDForMap;

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

var config int PickupLifespan, StickyProjectileLifespan, DoshPickupLifespan, CurrentNetDriverIndex, iConfigVersion;
var config byte ForcedMaxPlayers, MaxMonsters, FakePlayers, MaxDoshSpamAmount;
var config float PingSpamTime, DoshKillMultiplier, SpawnRateMultiplier, WaveCountMultiplier, AmmoCostMultiplier;

var config string AllowedBosses, AllowedOutbreaks, AllowedSpecialWaves, AllowedPerks;
var transient string CurrentAllowedBosses, CurrentAllowedOutbreaks, CurrentAllowedSpecialWaves, CurrentAllowedPerks;
var string DefaultAllowedOutbreaks, DefaultAllowedSpecialWaves;

var config bool bAllowOpenTraderCommand, bDisableZEDTime, bDisableMapRanking, bDisableTraderLocking, bDisableCustomLoadingScreen, bAllowDamagePopups, bUseEnhancedTraderMenu, bEnforceVanilla, bUseNormalSummerSCAnims, bAllowGamemodeVotes, bAttemptToLoadFHUD, bAttemptToLoadFHUDExt, bAttemptToLoadYAS, bAttemptToLoadAAL, bAttemptToLoadCVC, bAttemptToLoadLTI, bServerHidden, bNoEventZEDSkins, bNoEDARSpawns, bNoQPSpawns, bNoGasCrawlers, bNoRageSpawns, bNoGorefiends, bNoRioters, bNoPingsAllowed, bBroadcastPickups, bUseDynamicMOTD, bDisableTP, bDisallowHandChanges, bDropAllWepsOnDeath, bDisableGameConductor, bDisableCrossPerk, bDisableWeaponUpgrades, bDisableTraderDLCLocking, bDisablePickupSkinSystem;
var transient bool bShouldUseDynamicMOTD, bUpdatedMOTD, bUsingOpenTraderCommand, bHasDisabledZEDTime, bHasDisabledRanking, bShouldDisableTraderLocking, bShouldDisableCustomLoadingScreen, LastHeadshot, bShouldAllowDamagePopups, bShouldUseEnhancedTraderMenu, bLTILoaded, CurrentNormalSummerSCAnims, bForceResetInterpActors, bDisallowHandSwap, bPlayingEmote, bHandledTravel, bServerIsHidden, bNoPings, bToBroadcastPickups, bServerDisableTP, bForceDisableEDARs, bForceDisableQPs, bForceDisableGasCrawlers, bForceDisableRageSpawns, bServerDropAllWepsOnDeath, bBypassGameConductor, bShouldDisableCrossPerk, bShouldDisableUpgrades, bShouldDisableTraderDLCLocking, bShouldDisablePickupSkinSystem, bForceDisableGorefiends, bForceDisableRioters;
var transient repnotify bool bNoEventSkins, bServerEnforceVanilla;
var transient byte RepMaxPlayers;

struct MapSeasonalInfo
{
    var string MapName, Type;

    structdefaultproperties
    {
        Type="None"
    }
};
var config array<MapSeasonalInfo> MapTypes;
var int ForcedSeasonalID;

var array< class<KFWeapon> > WeaponExploitFix;

var KFWeaponAttachment TommyGun3PAttachment;
var KFMuzzleFlash TommyGunMuzzleFlash;
var SkeletalMesh TommyGunFPMesh;
var array<StaticMesh> WeaponPickupMeshes;

struct FDynamicMOTDInfo
{
    var bool bYASLoaded, bAALLoaded, bCVCLoaded, bLTILoaded, bFHUDLoaded, bNoEventSkins, bNoPings, bToBroadcastPickups, bDisableTP, bDisallowHandSwap, bUseNormalSummerSCAnims, bEnforceVanilla, bDropAllWepsOnDeath, bNoEDARs, bNoQPSpawns, bNoGasCrawlers, bNoRageSpawns, bNoGorefiends, bNoRioters, bBypassGameConductor, bShouldUseEnhancedTraderMenu, bShouldDisableUpgrades, bShouldDisableCrossPerk, bShouldAllowDamagePopups, bHasDisabledZEDTime, bUsingOpenTraderCommand, bShouldDisableTraderDLCLocking;
    var byte CurrentMaxPlayers, CurrentMaxMonsters, CurrentFakePlayers, MaxDoshSpamAmount, BossData, OutbreakData, PerkData, SpecialWaveData;
    var int CurrentPickupLifespan, CurrentStickyProjectileLifespan, CurrentDoshPickupLifespan;
    var float CurrentDoshKillMultiplier, CurrentSpawnRateMultiplier, CurrentWaveCountMultiplier, CurrentAmmoCostMultiplier, XPMultiplier;
};
var FDynamicMOTDInfo DynamicMOTD;

struct FLocalizedMOTD
{
    var string Name, Extra;
};
var localized array<FLocalizedMOTD> LocalizedMOTD;
var localized string EnabledString, DisabledString;

replication
{
    if( bNetInitial )
        InitialWeeklyIndex, InitialSeasonalEventDate, CurrentForcedSeasonalEventDate, bServerEnforceVanilla, bServerDropAllWepsOnDeath, bLTILoaded, bShouldDisableUpgrades, bShouldDisableCrossPerk, bShouldDisableCustomLoadingScreen, bShouldDisableTraderLocking, bHasDisabledRanking, bShouldUseDynamicMOTD, bShouldDisableTraderDLCLocking, bShouldDisablePickupSkinSystem;
    if( true )
        KFGRI, KFGRIE, bServerIsHidden, bNoEventSkins, bNoPings, bServerDisableTP, CurrentMapName, bDisallowHandSwap, CurrentMaxDoshSpamAmount, ForcedSeasonalID;
}

simulated function ReplicatedEvent(name VarName)
{
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
            if( PC != None )
                PC.UpdateSeasonalState();
            break;
        default:
            Super.ReplicatedEvent(VarName);
            break;
    }
}

simulated function WaitForGRIData()
{
    ReplicatedEvent('DynamicMOTD');
}

simulated function PreBeginPlay()
{
    local int Index, i;
    local FAchCollectibleOverride AchID;
    local KFGameInfo_WeeklySurvival WeeklyGI;
    local KFWeaponAttachment Attachment;
    local KFMuzzleFlash MuzzleFlash;
    local string WSDownloader;
    local MapSeasonalInfo MapInfo;
    
    MuzzleFlash = new class'KFMuzzleFlash' (KFMuzzleFlash(DynamicLoadObject("WEP_TommyGun_ARCH.Wep_TommyGun_MuzzleFlash_3P", class'KFMuzzleFlash')));
    MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = ParticleSystem'UKFP_TommyGun_EMIT.FX_Wep_MuzzleFlash_TommyGun';
    
    Attachment = Spawn(class'KFWeaponAttachment', WorldInfo, 'Wep_TommyGun_3P',,, KFWeaponAttachment(DynamicLoadObject("WEP_TommyGun_ARCH.Wep_TommyGun_3P", class'KFWeaponAttachment')), true);
    Attachment.MuzzleFlashTemplate = MuzzleFlash;
    TommyGun3PAttachment = Attachment;
    default.TommyGun3PAttachment = TommyGun3PAttachment;
    
    MuzzleFlash = new class'KFMuzzleFlash' (KFMuzzleFlash(DynamicLoadObject("WEP_TommyGun_ARCH.Wep_TommyGun_MuzzleFlash", class'KFMuzzleFlash')));
    MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = ParticleSystem'UKFP_TommyGun_EMIT.FX_Wep_MuzzleFlash_TommyGun';
    
    TommyGunMuzzleFlash = MuzzleFlash;
    default.TommyGunMuzzleFlash = TommyGunMuzzleFlash;
    
    if( Role == ROLE_Authority )
    {
        AddLoadPackage(class<Object>(DynamicLoadObject("UnofficialKFPatch_LevelTransition.MS_Game", class'Class')));
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.AssetLib');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.MenuBarWidget_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.PerksMenu_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.PostGameMenu_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.TraderMenu_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.UKFP_InGameHUD_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.UKFP_InGameHUD_ZED_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.UKFP_PartyWidget_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.UKFP_TraderMenuV2_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.UKFP_VersusLobbyWidget_SWF');
        AddLoadPackage(SwfMovie'UKFP_UI_HUD.UKFP_ZedternalLobbyWidget_SWF');
    }
    
    if( iConfigVersion <= 0 )
    {
		PingSpamTime = 10;
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 1 )
    {
        DoshKillMultiplier = 1.f;
        SpawnRateMultiplier = 1.f;
        WaveCountMultiplier = 1.f;
        AmmoCostMultiplier = 1.f;
        AllowedOutbreaks = default.DefaultAllowedOutbreaks;
        AllowedSpecialWaves = default.DefaultAllowedSpecialWaves;
        AllowedPerks = "BZ,CO,SU,FM,DO,FB,GS,SS,SW,SV";
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 2 )
    {
        if( MapTypes.Find('MapName', "KF-KrampusLair") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-KrampusLair";
            MapInfo.Type = "XMas";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-TragicKingdom") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-TragicKingdom";
            MapInfo.Type = "Summer";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-Airship") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-Airship";
            MapInfo.Type = "Summer";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-SantasWorkshop") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-SantasWorkshop";
            MapInfo.Type = "XMas";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-SteamFortress") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-SteamFortress";
            MapInfo.Type = "Summer";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-MonsterBall") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-MonsterBall";
            MapInfo.Type = "Halloween";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-AshwoodAsylum") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-AshwoodAsylum";
            MapInfo.Type = "Halloween";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-Sanitarium") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-Sanitarium";
            MapInfo.Type = "Halloween";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-HellmarkStation") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-HellmarkStation";
            MapInfo.Type = "Halloween";
            MapTypes.AddItem(MapInfo);
        }
        
        if( MapTypes.Find('MapName', "KF-Elysium") == INDEX_NONE )
        {
            MapInfo.MapName = "KF-Elysium";
            MapInfo.Type = "Halloween";
            MapTypes.AddItem(MapInfo);
        }
        
        iConfigVersion++;
    }
	
	SaveConfig();
    
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
    KFGIE = KFGameInfo_Endless(MyKFGI);
    
    `Log("Loaded!",,'Unofficial KF2 Patch');

    Super.PreBeginPlay();
    
    default.StaticReference = self;
    UKFPReplicationInfo(`FindDefaultObject(class'UKFPReplicationInfo')).StaticReference = self;
    
    if( Role < ROLE_Authority && `GetChatRep() != None && `GetChatRep().FunctionProxy != None )
        FunctionProxy = `GetChatRep().FunctionProxy;
    else
    {
        FunctionProxy = New class<ProxyInfo>(SafeLoadObject("UnofficialKFPatch.FunctionProxy", Class'Class'));
        FunctionProxy.WorldInfo = WorldInfo;
        FunctionProxy.Init();
    }

    OnlineSub = OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem());
    
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
		
        WSDownloader = "OnlineSubsystemSteamworks.SteamWorkshopDownload";
        Index = NetDriver.DownloadManagers.Find(WSDownloader);
		if( Index == INDEX_NONE )
		{
            for( i=0; i<NetDriver.DownloadManagers.Length; i++ )
            {
                if( NetDriver.DownloadManagers[i] ~= "Engine.ChannelDownload" )
                {
                    NetDriver.DownloadManagers.InsertItem(i, WSDownloader);
                    break;
                }
            }
            
            Index = NetDriver.DownloadManagers.Find(WSDownloader);
            if( Index == INDEX_NONE )
                NetDriver.DownloadManagers.AddItem(WSDownloader);
                
			NetDriver.SaveConfig();
		}
        
        WorkshopTool = Spawn(class'WorkshopTool', self);
    }
}

simulated function CheckForMapFixes()
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

function CheckPrivateGameWorkshop(name SessionName,bool bWasSuccessful)
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

function DestroySuccess(name SessionName,bool bWasSuccessful)
{
    if( bWasSuccessful && SessionName == MyKFGI.PlayerReplicationInfoClass.default.SessionName )
    {
        `Log("Session succesfully hidden from master server.",,'Private Game');
        OnlineSub.GameInterface.ClearDestroyOnlineGameCompleteDelegate(DestroySuccess);
    }
}

function InitGameReplicationInfo(KFGameReplicationInfo GRI)
{
    KFGRI = GRI;
    KFGRIE = KFGameReplicationInfo_Endless(KFGRI);
    
    KFGRI.NetPriority = 2.f;
    KFGRI.GameAmmoCostScale = FMax(CurrentAmmoCostMultiplier, 1.f);
    
    if( bNoEventSkins || bServerEnforceVanilla )
    {
        MyKFGI.AllowSeasonalSkinsIndex = 1;
        GRI.NotifyAllowSeasonalSkins(1);
    }
    
    if( KFGameInfo_WeeklySurvival(MyKFGI) == None )
    {
        KFGRI.PerksAvailableData = GetAllowedPerkList();
        KFGRI.PerksAvailableData.bPerksAvailableLimited = KFGRI.PerksAvailableData.bBerserkerAvailable || KFGRI.PerksAvailableData.bCommandoAvailable || KFGRI.PerksAvailableData.bSupportAvailable || KFGRI.PerksAvailableData.bFieldMedicAvailable || KFGRI.PerksAvailableData.bDemolitionistAvailable || KFGRI.PerksAvailableData.bFirebugAvailable || KFGRI.PerksAvailableData.bFirebugAvailable || KFGRI.PerksAvailableData.bGunslingerAvailable || KFGRI.PerksAvailableData.bSharpshooterAvailable || KFGRI.PerksAvailableData.bSwatAvailable || KFGRI.PerksAvailableData.bSurvivalistAvailable;
    }
}

simulated function Tick(float DT)
{
    if( !bCleanedUp && WorldInfo.NextSwitchCountdown > 0.f && (WorldInfo.NextSwitchCountdown-(DT*4.f))<=0.f )
        Cleanup();
        
	Super.Tick(DT);
    
    if( bServerEnforceVanilla && WorldInfo.RBPhysicsGravityScaling != 1.f )
        WorldInfo.RBPhysicsGravityScaling = 1.f;
}

simulated function Cleanup()
{
    if( bCleanedUp )
        return;
      
    FunctionProxy.Cleanup();

    if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer )
    {
        NetDriver = None;
        
        CurrentNetDriverIndex++;
        if( CurrentNetDriverIndex != default.CurrentNetDriverIndex )
            SaveConfig();
    }

    bCleanedUp = true;
}

function bool ProcessChatMessage(string Msg, PlayerController Sender, optional bool bTeamMessage)
{
    local KFPlayerController KFPC;
    local Mutator M;
    
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
            KFPC.ReceiveLocalizedMessage(class'UKFPLocalMessage', KFGRI.bWaveIsActive ? UKFP_NotWave : UKFP_JoinCommand);
            return false;
        }
        PlayerChangeSpec(KFPC, true);
        return true;
    }
    else if( Msg ~= "ot" )
    {
        if( !bUsingOpenTraderCommand || MyKFGI.IsWaveActive() )
            return true;
        KFPC.ServerSetEnablePurchases(true);
        KFPC.ClientOpenTraderMenu(true);
        return true;
    }
    else if( Left(Msg, 11) ~= "changeslots" || Left(Msg, 2) ~= "cs" )
    {
        if( !KFPC.PlayerReplicationInfo.bAdmin )
            return false;
            
        // Prevents rogue mutators from blocking this command or breaking it - FMX
        for( M=MyKFGI.BaseMutator; M!=None; M=M.NextMutator )
        {
            if( M.IsA('UKFPMutator') )
                break;
        }
            
        if( M != None )
            M.Mutate(Msg, KFPC);
        
        return false;
    }
    else if( VotingHandler != None )
        VotingHandler.ParseCommand(Msg, KFPC);
    
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
        KFPC.ConsoleCommand(Msg);
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
        KFPC.ReceiveLocalizedMessage(class'UKFPLocalMessage', CRI.UKFPInteraction.bDropProtection ? UKFP_PickupDisabled : UKFP_PickupEnabled);
        CRI.UKFPInteraction.SaveConfig();
        CRI.ServerSetDropProtection(CRI.UKFPInteraction.bDropProtection);
        return true;
    }
    else if( Msg ~= "dlk" )
    {
        CRI.UKFPInteraction.SetLargeKillTicker(!CRI.UKFPInteraction.bDisableLargeKillTicker);
        return true;
    }
    
    return false;
}

function PlayerChangeSpec( KFPlayerController PC, bool bSpectator )
{
    local ReplicationHelper CRI;
    
    CRI = GetPlayerChat(PC.PlayerReplicationInfo);
    if( CRI == None )
        return;
        
	if( bSpectator==PC.PlayerReplicationInfo.bOnlySpectator || CRI.NextSpectateChange>WorldInfo.TimeSeconds )
    {
        PC.ReceiveLocalizedMessage(class'UKFPLocalMessage', (bSpectator==PC.PlayerReplicationInfo.bOnlySpectator) ? UKFP_AlreadySpectator : UKFP_WaitForSpectator);
		return;
    }
        
	CRI.NextSpectateChange = WorldInfo.TimeSeconds+0.5;

	if( WorldInfo.Game.AtCapacity(bSpectator,PC.PlayerReplicationInfo.UniqueId) )
        PC.ReceiveLocalizedMessage(class'UKFPLocalMessage', UKFP_SpectatorMaxCapacity);
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
        PC.BroadcastLocalizedMessage(class'UKFPLocalMessage', UKFP_PlayerBecameSpectator, PC.PlayerReplicationInfo);
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
            PC.ReceiveLocalizedMessage(class'UKFPLocalMessage', UKFP_SpectatorFailed);
			return;
		}
		++WorldInfo.Game.NumPlayers;
		--WorldInfo.Game.NumSpectators;
		PC.Reset();
        PC.BroadcastLocalizedMessage(class'UKFPLocalMessage', UKFP_SpectatorBecamePlayer, PC.PlayerReplicationInfo);
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
        `Log("Player"@PC.PlayerReplicationInfo.PlayerName@"("$`ConvertUIDToSteamID64(PC.PlayerReplicationInfo.UniqueId)$") has entered the server!",, 'Join Log');
        
        if( VotingHandler != None )
            VotingHandler.NotifyLogin(PC);
        
        CRI = Spawn(class'ReplicationHelper', PC);
        ChatArray.AddItem(CRI);
        
		CRI.PingFadeTime = PingSpamTime;
        CRI.KFPC = PC;
        CRI.PRI = PC.PlayerReplicationInfo;
        CRI.MainRepInfo = self;

        if( CurrentSeasonalIndex > 0 )
        {
            if( WorldInfo.NetMode != NM_DedicatedServer )
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
        
        CRI.ClientRecieveImportantData(bShouldUseEnhancedTraderMenu, RepMaxPlayers);
        if( KFGameInfo_WeeklySurvival(MyKFGI) != None )
            CRI.ClientSetWeeklyIndex(KFGameInfo_WeeklySurvival(MyKFGI).ActiveEventIdx);
            
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
            
        `Log("Player"@PC.PlayerReplicationInfo.PlayerName@"("$`ConvertUIDToSteamID64(PC.PlayerReplicationInfo.UniqueId)$") has left the server!",, 'Join Log');
    }
    
	if( NetDriver != None && MyKFGI.NumPlayers <= 0 && NetDriver.NetServerLobbyTickRate == NetDriver.default.NetServerMaxTickRate && MyKFGI.bWaitingToStartMatch )
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
        
    if( MyKFGI.NumPlayers <= 0 && !MyKFGI.bWaitingToStartMatch && KFGRI.bTraderIsOpen )
        MyKFGI.EndOfMatch(false);
}

function NotifyPlayerDied(KFPawn_Human P, KFPlayerController PC, Controller Killer, class<DamageType> DamageType)
{
    if( PC != None && (KFAIController(Killer) != None || class<DmgType_Suicided>(DamageType) == None) )
        PlayersDiedThisWave.AddItem(PC);
}

function OnZEDTakeDamage(KFPawn_Monster P, out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
    local ReplicationHelper CRI;
    
    if( !bShouldAllowDamagePopups )
        return;
    
    if( LastDamageDealer != None )
    {
        ClearTimer('CheckDamageDone');
        CheckDamageDone();
    }
    
    if( InDamage>0 && InstigatedBy != None )
    {
        if( P != None && InstigatedBy.PlayerReplicationInfo != None )
        {
            CRI = GetPlayerChat(InstigatedBy.PlayerReplicationInfo);
            if( CRI != None && !CRI.bNoDamageTracking )
            {
                LastDamageDealer = CRI;
                LastHitZed = P;
                LastHitHP = P.Health;
                LastDamagePosition = HitLocation;
                LastDamageDMGType = class<KFDamageType>(DamageType);
                LastHeadshot = P.HitZones.Find('ZoneName', HitInfo.BoneName) == HZI_Head;
                SetTimer(0.1,false,'CheckDamageDone');
            }
        }
    }
}

function CheckDamageDone()
{
    local int Damage;

    if( LastDamageDealer!=None && LastHitZed!=None && LastHitHP!=LastHitZed.Health )
    {
        Damage = LastHitHP-Max(LastHitZed.Health,0);
        if( Damage>0 )
            LastDamageDealer.AddDamageNumberMessage(Damage,LastDamagePosition,LastDamageDMGType,LastHitZed.Class,LastHeadshot);
    }
    LastHitZed = None;
    LastDamageDealer = None;
    LastHitHP = 0;
}

simulated function ReplicationHelper GetPlayerChat(PlayerReplicationInfo PRI)
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

function WriteToClient(Controller C, string Message, optional string HexColor="0099FF")
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

function Broadcast(string Message, optional string HexColor="0099FF")
{
    local int i;
    
    for( i=0; i<ChatArray.Length; i++ )
    {
        if( ChatArray[i].KFPC != None )
            ChatArray[i].WriteLargeStringToChat(Message, HexColor);
    }
}

function NotifyMatchStarted()
{
	if( NetDriver != None && NetDriver.NetServerLobbyTickRate != NetDriver.default.NetServerLobbyTickRate )
	{
		NetDriver.NetServerLobbyTickRate = FMax(NetDriver.default.NetServerLobbyTickRate, 5);
		NetDriver.SaveConfig();
	}
}

simulated function LoadAllWeaponAssets(KFWeapon W)
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

simulated static function StaticLoadWeaponAssets(class<KFWeapon> WeaponClass)
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

simulated function array<MaterialInterface> LoadWeaponSkin(int ItemId, EWeaponSkinType Type)
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

static function Object SafeLoadObject( string S, Class ObjClass, optional bool bCanFail )
{
    local Object O;
    
    O = FindObject(S,ObjClass);
    return O!=None ? O : DynamicLoadObject(S,ObjClass,bCanFail);
}

simulated function PlayEmoteAnimation(KFPawn_Human P)
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

simulated function PawnAnimEnd(KFPawn P, AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
    if( P != None && bPlayingEmote )
    {
        P.SetWeaponAttachmentVisibility(true);
        bPlayingEmote = false;
    }
}

// Causes issues and I'm tired of dealing with it so lets disable this for now - FMX
simulated function PreClientTravel(KFPlayerController PC, string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel);
/*{
    if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer )
        return;
        
    if( !bHandledTravel )
    {
        bHandledTravel = true;
        PendingMapSwitch();
        TravelMapName = StripOptionsFromURL(PendingURL);
    }
}*/

static function string StripOptionsFromURL( string URL )
{
    local int Index;
    
    Index = InStr(URL, "?");
    if( Index != INDEX_NONE )
        return Left(URL, Index);
        
	return URL;
}

simulated function PendingMapSwitch()
{
    local string URL;
    local array<string> S;
    local class<GameInfo> RedirectCheck;
    
    if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer || bShouldDisableCustomLoadingScreen )
        return;
        
    URL = WorldInfo.GetAddressURL();
    S = SplitString(URL, ":");
    
    // Can't load a outside .u but can't intergrate code into the package due to workshop deleting files and kicking out players. So lets just work around that in a really stupid way - FMX
    RedirectCheck = class<GameInfo>(DynamicLoadObject("UnofficialKFPatch_LevelTransition.MS_Game", class'Class', true));
    if( RedirectCheck == None )
    {
        class'MS_Game_Http'.static.SetReference();
        ConsoleCommand("Open KFMainMenu?Game="$PathName(class'MS_Game_Http')$"?MapName="$TravelMapName$"?SpectatorInfo="$(GetALocalPlayerController().PlayerReplicationInfo.bOnlySpectator ? "1" : "0")$"?URL="$S[0]$"?Port="$S[1]$"?bServerHidden="$(bServerIsHidden ? 1 : 0));
    }
    else GetALocalPlayerController().ConsoleCommand("Open KFMainMenu?Game=UnofficialKFPatch_LevelTransition.MS_Game?MapName="$TravelMapName$"?SpectatorInfo="$(GetALocalPlayerController().PlayerReplicationInfo.bOnlySpectator ? "1" : "0")$"?URL="$S[0]$"?Port="$S[1]$"?bServerHidden="$(bServerIsHidden ? 1 : 0));
}

simulated function byte GetZEDSeasonalIndex()
{
    local int SeasonalID;
    local KFMapInfo KFMI;
    local bool bAllowSeasonalSkins;
    local KFPlayerController PC;
    local KFGameReplicationInfo GRI;
	
    GRI = KFGameReplicationInfo(WorldInfo.GRI);
    PC = KFPlayerController(GetALocalPlayerController());
    SeasonalID = class'KFGameEngine'.static.GetSeasonalEventIDForZedSkins();

    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    if( KFMI != None )
        KFMI.ModifySeasonalEventId(SeasonalID);
        
    bAllowSeasonalSkins = (PC != None && PC.GetAllowSeasonalSkins()) || GRI.bAllowSeasonalSkins;
    if( !bAllowSeasonalSkins )
        SeasonalID = SEI_None;
    else if( ForcedSeasonalID != -1 )
        SeasonalID = ForcedSeasonalID;
    else if( GRI.SeasonalSkinsIndex != -1 )
        SeasonalID = GRI.SeasonalSkinsIndex;
    
    return SeasonalID;
}

final function SeasonalEventIndex GetSeasonalID(string ID)
{
    switch(Caps(ID))
    {
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
        case "NONE":
        case "REGULAR":
        case "DEFAULT":
        default:
             return SEI_None;
    }
    
    return SEI_None;
}

simulated function KFCharacterInfoBase GetSeasonalCharacterArch(class<KFPawn_Monster> Monster)
{
    local string ToLoad;
    local KFCharacterInfoBase LoadedInfo;
    local PrecachedArch PrecacheInfo;
    local int Index;
    
    ToLoad = Monster.default.MonsterArchPath;
    
    if( !(bNoEventSkins || bServerEnforceVanilla) )
    {
        switch( GetZEDSeasonalIndex() % 10 )
        {
            case SEI_Summer:
                ToLoad = "SUMMER_"$ToLoad;
                break;
            case SEI_Winter:
                ToLoad = "XMAS_"$ToLoad;
                break;
            case SEI_Fall:
                ToLoad = "HALLOWEEN_"$ToLoad;
                break;
        }
    }
	
    Index = PrecachedArchs.Find('ArchPath', ToLoad);
    if( Index != INDEX_NONE )
        return PrecachedArchs[Index].Arch;

    LoadedInfo = KFCharacterInfoBase(SafeLoadObject(ToLoad, class'KFCharacterInfoBase', true));
    if( LoadedInfo == None )
        LoadedInfo = KFCharacterInfoBase(SafeLoadObject(Monster.default.MonsterArchPath, class'KFCharacterInfoBase'));
        
    if( LoadedInfo != None )
    {
        PrecacheInfo.ArchPath = ToLoad;
        PrecacheInfo.Arch = LoadedInfo;
        PrecachedArchs.AddItem(PrecacheInfo);
    }

    return LoadedInfo;
}

function ScoreKill(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
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

function PlayerReplicationInfo FindPRIFromDrop(KFDroppedPickup Drop, out int Index)
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

function bool OverridePickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup, out byte bAllowPickup)
{
    local string WeaponName, SteamID, OwnerName;
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
    
    if( SteamID == OnlineSub.UniqueNetIdToInt64(Other.PlayerReplicationInfo.UniqueId) )
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

    foreach ChatArray(CRI)
        CRI.OnPickupBroadcasted(Other.PlayerReplicationInfo, WeaponName, OwnerName, SellPrice);

    return false;
}

simulated function class<KFPerk> GetPerkTypeCastFromClass( class<KFPerk> InPerkClass )
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

function AddLoadPackage( Object O )
{
    if( ExternalObjs.Find(O)==-1 )
        ExternalObjs.AddItem(O);
}

function PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string OutError, bool bSpectator)
{
    Broadcast("<font color=\"#438DFF\" face=\"MIcon\">"$`GetMIconChar("account-network")$"</font> <font color=\"#FFFFFF\" face=\"MIcon\">"$(Len(OnlineSub.UniqueNetIdToInt64(UniqueId)) == 17 ? `GetMIconChar("steam") : `GetMIconChar("google-controller"))$"</font> <font color=\"#0099FF\">"$WorldInfo.Game.ParseOption( Options, "Name" )@"is connecting</font>.");
}

function string ConvertMapName(string MapName)
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

function bool ShouldMapBeIgnored()
{
    return IgnoreDecentMaps.Find(CurrentMapName) != INDEX_NONE;
}

function CheckBossTeleport()
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

function UpdateWaveEndKismet(Sequence GameSeq, optional bool bBossWave)
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

function ForceUpdateEndlessDecent()
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

function NotifyWaveUpdated()
{
    //local bool bStartSpecialWave;
    
    WorldInfo.ForceGarbageCollection();

    /*if( KFGIE != None && KFGRIE != None && !KFGIE.IsUnrankedGame() )
    {
        if( !KFGRI.bWaveIsActive )
            bStartSpecialWave = TrySetNextWaveSpecial();
        else if( bStartSpecialWave && KFGRIE.CurrentWeeklyMode != INDEX_NONE )
            KFGIE.StartOutbreakRound(KFGRIE.CurrentWeeklyMode);
    }*/
}

function NotifyWaveStarted()
{
    PlayersDiedThisWaveOld.Length = 0;
    
    SavedWaveNum += 1;
    if( KFGameReplicationInfo(WorldInfo.GRI).IsBossWave() )
        SavedWaveNum = 1;
        
    ForceUpdateEndlessDecent();
    NotifyWaveUpdated();
}

function NotifyWaveEnded()
{
    local int i;
    
    /*if( KFGIE != None && !KFGIE.IsUnrankedGame() && KFGRI.WaveNum == 1 && !KFGIE.bIsInHoePlus && (Caps(CurrentAllowedOutbreaks) != default.DefaultAllowedOutbreaks || Caps(CurrentAllowedSpecialWaves) != default.DefaultAllowedSpecialWaves) )
    {
        KFGIE.SpecialWaveStart = 2;
        KFGIE.OutbreakWaveStart = 2;
        while( !KFGIE.bIsInHoePlus )
            KFGIE.IncrementDifficulty();
    }*/
    
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
    
    NotifyWaveUpdated();
}

function FixDecentEndless(bool bEnabled)
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

simulated function GetYearAndMonthFromEvent(out int Year, out int Month)
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
        case SET_Summer2023:
            Month = 7;
            Year = 2023;
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
        case SET_Fall2023:
            Month = 10;
            Year = 2023;
            break;
    }
}

function NotifyServerTravel(bool bSeamless)
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

simulated function WaitForStatsRead()
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

simulated function bool GetEnforceVanilla()
{
    return bServerEnforceVanilla;
}

function GetAllowedBossList(out array< class<KFPawn_Monster> > BossList)
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
                BossList.AddItem(MyKFGI.AIBossClassList[BAT_Hans]);
                break;
            case 'P':
                BossList.AddItem(MyKFGI.AIBossClassList[BAT_Patriarch]);
                break;
            case 'K':
                BossList.AddItem(MyKFGI.AIBossClassList[BAT_KingFleshpound]);
                break;
            case 'A':
                BossList.AddItem(MyKFGI.AIBossClassList[BAT_KingBloat]);
                break;
            case 'M':
                BossList.AddItem(MyKFGI.AIBossClassList[BAT_Matriarch]);
                break;
        }
    }
}

function bool TrySetNextWaveSpecial()
{
    local int SpecialWaveType;
    local float OutbreakPct, SpecialWavePct;

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

function int GetRandomEnabledSpecialWave(optional out array<byte> IDs)
{
    local array<string> SpecialWaveList;
    local int i;
    
    if( Caps(CurrentAllowedSpecialWaves) == default.DefaultAllowedSpecialWaves )
        return KFGIE.EndlessDifficulty.GetSpecialWaveType();
    
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
    
    i = KFGIE.EndlessDifficulty.GetSpecialWaveType();
    if( IDs.Find(i) != INDEX_NONE )
        return i;

    return INDEX_NONE;
}

function int GetRandomEnabledOutbreak(optional out array<byte> IDs)
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

function PerkAvailableData GetAllowedPerkList(optional out array<byte> IDs)
{
    local array<string> PerkList;
    local int i, Index;
    local class<KFPerk> PerkClass;
    local class<KFPlayerController> PCC;
    local PerkAvailableData PerkData;
    
    if( CurrentAllowedPerks == "" )
        return KFGRI.PerksAvailableData;
    
    PerkList = SplitString(CurrentAllowedPerks, ",", true);
    if( PerkList.Length <= 0 )
        return KFGRI.PerksAvailableData;
        
    PCC = class<KFPlayerController>(MyKFGI.PlayerControllerClass);
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

defaultproperties
{
	bAlwaysTick=true
	bTickIsDisabled=false
    
    NetPriority=4
    NetUpdateFrequency=20
    
    ForcedSeasonalID=-1
    
    Begin Object Class=class'KFGFxObject_TraderItems' Name=OriginalTraderItems_0
        ObjectArchetype=KFGFxObject_TraderItems'GP_Trader_ARCH.DefaultTraderItems'
    End Object
    OriginalTraderItems=OriginalTraderItems_0
    
    IgnoreDecentMaps.Add("KF-Elysium")
    
    MapNameOverrides.Add((Original="KF-DesolationOriginal",New="KF-Desolation"))
    MapNameOverrides.Add((Original="KF-Nuked-Beta",New="KF-Nuked"))
    MapNameOverrides.Add((Original="KF-ShoppingSpreeOriginal",New="KF-ShoppingSpree"))
    MapNameOverrides.Add((Original="KF-Sanitarium-classic",New="KF-Sanitarium"))
    MapNameOverrides.Add((Original="KF-Rig_zfix",New="KF-Rig"))
    MapNameOverrides.Add((Original="KF-CarillonHamletB1",New="KF-CarillonHamlet"))
    MapNameOverrides.Add((Original="KF-Crash_Original",New="KF-Crash"))
    MapNameOverrides.Add((Original="KF-Crash_Night",New="KF-Crash"))
    MapNameOverrides.Add((Original="KF-Crash_Final",New="KF-Crash"))

    WeaponExploitFix.Add(class'KFGameContent.KFWeap_HRG_Vampire')
    WeaponExploitFix.Add(class'KFGameContent.KFWeap_HRG_BlastBrawlers')
    WeaponExploitFix.Add(class'KFGameContent.KFWeap_Blunt_MedicBat')
    WeaponExploitFix.Add(class'KFGameContent.KFWeap_AssaultRifle_LazerCutter')

    WeaponPickupMeshes.Add(StaticMesh'UKFP_3P_Centerfire_MESH.Wep_3rdP_Centerfire_Pickup')
    WeaponPickupMeshes.Add(StaticMesh'UKFP_3P_M14EBR_MESH.Wep_M14EBR_Pickup')
    WeaponPickupMeshes.Add(StaticMesh'UKFP_3P_Mosin_MESH.WEP_3rdP_Mosin_Pickup')
    
    DefaultAllowedOutbreaks="B,TT,BZ,P,UU,BK"
    DefaultAllowedSpecialWaves="CL,CS,C,S,SR,H,SC,CA,GF,B,FP"
    
    TommyGunFPMesh=SkeletalMesh'UKFP_1P_TommyGun_MESH.Wep_1stP_TommyGun_Rig'
}