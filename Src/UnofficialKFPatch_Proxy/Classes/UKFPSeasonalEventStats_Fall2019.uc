class UKFPSeasonalEventStats_Fall2019 extends UKFPSeasonalEventStats;

var int EndlessWaveRequired, ZedKillsRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 0; // Defeat any boss on Survival Hard or higher difficulty on Asylum
	bObjectiveIsValidForMap[1] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Asylum
	bObjectiveIsValidForMap[2] = 0; // Complete the Weekly on Asylum
	bObjectiveIsValidForMap[3] = 0; // Kill 1500 Zeds on Asylum
	bObjectiveIsValidForMap[4] = 0; // Complete Nuked on Objective Hard or higher difficulty

    if( InStr(MapName, "KF-AshwoodAsylum", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
	}
    else if( InStr(MapName, "KF-Nuked", false, true) != INDEX_NONE )
		bObjectiveIsValidForMap[4] = 1;

	SetSeasonalEventStatsMaxEx(0, 0, 0, ZedKillsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(7481);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( bObjectiveIsValidForMap[0] != 0 )
	{
		if( GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Fall, 0);
	}

	if( bObjectiveIsValidForMap[2] != 0 )
	{
		if( GameClass == class'KFGameInfo_WeeklySurvival' )
			FinishedObjectiveEx(SEI_Fall, 2);
	}

	if( bObjectiveIsValidForMap[4] != 0 )
	{
		if( GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Fall, 4);
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if( bObjectiveIsValidForMap[3] != 0 )
	{
		IncrementSeasonalEventStatEx(3, 1);
		if( GetSeasonalEventStatValue(3) >= ZedKillsRequired )
			FinishedObjectiveEx(SEI_Fall, 3);
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	if( bObjectiveIsValidForMap[1] != 0 )
	{
		if( WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Fall, 1);
	}
}

defaultproperties
{
	EndlessWaveRequired=15
	ZedKillsRequired=1500
}