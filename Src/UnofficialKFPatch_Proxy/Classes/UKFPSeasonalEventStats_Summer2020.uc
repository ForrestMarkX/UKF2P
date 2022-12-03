class UKFPSeasonalEventStats_Summer2020 extends UKFPSeasonalEventStats;

var int BossDeathsRequired, DoshEarnRequired, EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the weekly on Desolation
	bObjectiveIsValidForMap[2] = 0; // Activate the power generator on Desolation
	bObjectiveIsValidForMap[3] = 0; // Earn 75,000 Dosh through kills, rewards and healing on Desolation
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Desolation
	
    if( InStr(MapName, "KF-Desolation", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(BossDeathsRequired, 0, 0, DoshEarnRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8292); // Space Pirate Monkey backpack
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;

	ObjIdx = 1;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(SEI_Summer, ObjIdx);
}

simulated event OnGameEnd(class<GameInfo> GameClass)
{
	local int ObjIdx;
	local int TotalDoshEarned;
	
	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		TotalDoshEarned = Outer.MyKFPC.MatchStats.TotalDoshEarned + Outer.MyKFPC.MatchStats.GetDoshEarnedInWave();
		if( TotalDoshEarned > 0 )
		{
			IncrementSeasonalEventStatEx(ObjIdx, TotalDoshEarned);
			if( GetSeasonalEventStatValue(ObjIdx) >= DoshEarnRequired )
				FinishedObjectiveEx(SEI_Summer, ObjIdx);
		}
	}
}

simulated function OnBossDied()
{
	local int ObjIdx;
	
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= BossDeathsRequired )
			FinishedObjectiveEx(SEI_Summer, ObjIdx);
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(SEI_Summer, ObjIdx);
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx )
		FinishedObjectiveEx(EventIndex, ObjectiveIndex);
}

defaultproperties
{
	BossDeathsRequired=15
	DoshEarnRequired=75000
	EndlessWaveRequired=15
}