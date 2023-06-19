class KFWeaponProxy extends Object;

stripped simulated event context(KFWeapon.PreBeginPlay) PreBeginPlay()
{
    if( IsA('KFWeap_AssaultRifle_Thompson') )
    {
        if( AttachmentArchetypeName ~= "WEP_TommyGun_ARCH.Wep_TommyGun_3P" )
            AttachmentArchetypeName = PathName(class'UKFPReplicationInfo'.default.TommyGun3PAttachment);
        if( MuzzleFlashTemplateName ~= "WEP_TommyGun_ARCH.Wep_TommyGun_MuzzleFlash" )
            MuzzleFlashTemplateName = PathName(class'UKFPReplicationInfo'.default.TommyGunMuzzleFlash);
        if( FirstPersonMeshName ~= "WEP_1P_TommyGun_MESH.Wep_1stP_TommyGun_Rig" )
            FirstPersonMeshName = PathName(class'UKFPReplicationInfo'.default.TommyGunFPMesh);
    }
    else if( IsA('KFWeap_Rifle_CenterfireMB464') && PickupMeshName ~= "WEP_3P_Centerfire_MESH.Wep_3rdP_Centerfire_Pickup" )
        PickupMeshName = PathName(class'UKFPReplicationInfo'.default.WeaponPickupMeshes[0]);
    else if( IsA('KFWeap_Rifle_M14EBR') && PickupMeshName ~= "WEP_3P_Centerfire_MESH.Wep_M14EBR_Pickup" )
        PickupMeshName = PathName(class'UKFPReplicationInfo'.default.WeaponPickupMeshes[1]);
    else if( IsA('KFWeap_Rifle_MosinNagant') && PickupMeshName ~= "WEP_3P_Mosin_MESH.WEP_3rdP_Mosin_Pickup" )
        PickupMeshName = PathName(class'UKFPReplicationInfo'.default.WeaponPickupMeshes[2]);
   
	Super.PreBeginPlay();

	MySkelMesh = KFSkeletalMeshComponent(Mesh);
	if( MySkelMesh == None )
		`Warn("A Invalid KFSkeletalMeshComponent(Mesh) cast!!!");

 	WeaponAnimSeqNode = KFAnimSeq_Tween( GetWeaponAnimNodeSeq() );

	InitializeAmmo();
	InitializeEquipTime();

	if( RecoilRate > 0 && RecoilBlendOutRatio > 0 )
	{
		RecoilYawBlendOutRate = maxRecoilYaw/RecoilRate * RecoilBlendOutRatio;
		RecoilPitchBlendOutRate = maxRecoilPitch/RecoilRate * RecoilBlendOutRatio;
	}

	if( Role == ROLE_Authority )
	{
		if( MedicCompClass != None )
		{
			MedicComp = Spawn(MedicCompClass, Owner);
			MedicComp.Init(self, AmmoCost[ALTFIRE_FIREMODE]);
			MedicCompRepActor = MedicComp;
		}

		if( TargetingCompClass != None )
		{
			TargetingComp = Spawn(TargetingCompClass, Owner);
			TargetingComp.Init(self);
			TargetingCompRepActor = TargetingComp;
		}
	}
}

stripped simulated function context(KFWeapon.SpawnProjectile) KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
	local KFProjectile	SpawnedProjectile;
	local int ProjDamage;
    
	SpawnedProjectile = Spawn(KFProjClass, Self,, RealStartLoc);
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		if( InstantHitDamage.Length > CurrentFireMode && InstantHitDamageTypes.Length > CurrentFireMode )
		{
            ProjDamage = GetModifiedDamage(CurrentFireMode);
            SpawnedProjectile.Damage = ProjDamage;
            SpawnedProjectile.MyDamageType = InstantHitDamageTypes[CurrentFireMode];
		}

		SpawnedProjectile.InitialPenetrationPower = GetInitialPenetrationPower(CurrentFireMode);
		SpawnedProjectile.PenetrationPower = SpawnedProjectile.InitialPenetrationPower;

		SpawnedProjectile.UpgradeDamageMod = GetUpgradeDamageMod();
		SpawnedProjectile.Init( AimDir );
	}

	if( MedicComp != None && KFProj_HealingDart(SpawnedProjectile) != None )
	{
		if( TargetingComp != None && TargetingComp.LockedTarget[1] != None )
			KFProj_HealingDart(SpawnedProjectile).SeekTarget = TargetingComp.LockedTarget[1];
	}
    
    if( SpawnedProjectile.bNoReplicationToInstigator && WorldInfo.NetMode == NM_DedicatedServer )
        CheckForReplication(SpawnedProjectile, AimDir, RealStartLoc);

	return SpawnedProjectile;
}

stripped final function context(KFWeapon) CheckForReplication(KFProjectile SpawnedProjectile, vector AimDir, vector RealStartLoc)
{
    local ReplicatedProjectile P;

    P = Spawn(class'ReplicatedProjectile', Self);
    P.RepInfo.Pawn = Instigator;
    P.RepInfo.ProjectileClass = SpawnedProjectile.Class;
    P.RepInfo.AimLoc = `ConvertVectorToUnCompressed(RealStartLoc);
    P.RepInfo.AimDir = `ConvertVectorToUnCompressed(AimDir);
    P.RepInfo.PenPower = SpawnedProjectile.InitialPenetrationPower;
    P.LifeSpan = SpawnedProjectile.LifeSpan;
    P.bNetDirty = true;
    P.bForceNetUpdate = true;
}

stripped function context(KFWeapon.GivenTo) GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	Super.GivenTo(thisPawn, bDoNotActivate);

	if( !Instigator.IsLocallyControlled() )
		ClearSkinItemId();

	LoadAllWeaponAssets();

	KFInventoryManager(InvManager).AddCurrentCarryBlocks( GetModifiedWeightValue() );
	KFPawn(Instigator).NotifyInventoryWeightChanged();

	if( MedicComp != None )
		MedicComp.OnWeaponGivenTo(thisPawn);
}

stripped reliable client function context(KFWeapon.ClientGivenTo) ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	LoadAllWeaponAssets();
	Super.ClientGivenTo(NewOwner, bDoNotActivate);
}

stripped final simulated function context(KFWeapon) LoadAllWeaponAssets()
{
    local UKFPReplicationInfo UKFRI;
    
    if( WeaponContentLoaded )
        return;
    
    UKFRI = `GetURI();
    if( UKFRI != None )
        UKFRI.LoadAllWeaponAssets(self);
}

