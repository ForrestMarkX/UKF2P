class ActorProxy extends Object;

stripped simulated event context(Actor.FellOutOfWorld) FellOutOfWorld(class<DamageType> dmgType)
{
    if( Role == ROLE_Authority && IsA('DroppedPickup') )
    {
        PickupFellOutOfWorld();
        return;
    }
    
	SetPhysics(PHYS_None);
	SetHidden(True);
	SetCollision(false,false);
	Destroy();
}

stripped final function context(DroppedPickup) PickupFellOutOfWorld()
{
    local KFGameReplicationInfo GRI;
    local KFTraderTrigger Trader;
    local vector BoxExtent, HitLocation;
    local int NumLoops;
    local float CollisionRadius, CollisionHeight;
    
    if( Instigator != None )
    {
        Instigator.GetBoundingCylinder(CollisionRadius, CollisionHeight);
        HitLocation = Instigator.Location + (CollisionHeight * vect(0, 0, 0.5f));
        SetLocation(HitLocation);
        if( Location != HitLocation )
        {
            SetPhysics(PHYS_None);
            SetHidden(True);
            SetCollision(false,false);
            Destroy();
        }
    }
    else
    {
        GRI = KFGameReplicationInfo(WorldInfo.GRI);
        if( GRI.NextTrader != None )
            Trader = GRI.NextTrader;
        else Trader = GRI.OpenedTrader;
        
        if( Trader != None && Trader.TraderMeshActor != None )
        {
            GetBoundingCylinder(CollisionRadius, CollisionHeight);
            
            BoxExtent.X = CollisionRadius;
            BoxExtent.Y = CollisionRadius;
            BoxExtent.Z = CollisionHeight;
            
            HitLocation = Trader.TraderMeshActor.Location;
            while( true )
            {
                if( NumLoops >= 1000 )
                {
                    `Warn("Failed to find a location for "$self$" 1000 times!");
                    SetLocation(HitLocation);
                    break;
                }
                
                if( FindSpot(BoxExtent, HitLocation) )
                {
                    SetLocation(HitLocation);
                    break;
                }
                
                NumLoops++;
            }
            
            if( Location != HitLocation )
            {
                SetPhysics(PHYS_None);
                SetHidden(True);
                SetCollision(false,false);
                Destroy();
            }
        }
    }
}