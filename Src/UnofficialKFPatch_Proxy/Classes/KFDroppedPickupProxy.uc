class KFDroppedPickupProxy extends Object;

stripped simulated function context(KFDroppedPickup.SetPickupMesh) SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	local ActorComponent Comp;
	local SkeletalMeshComponent SkelMC;
	local StaticMeshComponent StaticMC;
	local KFGameInfo KFGI;
    
    NetUpdateFrequency = 10.f;

	if( Role == ROLE_Authority )
	{
		if( Inventory != None && Inventory.IsA('KFWeapon') )
		{
			SkinItemId = KFWeapon(Inventory).SkinItemId;
            bEmptyPickup = !KFWeapon(Inventory).HasAnyAmmo();
			bUpgradedPickup = KFWeapon(Inventory).CurrentWeaponUpgradeIndex > 0;
		}

        Lifespan = `GetURI().CurrentPickupLifespan;
        if( Lifespan > 0.f )
            SetTimer(Lifespan, false, 'TryFadeOut');
            
        AddPickupToList();
	}

	if( NewPickupMesh != None )
	{
		if( CollisionComponent == None || CollisionComponent.Class != NewPickupMesh.Class )
		{
			Comp = new(self) NewPickupMesh.Class(NewPickupMesh);
			MyMeshComp = MeshComponent(Comp);
			AttachComponent(Comp);
			MyCylinderComp = CylinderComponent(CollisionComponent);
			AlignMeshToCylinder();

			CollisionComponent = PrimitiveComponent(Comp);
		}
		else Comp = CollisionComponent;

		if( class<KFWeapon>(InventoryClass) != None )
			StaticMeshComponent(MyMeshComp).SetStaticMesh(GetPickupMesh(class<KFWeapon>(InventoryClass)));

		CollisionComponent.SetScale3D(NewPickupMesh.Scale3D);

		CollisionComponent.SetBlockRigidBody(TRUE);
		CollisionComponent.SetActorCollision(TRUE,FALSE);
		CollisionComponent.SetRBChannel( RBCC_Pickup );
		CollisionComponent.SetRBCollidesWithChannel( RBCC_Default, TRUE );
		if( !bIgnoreBlockingVolumes )
			CollisionComponent.SetRBCollidesWithChannel( RBCC_BlockingVolume, TRUE );
            
		CollisionComponent.SetNotifyRigidBodyCollision( TRUE );
		CollisionComponent.ScriptRigidBodyCollisionThreshold = 100;
		CollisionComponent.WakeRigidBody();

		SkelMC = SkeletalMeshComponent(CollisionComponent);
		if( SkelMC != None )
		{
			SkelMC.bUpdateSkelWhenNotRendered=FALSE;
			SkelMC.bComponentUseFixedSkelBounds=FALSE;

			SkelMC.PhysicsWeight = 1.f;
			SkelMC.SetHasPhysicsAssetInstance(TRUE);
			if( Role == ROLE_Authority )
				SetPhysics(PHYS_RigidBody);

			SkelMC.PhysicsAssetInstance.SetAllBodiesFixed(false);

			bCallRigidBodyWakeEvents = true;
		}
		else
		{
			StaticMC = StaticMeshComponent(CollisionComponent);
			if (StaticMC != none && bEnableStaticMeshRBPhys)
			{
				CollisionComponent.InitRBPhys();
				if( Role == ROLE_Authority && CollisionComponent.BodyInstance != None )
					SetPhysics(PHYS_RigidBody);

				bCallRigidBodyWakeEvents = true;

				MyMeshComp.SetRBLinearVelocity(Velocity);
				Velocity = vect(0,0,0);
			}
		}

		SetPickupSkin(SkinItemId);
	}
}

auto state Pickup
{
	stripped simulated function context(KFDroppedPickup.Pickup.BeginState) BeginState(Name PreviousStateName)
	{
        Lifespan = `GetURI().CurrentPickupLifespan;
        if( Lifespan > 0.f )
            SetTimer(LifeSpan - 1, false);
	}
}

stripped event context(KFDroppedPickup.Destroyed) Destroyed()
{
    RemovePickupFromList();
    
    Super.Destroyed();

    Inventory.Destroy();
    Inventory = None;
}

