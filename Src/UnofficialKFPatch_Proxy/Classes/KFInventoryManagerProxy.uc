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

stripped reliable server final private function context(KFInventoryManager.ServerBuyUpgrade) ServerBuyUpgrade(byte ItemIndex, int CurrentUpgradeLevel)
{
	local STraderItem WeaponItem;
	local KFWeapon KFW;
	local int NewUpgradeLevel;
    
    if( `GetURI().bShouldDisableUpgrades )
        return;

	if( Role == ROLE_Authority && bServerTraderMenuOpen )
	{
		if( GetTraderItemFromWeaponLists(WeaponItem, ItemIndex) )
		{
			if( !ProcessUpgradeDosh(WeaponItem, CurrentUpgradeLevel) )
				return;

			NewUpgradeLevel = CurrentUpgradeLevel + 1;

			if( GetWeaponFromClass(KFW, WeaponItem.ClassName) )
			{
				if( KFW != None )
				{
					KFW.SetWeaponUpgradeLevel(NewUpgradeLevel);
					if( CurrentUpgradeLevel > 0 )
						AddCurrentCarryBlocks(-KFW.GetUpgradeStatAdd(EWUS_Weight, CurrentUpgradeLevel));

					AddCurrentCarryBlocks(KFW.GetUpgradeStatAdd(EWUS_Weight, NewUpgradeLevel));
					`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Upgrade," @ KFW.Class $ "," @ NewUpgradeLevel);
					`AnalyticsLog(("upgrade", Instigator.PlayerReplicationInfo, "upgrade", KFW.Class, "#" $ NewUpgradeLevel));
				}
			}
			else ServerAddTransactionUpgrade(ItemIndex, NewUpgradeLevel);
		}
	}
}

stripped reliable server final private event context(KFInventoryManager.ServerAddTransactionUpgrade) ServerAddTransactionUpgrade(int ItemIndex, int NewUpgradeLevel)
{
	if( !`GetURI().bShouldDisableUpgrades && bServerTraderMenuOpen )
		AddTransactionUpgrade(ItemIndex, NewUpgradeLevel);
}