class KFWeap_Pistol_AF2011Proxy extends Object;

stripped simulated function context(KFWeap_Pistol_AF2011.SpawnProjectile) KFProjectile SpawnProjectile(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	if( CurrentFireMode == GRENADE_FIREMODE )
		return Super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
    SpawnCorrectedProjectiles(KFProjClass, RealStartLoc, AimDir);
	return None;
}

stripped final simulated function context(KFWeap_Pistol_AF2011) SpawnCorrectedProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
    local vector X, Y, Z, OffsetMod;
    
    if( Instigator == None )
        return;
        
    GetAxes(Instigator.GetViewRotation(), X, Y, Z);
    
	OffsetMod = BarrelOffset * 0.5f;
    OffsetMod = (Y * OffsetMod.X) + (X * OffsetMod.Y) + (Z * OffsetMod.Z);
    
	Super.SpawnProjectile(KFProjClass, RealStartLoc + OffsetMod, AimDir);
	Super.SpawnProjectile(KFProjClass, RealStartLoc - OffsetMod, AimDir);
}