stripped final function context(KFDroppedPickup) AddPickupToList()
{
    local UKFPReplicationInfo UKFRI;
    local int Index;
    local FPlayerPickups Info;
    
    if( Instigator == None )
        return;
    
    UKFRI = `GetURI();
    if( UKFRI == None )
        return;
        
    Index = UKFRI.PlayerPickups.Find('PRI', Instigator.PlayerReplicationInfo);
    if( Index == INDEX_NONE )
    {
        Info.PRI = Instigator.PlayerReplicationInfo;
        Info.OwnerSteamID = UKFRI.OnlineSub.UniqueNetIdToInt64(Instigator.PlayerReplicationInfo.UniqueId);
        Info.OwnerName = Instigator.PlayerReplicationInfo.PlayerName;
        Info.Pickups.AddItem(self);
        UKFRI.PlayerPickups.AddItem(Info);
    }
    else UKFRI.PlayerPickups[Index].Pickups.AddItem(self);
}

stripped final function context(KFDroppedPickup) RemovePickupFromList()
{
    local UKFPReplicationInfo UKFRI;
    local int i, j;
    
    UKFRI = `GetURI();
    if( UKFRI == None )
        return;
        
    for( i=0; i<UKFRI.PlayerPickups.Length; i++ )
    {
        if( UKFRI.PlayerPickups[i].PRI == None )
        {
            UKFRI.PlayerPickups.Remove(i, 1);
            continue;
        }
        
        for( j=0; j<UKFRI.PlayerPickups[i].Pickups.Length; j++ )
        {
            if( UKFRI.PlayerPickups[i].Pickups[j] == self )
            {
                UKFRI.PlayerPickups[i].Pickups.Remove(j, 1);
                break;
            }
        }
    }
}

stripped function context(KFDroppedPickup.GiveTo) GiveTo(Pawn P)
{
    local KFWeapon KFW;
    local class<KFWeapon> KFWInvClass;
    local Inventory NewInventory;
    local KFInventoryManager KFIM;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None && KFGRI.bIsEndlessPaused )
		return;

    KFIM = KFInventoryManager(P.InvManager);
    if( KFIM != None )
    {
        KFWInvClass = class<KFWeapon>(InventoryClass);
        foreach KFIM.InventoryActors(class'KFWeapon', KFW)
        {
            if( KFW.Class == InventoryClass )
            {
                if( KFW.DualClass == None )
                {
                    PlayerController(P.Owner).ReceiveLocalizedMessage(class'KFLocalMessage_Game', GMT_AlreadyCarryingWeapon);
                    return;
                }
                break;
            }
            else if( KFWInvClass != None && KFW.Class == KFWInvClass.default.DualClass )
            {
                PlayerController(P.Owner).ReceiveLocalizedMessage(class'KFLocalMessage_Game', GMT_AlreadyCarryingWeapon);
                return;
            }
        }

		if( KFWInvClass != None && KFWeapon(Inventory) != None && !KFIM.CanCarryWeapon(KFWInvClass, KFWeapon(Inventory).CurrentWeaponUpgradeIndex) )
		{
			PlayerController(P.Owner).ReceiveLocalizedMessage(class'KFLocalMessage_Game', GMT_TooMuchWeight);
			return;
		}

        NewInventory = KFIM.CreateInventory(InventoryClass, true);
        if( NewInventory != None )
        {
            KFW = KFWeapon(NewInventory);
            if( KFW != None )
            {
                KFW.SetOriginalValuesFromPickup(KFWeapon(Inventory));
                KFW = KFIM.CombineWeaponsOnPickup(KFW);
                KFW.NotifyPickedUp();
                ClientForceWeaponSkin(P, KFW, SkinItemId);
            }

            Destroy();
        }
    }

    if( Role == ROLE_Authority )
        NotifyHUDofWeapon(P);
}

stripped final function context(KFDroppedPickup) ClientForceWeaponSkin(Pawn P, KFWeapon KFW, int SkinID)
{
    local UKFPReplicationInfo UKFPRep;
    local ReplicationHelper CRI;
    
    if( P == None )
        return;
    
    UKFPRep = `GetURI();
    if( UKFPRep == None )
        return;
        
    CRI = UKFPRep.GetPlayerChat(P.PlayerReplicationInfo);
    if( CRI == None )
        return;
        
    CRI.ClientForceWeaponSkin(KFW, SkinID);
}