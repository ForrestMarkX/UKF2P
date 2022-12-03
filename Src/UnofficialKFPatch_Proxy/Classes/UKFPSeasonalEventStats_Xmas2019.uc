class UKFPSeasonalEventStats_Xmas2019 extends UKFPSeasonalEventStats;

var int TentacleTrapKillsRequired, SuctionTrapKillsRequired, MatriarchKillsRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 0; // Defeat any boss on Survival Hard or higher difficulty on Sanitarium
	bObjectiveIsValidForMap[1] = 0; // Use Tentacle Whip trap to kill 20 zeds on Sanitarium
	bObjectiveIsValidForMap[2] = 0; // Use Suction Trap to kill 20 zeds on Sanitarium
	bObjectiveIsValidForMap[3] = 0; // Kill the Matriarch 10 times on any map or mode
	bObjectiveIsValidForMap[4] = 0; // Complete Biotics Lab on Objective Hard or higher difficulty

    if( InStr(MapName, "KF-Sanitarium", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
	} 
    else if( InStr(MapName, "KF-BioticsLab", false, true) != INDEX_NONE )
		bObjectiveIsValidForMap[4] = 1;

	SetSeasonalEventStatsMaxEx(0, TentacleTrapKillsRequired, SuctionTrapKillsRequired, MatriarchKillsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if (IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4))
	{
		GrantEventItemEx(7831);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( bObjectiveIsValidForMap[0] != 0 )
	{
		if( GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Winter, 0);
	}

	if( bObjectiveIsValidForMap[4] != 0 )
	{
		if( GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Winter, 4);
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if( bObjectiveIsValidForMap[1] != 0 )
	{
		if( ClassIsChildOf(DT, class'KFDT_Trap_SanitariumTentacle') )
		{
			IncrementSeasonalEventStatEx(1, 1);
			if (Outer.GetSeasonalEventStatValue(1) >= TentacleTrapKillsRequired)
				FinishedObjectiveEx(SEI_Winter, 1);
		}
	}

	if( bObjectiveIsValidForMap[2] != 0 )
	{
		if( ClassIsChildOf(DT, class'KFDT_Trap_SanitariumSuction') )
		{
			IncrementSeasonalEventStatEx(2, 1);
			if( GetSeasonalEventStatValue(2) >= SuctionTrapKillsRequired )
				FinishedObjectiveEx(SEI_Winter, 2);
		}
	}

	if( ClassIsChildOf(MonsterClass, class'KFPawn_ZedMatriarch') )
	{
		IncrementSeasonalEventStatEx(3, 1);
		if( GetSeasonalEventStatValue(3) >= MatriarchKillsRequired )
			FinishedObjectiveEx(SEI_Winter, 3);
	}
}

defaultproperties
{
	TentacleTrapKillsRequired=20
	SuctionTrapKillsRequired=20
	MatriarchKillsRequired=10
}