class UKFPSeasonalEventStats_Summer2021 extends UKFPSeasonalEventStats;

var int ZedsStompRequired, LaserKillsRequired, JumpKillsRequired, EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Stomp on 50 Zeds
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Moonbase
	bObjectiveIsValidForMap[2] = 0; // Use the laser trap to kill 20 Zeds on Moonbase
	bObjectiveIsValidForMap[3] = 0; // Kill 300 Zeds while jumping in the air on Moonbase
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Moonbase

    if( InStr(MapName, "KF-Moonbase", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(ZedsStompRequired, 0, LaserKillsRequired, JumpKillsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(8844);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( bObjectiveIsValidForMap[1] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(SEI_Summer, 1);
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
	local KFPlayerController KFPC;
	local KFPawn_Human KFP;
    
    if( !bKiller )
        return;

	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && ClassIsChildOf(DT, class'KFDT_EMPTrap') )
	{
        IncrementSeasonalEventStatEx(ObjIdx, 1);
        if( GetSeasonalEventStatValue(ObjIdx) >= LaserKillsRequired )
            FinishedObjectiveEx(SEI_SUMMER, ObjIdx);
	}

	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		KFPC = MyKFPC;
		if( KFPC != None )
		{
			KFP = KFPawn_Human(KFPC.Pawn);
			if( KFP != None && KFP.Physics == PHYS_Falling )
			{
				IncrementSeasonalEventStatEx(ObjIdx, 1);
				if( GetSeasonalEventStatValue(ObjIdx) >= JumpKillsRequired )
					FinishedObjectiveEx(SEI_SUMMER, ObjIdx);
			}
		}
	}
}

simulated function OnHitGiven(class<DamageType> DT)
{
	local int ObjIdx;
    
	ObjIdx = 0;
	if( ClassIsChildOf(DT, class'DmgType_Crushed') )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= ZedsStompRequired )
			FinishedObjectiveEx(SEI_SUMMER, ObjIdx);
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(SEI_Summer, ObjIdx);
}

defaultproperties
{
	ZedsStompRequired=50
	LaserKillsRequired=20
	JumpKillsRequired=300	
	EndlessWaveRequired=15
}
