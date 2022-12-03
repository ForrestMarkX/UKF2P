class KFCharacterInfo_HumanProxy extends Object;

stripped private function context(KFCharacterInfo_Human.SetBodyMeshAndSkin) SetBodyMeshAndSkin( byte CurrentBodyMeshIndex, byte CurrentBodySkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI )
{
	local SkeletalMesh CharBodyMesh;

    if( KFP.WorldInfo.NetMode == NM_DedicatedServer )
    {
        CurrentBodyMeshIndex = 0;
        CurrentBodySkinIndex = 0;
    }

	if( BodyVariants.Length > 0 )
	{
		CurrentBodyMeshIndex = (CurrentBodyMeshIndex < BodyVariants.Length) ? CurrentBodyMeshIndex : byte(0);
		CharBodyMesh = SkeletalMesh(`SafeLoadObject(BodyVariants[CurrentBodyMeshIndex].MeshName, class'SkeletalMesh'));

		if( CharBodyMesh != KFP.Mesh.SkeletalMesh )
		{
			KFP.Mesh.SetSkeletalMesh(CharBodyMesh);
			KFP.OnCharacterMeshChanged();
		}

		if( KFP.WorldInfo.NetMode != NM_DedicatedServer )
			SetBodySkinMaterial(BodyVariants[CurrentBodyMeshIndex], CurrentBodySkinIndex, KFP);
	}
	else `Warn("Character does not have a valid mesh");
}

stripped protected simulated function context(KFCharacterInfo_Human.SetBodySkinMaterial) SetBodySkinMaterial(OutfitVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP)
{
	local int i;
    
	if( KFP.WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( CurrentVariant.SkinVariations.Length > 0 )
            KFP.Mesh.SetMaterial(BodyMaterialID, MaterialInstance(`SafeLoadObject(CurrentVariant.SkinVariations[(NewSkinIndex < CurrentVariant.SkinVariations.Length) ? NewSkinIndex : byte(0)].SkinName, class'MaterialInstance')));
		else
		{
			for( i=0; i<KFP.Mesh.GetNumElements(); i++ )
				KFP.Mesh.SetMaterial(i, KFP.Mesh.GetMaterial(i));
		}
	}
}

stripped protected simulated function context(KFCharacterInfo_Human.SetHeadSkinMaterial) SetHeadSkinMaterial(OutfitVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP)
{
	local int i;
    
	if( KFP.WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( CurrentVariant.SkinVariations.Length > 0 )
            KFP.ThirdPersonHeadMeshComponent.SetMaterial(HeadMaterialID, MaterialInstance(`SafeLoadObject(CurrentVariant.SkinVariations[(NewSkinIndex < CurrentVariant.SkinVariations.Length) ? NewSkinIndex : byte(0)].SkinName, class'MaterialInstance')));
		else
		{
			for( i=0; i<KFP.ThirdPersonHeadMeshComponent.GetNumElements(); i++ )
				KFP.ThirdPersonHeadMeshComponent.SetMaterial(i, KFP.ThirdPersonHeadMeshComponent.GetMaterial(i));
		}
	}
}

stripped private function context(KFCharacterInfo_Human.SetHeadMeshAndSkin) SetHeadMeshAndSkin( byte CurrentHeadMeshIndex, byte CurrentHeadSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI )
{
	local string CharHeadMeshName;
	local SkeletalMesh CharHeadMesh;

	if ( HeadVariants.Length > 0 )
	{
		CurrentHeadMeshIndex = (CurrentHeadMeshIndex < HeadVariants.Length) ? CurrentHeadMeshIndex : byte(0);

		CharHeadMeshName = HeadVariants[CurrentHeadMeshIndex].MeshName;
		CharHeadMesh = SkeletalMesh(`SafeLoadObject(CharHeadMeshName, class'SkeletalMesh'));

		KFP.ThirdPersonHeadMeshComponent.SetSkeletalMesh(CharHeadMesh);
		KFP.ThirdPersonHeadMeshComponent.SetScale(DefaultMeshScale);

		KFP.ThirdPersonHeadMeshComponent.SetParentAnimComponent(KFP.Mesh);
		KFP.ThirdPersonHeadMeshComponent.SetShadowParent(KFP.Mesh);
		KFP.ThirdPersonHeadMeshComponent.SetLODParent(KFP.Mesh);

		KFP.AttachComponent(KFP.ThirdPersonHeadMeshComponent);

		if( KFP.WorldInfo.NetMode != NM_DedicatedServer )
			SetHeadSkinMaterial(HeadVariants[CurrentHeadMeshIndex], CurrentHeadSkinIndex, KFP);
	}
}

stripped protected simulated function context(KFCharacterInfo_Human.SetAttachmentMesh) SetAttachmentMesh(int CurrentAttachmentMeshIndex, int AttachmentSlotIndex, string CharAttachmentMeshName, name CharAttachmentSocketName, SkeletalMeshComponent PawnMesh, KFPawn KFP, bool bIsFirstPerson = false)
{
    local StaticMeshComponent StaticAttachment;
    local SkeletalMeshComponent SkeletalAttachment;
    local bool bIsSkeletalAttachment;
    local StaticMesh CharAttachmentStaticMesh;
    local SkeletalMesh CharacterAttachmentSkelMesh;
    local float MaxDrawDistance;
    local SkeletalMeshSocket AttachmentSocket;
    local vector AttachmentLocationRelativeToSocket, AttachmentScaleRelativeToSocket;
    local rotator AttachmentRotationRelativeToSocket;

    MaxDrawDistance = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.MaxDrawDistance;
    AttachmentLocationRelativeToSocket = CosmeticVariants[CurrentAttachmentMeshIndex].RelativeTranslation;
    AttachmentRotationRelativeToSocket = CosmeticVariants[CurrentAttachmentMeshIndex].RelativeRotation;
    AttachmentScaleRelativeToSocket = CosmeticVariants[CurrentAttachmentMeshIndex].RelativeScale;
    bIsSkeletalAttachment = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.bIsSkeletalAttachment;

    if( bIsSkeletalAttachment )
    {
        if( bIsFirstPerson && (SkeletalMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]) != None) )
            SkeletalAttachment = SkeletalMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]);
        else if( !bIsFirstPerson && (SkeletalMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]) != None) )
            SkeletalAttachment = SkeletalMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]);
        else
        {
            SkeletalAttachment = new(KFP) class'KFSkeletalMeshComponent';
            if( bIsFirstPerson )
                SetFirstPersonCosmeticAttachment(SkeletalAttachment);
            SkeletalAttachment.SetActorCollision(false, false);

            if( bIsFirstPerson )
                KFP.FirstPersonAttachments[AttachmentSlotIndex] = SkeletalAttachment;
            else KFP.ThirdPersonAttachments[AttachmentSlotIndex] = SkeletalAttachment;
        }

        CharacterAttachmentSkelMesh = SkeletalMesh(`SafeLoadObject(CharAttachmentMeshName, class'SkeletalMesh'));
        SkeletalAttachment.SetSkeletalMesh(CharacterAttachmentSkelMesh);

        SkeletalAttachment.SetParentAnimComponent(PawnMesh);
        SkeletalAttachment.SetLODParent(PawnMesh);
        SkeletalAttachment.SetScale(DefaultMeshScale);
        SkeletalAttachment.SetCullDistance(MaxDrawDistance);
        SkeletalAttachment.SetShadowParent(PawnMesh);
        SkeletalAttachment.SetLightingChannels(KFP.PawnLightingChannel);

        KFP.AttachComponent(SkeletalAttachment);
    }
    else
    {
        if( !bIsFirstPerson && (StaticMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]) != None) )
            StaticAttachment = StaticMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]);
        else if( bIsFirstPerson && (StaticMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]) != None) )
            StaticAttachment = StaticMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]);
        else
        {
            StaticAttachment = new(KFP) class'StaticMeshComponent';
            StaticAttachment.SetActorCollision(false, false);

            if( bIsFirstPerson )
                KFP.FirstPersonAttachments[AttachmentSlotIndex] = StaticAttachment;
            else KFP.ThirdPersonAttachments[AttachmentSlotIndex] = StaticAttachment;
        }

        CharAttachmentStaticMesh = StaticMesh(`SafeLoadObject(CharAttachmentMeshName, class'StaticMesh'));
        StaticAttachment.SetStaticMesh(CharAttachmentStaticMesh);

        StaticAttachment.SetScale(DefaultMeshScale);
        StaticAttachment.SetCullDistance(MaxDrawDistance);
        StaticAttachment.SetShadowParent(KFP.Mesh);
        StaticAttachment.SetLightingChannels(KFP.PawnLightingChannel);

        AttachmentSocket = PawnMesh.GetSocketByName(CharAttachmentSocketName);
        PawnMesh.AttachComponent(StaticAttachment, AttachmentSocket.BoneName, AttachmentSocket.RelativeLocation + AttachmentLocationRelativeToSocket, AttachmentSocket.RelativeRotation + AttachmentRotationRelativeToSocket, AttachmentSocket.RelativeScale * AttachmentScaleRelativeToSocket);
    }

    if( bIsFirstPerson )
        KFP.FirstPersonAttachmentSocketNames[AttachmentSlotIndex] = CharAttachmentSocketName;
    else KFP.ThirdPersonAttachmentSocketNames[AttachmentSlotIndex] = CharAttachmentSocketName;
}

stripped protected simulated function context(KFCharacterInfo_Human.SetAttachmentSkinMaterial) SetAttachmentSkinMaterial(int PawnAttachmentIndex, const out AttachmentVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP, optional bool bIsFirstPerson)
{
	local int i;
    
	if( KFP.WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( CurrentVariant.AttachmentItem.SkinVariations.Length > 0 )
		{
			if( NewSkinIndex < CurrentVariant.AttachmentItem.SkinVariations.Length )
			{
				if( bIsFirstPerson )
				{
					if( KFP.FirstPersonAttachments[PawnAttachmentIndex] != None )
						KFP.FirstPersonAttachments[PawnAttachmentIndex].SetMaterial(CurrentVariant.AttachmentItem.SkinMaterialID, MaterialInstance(`SafeLoadObject(CurrentVariant.AttachmentItem.SkinVariations[NewSkinIndex].Skin1pName, class'MaterialInstance')));
				}
				else KFP.ThirdPersonAttachments[PawnAttachmentIndex].SetMaterial(CurrentVariant.AttachmentItem.SkinMaterialID, MaterialInstance(`SafeLoadObject(CurrentVariant.AttachmentItem.SkinVariations[NewSkinIndex].SkinName, class'MaterialInstance')));
			}
			else RemoveAttachmentMeshAndSkin(PawnAttachmentIndex, KFP);
		}
		else
		{
			if( bIsFirstPerson )
			{
				if( KFP.FirstPersonAttachments[PawnAttachmentIndex] != None )
				{
					for( i=0; i<KFP.FirstPersonAttachments[PawnAttachmentIndex].GetNumElements(); i++ )
						KFP.FirstPersonAttachments[PawnAttachmentIndex].SetMaterial(i, KFP.FirstPersonAttachments[PawnAttachmentIndex].GetMaterial(i));
				}
			}
			else
			{
				for( i=0; i<KFP.ThirdPersonAttachments[PawnAttachmentIndex].GetNumElements(); i++ )
					KFP.ThirdPersonAttachments[PawnAttachmentIndex].SetMaterial(i, KFP.ThirdPersonAttachments[PawnAttachmentIndex].GetMaterial(i));
			}
		}
	}
}

stripped protected simulated function context(KFCharacterInfo_Human.SetWeeklyCowboyAttachmentSkinMaterial) SetWeeklyCowboyAttachmentSkinMaterial(int PawnAttachmentIndex, const out AttachmentVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP, optional bool bIsFirstPerson)
{
	local MaterialInstanceConstant MIC;
	
	if( KFP.WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( bIsFirstPerson )
		{
			if( KFP.FirstPersonAttachments[PawnAttachmentIndex] != None )
			{
				KFP.FirstPersonAttachments[PawnAttachmentIndex].SetMaterial(CurrentVariant.AttachmentItem.SkinMaterialID, CurrentVariant.AttachmentItem.SkinVariations[0].Skin1p);
				MIC = MaterialInstanceConstant(KFP.FirstPersonAttachments[PawnAttachmentIndex].GetMaterial(0));
			}
		}
		else
		{
			KFP.ThirdPersonAttachments[PawnAttachmentIndex].SetMaterial(CurrentVariant.AttachmentItem.SkinMaterialID, CurrentVariant.AttachmentItem.SkinVariations[0].Skin);
			MIC = MaterialInstanceConstant(KFP.ThirdPersonAttachments[PawnAttachmentIndex].GetMaterial(0));
		}

		if( MIC != None )
		{
			MIC.SetVectorParameterValue('color_monochrome', WWLHatMonoChromeValue);
			MIC.SetVectorParameterValue('Black_White_switcher', WWLHatColorValue);
		}
	}
}

stripped private function context(KFCharacterInfo_Human.SetAttachmentMeshAndSkin) SetAttachmentMeshAndSkin(int CurrentAttachmentMeshIndex, int CurrentAttachmentSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI)
{
	local string CharAttachmentMeshName;
	local name CharAttachmentSocketName;
	local int AttachmentSlotIndex;
	local KFGameReplicationInfo KFGRI;

	if( KFP.WorldInfo.NetMode == NM_DedicatedServer )
		return;

	AttachmentSlotIndex = GetAttachmentSlotIndex(CurrentAttachmentMeshIndex, KFP, KFPRI);
	if( AttachmentSlotIndex == INDEX_NONE )
		return;

	if( CosmeticVariants.Length > 0 && CurrentAttachmentMeshIndex < CosmeticVariants.Length )
	{
		CharAttachmentMeshName = Get1pMeshByIndex(CurrentAttachmentMeshIndex);
		if( CharAttachmentMeshName != "" )
		{
			CharAttachmentSocketName = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.SocketName1p;
			if( KFP.IsLocallyControlled() )
			{
				if( CharAttachmentSocketName != '' && KFP.Mesh.GetSocketByName(CharAttachmentSocketName) == None )
				{
					RemoveAttachmentMeshAndSkin(AttachmentSlotIndex, KFP, KFPRI);
					return;
				}
			}

			SetAttachmentMesh(CurrentAttachmentMeshIndex, AttachmentSlotIndex, CharAttachmentMeshName, CharAttachmentSocketName, KFP.ArmsMesh, KFP, true);

			KFGRI = KFGameReplicationInfo(KFP.WorldInfo.GRI);
			if( AttachmentSlotIndex == 2 && KFP != None && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 12 )
				SetWeeklyCowboyAttachmentSkinMaterial(AttachmentSlotIndex, CosmeticVariants[CurrentAttachmentMeshIndex], CurrentAttachmentSkinIndex, KFP, true);
			else SetAttachmentSkinMaterial(AttachmentSlotIndex, CosmeticVariants[CurrentAttachmentMeshIndex], CurrentAttachmentSkinIndex, KFP, true);
		}
		else
		{
			KFP.FirstPersonAttachments[AttachmentSlotIndex] = None;
			KFP.FirstPersonAttachmentSocketNames[AttachmentSlotIndex] = '';
		}

		CharAttachmentMeshName = GetMeshByIndex(CurrentAttachmentMeshIndex);
		if( CharAttachmentMeshName != "" )
		{
			CharAttachmentSocketName = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.SocketName;

			if( KFP.IsLocallyControlled() )
			{
				if( CharAttachmentSocketName != '' && KFP.Mesh.GetSocketByName(CharAttachmentSocketName) == None )
				{
					RemoveAttachmentMeshAndSkin(AttachmentSlotIndex, KFP, KFPRI);
					return;
				}
			}

			SetAttachmentMesh(CurrentAttachmentMeshIndex, AttachmentSlotIndex, CharAttachmentMeshName, CharAttachmentSocketName, KFP.Mesh, KFP, false);

			KFGRI = KFGameReplicationInfo(KFP.WorldInfo.GRI);
			if( AttachmentSlotIndex == 2 && KFP != None && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 12 )
				SetWeeklyCowboyAttachmentSkinMaterial(AttachmentSlotIndex, CosmeticVariants[CurrentAttachmentMeshIndex], CurrentAttachmentSkinIndex, KFP, false);
			else SetAttachmentSkinMaterial(AttachmentSlotIndex, CosmeticVariants[CurrentAttachmentMeshIndex], CurrentAttachmentSkinIndex, KFP, false);
		}
	}

	if( CurrentAttachmentMeshIndex == `CLEARED_ATTACHMENT_INDEX )
		RemoveAttachmentMeshAndSkin(AttachmentSlotIndex, KFP, KFPRI);
}

