class KFGFxTraderContainer_StoreProxy extends Object;

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
	if( Item.WeaponDef.default.SharedUnlockId != SCU_None && !class'KFUnlockManager'.static.IsSharedContentUnlocked(Item.WeaponDef.default.SharedUnlockId) )
	{
		if( bDebug )
			`Log("Item is not unlocked");
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