class KFGFxSpecialEventObjectivesContainerProxy extends Object;

stripped function context(KFGFxSpecialEventObjectivesContainer.HasObjectiveStatusChanged) bool HasObjectiveStatusChanged()
{
    local int i;
    local bool bHasChanged;
    local bool bTempStatus;
	local int ProgressValue, MaxValue;
	local float PercentageValue;
    
    if( SpecialEventObjectiveInfoList.Length != ObjectiveStatusList.Length )
    {
        ObjectiveStatusList.Length = SpecialEventObjectiveInfoList.Length;
        for( i=0; i<SpecialEventObjectiveInfoList.Length; i++ )
        {
			GetObjectiveProgressValues(i, ProgressValue, MaxValue, PercentageValue);
            ObjectiveStatusList[i].bComplete = KFPC.IsEventObjectiveComplete(i);
			ObjectiveStatusList[i].NumericValue = ProgressValue;
        }
        bHasChanged = true;
    }
    else
    {
        if( `GetChatRep() != None && `GetChatRep().bForceObjectiveRefresh )
        {
            `GetChatRep().bForceObjectiveRefresh = false;
            return true;
        }
        
        for( i=0; i<SpecialEventObjectiveInfoList.Length; i++ )
        {
            bTempStatus = KFPC.IsEventObjectiveComplete(i);
			GetObjectiveProgressValues(i, ProgressValue, MaxValue, PercentageValue);
            if( ObjectiveStatusList[i].bComplete != bTempStatus || ObjectiveStatusList[i].NumericValue != ProgressValue )
            {
                bHasChanged = true;
                ObjectiveStatusList[i].bComplete = bTempStatus;
				ObjectiveStatusList[i].NumericValue = ProgressValue;
            }
        }
    }

    return bHasChanged;
}