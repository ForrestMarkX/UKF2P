class KFInventoryManagerProxy extends Object;

stripped simulated function context(KFInventoryManager.ThrowMoney) ThrowMoney()
{
    `GetChatRep().ExecuteCommand("TossMoney");
}

stripped reliable server function context(KFInventoryManager.ServerThrowMoney) ServerThrowMoney()
{
	return;
}

stripped simulated event context(KFInventoryManager.DiscardInventory) DiscardInventory()
{
	local Inventory Inv;
	local KFPawn KFP;
    
    if( !`GetURI().bServerDropAllWepsOnDeath && !`GetURI().GetEnforceVanilla() )
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