class UKFPSeasonalEventStats_Summer2023 extends UKFPSeasonalEventStats;

var int HRGBombardierZedsRequired, EMPRequired, StandYourGroundRequired, EndlessWaveRequired, SummerEventIndex;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 1500 Zeds with HRG Bombardier
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Subduction
	bObjectiveIsValidForMap[2] = 1; // Stun 2500 Zeds with EMP affliction
	bObjectiveIsValidForMap[3] = 1; // Complete 25 Stand your Ground objectives
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Subduction

    if( InStr(MapName, "KF-Subduction", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(HRGBombardierZedsRequired, 0, EMPRequired, StandYourGroundRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(9672);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( bObjectiveIsValidForMap[1] != 0 && ClassIsChildOf(GameClass, class'KFGameInfo_WeeklySurvival') )
        FinishedObjectiveEx(SEI_Summer, 1);
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int HRGBombardierIdx, EMPIdx, StandYourGroundIdx, ObjectiveLimit;
	local bool bValidIdx;

	HRGBombardierIdx = 0;
	EMPIdx = 2;
	StandYourGroundIdx = 3;

	bValidIdx = false;

	if( EventIndex == SummerEventIndex )
	{
		if( ObjectiveIndex == HRGBombardierIdx )
		{
			ObjectiveLimit = HRGBombardierZedsRequired;
			bValidIdx = true;
		}
		else if( ObjectiveIndex == EMPIdx )
		{
			ObjectiveLimit = EMPRequired;
			bValidIdx = true;
		}
		else if( ObjectiveIndex == StandYourGroundIdx )
		{
			ObjectiveLimit = StandYourGroundRequired;
			bValidIdx = true;
		}
		
		if( bValidIdx && bObjectiveIsValidForMap[ObjectiveIndex] != 0 )
		{
			IncrementSeasonalEventStatEx(ObjectiveIndex, 1);
			if( GetSeasonalEventStatValue(ObjectiveIndex) >= ObjectiveLimit )
				FinishedObjectiveEx(SummerEventIndex, ObjectiveIndex);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// Complete wave 15 on Endless Hard or higher difficulty on Subduction
	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SummerEventIndex, ObjIdx);
	}
}

simulated function OnAfflictionCaused(EAfflictionType Type)
{
	local int ObjIdx;

	// Stun 2500 Zeds with EMP affliction
	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( Type == AF_EMP )
		{
			IncrementSeasonalEventStatEx(ObjIdx, 1);
			if( GetSeasonalEventStatValue(ObjIdx) >= EMPRequired )
				FinishedObjectiveEx(SummerEventIndex, ObjIdx);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;

	// Kill 1500 Zeds with HRG Bombardier
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( DT == class'KFDT_Explosive_HRG_Warthog' ||  DT == class'KFDT_Explosive_HRG_Warthog_HighExplosive' || DT == class'KFDT_Ballistic_HRG_Warthog' )
		{
			IncrementSeasonalEventStatEx(ObjIdx, 1);
			if( GetSeasonalEventStatValue(ObjIdx) >= HRGBombardierZedsRequired )
				FinishedObjectiveEx(SummerEventIndex, ObjIdx);
		}
	}
}

defaultproperties
{
	HRGBombardierZedsRequired=1500
	EMPRequired=2500
	StandYourGroundRequired=25
	EndlessWaveRequired=15
	SummerEventIndex=SEI_Summer
}