class KFWeap_FlameBaseProxy extends Object;

simulated state WeaponEquipping
{
	stripped simulated function context(KFWeap_FlameBase.WeaponEquipping.BeginState) BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
        TurnOnPilot();
        if( !Instigator.IsFirstPerson() )
            ChangeVisibility(false);
	}
}

stripped simulated function context(KFWeap_FlameBase.ChangeVisibility) ChangeVisibility(bool bIsVisible)
{
    Super.ChangeVisibility(bIsVisible);

    if( bIsVisible && !bFireSpraying )
    {
    	FlamePool[0].SetHidden(true);
    	FlamePool[1].SetHidden(true);

    	FlamePool[0].SkeletalSprayMesh.SetHidden(true);
    	FlamePool[1].SkeletalSprayMesh.SetHidden(true);
    }
    else
    {
    	FlamePool[0].SetHidden(!bIsVisible);
    	FlamePool[1].SetHidden(!bIsVisible);

    	FlamePool[0].SkeletalSprayMesh.SetHidden(!bIsVisible);
    	FlamePool[1].SkeletalSprayMesh.SetHidden(!bIsVisible);
    }
    
    UpdateSprayVisibility(FlamePool[0], bIsVisible);
    UpdateSprayVisibility(FlamePool[1], bIsVisible);

	if( bIsVisible )
		TurnOnPilot();
	else TurnOffPilot();
}

stripped final simulated function context(KFWeap_FlameBase) UpdateSprayVisibility(KFSprayActor SprayActor, bool bIsVisible)
{
    local int Idx;
    
    if( SprayActor.CurrentSplashEffect != None )
        SprayActor.CurrentSplashEffect.SetHidden(!bIsVisible);
        
    SprayActor.SplashGlancingPSC.SetHidden(!bIsVisible);
    SprayActor.SplashDirectPSC.SetHidden(!bIsVisible);
    SprayActor.SplashPawnPSC.SetHidden(!bIsVisible);
    SprayActor.SplashMaterialBasedPSC.SetHidden(!bIsVisible);
    SprayActor.SprayStartPSC.SetHidden(!bIsVisible);
    
    for( Idx=0; Idx<SprayActor.BoneChain.Length; ++Idx )
    {
        if( SprayActor.BoneChain[Idx].BonePSC0 != None )
            SprayActor.BoneChain[Idx].BonePSC0.SetHidden(!bIsVisible);
        if( SprayActor.BoneChain[Idx].BonePSC1 != None )
            SprayActor.BoneChain[Idx].BonePSC1.SetHidden(!bIsVisible);
    }
    
    for( Idx=0; Idx<SprayActor.SprayLights.Length; ++Idx )
        SprayActor.SprayLights[Idx].Light.SetEnabled(bIsVisible);
}