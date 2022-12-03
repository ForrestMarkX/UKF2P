class KFSprayActorProxy extends Object;

stripped simulated function context(KFSprayActor.BeginSpray) BeginSpray()
{
	local int Idx;
	local float BlendTime;

	if( EndSpraySeqNode.bPlaying )
	{
		EndSpraySeqNode.bCauseActorAnimEnd = FALSE;
		CleanupEndFire();
	}

    if( Base.bHidden && KFWeapon(Base) == None )
        return;

    SkeletalSprayMesh.SetHidden(FALSE);

    SetHidden(FALSE);
	SetTickIsDisabled(false);
	bDetached = FALSE;
	bSkeletonHasBeenUpdated=FALSE;

	MaterialCurrentFadeVal = default.MaterialCurrentFadeVal;
	MIC_SprayMat0.SetScalarParameterValue('Fade', MaterialCurrentFadeVal);
	MIC_SprayMat1.SetScalarParameterValue('Fade', MaterialCurrentFadeVal);
	MIC_SprayMat2.SetScalarParameterValue('Fade', MaterialCurrentFadeVal);
	bSplashActive = false;
	bSprayMeshCollidedThisTick = false;
	bSprayMeshCollidedLastTick = false;
	HighestSprayMeshContactThisTick.BoneChainIndex = INDEX_NONE;
	bSprayMeshCollisionDuration = 0.f;
	Seeds.Length = 0;
	SeedSimTimeRemaining = 0.f;
	bWaitingToDestroy = false;
	ClearTimer(nameof(DestroyIfAllEmittersFinished));

	BlendTime = 0.f;
	if( EndSpraySeqNode.bPlaying )
		BlendTime = 0.15;

	StartSpraySeqNode.SetPosition(0.f, FALSE);

	StartSpraySeqNode.bPlaying = TRUE;
	AnimBlendNode.SetActiveChild(0, BlendTime);

    for( Idx=0; Idx<SprayLights.length; ++Idx )
        SprayLights[Idx].Light.SetEnabled(TRUE);

    if( SprayStartPSC != None )
        SprayStartPSC.ActivateSystem(TRUE);
    
	if( SeedWarmupTime > 0.f )
		UpdateSeeds(SeedWarmupTime);

	CurrentAge = 0.f;
    
    if( KFWeapon(Base) != None )
    {
        if( Base.bHidden || !Instigator.IsFirstPerson() )
        {
            if( CurrentSplashEffect != None )
                CurrentSplashEffect.SetHidden(true);
                
            SplashGlancingPSC.SetHidden(true);
            SplashDirectPSC.SetHidden(true);
            SplashPawnPSC.SetHidden(true);
            SplashMaterialBasedPSC.SetHidden(true);
            SprayStartPSC.SetHidden(true);
            
            for( Idx=0; Idx<BoneChain.Length; ++Idx )
            {
                if( BoneChain[Idx].BonePSC0 != None )
                    BoneChain[Idx].BonePSC0.SetHidden(true);
                if( BoneChain[Idx].BonePSC1 != None )
                    BoneChain[Idx].BonePSC1.SetHidden(true);
            }
            
            for( Idx=0; Idx<SprayLights.Length; ++Idx )
                SprayLights[Idx].Light.SetEnabled(false);
        }
        else
        {
            if( CurrentSplashEffect != None )
                CurrentSplashEffect.SetHidden(false);
                
            SplashGlancingPSC.SetHidden(false);
            SplashDirectPSC.SetHidden(false);
            SplashPawnPSC.SetHidden(false);
            SplashMaterialBasedPSC.SetHidden(false);
            SprayStartPSC.SetHidden(false);
            
            for( Idx=0; Idx<BoneChain.Length; ++Idx )
            {
                if( BoneChain[Idx].BonePSC0 != None )
                    BoneChain[Idx].BonePSC0.SetHidden(false);
                if( BoneChain[Idx].BonePSC1 != None )
                    BoneChain[Idx].BonePSC1.SetHidden(false);
            }
            
            for( Idx=0; Idx<SprayLights.Length; ++Idx )
                SprayLights[Idx].Light.SetEnabled(true);
        }

        for( Idx=0; Idx<SkeletalSprayMesh.GetNumElements(); Idx++ )
        {
            if( Base.bHidden || !Instigator.IsFirstPerson() )
                AssignMIC(Idx);
            else 
            {
                switch( Idx )
                {
                    case 0:
                        SkeletalSprayMesh.SetMaterial(Idx, MIC_SprayMat0);
                        break;
                    case 1:
                        SkeletalSprayMesh.SetMaterial(Idx, MIC_SprayMat1);
                        break;
                    case 2:
                        SkeletalSprayMesh.SetMaterial(Idx, MIC_SprayMat2);
                        break;
                    default:
                        SkeletalSprayMesh.SetMaterial(Idx, None);
                        break;
                }
            }
        }
    }

    if( Role == ROLE_Authority && ImpactProjectileClass != None )
    {
        if( KFPawn(Base) != None && KFPawn(Base).Controller != None && !KFPawn(Base).IsFirstPerson() )
            return;
        SetTimer( ImpactProjectileInterval, TRUE, nameof(LeaveImpactProjectile) );
    }
}

stripped final simulated function context(KFSprayActor) AssignMIC(int Index)
{
    local MaterialInstanceConstant Instance;
    
    Instance = MaterialInstanceConstant(SkeletalSprayMesh.GetMaterial(Index));
    if( Instance != None && Instance.Parent == Material'Wep_Mat_Lib.Wep_Basic_Glass_PM' )
        return;
    
    Instance = New(SkeletalSprayMesh) class'MaterialInstanceConstant';
    Instance.SetParent(Material'Wep_Mat_Lib.Wep_Basic_Glass_PM');
    Instance.SetScalarParameterValue('Glass_Opacity', 0.f);
    
    SkeletalSprayMesh.SetMaterial(Index, Instance);
}