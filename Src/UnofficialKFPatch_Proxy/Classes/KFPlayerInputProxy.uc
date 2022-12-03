class KFPlayerInputProxy extends Object;

stripped function context(KFPlayerInput.ApplyForceLookAtPawn) ApplyForceLookAtPawn( float DeltaTime, out int out_YawRot, out int out_PitchRot )
{
	local Vector RealTargetLoc, CamLoc;
	local Vector X, Y, Z;
	local Rotator CamRot, DeltaRot, CamRotWithFreeAim;
	local float AdhesionAmtY, AdhesionAmtZ, TargetRadius, TargetHeight;
	local int AdjustY, AdjustZ;
	local float DotDiffToTarget;
	local float UsedRotationRate;

	if( ForceLookAtPawn == None )
		return;

    if( Pawn != None && !Pawn.IsFirstPerson() )
        Pawn.GetActorEyesViewPoint( CamLoc, CamRot );
    else GetPlayerViewPoint( CamLoc, CamRot );
    
	CamRotWithFreeAim = CamRot + WeaponBufferRotation;
	GetAxes( CamRotWithFreeAim, X, Y, Z );

	if( ForceLookAtPawn != None && ForceLookAtPawn.Health > 0 )
	{
        RealTargetLoc = ForceLookAtPawn.GetAutoLookAtLocation(CamLoc, Pawn);

		if( bDebugAutoTarget )
		{
    		ForceLookAtPawn.GetBoundingCylinder( TargetRadius, TargetHeight );

			DrawDebugCylinder(RealTargetLoc+vect(0,0,5), RealTargetLoc-vect(0,0,5), 10, 12, 255, 0, 0);
            DrawDebugCylinder(ForceLookAtPawn.Location+vect(0,0,1)*TargetHeight, ForceLookAtPawn.Location-vect(0,0,1)*TargetHeight, TargetRadius, 12, 0, 255, 0);
		}

        DotDiffToTarget = Normal(RealTargetLoc - CamLoc) dot Normal(Vector(CamRotWithFreeAim));

    	if( DotDiffToTarget < ForceLookAtPawnMinAngle )
            UsedRotationRate = ForceLookAtPawnRotationRate;
        else UsedRotationRate = ForceLookAtPawnDampenedRotationRate;

		DeltaRot.Yaw = Rotator(RealTargetLoc - CamLoc).Yaw	- CamRotWithFreeAim.Yaw;
		DeltaRot.Pitch = Rotator(RealTargetLoc - CamLoc).Pitch	- CamRotWithFreeAim.Pitch;
		DeltaRot = Normalize( DeltaRot );

		if(	DeltaRot.Yaw != 0 )
		{
			AdhesionAmtY = UsedRotationRate;

			AdjustY = DeltaRot.Yaw * (AdhesionAmtY * DeltaTime);
			out_YawRot += AdjustY;
		}

		if( DeltaRot.Pitch != 0 )
		{
			AdhesionAmtZ = UsedRotationRate;

			AdjustZ = DeltaRot.Pitch * (AdhesionAmtZ * DeltaTime);
			out_PitchRot += AdjustZ;
		}
	}
}