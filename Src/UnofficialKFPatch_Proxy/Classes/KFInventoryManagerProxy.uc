class KFInventoryManagerProxy extends Object;

stripped simulated function context(KFInventoryManager.ThrowMoney) ThrowMoney()
{
    `GetChatRep().ExecuteCommand("TossMoney");
}

stripped reliable server function context(KFInventoryManager.ServerThrowMoney) ServerThrowMoney()
{
	return;
}

stripped final simulated function context(KFInventoryManager) DiscardInventoryEx()
{
	local Inventory Inv;
	local KFPawn KFP;
	local UKFPReplicationInfo URI;
    
	URI = `GetURI();
    if( URI == None || !URI.bServerDropAllWepsOnDeath )
    {
        foreach InventoryActors(class'Inventory', Inv)
        {
            if( Instigator.Weapon != Inv )
                Inv.bDropOnDeath = false;
        }
    }

	Super.DiscardInventory();

	KFP = KFPawn(Instigator);
	if( KFP != None )
		KFP.MyKFWeapon = None;
}

stripped simulated event context(KFInventoryManager.DiscardInventory) DiscardInventory()
{
	DiscardInventoryEx();
}