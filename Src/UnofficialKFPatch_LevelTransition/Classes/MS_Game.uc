// Minimal intermission gametype.
Class MS_Game extends GameInfo;

var string PendingURL, SpectatorInfo, MapName;
var bool bServerHidden;

function Timer();

function InitGame( string Options, out string ErrorMessage )
{
    MaxPlayers = 99;
    MaxSpectators = 99;

    SpectatorInfo = ParseOption(Options, "SpectatorInfo");
    PendingURL = ParseOption(Options, "URL")$":"$ParseOption(Options, "Port");
    MapName = ParseOption(Options, "MapName");
    bServerHidden = bool(ParseOption(Options, "bServerHidden"));
}

function PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
    local NavigationPoint StartSpot;
    local PlayerController NewPlayer;
    local rotator SpawnRotation;

    // Find a start spot.
    StartSpot = FindPlayerStart( None, 255, Portal );
    SpawnRotation.Yaw = StartSpot.Rotation.Yaw;
    NewPlayer = SpawnPlayerController(StartSpot.Location, SpawnRotation);
    MS_PC(NewPlayer).Game = self;

    NewPlayer.GotoState('PlayerWaiting');
    return newPlayer;
}

function PostLogin( PlayerController NewPlayer )
{
    MS_PC(NewPlayer).ClientSetHUD(HudType);
}

defaultproperties
{
    PlayerControllerClass=class'MS_PC'
    HUDType=class'MS_HUD'
}