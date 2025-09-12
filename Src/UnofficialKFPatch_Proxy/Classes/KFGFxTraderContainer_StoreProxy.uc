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
    if( !`GetURI().bShouldDisableTraderDLCLocking )
        SlotObject.SetBool("bDLCLocked", TraderItem.WeaponDef.default.SharedUnlockId != SCU_None && !class'KFUnlockManager'.static.IsSharedContentUnlocked(TraderItem.WeaponDef.default.SharedUnlockId));
    else SlotObject.SetBool("bDLCLocked", false);
    if( `GetURI().bLTILoaded && !`GetURI().bShouldDisableTraderLocking )
        SlotObject.SetBool("bRemoved", KFPC.GetPurchaseHelper().TraderItems.SaleItems.Find('WeaponDef', TraderItem.WeaponDef) == INDEX_NONE);
	else SlotObject.SetBool("bRemoved", false);
    
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
	if( `GetURI().bShouldDisableTraderDLCLocking && (Item.WeaponDef.default.SharedUnlockId != SCU_None && !class'KFUnlockManager'.static.IsSharedContentUnlocked(Item.WeaponDef.default.SharedUnlockId)) )
	{
		if (bDebug)
		{
			`log("Item is not unlocked");
		}
		return true;
	}
	if( Item.WeaponDef.default.PlatformRestriction != PR_All && class'KFUnlockManager'.static.IsPlatformRestricted(Item.WeaponDef.default.PlatformRestriction) )
	{
		if( bDebug )
			`Log("Item is platform restricted");
		return true;
	}
	bUses9mm = Has9mmGun();
	if( bUses9mm && (Item.ClassName == 'KFWeap_HRG_93r' || Item.ClassName == 'KFWeap_HRG_93r_Dual') )
	{
		if( bDebug )
			`Log("9mm owned, skip HRG_93");
		return true;
	}
	if( !bUses9mm && (Item.ClassName == 'KFWeap_Pistol_9mm' || Item.ClassName == 'KFWeap_Pistol_Dual9mm') )
	{
		if( bDebug )
			`Log("HRG_93R owned, skip 9mm");
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

stripped function context(KFGFxTraderContainer_Store.RefreshWeaponListByPerk) RefreshWeaponListByPerk(byte FilterIndex, const out array<STraderItem> ItemList)
{
 	local int i, SlotIndex;
	local GFxObject ItemDataArray;
	local array<STraderItem> OnPerkWeapons, SecondaryWeapons, OffPerkWeapons;
	local class<KFPerk> TargetPerkClass;
	local bool bDebug;
    
	if( FilterIndex == 255 || FilterIndex == INDEX_NONE )
		return;
    
	if( KFPC != None )
	{
		if( FilterIndex < KFPC.PerkList.Length )
			TargetPerkClass = KFPC.PerkList[FilterIndex].PerkClass;
		else TargetPerkClass = None;

		SlotIndex = 0;
	    ItemDataArray = CreateArray();

		for( i=0; i<ItemList.Length; i++ )
		{			
			if( IsItemFiltered(ItemList[i], bDebug) )
				continue;
			
			if( ItemList[i].AssociatedPerkClasses.length > 0 && ItemList[i].AssociatedPerkClasses[0] != None && (FilterIndex >= KFPC.PerkList.Length || ItemList[i].AssociatedPerkClasses.Find(TargetPerkClass) == INDEX_NONE ) )
				continue;

			if( ItemList[i].AssociatedPerkClasses.length > 0 )
			{
				switch( ItemList[i].AssociatedPerkClasses.Find(TargetPerkClass) )
				{
					case 0:
						if( OnPerkWeapons.length == 0 && MyTraderMenu.SelectedList == TL_Shop )
						{
							if( GetInt( "currentSelectedIndex" ) == 0 )
								MyTraderMenu.SetTraderItemDetails(i);
						}
						OnPerkWeapons.AddItem(ItemList[i]);
						break;
					case 1:
                        if( `GetURI().bShouldDisableCrossPerk )
                            break;
						SecondaryWeapons.AddItem(ItemList[i]);
						break;
					default:
						OffPerkWeapons.AddItem(ItemList[i]);
						break;
				}
			}
		}

		for( i=0; i<OnPerkWeapons.length; i++ )
		{
			SetItemInfo(ItemDataArray, OnPerkWeapons[i], SlotIndex);
			SlotIndex++;	
		}

		for( i=0; i<SecondaryWeapons.length; i++ )
		{
			SetItemInfo(ItemDataArray, SecondaryWeapons[i], SlotIndex);
			SlotIndex++;
		}

		for( i=0; i<OffPerkWeapons.length; i++ )
		{
			SetItemInfo(ItemDataArray, OffPerkWeapons[i], SlotIndex);
			SlotIndex++;
		}

		SetObject("shopData", ItemDataArray);
	}
}