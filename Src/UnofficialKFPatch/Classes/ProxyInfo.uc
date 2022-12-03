class ProxyInfo extends Object
    dependson(UKFPReplicationInfo);

var WorldInfo WorldInfo;

function Init();
function Cleanup();
function ForceUpdateWeeklyIndex(int WeeklyIndex);
function int GetSeasonalEventID(KFGameEngine Engine);
function ForceSeasonalEvent(ESeasonalEventType Type);
function OnSeasonalDataLoaded(KFPlayerController PC, ReplicationHelper CRI);
function CheckSpecialEventID(KFPlayerController PC);
function bool IsReadSuccessful(KFPlayerController PC);

defaultproperties
{
}