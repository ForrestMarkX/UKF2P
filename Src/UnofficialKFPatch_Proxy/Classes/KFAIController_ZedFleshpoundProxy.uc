class KFAIController_ZedFleshpoundProxy extends Object;

stripped function context(KFAIController_ZedFleshpound.SpawnEnraged) bool SpawnEnraged()
{
    return SpawnEnragedEx();
}

stripped final function context(KFAIController_ZedFleshpound) bool SpawnEnragedEx()
{
    local UKFPReplicationInfo URI;
    
    URI = `GetURI();
    if( URI != None && URI.bForceDisableRageSpawns && !MyKFPawn.IsABoss() )
        return false;
    
    RagePlugin.DoSpawnRage();
    return true;
}