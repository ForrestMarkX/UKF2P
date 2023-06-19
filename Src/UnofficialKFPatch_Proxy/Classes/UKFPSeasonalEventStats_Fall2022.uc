class UKFPSeasonalEventStats_Fall2022 extends UKFPSeasonalEventStats;

var int BossKillsRequired, ZedsInBonfiresRequired, EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on BarmwichTown
	bObjectiveIsValidForMap[2] = 0; // Open the Weapon Room
	bObjectiveIsValidForMap[3] = 0; // Make 50 Zeds to pass through the bonfires of Barmwitch Town
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Barmwitch Town

    if( InStr(MapName, "KF-BarmwichTown", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

    SetSeasonalEventStatsMaxEx(BossKillsRequired, 0, 0, ZedsInBonfiresRequired, EndlessWaveRequired);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(9424);
	}
}

// Kill 15 Bosses on any map or mode
simulated function OnBossDied()
{
	local int ObjIdx;
    
	ObjIdx = 0;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= BossKillsRequired )
			FinishedObjectiveEx(SEI_Fall, ObjIdx);
	}
}

// Complete the Weekly on Netherhold
simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
    
    ObjIdx = 1;
    if( bObjectiveIsValidForMap[ObjIdx] != 0 && ClassIsChildOf(GameClass, class'KFGameInfo_WeeklySurvival') )
        FinishedObjectiveEx(SEI_Fall, ObjIdx);
}

// Complete wave 15 on Endless Hard or higher difficulty on Netherhold
simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
    
	ObjIdx = 4;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( WaveNum >= EndlessWaveRequired && ClassIsChildOf(GameClass, class'KFGameInfo_Endless') && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Fall, ObjIdx);
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int WeaponRoomIdx, BonfireIdx;
    
	WeaponRoomIdx = 2;
	BonfireIdx = 3;

	if( EventIndex == SEI_Fall )
	{
		if( ObjectiveIndex == WeaponRoomIdx )
		{
			if( bObjectiveIsValidForMap[ObjectiveIndex] != 0 )
				FinishedObjectiveEx(SEI_Fall, ObjectiveIndex);
		}
		else if( ObjectiveIndex == BonfireIdx )
		{
			if( bObjectiveIsValidForMap[ObjectiveIndex] != 0 )
			{
				IncrementSeasonalEventStatEx(ObjectiveIndex, 1);
				if( GetSeasonalEventStatValue(ObjectiveIndex) >= ZedsInBonfiresRequired )
					FinishedObjectiveEx(SEI_Fall, ObjectiveIndex);
			}
		}
	}
}

defaultproperties
{
    BossKillsRequired=15
	EndlessWaveRequired=15
    ZedsInBonfiresRequired=50
}