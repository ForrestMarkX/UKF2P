// Minimal intermission gametype.
Class MS_Game_Http extends GameInfo;

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
    
    class'MS_TMPUI'.static.Remove();
}

static final function SetReference()
{
	class'MS_TMPUI'.static.Apply();
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
    MS_PC_Http(NewPlayer).Game = self;

    NewPlayer.GotoState('PlayerWaiting');
    return newPlayer;
}

function PostLogin( PlayerController NewPlayer )
{
    MS_PC_Http(NewPlayer).ClientSetHUD(HudType);
}

defaultproperties
{
    PlayerControllerClass=class'MS_PC_Http'
    HUDType=class'MS_HUD_Http'
}