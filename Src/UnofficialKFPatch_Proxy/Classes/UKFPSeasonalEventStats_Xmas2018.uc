class UKFPSeasonalEventStats_Xmas2018 extends UKFPSeasonalEventStats;

var int PerfectEscortsRequired, ZedKillsRequired, BossDeathsRequired, PerfectEscortCount, ZedKillsCount;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 0; // complete all escorts at full health (Santa's Workshop)
	bObjectiveIsValidForMap[1] = 0; // complete weekly event (Shopping Spree)
	bObjectiveIsValidForMap[2] = 1; // kill zeds (as an individual) (any map)
	bObjectiveIsValidForMap[3] = 1; // kill bosses (as a team) (any map)
	bObjectiveIsValidForMap[4] = 0; // defeat Krampus on Hard (Santa's Workshop)

    if( InStr(MapName, "KF-SantasWorkshop", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}
    else if( InStr(MapName, "KF-ShoppingSpree", false, true) != INDEX_NONE )
		bObjectiveIsValidForMap[1] = 1;
       
    SetSeasonalEventStatsMaxEx(0, 0, ZedKillsRequired, BossDeathsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) && IsEventObjectiveComplete(1) && IsEventObjectiveComplete(2) && IsEventObjectiveComplete(3) && IsEventObjectiveComplete(4))
		GrantEventItemEx(5378);
}

static private event bool AllowEventBossOverrideForMap(string MapName)
{
	return InStr(MapName, "KF-SantasWorkshop", false, true) != INDEX_NONE;
}

simulated function OnMapObjectiveDeactivated(Actor ObjectiveInterfaceActor)
{
	if( bObjectiveIsValidForMap[0] != 0 && KFGameReplicationInfo(Outer.MyKFPC.WorldInfo.GRI).GameDifficulty >= `DIFFICULTY_HARD )
	{
		if( KFMapObjective_EscortPawns(ObjectiveInterfaceActor) != None && KFMapObjective_EscortPawns(ObjectiveInterfaceActor).CompletionPct > 0.99f )
		{
			if( ++PerfectEscortCount == PerfectEscortsRequired )
				FinishedObjectiveEx(SEI_Winter, 0);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if( bObjectiveIsValidForMap[2] != 0 )
	{
        IncrementSeasonalEventStatEx(2, 1);
        if( GetSeasonalEventStatValue(2) >= ZedKillsRequired )
            FinishedObjectiveEx(SEI_Winter, 2);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( bObjectiveIsValidForMap[4] != 0 )
	{
		if( GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Winter, 4);
	}
	else if( bObjectiveIsValidForMap[1] != 0 )
	{
		if( GameClass == class'KFGameInfo_WeeklySurvival' )
			FinishedObjectiveEx(SEI_Winter, 1);
	}
}

simulated function OnBossDied()
{
	if( bObjectiveIsValidForMap[3] != 0 )
	{
        IncrementSeasonalEventStatEx(3, 1);
        if( GetSeasonalEventStatValue(3) >= BossDeathsRequired )
            FinishedObjectiveEx(SEI_Winter, 3);
	}
}

defaultproperties
{
	PerfectEscortsRequired=3
	ZedKillsRequired=2500
	BossDeathsRequired=25
}