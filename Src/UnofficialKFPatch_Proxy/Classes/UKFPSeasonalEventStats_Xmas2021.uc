class UKFPSeasonalEventStats_Xmas2021 extends UKFPSeasonalEventStats;

var int WeaponRequiredPrice, DecapitationsRequired, DoshRequired, WeaponsRequired, EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Decapitate 1000 Zeds on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Carillon Hamlet
	bObjectiveIsValidForMap[2] = 0; // Earn 75,000 Dosh through kills, rewards and healing on Carillon Hamlet
	bObjectiveIsValidForMap[3] = 0; // Use the trader to purchase a total of 20 weapons that cost 1500 Dosh or more on Carrion Hamlet.
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Carillon Hamlet

    if( InStr(MapName, "KF-CarillonHamlet", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(DecapitationsRequired, 0, DoshRequired, WeaponsRequired, 0);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(9177);
	}
}

simulated function OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;
	
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= DecapitationsRequired )
			FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
    
	ObjIdx = 1;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && GameClass == class'KFGameInfo_WeeklySurvival' )
        FinishedObjectiveEx(SEI_Winter, ObjIdx);
}

simulated event OnWeaponPurchased(class<KFWeaponDefinition> WeaponDef, int Price)
{
	local int ObjIdx;

	ObjIdx = 3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && Price >= WeaponRequiredPrice )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= WeaponsRequired )
			FinishedObjectiveEx(SEI_Winter, ObjIdx);
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
	local int TotalDoshEarned;
	
	ObjIdx = 2;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		TotalDoshEarned = Outer.MyKFPC.MatchStats.TotalDoshEarned + Outer.MyKFPC.MatchStats.GetDoshEarnedInWave();
		if( TotalDoshEarned > 0 )
		{
			IncrementSeasonalEventStatEx(ObjIdx, TotalDoshEarned);
			if( GetSeasonalEventStatValue(ObjIdx) >= DoshRequired )
				FinishedObjectiveEx(SEI_Winter, ObjIdx);
		}
	}

	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
        FinishedObjectiveEx(SEI_Winter, ObjIdx);
}

defaultproperties
{ 
	DecapitationsRequired=1000
	DoshRequired=75000
	WeaponsRequired=20
	EndlessWaveRequired=15

	WeaponRequiredPrice=1500
}