stripped simulated function context(KFWeapon.GetWeaponAttachmentTemplate) KFWeaponAttachment GetWeaponAttachmentTemplate()
{
	if( AttachmentArchetype == None )
    {
		class'UKFPReplicationInfo'.static.StaticLoadWeaponAssets(Class);
        LoadAllWeaponAssets();
    }
    
	return AttachmentArchetype;
}

stripped simulated function context(KFWeapon.AttachWeaponTo) AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local KFPawn KFP;
	local int i;

	if( !WeaponContentLoaded )
		return;

	KFP = KFPawn(Instigator);
	if( KFP != None && KFP.ArmsMesh != None )
	{
		KFP.ArmsMesh.SetParentAnimComponent(MySkelMesh);
		KFP.ArmsMesh.SetFOV(MySkelMesh.FOV);
		for( i=0; i<`MAX_COSMETIC_ATTACHMENTS; i++ )
		{
			if( KFP.FirstPersonAttachments[i] != None )
			{
				if( SkeletalMeshComponent(KFP.FirstPersonAttachments[i]) != None )
				{
					SkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetParentAnimComponent(MySkelMesh);
					SkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetLODParent(MySkelMesh);
				}

				if( KFSkeletalMeshComponent(KFP.FirstPersonAttachments[i]) != None )
					KFSkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetFOV(MySkelMesh.FOV);
			}
		}
	}
    
    AttachComponent(Mesh);
    EnsureWeaponOverlayComponentLast();
    bPendingShow = true;

	if ( Instigator.IsFirstPerson() )
	{
		if( KFP.AllowFirstPersonPreshadows() )
			Mesh.bAllowPerObjectShadows = true;
		else Mesh.bAllowPerObjectShadows = false;

		SetHidden(true);

		if( KFP != None )
		{
			SetMeshLightingChannels(KFP.PawnLightingChannel);
			if( KFP.ArmsMesh != None )
			{
				Mesh.SetShadowParent(KFP.ArmsMesh);
				AttachComponent(KFP.ArmsMesh);

				for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
				{
					if (KFP.FirstPersonAttachments[i] != none)
						AttachComponent(KFP.FirstPersonAttachments[i]);
				}
			}
		}
	}
	else if( bWeaponNeedsServerPosition && (WorldInfo.NetMode == NM_DedicatedServer || (WorldInfo.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled())) )
		SetHidden(true);
	else
	{
		SetHidden(true);
		if( KFP != None )
		{
			KFP.ArmsMesh.SetHidden(true);
			for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
			{
				if (KFP.FirstPersonAttachments[i] != none)
					KFP.FirstPersonAttachments[i].SetHidden(true);
			}
		}
	}

	if( KFP != None )
		AttachThirdPersonWeapon(KFP);

	if( MedicComp != None )
		MedicComp.OnWeaponAttachedTo();

	if( TargetingComp != None )
		TargetingComp.OnWeaponAttachedTo();

	if( WorldInfo.NetMode != NM_DedicatedServer && SkinItemId > 0 && class'KFWeaponSkinList'.static.SkinNeedsCodeUpdates(SkinItemId) && Tag != 'ReplicatedWeapon' )
	{
		Timer_UpdateWeaponSkin();
		SetTimer(0.1f, true, 'Timer_UpdateWeaponSkin');
	}
}

stripped simulated event context(KFWeapon.SetPosition) SetPosition(KFPawn Holder)
{
	local vector DrawOffset, ViewOffset,  FinalLocation;
	local rotator NewRotation, FinalRotation, SpecRotation;
	local PlayerController PC;
	local KFPlayerController KFPC;
	local vector SpecViewLoc;
	local Rotator DebugRotationOffset;
	local rotator UsedBufferRotation;
	local vector CamLoc;
	local rotator CamRot;
	local int i;
	local KFPawn KFP;

	if( bForceHidden )
	{
		Mesh.SetHidden(true);
		Holder.ArmsMesh.SetHidden(true);
		KFP = KFPawn(Instigator);
		if( KFP != None )
		{
			for( i=0; i<`MAX_COSMETIC_ATTACHMENTS; i++ )
			{
				if( KFP.FirstPersonAttachments[i] != None )
					KFP.FirstPersonAttachments[i].SetHidden(true);
			}
		}
		NewRotation = Holder.GetViewRotation();
		SetLocation(Instigator.GetPawnViewLocation() + (HiddenWeaponsOffset >> NewRotation));
		SetRotation(NewRotation);
		SetBase(Instigator);
		return;
	}

	if( bPendingShow )
	{
		SetHidden(False);
		bPendingShow = FALSE;
	}
    
    Mesh.SetHidden(!Holder.IsFirstPerson());

	PC = GetALocalPlayerController();
	ViewOffset = PlayerViewOffset;

	if( class'Engine'.static.IsRealDStereoEnabled() )
		ViewOffset.X -= 30;

	if( Holder.Controller == None && KFDemoRecSpectator(PC) != None )
	{
		PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
		DrawOffset = ViewOffset >> SpecRotation;
		DrawOffset += Holder.WeaponBob(BobDamping, JumpDamping);
		FinalLocation = SpecViewLoc + DrawOffset;
		SetLocation(FinalLocation);
		SetBase(Holder);

		SetRotation(SpecRotation);
		return;
	}

    SetupHandOffset(Holder, ViewOffset);
    
	NewRotation = (Holder.Controller == None) ? Holder.GetBaseAimRotation() : Holder.Controller.Rotation;
	NewRotation += ZoomRotInterp;

	KFPC = KFPlayerController( Holder.Controller );
	if( KFPC != None )
	{
		if( bDebugRecoilPosition )
		{
			DebugRotationOffset.Pitch = RecoilISMaxPitchLimit;
			KFPC.WeaponBufferRotation = DebugRotationOffset;
		}

		if( KFPC.WeaponBufferRotation.Pitch < 32768 )
            UsedBufferRotation.Pitch = KFPC.WeaponBufferRotation.Pitch/IronSightMeshFOVCompensationScale;
        else UsedBufferRotation.Pitch = 65535 - ((65535 - KFPC.WeaponBufferRotation.Pitch)/IronSightMeshFOVCompensationScale);

        if( KFPC.WeaponBufferRotation.Yaw < 32768 )
            UsedBufferRotation.Yaw = KFPC.WeaponBufferRotation.Yaw/IronSightMeshFOVCompensationScale;
        else UsedBufferRotation.Yaw = 65535 - ((65535 - KFPC.WeaponBufferRotation.Yaw) / IronSightMeshFOVCompensationScale);

		NewRotation += UsedBufferRotation;
	}

	if( bFollowAnimSeqCamera && GetAnimSeqCameraPosition(CamLoc, CamRot) )
	{
		ViewOffset += CamLoc;
		NewRotation += CamRot;
	}

	FinalRotation = NewRotation;
    
    SetupViewRoll(Holder, FinalRotation);

	DrawOffset.Z += Holder.GetEyeHeight();
	DrawOffset += Holder.WeaponBob(BobDamping, JumpDamping);
	DrawOffset += (WeaponLag + ViewOffset) >> FinalRotation;

	FinalLocation = Holder.Location + DrawOffset;
    
    CalcViewModelView(self, BobDamping, FinalLocation, FinalRotation);

	SetLocation(FinalLocation);
	SetRotation(FinalRotation);
	SetBase(Holder);
}

