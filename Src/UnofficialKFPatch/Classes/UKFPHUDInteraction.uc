class UKFPHUDInteraction extends Interaction
    config(UnofficialPatch);

const HUDBorderSize = 3;

var ReplicationHelper ChatRep;
var KFGFxHudWrapper HUD;
var KFPlayerController KFPlayerOwner;
var WorldInfo WorldInfo;
var Canvas Canvas;

struct FStatusIcon
{
    var float Value, MaxValue, LerpValue;
    var string UID, Name;
    var Color Color, BackgroundColor;
    var Texture2D Icon;
    var delegate<OnStatusThink> StatusThink;
    var KFPawn_Human Pawn;
};
var transient array<FStatusIcon> Statuses;

var config int WeaponBobStyle;
var array< class<WeaponBobStyle> > BobStyles;
var array<string> BobStylesToLoad;
var WeaponBobStyle CurrentBobClass;

var config enum EWeaponHand
{
	HAND_Right,
	HAND_Left,
	HAND_Centered
} WeaponHand;

var transient float SizeX, SizeY, ScaledBorderSize, ScaledBorderSizeDouble, AlphaInverse, ActualWaveInfoAlpha, ActualPlayerStatusAlpha, ActualPlayerBackpackAlpha, ActualBossHealthBarAlpha;
var transient vector PLCameraLoc,PLCameraDir;
var transient rotator PLCameraRot;
var transient array<Texture> ZEDIcons;
var transient byte CurrentPacketLossAlpha, CurrentPausedAlpha;
var transient string MatchOverText;

var AkEvent PingSound;

struct FPingLocation
{
    var Actor A;
    var float PingTime, PingSize;
    var Texture PingTexture;
    var Color PingColor;
    var vector HitLocation;
    var int TexSizeX, TexSizeY;
    var bool bHitWorld;
    var string PingName;
    var int MaxPingSize;
    var PlayerReplicationInfo PRIOwner;
};
var transient array<FPingLocation> PingLocations;

var config int iConfigVersion, DoshThrowAmt;
var config byte PingAlphaColor;
var config float MaxPingIconSize;
var config byte HUDAlpha, WaveInfoAlpha, PlayerStatusAlpha, PlayerBackpackAlpha, BossHealthBarAlpha;

var config bool bDisableLargeKillTicker, bPingsEnabled, bEnableZEDTimeUI, bDropProtection, bFilterHRGWeapons;
var transient bool bHasPacketLoss, bHUDSizeInitialized;

var Texture BossIconTexture, ZEDPingTexture, AmmoPingTexture, ArmorPingTexture, WeaponPingTexture, WorldPingTexture, CashPingTexture, DoorPingTexture, CollectiblePingTexture, ObjectivePingTexture;
var float PingFadeTime, PingFadeInTime, PingFadeOutTime;

struct FWidgetAlpha
{
    var GFxObject Widget;
    var float Alpha;
};
var array<FWidgetAlpha> WidgetAlphas;

function Initialized()
{
    return;
}

final private function SetupBobStyle()
{
    return;
}

function PostRender(Canvas C)
{
    return;
}

delegate FStatusIcon OnStatusThink(FStatusIcon Status, float DeltaTime);

final function AddStatusEffect( coerce string UID, KFPawn_Human P, coerce string StatusName, Color Col, Texture2D Icon, float MaxValue, delegate<OnStatusThink> StatusThink )
{
    return;
}

final function AddActorPing(PlayerReplicationInfo PRI, Actor A, Vector HitLocation, bool bHitWorld)
{
    return;
}

final exec function SetNoHRG(bool B)
{
    return;
}

final exec function SetBobStyle(int Style)
{
    return;
}

final exec function DebugCamera()
{
    `Log(KFPlayerOwner.PlayerCamera.CameraStyle,,'DebugCamera');
    `Log(KFPlayerOwner.UsingFirstPersonCamera(),,'DebugCamera');
    `Log(KFPlayerOwner.Pawn,,'DebugCamera');
    `Log(KFPlayerOwner.Pawn.Mesh,,'DebugCamera');
    `Log(KFPlayerOwner.Pawn.Mesh.bOwnerNoSee,,'DebugCamera');
}

final exec function SetWeaponHand(string S)
{
    return;
}

final exec function ToggleCameraMode()
{
    return;
}

final exec function SetHUDScale(float Scale)
{
    return;
}

final exec function SetOtherHUDAlpha(byte Alpha)
{
    return;
}

final exec function SetWaveInfoAlpha(byte Alpha)
{
    return;
}

final exec function SetPlayerStatusAlpha(byte Alpha)
{
    return;
}

final exec function SetPlayerBackpackAlpha(byte Alpha)
{
    return;
}

final exec function SetBossHealthBarAlpha(byte Alpha)
{
    return;
}

final exec function ThrowMoney(int Amount)
{
    return;
}

final exec function SetDoshThrowAmount(int Amount)
{
    return;
}

final exec function SetDropProtection(bool B)
{
    return;
}

final exec function SetLargeKillTicker(bool B)
{
    return;
}

final exec function SetZEDTimeEnabled(bool B)
{
    return;
}

final exec function SetPingsEnabled(bool B)
{
    return;
}

final exec function SetPingAlpha(byte Alpha)
{
    return;
}

final exec function SetPingSize(float Size)
{
    return;
}

final exec function PingLocation()
{
    return;
}

defaultproperties
{
    PingFadeTime=10
    PingFadeInTime=0.25
    PingFadeOutTime=0.25
    
    BossIconTexture=Texture2D'ZED_Patriarch_UI.ZED-VS_Icon_Boss'
    ZEDPingTexture=Texture2D'UI_PerkIcons_TEX.UI_PerkIcon_ZED'
    AmmoPingTexture=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Trader'
    ArmorPingTexture=Texture2D'UI_Objective_Tex.UI_Obj_Healing_Loc'
    WeaponPingTexture=Texture2D'UI_TraderMenu_TEX.UI_WeaponSelect_Trader_Type'
    WorldPingTexture=Texture2D'UI_LevelChevrons_TEX.UI_LevelChevron_Icon_02'
    CashPingTexture=Texture2D'UI_Objective_Tex.UI_Obj_Dosh_Loc'
    DoorPingTexture=Texture2D'Objectives_UI.UI_Objectives_SS_Steampunk_Welder'
    CollectiblePingTexture=Texture2D'UI_PerkIcons_TEX.UI_Horzine_H_Logo'
    ObjectivePingTexture=Texture2D'Objectives_UI.UI_Objectives_Xmas_DefendObj'
    
    PingSound=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Check_A_01'
    
    BobStylesToLoad.Add("UnofficialKFPatch.QuakeBobStyle")
    BobStylesToLoad.Add("UnofficialKFPatch.DoomBobStyle")
    BobStylesToLoad.Add("UnofficialKFPatch.DoomInverseBobStyle")
    BobStylesToLoad.Add("UnofficialKFPatch.DoomAlphaBobStyle")
    BobStylesToLoad.Add("UnofficialKFPatch.DoomAlphaInverseBobStyle")
    BobStylesToLoad.Add("UnofficialKFPatch.HL2BobStyle")
    BobStylesToLoad.Add("UnofficialKFPatch.NoBobStyle")
}