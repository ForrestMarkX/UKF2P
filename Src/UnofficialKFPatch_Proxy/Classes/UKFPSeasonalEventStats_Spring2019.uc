class UKFPSeasonalEventStats_Spring2019 extends UKFPSeasonalEventStats;

var int ZedKillsRequired, BossDeathsRequired, EndlessWaveRequired, ZedKillsCount;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // kill bosses (any map)
	bObjectiveIsValidForMap[1] = 0; // complete weekly event (Spillway)
	bObjectiveIsValidForMap[2] = 1; // kill zeds (as an individual) (any map)
	bObjectiveIsValidForMap[3] = 0; // complete waves on endless hard or higher (Spillway)
	bObjectiveIsValidForMap[4] = 0; // defeat any boss on Survival Hard or higher (Spillway)

    if( InStr(MapName, "KF-Spillway", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(BossDeathsRequired, 0, ZedKillsRequired, 0, 0);
}

simulated function GrantEventItemsEx()
{
	if (IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4))
	{
		GrantEventItemEx(7155);
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
    if( !bKiller )
        return;
        
	if (bObjectiveIsValidForMap[2] != 0)
	{
		IncrementSeasonalEventStatEx(2, 1);
		if (GetSeasonalEventStatValue(2) >= ZedKillsRequired)
		{
			FinishedObjectiveEx(SEI_Spring, 2);
		}
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if (bObjectiveIsValidForMap[4] != 0)
	{
		if (GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjectiveEx(SEI_Spring, 4);
		}
	}

	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjectiveEx(SEI_Spring, 1);
		}
	}
}

simulated function OnBossDied()
{
	if (bObjectiveIsValidForMap[0] != 0)
	{
		IncrementSeasonalEventStatEx(0, 1);
		if (GetSeasonalEventStatValue(0) >= BossDeathsRequired)
		{
			FinishedObjectiveEx(SEI_Spring, 0);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	if (bObjectiveIsValidForMap[3] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjectiveEx(SEI_Spring, 3);
		}
	}
}
defaultproperties
{
	ZedKillsRequired=1500
	BossDeathsRequired=15
	EndlessWaveRequired=15
}