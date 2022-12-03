class UKFPSeasonalEventStats extends KFSeasonalEventStats;

var ReplicationHelper CRI;

function Init(string MapName);
simulated function OnDataLoaded();
simulated function OnAllMapCollectiblesFound();
simulated function GrantEventItemsEx();

final function ResetSeasonalEventStatEx(int StatIdx)
{
    if( CRI != None && CRI.SeasonalObjectiveStats != None )
        CRI.SeasonalObjectiveStats.ResetCurrentObjectStat(StatIdx);
}

final function IncrementSeasonalEventStatEx(int StatIdx, int Inc)
{
    if( CRI != None && CRI.SeasonalObjectiveStats != None )
        CRI.SeasonalObjectiveStats.IncrementCurrentObjectStat(StatIdx, Inc);
}

final function SetSeasonalEventStatsMaxEx(int StatMax1, int StatMax2, int StatMax3, int StatMax4, int StatMax5)
{
    if( CRI != None && CRI.SeasonalObjectiveStats != None )
    {
        CRI.SeasonalObjectiveStats.SeasonalEventStatsMax1 = StatMax1;
        CRI.SeasonalObjectiveStats.SeasonalEventStatsMax2 = StatMax2;
        CRI.SeasonalObjectiveStats.SeasonalEventStatsMax3 = StatMax3;
        CRI.SeasonalObjectiveStats.SeasonalEventStatsMax4 = StatMax4;
        CRI.SeasonalObjectiveStats.SeasonalEventStatsMax5 = StatMax5;
    }
}

final function FinishedObjectiveEx(int EventIndex, int ObjectiveIndex)
{
	if( CRI.WorldInfo.NetMode != NM_DedicatedServer && CRI.KFPC.IsLocalPlayerController() && !CRI.KFPC.PlayerReplicationInfo.bOnlySpectator && !Outer.HasCheated() && !IsEventObjectiveComplete(ObjectiveIndex) )
	{
        IncrementSeasonalEventStatEx(ObjectiveIndex, 1);
        
		if( CRI.KFPC.MyGFxHUD != None && CRI.KFPC.MyGFxHUD.LevelUpNotificationWidget != None && ((class'KFGameEngine'.static.GetSeasonalEventID() % 10) == EventIndex) )
			CRI.KFPC.MyGFxHUD.LevelUpNotificationWidget.FinishedSpecialEvent(EventIndex, ObjectiveIndex);
		if( CRI.KFPC.MyGFxManager != None && CRI.KFPC.MyGFxManager.StartMenu != None && CRI.KFPC.MyGFxManager.StartMenu.MissionObjectiveContainer != None )
			CRI.KFPC.MyGFxManager.StartMenu.MissionObjectiveContainer.Refresh();

        GrantEventItemsEx();
	}
}

final function bool IsEventObjectiveComplete(int EventIndex)
{
	return CRI.SeasonalObjectiveStats.IsEventObjectiveComplete(EventIndex);
}

final function int GetSeasonalEventStatValue(int EventIndex)
{
	return CRI.SeasonalObjectiveStats.GetCurrentObjectStat(EventIndex);
}

final function GrantEventItemEx(int ItemId)
{
    local class<KFSeasonalEventStats> OverrideEventClass;
    local KFSeasonalEventStats OverrideEvent;

    switch( class'KFGameEngine'.default.SeasonalEventId )
    {
        case SEI_Spring:
            OverrideEventClass = class'KFGameContent.KFSeasonalEventStats_Spring2021';
            break;
        case SEI_Summer:
            OverrideEventClass = class'KFGameContent.KFSeasonalEventStats_Summer2022';
            break;
        case SEI_Fall:
            OverrideEventClass = class'KFGameContent.KFSeasonalEventStats_Fall2022';
            break;
        case SEI_Winter:
            OverrideEventClass = class'KFGameContent.KFSeasonalEventStats_Xmas2022';
            break;
    }
    
    if( OverrideEventClass != None )
    {
        OverrideEvent = new(Outer) OverrideEventClass;
        OverrideEvent.GrantEventItem(ItemId);
    }
}