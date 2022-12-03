class UKFPSeasonalEventStats_Fall2018 extends UKFPSeasonalEventStats;

var int TrapKillsRequired, ZedKillsRequired, EndlessWaveRequired;
var int TotalTrapKills;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 0; // Kill 25 zeds with traps
	bObjectiveIsValidForMap[1] = 0; // Collect 10 glowing skulls
	bObjectiveIsValidForMap[2] = 0; // Kill 2500 Zeds
	bObjectiveIsValidForMap[3] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Monster Ball
	bObjectiveIsValidForMap[4] = 0; // Kill Hans Volter on Monster Ball

	if( InStr(MapName, "KF-MonsterBall", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(0, 0, ZedKillsRequired, 0, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
        // Halloween MKB skin
		GrantEventItemEx(6456);
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;
    
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( class<KFDamageType>(DT) != None && class<KFDamageType>(DT).default.bIsTrapDamage )
		{
			TotalTrapKills++;
			if( TotalTrapKills >= TrapKillsRequired )
				FinishedObjectiveEx(SEI_Fall, ObjIdx);
		}
	}
    
	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
        IncrementSeasonalEventStatEx(ObjIdx, 1);
        if( GetSeasonalEventStatValue(ObjIdx) >= ZedKillsRequired )
            FinishedObjectiveEx(SEI_Fall, ObjIdx);
	}
    
	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && class<KFPawn_ZedHans>(MonsterClass) != None )
        FinishedObjectiveEx(SEI_Fall, ObjIdx);
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
	
	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(SEI_Fall, ObjIdx);
}

simulated function OnAllMapCollectiblesFound()
{
    local int ObjIdx;
    
	ObjIdx = 1;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
        FinishedObjectiveEx(SEI_Fall, ObjIdx);
}

defaultproperties
{ 
	TrapKillsRequired=25
	ZedKillsRequired=2500
	EndlessWaveRequired=15
}