stripped final simulated function context(KFWeapon) CalcViewModelView( KFWeapon W, float BobDamping, out vector Pos, out rotator Ang )
{
    local KFPawn_Human P;
	local ReplicationHelper RepInfo;
	
    P = KFPawn_Human(Instigator);
	RepInfo = `GetChatRep();
    if( P != None && RepInfo != None )
		RepInfo.CalcViewModelView(P, W, BobDamping, Pos, Ang);
}

stripped simulated event context(KFWeapon.HandleRecoil) HandleRecoil()
{
	local rotator NewRecoilRotation;
	local float CurrentRecoilModifier;
	local KFPawn KFP;

	if( Instigator == None )
		return;
        
	if( MedicComp != None )
		MedicComp.AdjustRecoil(CurrentFireMode);

	CurrentRecoilModifier = GetUpgradedRecoilModifier(CurrentFireMode);

	NewRecoilRotation.Pitch = RandRange( minRecoilPitch, maxRecoilPitch );
	NewRecoilRotation.Yaw = RandRange( minRecoilYaw, maxRecoilYaw );

	if( Instigator.Physics == PHYS_Falling )
		CurrentRecoilModifier *= FallingRecoilModifier;

	KFP = KFPawn(Instigator);
	if( KFP != None )
	{
		if( VSizeSq(Instigator.Velocity) > 50 )
		{
			if( Instigator.bIsWalking )
				CurrentRecoilModifier *= WalkingRecoilModifier;
			else CurrentRecoilModifier *= JoggingRecoilModifier;
		}
        
		if( Instigator.bIsCrouched )
			CurrentRecoilModifier *= StanceCrouchedRecoilModifier;

		if( !bUsingSights )
			CurrentRecoilModifier *= HippedRecoilModifier;
	}
    
    if( GetPerk() != None )
        ModifyRecoil( CurrentRecoilModifier );

	NewRecoilRotation *= CurrentRecoilModifier;
    LastRecoilModifier = CurrentRecoilModifier;

	SetRecoil(NewRecoilRotation,RecoilRate);
}

stripped simulated static event context(KFWeapon.GetWeaponPerkClass) class<KFPerk> GetWeaponPerkClass( class<KFPerk> InstigatorPerkClass )
{
    return GetWeaponActualPerkClass(InstigatorPerkClass);
}

stripped final simulated static function context(KFWeapon) class<KFPerk> GetWeaponActualPerkClass(class<KFPerk> InstigatorPerkClass )
{
    local int i;
    
	if( default.AssociatedPerkClasses.Length > 1 )
	{
        for( i=0; i<default.AssociatedPerkClasses.Length; i++ )
        {
            if( ClassIsChildOf(InstigatorPerkClass, default.AssociatedPerkClasses[i]) )
                return InstigatorPerkClass;
        }
	}
    
	return default.AssociatedPerkClasses[0];
}

stripped static final simulated function context(KFWeapon) EWeaponHand GetHand(KFWeapon W)
{
	local ReplicationHelper RHI;
    
    if( W.Instigator == None )
        return HAND_Right;
        
    RHI = `GetURI().GetPlayerChat(W.Instigator.PlayerReplicationInfo);
	if( RHI != None )
        return RHI.GetHand(W);

	return HAND_Right;
}

