class KFProj_RicochetStickBulletProxy extends Object;

stripped simulated function context(KFProj_RicochetStickBullet.Stick) Stick(StickInfo MyStickInfo, bool bReplicated )
{
	if( WorldInfo.NetMode != NM_DedicatedServer && ProjEffects!=None )
	{
		ProjEffects.DeactivateSystem();

		ProjEffects.SetTemplate(ProjPickupTemplate);
		ProjEffects.ActivateSystem();
		ProjEffects.SetVectorParameter('Rotation', vect(0,0,0));
	}

	if( WorldInfo.NetMode != NM_DedicatedServer && !bStuck )
		`ImpactEffectManager.PlayImpactEffects(Location, Instigator, MyStickInfo.HitNormal, ImpactEffects);

	if( !IsZero(DecodeSmallVector(MyStickInfo.RayDir)) )
		SetRotation(Rotator(DecodeSmallVector(MyStickInfo.RayDir)));
	else SetRotation(Rot(0,0,0));

	SetPhysics(PHYS_None);

	if( bReplicated )
	{
		SetLocation(MyStickInfo.HitLocation);
		bStuck = true;
	}
	else if( Role == ROLE_Authority )
	{
		bStuck = true;
		LifeSpan = `GetURI().CurrentPickupLifespan;
	}

	if( bStopAmbientSoundOnExplode )
		StopAmbientSound();

	if( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
	{
		DelayedStickInfo = MyStickInfo;
		SetTimer(0.01, false, nameof(DelayedStick));
	}
	else
	{
		if( Role == ROLE_Authority )
		{
			RepStickInfo = MyStickInfo;
			bForceNetUpdate = TRUE;
			NetUpdateFrequency = 3;
		}

		GotoState('Pickup');
	}
}