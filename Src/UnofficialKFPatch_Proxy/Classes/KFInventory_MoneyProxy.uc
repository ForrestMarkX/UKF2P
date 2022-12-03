class KFInventory_MoneyProxy extends Object;

stripped function context(KFInventory_Money.DropFrom) DropFrom(vector StartLocation, vector StartVelocity)
{
	local KFDroppedPickup_Cash KFDP;
	local PlayerReplicationInfo PRI;
	local int Amount;
	local KFGameReplicationInfo KFGRI;
	
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( DroppedPickupClass == None || DroppedPickupMesh == None || (KFGRI != None && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 16) )
		return;

	PRI = Instigator.PlayerReplicationInfo;
	if( PRI != None && PRI.Score > 0 )
		Amount = Min(GetDoshThrowAmount(), int(PRI.Score));

	if( Amount <= 0 )
		return;

	StartLocation.Z += Instigator.BaseEyeHeight / 2;

	KFDP = KFDroppedPickup_Cash(Spawn(DroppedPickupClass,PlayerController(Instigator.Controller),, StartLocation,,,true));
	if( KFDP == None )
	{
		PlayerController(Instigator.Controller).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_FailedDropInventory );
		return;
	}

	KFDP.SetPhysics(PHYS_Falling);
	KFDP.Inventory	= self;
	KFDP.InventoryClass = class;
	KFDP.Velocity = StartVelocity * 1.6;
	KFDP.Instigator = Instigator;
	KFDP.SetPickupMesh(DroppedPickupMesh);
	KFDP.SetPickupParticles(DroppedPickupParticles);

	KFDP.CashAmount = Amount;
	KFDP.TosserPRI = PRI;
	if( KFPlayerReplicationInfo(PRI) != None )
		KFPlayerReplicationInfo(PRI).AddDosh( -Amount );

	`DialogManager.PlayDoshTossDialog( KFPawn(Instigator) );
}

stripped final function context(KFInventory_Money) int GetDoshThrowAmount()
{
    local UKFPReplicationInfo UKFPRep;
    local ReplicationHelper CRI;
    
    if( Instigator == None )
        return 50;
    
    UKFPRep = `GetURI();
    if( UKFPRep == None )
        return 50;
        
    CRI = UKFPRep.GetPlayerChat(Instigator.PlayerReplicationInfo);
    if( CRI == None )
        return 50;
        
    return CRI.ServerDoshThrowAmt;
}