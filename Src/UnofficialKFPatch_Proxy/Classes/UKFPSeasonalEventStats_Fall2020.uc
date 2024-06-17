class UKFPSeasonalEventStats_Fall2020 extends UKFPSeasonalEventStats;

var int DeathsRequired, DecapitationsRequired, EndlessWaveRequired, PowerUpsRequired, FallEventIndex;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 2000 Zeds on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete Weekly on Hellmark Station
	bObjectiveIsValidForMap[2] = 0; // Get the Hellish Rage from a Hellmark Station Obelisk 10 times
	bObjectiveIsValidForMap[3] = 0; // Decapitate 600 Zeds on Hellmark Station
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Hellmark Station
	
    if( InStr(MapName, "KF-HellmarkStation", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(DeathsRequired, 0, PowerUpsRequired, DecapitationsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8461); // Voodoo back pack
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
    
    if( !bKiller )
        return;
	
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= DeathsRequired )
			FinishedObjectiveEx(FallEventIndex, ObjIdx);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;

	ObjIdx = 1;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(FallEventIndex, ObjIdx);
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= PowerUpsRequired )
			FinishedObjectiveEx(FallEventIndex, ObjIdx);
	}
}

simulated function OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;
	
	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= DecapitationsRequired )
			FinishedObjectiveEx(FallEventIndex, ObjIdx);
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(FallEventIndex, ObjIdx);
}

defaultproperties
{
	DeathsRequired=2000
	DecapitationsRequired=600
	EndlessWaveRequired=15
	PowerUpsRequired=10
}