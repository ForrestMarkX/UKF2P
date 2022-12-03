class KFOnlineStatsWriteOriginal extends Object;

private event AddToKills( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT, bool bKiller );
final simulated function SeasonalEventStats_OnMapObjectiveDeactivated(Actor ObjectiveInterfaceActor);
final simulated function SeasonalEventStats_OnMapCollectibleFound(PlayerReplicationInfo FinderPRI, int CollectibleID);
final simulated function SeasonalEventStats_OnHitTaken();
final simulated function SeasonalEventStats_OnHitGiven(class<DamageType> DT);
final simulated function SeasonalEventStats_OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT);
final simulated function SeasonalEventStats_OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT);
final simulated function SeasonalEventStats_OnBossDied();
final simulated function SeasonalEventStats_OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass);
final simulated function SeasonalEventStats_OnTryCompleteObjective(int ObjectiveIndex, int EventIndex);
final simulated function SeasonalEventStats_OnWeaponPurchased(class<KFWeaponDefinition> WeaponDef, int Price);
final simulated function SeasonalEventStats_OnAfflictionCaused(EAfflictionType Type);