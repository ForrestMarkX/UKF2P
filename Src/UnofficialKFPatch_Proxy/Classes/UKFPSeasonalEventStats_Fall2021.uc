class UKFPSeasonalEventStats_Fall2021 extends UKFPSeasonalEventStats;

var int BossKillsRequired, EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Netherhold
	bObjectiveIsValidForMap[2] = 0; // Find the nether heart
	bObjectiveIsValidForMap[3] = 0; // Unlock the chapel and the dining hall doors
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Netherhold
	
    if( InStr(MapName, "KF-Netherhold", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(BossKillsRequired, 0, 0, 0, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8990); 
	}
}

simulated function OnBossDied()
{
	local int ObjIdx;
    
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= BossKillsRequired )
			FinishedObjectiveEx(SEI_Fall, ObjIdx);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
    
    ObjIdx = 1;
    if( bObjectiveIsValidForMap[ObjIdx] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(SEI_Fall, ObjIdx);
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
    
	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(SEI_Fall, ObjIdx);
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int NetherHeartIdx, ChapelIdx;
    
	NetherHeartIdx = 2;
	ChapelIdx = 3;

    if( EventIndex == SEI_Fall && (ObjectiveIndex == NetherHeartIdx || ObjectiveIndex == ChapelIdx) && bObjectiveIsValidForMap[ObjectiveIndex] != 0 )
        FinishedObjectiveEx(SEI_Fall, ObjectiveIndex);
}

defaultproperties
{
    BossKillsRequired=15
	EndlessWaveRequired=15
}