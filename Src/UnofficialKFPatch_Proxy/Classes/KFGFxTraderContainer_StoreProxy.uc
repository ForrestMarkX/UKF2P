class KFGFxTraderContainer_StoreProxy extends Object;

stripped function context(KFGFxTraderContainer_Store.SetItemInfo) SetItemInfo(out GFxObject ItemDataArray, STraderItem TraderItem, int SlotIndex)
{
	local GFxObject SlotObject;
	local string ItemTexPath;
	local string IconPath;
	local string SecondaryIconPath;
	local bool bCanAfford, bCanCarry;
	local int AdjustedBuyPrice, ItemUpgradeLevel;

	SlotObject = CreateObject("Object");

	ItemTexPath = "img://"$TraderItem.WeaponDef.static.GetImagePath();
	if( TraderItem.AssociatedPerkClasses.length > 0 && TraderItem.AssociatedPerkClasses[0] != none)
	{
		IconPath = "img://"$TraderItem.AssociatedPerkClasses[0].static.GetPerkIconPath();
		if( TraderItem.AssociatedPerkClasses.length > 1 )
			SecondaryIconPath = "img://"$TraderItem.AssociatedPerkClasses[1].static.GetPerkIconPath();
	}
	else IconPath = "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath;
	SlotObject.SetString("buyText", Localize("KFGFxTraderContainer_ItemDetails", "BuyString", "KFGame"));

	SlotObject.SetInt("itemID", TraderItem.ItemID);
	SlotObject.SetString("weaponSource", ItemTexPath);
	SlotObject.SetString("perkIconSource", IconPath);
	SlotObject.SetString("perkSecondaryIconSource", SecondaryIconPath);

	SlotObject.SetString("weaponName", TraderItem.WeaponDef.static.GetItemName());
	SlotObject.SetString("weaponType", TraderItem.WeaponDef.static.GetItemCategory());

	ItemUpgradeLevel = TraderItem.SingleClassName != '' ? KFPC.GetPurchaseHelper().GetItemUpgradeLevelByClassName(TraderItem.SingleClassName) : INDEX_None;
	SlotObject.SetInt("weaponWeight", MyTraderMenu.GetDisplayedBlocksRequiredFor(TraderItem, ItemUpgradeLevel));

	AdjustedBuyPrice = KFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(TraderItem);

	SlotObject.SetInt("weaponCost",  AdjustedBuyPrice);

	bCanAfford = KFPC.GetPurchaseHelper().GetCanAfford(AdjustedBuyPrice);
	bCanCarry = KFPC.GetPurchaseHelper().CanCarry(TraderItem, ItemUpgradeLevel);
    
	SlotObject.SetBool("bCanAfford", bCanAfford);
	SlotObject.SetBool("bCanCarry", bCanCarry);
	SlotObject.SetBool("bDLCLocked", TraderItem.WeaponDef.default.SharedUnlockId != SCU_None && !class'KFUnlockManager'.static.IsSharedContentUnlocked(TraderItem.WeaponDef.default.SharedUnlockId));
    if( `GetURI().bLTILoaded )
        SlotObject.SetBool("bRemoved", KFPC.GetPurchaseHelper().TraderItems.SaleItems.Find('WeaponDef', TraderItem.WeaponDef) == INDEX_NONE);
	
    if( SlotObject.GetBool("bDLCLocked") || SlotObject.GetBool("bRemoved") )
    {
        SlotObject.SetBool("bCanAfford", false);
        SlotObject.SetBool("bCanCarry", false);
    }
    
	ItemDataArray.SetElementObject(SlotIndex, SlotObject);
}

stripped function context(KFGFxTraderContainer_Store.IsItemFiltered) bool IsItemFiltered(STraderItem Item, optional bool bDebug)
{
	if( KFPC.GetPurchaseHelper().IsInOwnedItemList(Item.ClassName) )
	{
		if( bDebug )
			`Log("Item is owned");
		return true;
	}
	if( KFPC.GetPurchaseHelper().IsInOwnedItemList(Item.DualClassName) )
	{
		if( bDebug )
			`Log("Dual Item is owned");
		return true;
	}
	if( !KFPC.GetPurchaseHelper().IsSellable(Item) )
	{
		if( bDebug )
			`Log("Item is not sellable");
		return true;
	}
	if( Item.WeaponDef.default.PlatformRestriction != PR_All && class'KFUnlockManager'.static.IsPlatformRestricted(Item.WeaponDef.default.PlatformRestriction) )
	{
		if( bDebug )
			`Log("Item is platform restricted");
		return true;
	}
	if( `GetChatRep().UKFPInteraction.bFilterHRGWeapons && InStr(Item.WeaponDef.Name, "_HRG") != INDEX_NONE )
	{
		if( bDebug )
			`Log("Item was HRG");
		return true;
	}

   	return false;
}