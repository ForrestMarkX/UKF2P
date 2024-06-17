class KFGFxMissionObjectivesContainerProxy extends Object;

stripped function context(KFGFxMissionObjectivesContainer.ShowShouldSpecialEvent) bool ShowShouldSpecialEvent()
{
    return class'KFGameEngine'.default.SeasonalEventId > SEI_None && class'KFGfxMenu_StartGame'.static.GetSpecialEventClass(class'KFGameEngine'.default.SeasonalEventId) != class'KFGFxSpecialEventObjectivesContainer' && (KFPC.SeasonalEventIsValid() || class'WorldInfo'.static.IsMenuLevel());
}
