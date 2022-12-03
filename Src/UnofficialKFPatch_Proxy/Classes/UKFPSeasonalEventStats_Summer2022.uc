class UKFPSeasonalEventStats_Summer2022 extends UKFPSeasonalEventStats;

var int ZedsKillRequired, WavesRequired, ZedsThrowSeaRequired, EndlessWaveRequired;
var transient int LastWaveFinished;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 1500 Zeds on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Rig
	bObjectiveIsValidForMap[2] = 0; // Complete 100 waves on Rig
	bObjectiveIsValidForMap[3] = 0; // Throw 50 Zeds to the sea on Rig
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Rig

    if( InStr(MapName, "KF-Rig", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(ZedsKillRequired, 0, WavesRequired, ZedsThrowSeaRequired, EndlessWaveRequired);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(9334);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// Rig weekly
	if( bObjectiveIsValidForMap[1] != 0 && ClassIsChildOf(GameClass, class'KFGameInfo_WeeklySurvival') )
        FinishedObjectiveEx(SEI_Summer, 1);
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;

	// Kill 1500 Zeds on any map or mode
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= ZedsKillRequired )
			FinishedObjectiveEx(SEI_SUMMER, ObjIdx);
	}
}

simulated function OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass)
{
	local int ObjIdx;

	// Throw 50 Zeds to the sea on Rig
	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( ClassIsChildOf(TriggerClass, class'KFSeaTrigger') )
		{
			IncrementSeasonalEventStatEx(ObjIdx, 1);
			if( GetSeasonalEventStatValue(ObjIdx) >= ZedsThrowSeaRequired )
				FinishedObjectiveEx(SEI_SUMMER, ObjIdx);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
	local bool CanIncreaseWave;

	CanIncreaseWave = false;

	// Complete 100 waves on Rig
	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( ClassIsChildOf(GameClass, class'KFGameInfo_Endless') )
		{
			if( LastWaveFinished != WaveNum )
			{
				CanIncreaseWave = true;
				LastWaveFinished = WaveNum;
			}
		}
		else CanIncreaseWave = true;

		if( CanIncreaseWave )
			IncrementSeasonalEventStatEx(ObjIdx, 1);

		if( GetSeasonalEventStatValue(ObjIdx) >= WavesRequired )
			FinishedObjectiveEx(SEI_SUMMER, ObjIdx);
	}

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && ClassIsChildOf(GameClass, class'KFGameInfo_Endless') && Difficulty >= `DIFFICULTY_HARD )
		FinishedObjectiveEx(SEI_Summer, ObjIdx);
}

defaultproperties
{
	ZedsKillRequired=1500
	WavesRequired=100
	ZedsThrowSeaRequired=50
	EndlessWaveRequired=15
	LastWaveFinished=-1
}