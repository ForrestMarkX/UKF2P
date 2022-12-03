class KFPawnProxy extends Object;

stripped simulated function context(KFPawn.SetWeaponAttachmentFromWeaponClass) SetWeaponAttachmentFromWeaponClass(class<KFWeapon> WeaponClass)
{
	if( WeaponClass == None )
	{
		WeaponAttachmentTemplate = None;
		WeaponAttachmentChanged();
	}
	else
	{
		if( WeaponClass.default.AttachmentArchetype == None )
            class'UKFPReplicationInfo'.static.StaticLoadWeaponAssets(WeaponClass); 
		else
		{
			WeaponAttachmentTemplate = WeaponClass.default.AttachmentArchetype;
			WeaponAttachmentChanged();
		}
	}
}

stripped simulated event context(KFPawn.OnAnimEnd) OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
    if( IsA('KFPawn_Human') && `GetURI() != None )
        `GetURI().PawnAnimEnd(self, SeqNode, PlayedTime, ExcessTime);
        
	if( SpecialMove != SM_None )
	{
		if( Mesh.TickGroup == TG_DuringAsyncWork && SpecialMoves[SpecialMove].bShouldDeferToPostTick )
		{
            SpecialMoves[SpecialMove].DeferredSeqName = SeqNode.AnimSeqName;
			`DeferredWorkManager.DeferSpecialMoveAnimEnd(SpecialMoves[SpecialMove]);
		}
		else SpecialMoves[SpecialMove].AnimEndNotify(SeqNode, PlayedTime, ExcessTime);
	}
}

stripped function context(KFPawn.JumpOffPawn) JumpOffPawn()
{
	local float Theta;

	if( Base == None || Base.Location.Z > Location.Z )
		return;
        
    if( KFPawn_ZedCrawler(Base) != None )
    {
        KFPawn_ZedCrawler(Base).Knockdown(Base.Velocity * 3, vect(1, 1, 1), Base.Location, 1000, 100);
        SetPhysics(PHYS_Falling);
        return;
    }

	Theta = 2.f * PI * FRand();
	SetPhysics(PHYS_Falling);

	if( Controller != None && !IsHumanControlled() )
	{
		Velocity.X += Cos(Theta) * (750 + CylinderComponent.CollisionRadius);
		Velocity.Y += Sin(Theta) * (750 + CylinderComponent.CollisionRadius);
		if( VSize2D(Velocity) > 2.0 * FMax(500.0, GroundSpeed) )
			Velocity = 2.0 * FMax(500.0, GroundSpeed) * Normal(Velocity);
		Velocity.Z = 400;

		AirControl = 0.05f;
		SetTimer(1.0, false, nameof(RestoreAirControlTimer));
	}
	else
	{
		Velocity.X += Cos(Theta) * (150 + CylinderComponent.CollisionRadius);
		Velocity.Y += Sin(Theta) * (150 + CylinderComponent.CollisionRadius);
		if( VSize2D(Velocity) > FMax(500.0, GroundSpeed) )
			Velocity = FMax(500.0, GroundSpeed) * Normal(Velocity);
		Velocity.Z = 200;
	}
}

stripped event context(KFPawn.PostBeginPlay) PostBeginPlay()
{
	Super.PostBeginPlay();

    if( IsA('KFPawn_Monster') )
        DelayPlayEntranceSound();
    else SoundGroupArch.PlayEntranceSound( self );

	if( WorldInfo.NetMode == NM_DedicatedServer )
		Mesh.bPauseAnims = true;
}

stripped final simulated function context(KFPawn) DelayPlayEntranceSound()
{
	local EntranceSoundPlayer ESP;

    ESP = new class'EntranceSoundPlayer';
    if( ESP != None )
    {
        ESP.PawnOwner = self;
        `TimerHelper.SetTimer(0.1f, false, 'DelayPlayEntranceSound', ESP);
    }
}

stripped simulated function context(KFPawn.WeaponBob) vector WeaponBob( float BobDamping, float JumpDamping )
{
	local Vector V;
	local KFPerk OwnerPerk;
    
	OwnerPerk = GetPerk();
	if( OwnerPerk != None && MyKFWeapon != None && MyKFWeapon.bUsingSights )
		OwnerPerk.ModifyWeaponBopDamping( BobDamping, MyKFWeapon );

	V = BobDamping * WalkBob;
	V.Z = (0.45 + 0.55 * BobDamping)*WalkBob.Z;
	if( !bWeaponBob || CheckForNoBob() )
		V = WalkBob;
	V.Z += JumpDamping *(LandBob - JumpBob);
    
	return V;
}

stripped final simulated function context(KFPawn) bool CheckForNoBob()
{
    local ReplicationHelper CRI;
    
    CRI = `GetChatRep();
    if( CRI != None && CRI.UKFPInteraction != None && CRI.UKFPInteraction.CurrentBobClass != None && !CRI.UKFPInteraction.CurrentBobClass.bAllowOriginalBobCode )
        return true;
        
    return false;
}

stripped simulated function context(KFPawn.PlayWeaponSwitch) PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon)
{
	MyKFWeapon = KFWeapon(Weapon);
    if( WorldInfo.NetMode != NM_DedicatedServer )
        CheckBobClass(OldWeapon, NewWeapon);
}

stripped final simulated function context(KFPawn) CheckBobClass(Weapon OldWeapon, Weapon NewWeapon)
{
    local ReplicationHelper CRI;
    
    CRI = `GetChatRep();
    if( CRI == None || CRI.UKFPInteraction == None )
        return;
        
    if( MyKFWeapon != None )
        MyKFWeapon.bUseAdditiveMoveAnim = (CRI.UKFPInteraction.CurrentBobClass != None && (CRI.UKFPInteraction.WeaponHand == HAND_Centered || CRI.UKFPInteraction.CurrentBobClass.bForceDisableAdditiveBobAnimation)) ? false : MyKFWeapon.default.bUseAdditiveMoveAnim;
}

stripped function context(KFPawn.SetSprinting) SetSprinting(bool bNewSprintStatus)
{
	if( bNewSprintStatus )
	{
        if( !bAllowSprinting )
            bNewSprintStatus = false;
		else if( bIsCrouched )
			bNewSprintStatus = false;
		else if( MyKFWeapon != None && !MyKFWeapon.AllowSprinting() )
			bNewSprintStatus = false;
	}

	bIsSprinting = bNewSprintStatus;
	if( MyKFWeapon != None )
    {
        if( bNewSprintStatus && ShouldNotAllowSprintAnimation() )
            return;
        MyKFWeapon.SetWeaponSprint(bNewSprintStatus);
    }
}

stripped final function context(KFPawn) bool ShouldNotAllowSprintAnimation()
{
    local ReplicationHelper CRI;
    
    CRI = `GetChatRep();
    if( CRI == None || CRI.UKFPInteraction == None )
        return false;
        
    return CRI.UKFPInteraction.CurrentBobClass != None && CRI.UKFPInteraction.WeaponHand == HAND_Centered;
}

stripped function context(KFPawn.DoJump) bool DoJump( bool bUpdating )
{
	if( Super.DoJump(bUpdating) && !IsDoingSpecialMove() )
	{
		if( MyKFWeapon != None && MyKFWeapon.bUsingSights && !MyKFWeapon.bKeepIronSightsOnJump )
			MyKFWeapon.PerformZoom(false);

        bJumping = true;
        NumJumpsRemaining = NumJumpsAllowed - 1;
        
        DoJumpGrunt();

		return true;
	}
    else if( NumJumpsRemaining > 0 && bJumping )
    {
        Velocity.Z = JumpZ;
        NumJumpsRemaining--;

        return true;
    }

	return false;
}

stripped final function context(KFPawn) DoJumpGrunt()
{
    local ReplicationHelper CRI;
    
    CRI = `GetChatRep();
    if( CRI == None || CRI.UKFPInteraction == None )
        return;
        
    if( CRI.UKFPInteraction.CurrentBobClass != None && CRI.UKFPInteraction.WeaponHand == HAND_Centered && VoiceGroupArch != None )
        PlaySoundBase(VoiceGroupArch.static.GetDialogAkEvent(53, false),,,,,, Rotation);
}