stripped static final simulated function context(KFWeapon) vector GetWeaponHandFireOffset(KFWeapon W)
{
	local vector FinalFireOffset;
	
	FinalFireOffset = W.FireOffset;
	switch ( GetHand(W) )
	{
		case HAND_Left:
			FinalFireOffset.Y *= -1.f;
			break;
		case HAND_Centered:
			FinalFireOffset.Y = 0.f;
			break;
	}
	
	return FinalFireOffset;
}

stripped simulated event context(KFWeapon.GetMuzzleLoc) vector GetMuzzleLoc()
{
    local vector X, Y, Z;
    local Rotator ViewRotation;

	if( Instigator != None )
	{
		if( bUsingSights )
		{
			ViewRotation = Instigator.GetViewRotation();

			if( KFPlayerController(Instigator.Controller) != None )
				ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;

			GetAxes(ViewRotation, X, Y, Z);

			return Instigator.GetWeaponStartTraceLocation() + X * FireOffset.X;
		}
		else
		{
			ViewRotation = Instigator.GetViewRotation();

			if( KFPlayerController(Instigator.Controller) != None )
				ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;

			return Instigator.GetPawnViewLocation() + (GetWeaponHandFireOffset(self) >> ViewRotation);
		}
	}

	return Location;
}

stripped final simulated function context(KFWeapon) AdjustWeaponPosition(out float ZAdjustment)
{
    local ReplicationHelper RHI;
    
    if( Instigator == None )
        return;

	RHI = `GetURI().GetPlayerChat(Instigator.PlayerReplicationInfo);
	if( RHI != None )
        RHI.AdjustWeaponPosition(self, ZAdjustment);
}

stripped simulated event context(KFWeapon.PostInitAnimTree) PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	WeaponAnimSeqNode = KFAnimSeq_Tween(SkelComp.FindAnimNode('WeaponSeq'));
	if( WeaponAnimSeqNode == None )
		WeaponAnimSeqNode = KFAnimSeq_Tween( GetWeaponAnimNodeSeq() );

	IdleBobBlendNode = AnimNodeAdditiveBlending(SkelComp.FindAnimNode('IdleBobAdditiveBlend'));
	ToggleAdditiveBobAnim(false, 0.f);

	EmptyMagBlendNode = AnimNodeBlendPerBone(SkelComp.FindAnimNode('EmptyMagBlend'));
	if( EmptyMagBlendNode != none && BonesToLockOnEmpty.Length > 0 )
		BuildEmptyMagNodeWeightList( EmptyMagBlendNode, BonesToLockOnEmpty );

	if( bHasLaserSight )
		AttachLaserSight();
        
    SetupWeaponSkelControl(SkelComp);
}

stripped final simulated function context(KFWeapon) SetupWeaponSkelControl(SkeletalMeshComponent SkelComp)
{
    local int i;
    local ReplicationHelper RHI;
    
    RHI = `GetURI().GetPlayerChat(Instigator.PlayerReplicationInfo);
    if( RHI != None )
    {
        for( i=0; i<SkelComp.SkelControlTickArray.Length; i++ )
        {
            if( KFSkelControl_WeaponTilt(SkelComp.SkelControlTickArray[i]) != None )
            {
                RHI.WeaponTiltSkelControl = KFSkelControl_WeaponTilt(SkelComp.SkelControlTickArray[i]);
                RHI.DefaultWeaponTiltRot = RHI.WeaponTiltSkelControl.WeaponBoneRotation;
                RHI.WeaponTiltSkelControl.WeaponBoneRotation.Roll = 0;
                break;
            }
        }
    }
}

