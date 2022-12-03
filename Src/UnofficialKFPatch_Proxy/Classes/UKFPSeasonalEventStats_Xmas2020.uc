class UKFPSeasonalEventStats_Xmas2020 extends UKFPSeasonalEventStats;

var int RosesRequired, TomesRequired, EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 0; // Collect 3 roses in Elysium
	bObjectiveIsValidForMap[1] = 0; // Collect 4 tomes in Elysium
	bObjectiveIsValidForMap[2] = 0; // Complete one wave in Elysium's Botanica arena
	bObjectiveIsValidForMap[3] = 0; // Complete one wave in Elysium's Loremaster Sanctum arena
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Elysium
	
    if( InStr(MapName, "KF-Elysium", false, true) != INDEX_NONE )
	{
        bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(RosesRequired, TomesRequired, 0, 0, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8608);
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx )
	{
        IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= RosesRequired )
			FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}

	ObjIdx = 1;
    if( bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx )
	{
        IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= TomesRequired )
			FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}

	ObjIdx = 2;
    if( bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx )
		FinishedObjectiveEx(SEI_Winter, ObjIdx);
        
	ObjIdx = 3;
    if( bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx )
		FinishedObjectiveEx(SEI_Winter, ObjIdx);
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}
}

defaultproperties
{
	RosesRequired=3
	TomesRequired=4
	EndlessWaveRequired=15
}