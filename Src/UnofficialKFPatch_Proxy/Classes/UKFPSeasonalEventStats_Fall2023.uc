class UKFPSeasonalEventStats_Fall2023 extends UKFPSeasonalEventStats;

var int HansVolterKillsRequired, CollectiblesLimit, EndlessWaveRequired;
var transient string SavedMapName;

function Init(string MapName)
{
	local string CapsMapName;

	CapsMapName = Caps(MapName);

	SavedMapName = CapsMapName;

	bObjectiveIsValidForMap[0] = 1; // Kill Hans Volter in 5 different maps
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Castle Volter
	bObjectiveIsValidForMap[2] = 0; // Find ten Castle Volter's Collectibles
	bObjectiveIsValidForMap[3] = 0; // Unlock the Castle Volter's trophy room
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Castle Volter
	
    if( InStr(MapName, "KF-CastleVolter", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMaxEx(HansVolterKillsRequired, 0, CollectiblesLimit, 0, EndlessWaveRequired);
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(9754);
	}
}

simulated function OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
    ObjIdx = 1;
	
    if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjectiveEx(SEI_Fall, ObjIdx);
		}
	}

	CheckRestartObjective(2, CollectiblesLimit);
}

simulated function OnGameEnd(class<GameInfo> GameClass)
{
	CheckRestartObjective(2, CollectiblesLimit);
}

simulated function OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
    
	ObjIdx = 4;

	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD )
			FinishedObjectiveEx(SEI_Fall, ObjIdx);
	}
}

simulated function CheckRestartObjective(int ObjectiveIndex, int ObjectiveLimit)
{
	local int StatValue;

	StatValue = GetSeasonalEventStatValue(ObjectiveIndex);
	if( StatValue != 0 && StatValue < ObjectiveLimit )
		ResetSeasonalEventStatEx(ObjectiveIndex);
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

	ObjIdx=3;
	if( bObjectiveIsValidForMap[ObjIdx] != 0 && EventIndex == SEI_Fall && ObjectiveIndex == ObjIdx )
		FinishedObjectiveEx(EventIndex, ObjectiveIndex);
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
	local KFProfileSettings Profile;

	ObjIdx = 0;

	if( IsEventObjectiveComplete(ObjIdx) )
		return;

	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		if( MonsterClass == class'KFPawn_ZedHansBase' || MonsterClass == class'KFPawn_ZedHans' )
		{
			if( GetSeasonalEventStatValue(ObjIdx) < HansVolterKillsRequired )
			{
				Profile = KFProfileSettings(Outer.MyKFPC.OnlineSub.PlayerInterface.GetProfileSettings(Outer.MyKFPC.StoredLocalUserNum));
				if( Profile != None )
				{
					if( Profile.AddHansVolterKilledInMap(SavedMapName) )
					{
						IncrementSeasonalEventStatEx(ObjIdx, 1);
						if( GetSeasonalEventStatValue(ObjIdx) >= HansVolterKillsRequired )
							FinishedObjectiveEx(SEI_Fall, ObjIdx);
					}
				}
			}
		}
	}
}

simulated function OnCollectibleFound(int Limit)
{
	local int ObjIdx;

	ObjIdx = 2;

	if( bObjectiveIsValidForMap[ObjIdx] != 0 )
	{
		IncrementSeasonalEventStatEx(ObjIdx, 1);
		if( GetSeasonalEventStatValue(ObjIdx) >= CollectiblesLimit )
			FinishedObjectiveEx(SEI_Fall, ObjIdx);
	}	
}

defaultproperties
{
    HansVolterKillsRequired=5
	CollectiblesLimit=10
	EndlessWaveRequired=15
}
