class KFOnlineStatsWriteProxy extends Object;

`define RecordAARZedKill(KFPC,MonsterClass,DT) if(`KFPC != none && `KFPC.MatchStats != none ){`KFPC.MatchStats.RecordZedKill(`MonsterClass,`DT);}

stripped private event context(KFOnlineStatsWrite.AddToKills) AddToKills( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT, bool bKiller )
{
	SeasonalEventStats_OnZedKilled(MonsterClass, Difficulty, DT);

	if( !bKiller )
		return;

	IncrementIntStat( STATID_Kills, 1 );
	Kills++;

	if( !MonsterClass.default.bVersusZed && !MonsterClass.default.bLargeZed && !MonsterClass.static.IsABoss() )
        `GetChatRep().ReceiveKillMessage(MonsterClass,, MyKFPC.PlayerReplicationInfo, class<KFDamageType>(DT));

	if( IsStalkerKill( MonsterClass, DT ) )
	{
		AddStalkerKill( Difficulty );
	}
	else if( IsCrawlerKill( MonsterClass, DT ) )
	{
		AddCrawlerKill( Difficulty );
	}
	else if( IsFleshPoundKill( MonsterClass, DT ) )
	{
		AddFleshpoundKill( Difficulty );
	}
	else if( IsClotKill( MonsterClass, DT ) )
	{
		AddClotKill( Difficulty );
	}
	else if( IsClotSurvivalistKill( MonsterClass ) )
	{
		AddClotSurvivalistKill( Difficulty );
	}
	else if( IsBloatKill( MonsterClass, DT ) )
	{
		AddBloatKill( Difficulty );
	}

	`RecordAARZedKill(MyKFPC, MonsterClass, DT);

    AddToKillObjectives(MonsterClass);
}

stripped final simulated function context(KFOnlineStatsWrite) bool SeasonalEventIsValidEx()
{
    return SeasonalEvent != None;
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnMapObjectiveDeactivated) SeasonalEventStats_OnMapObjectiveDeactivated(Actor ObjectiveInterfaceActor)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnMapObjectiveDeactivated(ObjectiveInterfaceActor);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnMapCollectibleFound) SeasonalEventStats_OnMapCollectibleFound(PlayerReplicationInfo FinderPRI, int CollectibleID)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnMapCollectibleFound(FinderPRI, CollectibleID);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnHitTaken) SeasonalEventStats_OnHitTaken()
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnHitTaken();
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnHitGiven) SeasonalEventStats_OnHitGiven(class<DamageType> DT)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnHitGiven(DT);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnZedKilled) SeasonalEventStats_OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnZedKilled(MonsterClass, Difficulty, DT);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnZedKilledByHeadshot) SeasonalEventStats_OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnZedKilledByHeadshot(MonsterClass, Difficulty, DT);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnBossDied) SeasonalEventStats_OnBossDied()
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnBossDied();
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnTriggerUsed) SeasonalEventStats_OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnTriggerUsed(TriggerClass);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnTryCompleteObjective) SeasonalEventStats_OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnTryCompleteObjective(ObjectiveIndex, EventIndex);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnWeaponPurchased) SeasonalEventStats_OnWeaponPurchased(class<KFWeaponDefinition> WeaponDef, int Price)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnWeaponPurchased(WeaponDef, Price);
}

stripped final simulated function context(KFOnlineStatsWrite.SeasonalEventStats_OnAfflictionCaused) SeasonalEventStats_OnAfflictionCaused(EAfflictionType Type)
{
	if( SeasonalEventIsValidEx() )
		SeasonalEvent.OnAfflictionCaused(Type);
}