stripped simulated function context(KFCharacterInfo_Human.SetArmsMeshAndSkin) SetArmsMeshAndSkin(byte ArmsMeshIndex, byte ArmsSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI)
{
	local byte CurrentArmMeshIndex, CurrentArmSkinIndex;
	local string CharArmMeshName;
	local SkeletalMesh CharArmMesh;

	if( KFP.WorldInfo.NetMode != NM_DedicatedServer && KFP.IsHumanControlled() && KFP.IsLocallyControlled() )
	{
		if( CharacterArmVariants.Length > 0 )
		{
			CurrentArmMeshIndex = (ArmsMeshIndex < CharacterArmVariants.Length) ? ArmsMeshIndex : byte(0);
			CharArmMeshName = CharacterArmVariants[CurrentArmMeshIndex].MeshName;
			CharArmMesh = SkeletalMesh(`SafeLoadObject(CharArmMeshName, class'SkeletalMesh'));

			KFP.ArmsMesh.SetSkeletalMesh(CharArmMesh);

			if( CharacterArmVariants[CurrentArmMeshIndex].SkinVariants.Length > 0 )
				KFP.ArmsMesh.SetMaterial(0, MaterialInstance(`SafeLoadObject(CharacterArmVariants[CurrentArmMeshIndex].SkinVariantsName[(ArmsSkinIndex < CharacterArmVariants[CurrentArmMeshIndex].SkinVariants.Length) ? ArmsSkinIndex : byte(0)], class'MaterialInstance')));
			else KFP.ArmsMesh.SetMaterial(0, KFP.ArmsMesh.GetMaterial(0));
		}
		else if( ArmMesh != None )
		{
			KFP.ArmsMesh.SetMaterial(0, KFP.ArmsMesh.GetMaterial(0));
	        KFP.ArmsMesh.SetSkeletalMesh(ArmMesh);
		}
		else `Warn("Character does not have a valid arms mesh");
	}
}

stripped function context(KFCharacterInfo_Human.DetachConflictingAttachments) DetachConflictingAttachments(int NewAttachmentMeshIndex, KFPawn KFP, optional KFPlayerReplicationInfo KFPRI, optional out array<int> out_RemovedAttachments )
{
    // Do Nothing
    return;
}