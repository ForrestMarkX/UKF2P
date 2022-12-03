class KFAIControllerProxy extends Object;

stripped event context(KFAIController.FindNewEnemy) bool FindNewEnemy()
{
    local Pawn PotentialEnemy, BestEnemy;
    local float BestDist, NewDist;
    local int BestEnemyZedCount;
    local int PotentialEnemyZedCount;
    local bool bUpdateBestEnemy;
 
    if( Pawn == None )
        return false;
 
    BestDist = MaxInt;
    foreach WorldInfo.AllPawns( class'Pawn', PotentialEnemy )
    {
        if( !PotentialEnemy.IsAliveAndWell() || Pawn.IsSameTeam(PotentialEnemy) || !PotentialEnemy.CanAITargetThisPawn(self) )
            continue;

        NewDist = VSizeSq(PotentialEnemy.Location - Pawn.Location);
        if( BestEnemy == None || BestDist > NewDist )
        {
            BestEnemyZedCount = INDEX_None;
            bUpdateBestEnemy = true;
        }
        else
        {
            if( BestEnemyZedCount == INDEX_None )
                BestEnemyZedCount = NumberOfZedsTargetingPawn(BestEnemy);

            PotentialEnemyZedCount = NumberOfZedsTargetingPawn( PotentialEnemy );
            if( PotentialEnemyZedCount < BestEnemyZedCount )
            {
                BestEnemyZedCount = PotentialEnemyZedCount;
                bUpdateBestEnemy = true;
            }
        }

        if( bUpdateBestEnemy )
        {
            BestEnemy = PotentialEnemy;
            BestDist = NewDist;
            bUpdateBestEnemy = false;
        }
    }
 
    if( Enemy != None && BestEnemy != None && BestEnemy == Enemy )
        return false;
        
    if( BestEnemy != None )
    {
        ChangeEnemy(BestEnemy);
        return HasValidEnemy();
    }
 
    return false;
}