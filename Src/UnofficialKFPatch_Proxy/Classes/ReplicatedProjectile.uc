class ReplicatedProjectile extends Info;

struct FRepProjectileInfo
{
    var Pawn Pawn;
    var class<KFProjectile> ProjectileClass;
    var FUncompressedVector AimLoc, AimDir;
    var float PenPower;
};
var repnotify FRepProjectileInfo RepInfo;

replication
{
    if( bNetDirty && Role==ROLE_Authority )
        RepInfo;
}

simulated function ReplicatedEvent(name VarName)
{
    local KFPlayerController PC;
    local KFProjectile SpawnedProjectile;
    
	switch( VarName )
	{
    case 'RepInfo':
        PC = KFPlayerController(GetALocalPlayerController());
        if( PC != None && PC.RealViewTarget == RepInfo.Pawn.PlayerReplicationInfo )
        {
            SpawnedProjectile = Spawn(RepInfo.ProjectileClass,,, `ConvertUnCompressedVector(RepInfo.AimLoc));
            if( SpawnedProjectile != None )
            {
                SpawnedProjectile.InitialPenetrationPower = RepInfo.PenPower;
                SpawnedProjectile.PenetrationPower = RepInfo.PenPower;
                SpawnedProjectile.Instigator = RepInfo.Pawn;
                SpawnedProjectile.Init( `ConvertUnCompressedVector(RepInfo.AimDir) );
            }
        }
        Destroy();
        return;
	}

    Super.ReplicatedEvent(VarName);
}

defaultproperties
{
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
    bMovable=false
    bTickIsDisabled=true
    bNetTemporary=true
    bGameRelevant=true
	LifeSpan=+0014.000000
	NetPriority=+00002.500000
}