class UKFPSeasonalEventStats_Spring2021 extends UKFPSeasonalEventStats;

var int BossKillsRequired, EDARKillsRequired, WavesWithoutDamageRequired, EndlessWaveRequired;
var bool bHitTakenThisWave;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Dystopia 2029
	bObjectiveIsValidForMap[2] = 0; // Kill 100 E.D.A.R.s on Dystopia 2029
	bObjectiveIsValidForMap[3] = 0; // Complete a wave without taking any damage 10 times on Dystopia 2029
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Dystopia 2029

    if( InStr(MapName, "KF-Dystopia2029", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(BossKillsRequired, 0, EDARKillsRequired, WavesWithoutDamageRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8716);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( bObjectiveIsValidForMap[1] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(SEI_Spring, 1);
}

simulated function OnBossDied()
{
	local int ObjIdx;

	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= BossKillsRequired )
			FinishedObjectiveEx(SEI_Spring, ObjIdx);
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
    
    if( !bKiller )
        return;

	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && ClassIsChildOf(MonsterClass, class'KFPawn_ZedDAR') )
	{
        IncrementSeasonalEventStatEx(ObjIdx, 1);
        if( GetSeasonalEventStatValue(ObjIdx) >= EDARKillsRequired )
            FinishedObjectiveEx(SEI_Spring, ObjIdx);
	}
}

simulated function OnHitTaken()
{
	bHitTakenThisWave = true;
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( !bHitTakenThisWave )
		{
			IncrementSeasonalEventStatEx(ObjIdx, 1);
			if( GetSeasonalEventStatValue(ObjIdx) >= WavesWithoutDamageRequired )
				FinishedObjectiveEx(SEI_Spring, ObjIdx);
		}
		bHitTakenThisWave = false;
	}

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(SEI_Spring, ObjIdx);
}

defaultproperties
{
	BossKillsRequired=15
	EDARKillsRequired=50
	WavesWithoutDamageRequired=10
	EndlessWaveRequired=15

	bHitTakenThisWave=false
}
