class UKFPLocalMessage extends KFLocalMessage
	abstract;
    
enum EUKFPLocalMessageType
{
    UKFP_NotWave,
    UKFP_JoinCommand,
    UKFP_PickupEnabled,
    UKFP_PickupDisabled,
    UKFP_AlreadySpectator,
    UKFP_WaitForSpectator,
    UKFP_SpectatorMaxCapacity,
    UKFP_SpectatorFailed,
    UKFP_PlayerBecameSpectator,
    UKFP_SpectatorBecamePlayer,
};

var localized string SpectatorNotWave, SpectatorJoinCommand;
var localized string PickupsDisabled, PickupsEnabled;
var localized string CantChangeSpec, AlreadySpectator, WaitForSpectator, SpectatorMaxCapacity, SpectatorFailed, PlayerBecameSpectator, SpectatorBecamePlayer;

static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch( Switch )
    {
        case UKFP_NotWave:
            return default.SpectatorNotWave;
        case UKFP_JoinCommand:
            return default.SpectatorNotWave;
        case UKFP_PickupEnabled:
            return default.PickupsEnabled;
        case UKFP_PickupDisabled:
            return default.PickupsDisabled;
        case UKFP_AlreadySpectator:
            return default.CantChangeSpec@default.AlreadySpectator;
        case UKFP_WaitForSpectator:
            return default.CantChangeSpec@default.WaitForSpectator;
        case UKFP_SpectatorMaxCapacity:
            return default.SpectatorMaxCapacity;
        case UKFP_SpectatorFailed:
            return default.SpectatorFailed;
        case UKFP_PlayerBecameSpectator:
            return RelatedPRI_1.GetHumanReadableName()@default.PlayerBecameSpectator;
        case UKFP_SpectatorBecamePlayer:
            return RelatedPRI_1.GetHumanReadableName()@default.SpectatorBecamePlayer;
    }
    
    return "";
}

static function string GetHexColor(int Switch)
{
    switch( Switch )
    {
        case UKFP_NotWave:
        case UKFP_JoinCommand:
        case UKFP_PickupDisabled:
        case UKFP_AlreadySpectator:
        case UKFP_WaitForSpectator:
        case UKFP_SpectatorMaxCapacity:
        case UKFP_SpectatorFailed:
            return default.InteractionColor;
        case UKFP_PickupEnabled:
            return default.GameColor;
    }
    
    return default.EventColor;
}