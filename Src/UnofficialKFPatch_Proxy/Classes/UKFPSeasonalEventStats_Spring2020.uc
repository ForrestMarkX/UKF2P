class UKFPSeasonalEventStats_Spring2020 extends UKFPSeasonalEventStats;

var int ZedKillsRequired, BloodBlenderKillsRequired, TrapDoorKillsRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 1500 zeds on any map
	bObjectiveIsValidForMap[1] = 0; // Complete the weekly on Biolapse
	bObjectiveIsValidForMap[2] = 0; // Use the blood blender to kill 20 zeds on Biolapse
	bObjectiveIsValidForMap[3] = 0; // Use the trap doors to kill 20 zeds on Biolapse
	bObjectiveIsValidForMap[4] = 0; // Defeat any boss on Survival Hard or higher difficulty on Biolapse

    if( InStr(MapName, "KF-Biolapse", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(ZedKillsRequired, 0, BloodBlenderKillsRequired, TrapDoorKillsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8150);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;

	ObjIdx = 1;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( GameClass == class'KFGameInfo_WeeklySurvival' )
			FinishedObjectiveEx(SEI_Spring, ObjIdx);
	}

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Spring, ObjIdx);
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
		if( GetSeasonalEventStatValue(ObjIdx) >= ZedKillsRequired )
			FinishedObjectiveEx(SEI_Spring, ObjIdx);
	}

	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( ClassIsChildOf(DT, class'KFDT_Trap_BiolapseBloodBlender') )
		{
			IncrementSeasonalEventStatEx(ObjIdx, 1);
			if( GetSeasonalEventStatValue(ObjIdx) >= BloodBlenderKillsRequired )
				FinishedObjectiveEx(SEI_Spring, ObjIdx);
		}
	}

	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( ClassIsChildOf(DT, class'KFDT_Trap_BiolapseTrapDoor') )
		{
			IncrementSeasonalEventStatEx(ObjIdx, 1);
			if( GetSeasonalEventStatValue(ObjIdx) >= TrapDoorKillsRequired )
				FinishedObjectiveEx(SEI_Spring, ObjIdx);
		}
	}
}

defaultproperties
{
	ZedKillsRequired=1500
	BloodBlenderKillsRequired=20
	TrapDoorKillsRequired=20
}