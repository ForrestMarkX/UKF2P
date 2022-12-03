class UKFPSeasonalEventStats_Xmas2022 extends UKFPSeasonalEventStats;

var transient int ShotgunJumpsIdx, FrozenZedsRequired, ShotgunJumpsRequired, BallisticBouncerImpactsRequired, EndlessWaveRequired, XmasEventIndex;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Freeze 500 Zeds using ice arsenal
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Crash
	bObjectiveIsValidForMap[2] = 0; // Use 4 Boomstick Jumps in a same match on Crash
	bObjectiveIsValidForMap[3] = 1; // Hit 3 Zeds with a shot of HRG Ballistic Bouncer (15 times)
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Crash

    if( InStr(MapName, "KF-Crash", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

    SetSeasonalEventStatsMaxEx(FrozenZedsRequired, 0, ShotgunJumpsRequired, BallisticBouncerImpactsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(9568);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
    
	ObjIdx = 1;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(SEI_Winter, ObjIdx);
    CheckRestartObjective(ShotgunJumpsIdx, ShotgunJumpsRequired);
}

simulated function OnGameEnd(class<GameInfo> GameClass)
{
	CheckRestartObjective(ShotgunJumpsIdx, ShotgunJumpsRequired);
}

final simulated function CheckRestartObjective(int ObjectiveIndex, int ObjectiveLimit)
{
	local int StatValue;

	StatValue = GetSeasonalEventStatValue(ObjectiveIndex);
	if( StatValue != 0 && StatValue < ObjectiveLimit )
		ResetSeasonalEventStatEx(ObjectiveIndex);
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int FrozenZedsIdx, BallisticBouncerImpactsIdx, ObjectiveLimit;
	local bool bValidIdx;

    FrozenZedsIdx = 0;
	BallisticBouncerImpactsIdx = 3;

    if( ObjectiveIndex == FrozenZedsIdx )
    {
        ObjectiveLimit = FrozenZedsRequired;
        bValidIdx = true;
    }
    else if( ObjectiveIndex == ShotgunJumpsIdx )
    {
        ObjectiveLimit = ShotgunJumpsRequired;
        bValidIdx = true;
    }
    else if( ObjectiveIndex == BallisticBouncerImpactsIdx )
    {
        ObjectiveLimit = BallisticBouncerImpactsRequired;
        bValidIdx = true;
    }
    
    if( bValidIdx && bObjectiveIsValidForMap[ObjectiveIndex] != 0 )
    {
        IncrementSeasonalEventStatEx(ObjectiveIndex, 1);
        if( GetSeasonalEventStatValue(ObjectiveIndex) >= ObjectiveLimit )
            FinishedObjectiveEx(SEI_Winter, ObjectiveIndex);
    }
}

simulated function OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}
}

simulated function OnAfflictionCaused(EAfflictionType Type)
{
	local int ObjIdx;

    ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && Type == AF_Freeze )
	{
        IncrementSeasonalEventStatEx(ObjIdx, 1);
        if( GetSeasonalEventStatValue(ObjIdx) >= FrozenZedsRequired )
            FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}
}

defaultproperties
{ 
	ShotgunJumpsIdx=2

	FrozenZedsRequired=500
	ShotgunJumpsRequired=4
	BallisticBouncerImpactsRequired=30
	EndlessWaveRequired=15
	XmasEventIndex=SEI_Winter
}