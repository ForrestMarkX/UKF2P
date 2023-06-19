class KFAutoPurchaseHelperProxy extends Object;

stripped function context(KFAutoPurchaseHelper.CanUpgrade) bool CanUpgrade(STraderItem SelectedItem, out int CanCarryIndex, out int bCanAffordIndex, optional bool bPlayDialog)
{
	local bool bCanAfford, bCanCarry;
	local int UpgradePrice;
	local int ItemUpgradeLevel;
	local KFPlayerController MyKFPC;
	local int AddedWeightBlocks;
    
    if( `GetURI().bShouldDisableUpgrades )
    {
        CanCarryIndex = 0;
        bCanAffordIndex = 0;
        return false;
    }

	MyKFPC = Outer;

	ItemUpgradeLevel = GetItemUpgradeLevelByClassName(SelectedItem.ClassName);
	if (ItemUpgradeLevel == INDEX_NONE || !(ItemUpgradeLevel < SelectedItem.WeaponDef.default.UpgradePrice.length))
	{
		`Log("Item at max level");
		return false;
	}
    
	UpgradePrice = SelectedItem.WeaponDef.static.GetUpgradePrice(ItemUpgradeLevel);
	bCanAfford = GetCanAfford(UpgradePrice);
	AddedWeightBlocks = SelectedItem.WeaponUpgradeWeight[ItemUpgradeLevel + 1] - SelectedItem.WeaponUpgradeWeight[ItemUpgradeLevel];
	bCanCarry = !(TotalBlocks + AddedWeightBlocks > MaxBlocks);

	if( bPlayDialog )
		MyKFPC.PlayTraderSelectItemDialog(!bCanAfford, !bCanCarry);

	CanCarryIndex = bCanCarry ? 1 : 0;
	bCanAffordIndex = bCanAfford ? 1 : 0;
    
	return bCanAfford && bCanCarry;
}