stripped final simulated function context(KFWeapon) SetupHandOffset(KFPawn Holder, out vector ViewOffset)
{
    local ReplicationHelper RHI;
    
    RHI = `GetURI().GetPlayerChat(Holder.PlayerReplicationInfo);
    if( RHI == None )
        return;
        
	switch ( GetHand(self) )
	{
		case HAND_Left:
			if( RHI != None && RHI.bUndoWeaponFlip )
			{
				Mesh.SetScale3D(default.Mesh.Scale3D);
				Mesh.SetRotation(default.Mesh.Rotation);
			}
			else
			{
				Mesh.SetScale3D(default.Mesh.Scale3D * vect(1,-1,1));
				Mesh.SetRotation(rot(0,0,0) - default.Mesh.Rotation);
				ViewOffset.Y *= -1.f;
			}
			break;
		case HAND_Centered:
			ViewOffset.Y = 0.f;
			if( !bUsingSights || IsA('KFWeap_Minigun') )
				AdjustWeaponPosition(ViewOffset.Z);
		case HAND_Right:
		default:
			Mesh.SetScale3D(default.Mesh.Scale3D);
			Mesh.SetRotation(default.Mesh.Rotation);
			break;
	}
}

stripped final simulated function context(KFWeapon) float CalcWeaponTiltWeight(KFPawn P)
{
    local matrix ViewMatrix;
    local vector PlayerVel;
    local float NormX, NormY, NormZ, Adjuster;
    local ReplicationHelper RHI;
	
	if( P == None || WorldInfo.NetMode == NM_DedicatedServer )
		return 0.f;
    
    RHI = `GetURI().GetPlayerChat(P.PlayerReplicationInfo);
    if( RHI == None || RHI.WeaponTiltSkelControl == None )
        return 0.f;

    ViewMatrix = MakeRotationMatrix(P.GetViewRotation());
    PlayerVel = Normal(P.Velocity);
    
    NormY = ViewMatrix.YPlane.Y * PlayerVel.Y;
    NormX = ViewMatrix.YPlane.X * PlayerVel.X;
    NormZ = ViewMatrix.YPlane.Z * PlayerVel.Z;

    Adjuster = (NormX + NormY) + NormZ;
    
    if ( Adjuster < -RHI.WeaponTiltSkelControl.StrafeDeadzoneCos )
        return ((1.f - RHI.WeaponTiltSkelControl.StrafeDeadzoneCos) + Adjuster) / RHI.WeaponTiltSkelControl.StrafeDeadzoneCos;
    if ( Adjuster <= RHI.WeaponTiltSkelControl.StrafeDeadzoneCos )
        return 0.f;
        
    return (Adjuster - (1.f - RHI.WeaponTiltSkelControl.StrafeDeadzoneCos)) / RHI.WeaponTiltSkelControl.StrafeDeadzoneCos;
}

stripped final simulated function context(KFWeapon) SetupViewRoll(KFPawn Holder, out rotator FinalRotation)
{
    local rotator Target;
    local ReplicationHelper RHI;
	
	if( Holder == None )
		return;
    
    RHI = `GetURI().GetPlayerChat(Holder.PlayerReplicationInfo);
    if( RHI == None )
        return;
    
    Target = RHI.DefaultWeaponTiltRot;
    if( VSizeSq(Holder.Velocity) > 100.f && !bUsingSights )
        Target.Roll *= CalcWeaponTiltWeight(Holder);
    else Target.Roll = 0;
    
    if( Target.Roll != RHI.CurWeaponAngMod.Roll )
        RHI.CurWeaponAngMod = RInterpTo(RHI.CurWeaponAngMod, Target, WorldInfo.DeltaSeconds * CustomTimeDilation, 8.f);
        
    FinalRotation.Roll = RHI.CurWeaponAngMod.Roll;
}