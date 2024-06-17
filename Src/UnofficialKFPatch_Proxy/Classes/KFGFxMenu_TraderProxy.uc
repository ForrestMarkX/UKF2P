class KFGFxMenu_TraderProxy extends Object;

stripped function context(KFGFxMenu_Trader.SetTraderItemDetails) SetTraderItemDetails(int ItemIndex)
{
	local STraderItem SelectedItem;
	local bool bCanAfford, bCanBuyItem, bCanCarry;
    
    if( `GetURI().bLTILoaded )
        SetTraderItemDetailsEx(ItemIndex);
    else
    {
        SelectedList = TL_Shop;
        
        if( ItemDetails != None && ShopContainer != None )
        {
            if( MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.Length >= 0 && ItemIndex < MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.Length )
            {
                SelectedItemIndex = ItemIndex;
                SelectedItem = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[ItemIndex];

                bCanAfford = MyKFPC.GetPurchaseHelper().GetCanAfford( MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(SelectedItem) );
                bCanCarry = MyKFPC.GetPurchaseHelper().CanCarry( SelectedItem );

                if( !bCanAfford || !bCanCarry )
                    bCanBuyItem = false;
                else bCanBuyItem = true;

                PurchaseError(!bCanAfford, !bCanCarry);

                ItemDetails.SetShopItemDetails(SelectedItem, MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(SelectedItem), bCanCarry, bCanBuyItem);
                bCanBuyOrSellItem = bCanBuyItem;
            }
            else ItemDetails.SetVisible(false);
        }
    }
}

stripped final function context(KFGFxMenu_Trader) SetTraderItemDetailsEx(int ItemIndex)
{
	local STraderItem SelectedItem;
	local bool bCanAfford, bCanBuyItem, bCanCarry;
    local KFGFxObject_TraderItems TraderItems;
    
    TraderItems = `GetURI().bShouldDisableTraderLocking ? MyKFPC.GetPurchaseHelper().TraderItems : `GetURI().OriginalTraderItems;
    SelectedList = TL_Shop;
    
    if( ItemDetails != None && ShopContainer != None )
    {
        if( TraderItems.SaleItems.Length >= 0 && ItemIndex < TraderItems.SaleItems.Length )
        {
            SelectedItemIndex = ItemIndex;
            SelectedItem = TraderItems.SaleItems[ItemIndex];

            bCanAfford = MyKFPC.GetPurchaseHelper().GetCanAfford( MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(SelectedItem) );
            bCanCarry = MyKFPC.GetPurchaseHelper().CanCarry( SelectedItem );

            if( !bCanAfford || !bCanCarry )
                bCanBuyItem = false;
            else bCanBuyItem = true;

            PurchaseError(!bCanAfford, !bCanCarry);

            ItemDetails.SetShopItemDetails(SelectedItem, MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(SelectedItem), bCanCarry, bCanBuyItem);
            bCanBuyOrSellItem = bCanBuyItem;
        }
        else ItemDetails.SetVisible(false);
    }
}

stripped function context(KFGFxMenu_Trader.RefreshShopItemList) RefreshShopItemList( TabIndices TabIndex, byte FilterIndex )
{
    if( `GetURI().bLTILoaded )
        RefreshShopItemListEx(TabIndex, FilterIndex);
    else
    {
        if( ShopContainer != None && FilterContainer != None )
        {
            switch( TabIndex )
            {
                case TI_Perks:
                    ShopContainer.RefreshWeaponListByPerk(FilterIndex, MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
                    FilterContainer.SetPerkFilterData(FilterIndex);
                    break;
                case TI_Type:
                    ShopContainer.RefreshItemsByType(FilterIndex, MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
                    FilterContainer.SetTypeFilterData(FilterIndex);
                    break;
                case TI_Favorites:
                    ShopContainer.RefreshFavoriteItems(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
                    FilterContainer.ClearFilters();
                    break;
                case TI_All:
                    ShopContainer.RefreshAllItems(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
                    FilterContainer.ClearFilters();
                    break;
            }
            FilterContainer.SetInt("selectedTab", TabIndex);
            FilterContainer.SetInt("selectedFilter", FilterIndex);

            if( SelectedList == TL_Shop )
            {
                if( SelectedItemIndex >= MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length )
                    SelectedItemIndex = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length - 1;
                SetTraderItemDetails(SelectedItemIndex);
                ShopContainer.SetSelectedIndex(SelectedItemIndex);
            }
        }
    }
}

stripped final function context(KFGFxMenu_Trader) RefreshShopItemListEx( TabIndices TabIndex, byte FilterIndex )
{
    local KFGFxObject_TraderItems TraderItems;
    
    TraderItems = `GetURI().bShouldDisableTraderLocking ? MyKFPC.GetPurchaseHelper().TraderItems : `GetURI().OriginalTraderItems;
    if( ShopContainer != None && FilterContainer != None )
    {
        switch( TabIndex )
        {
            case TI_Perks:
                ShopContainer.RefreshWeaponListByPerk(FilterIndex, TraderItems.SaleItems);
                FilterContainer.SetPerkFilterData(FilterIndex);
                break;
            case TI_Type:
                ShopContainer.RefreshItemsByType(FilterIndex, TraderItems.SaleItems);
                FilterContainer.SetTypeFilterData(FilterIndex);
                break;
            case TI_Favorites:
                ShopContainer.RefreshFavoriteItems(TraderItems.SaleItems);
                FilterContainer.ClearFilters();
                break;
            case TI_All:
                ShopContainer.RefreshAllItems(TraderItems.SaleItems);
                FilterContainer.ClearFilters();
                break;
        }
        FilterContainer.SetInt("selectedTab", TabIndex);
        FilterContainer.SetInt("selectedFilter", FilterIndex);

        if( SelectedList == TL_Shop )
        {
            if( SelectedItemIndex >= TraderItems.SaleItems.length )
                SelectedItemIndex = TraderItems.SaleItems.length - 1;
            SetTraderItemDetails(SelectedItemIndex);
            ShopContainer.SetSelectedIndex(SelectedItemIndex);
        }
    }
}

stripped function context(KFGFxMenu_Trader.Callback_FavoriteItem) Callback_FavoriteItem()
{
    if( `GetURI().bLTILoaded )
        Callback_FavoriteItemEx();
    else
    {
        if( SelectedList == TL_Shop )
        {
            ToggleFavorite(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[SelectedItemIndex].ClassName);
            if( CurrentTab == TI_Favorites )
                SetNewSelectedIndex(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length);
            SetTraderItemDetails(SelectedItemIndex);
        }
        else
        {
            ToggleFavorite(OwnedItemList[SelectedItemIndex].DefaultItem.ClassName);
            SetPlayerItemDetails(SelectedItemIndex);
        }
        RefreshItemComponents();
    }
}

stripped final function context(KFGFxMenu_Trader) Callback_FavoriteItemEx()
{
    local KFGFxObject_TraderItems TraderItems;
    
    TraderItems = `GetURI().bShouldDisableTraderLocking ? MyKFPC.GetPurchaseHelper().TraderItems : `GetURI().OriginalTraderItems;
    
    if( SelectedList == TL_Shop )
    {
        ToggleFavorite(TraderItems.SaleItems[SelectedItemIndex].ClassName);
        if( CurrentTab == TI_Favorites )
            SetNewSelectedIndex(TraderItems.SaleItems.Length);
        SetTraderItemDetails(SelectedItemIndex);
    }
    else
    {
        ToggleFavorite(OwnedItemList[SelectedItemIndex].DefaultItem.ClassName);
        SetPlayerItemDetails(SelectedItemIndex);
    }
    RefreshItemComponents();
}

stripped function context(KFGFxMenu_Trader.Callback_BuyOrSellItem) Callback_BuyOrSellItem()
{
	local STraderItem ShopItem;
	local SItemInformation ItemInfo;
	
    if( `GetURI().bLTILoaded )
        Callback_BuyOrSellItemEx();
    else
    {
        if( bCanBuyOrSellItem )
        {
            if( SelectedList == TL_Shop )
            {
                ShopItem = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[SelectedItemIndex];

                MyKFPC.GetPurchaseHelper().PurchaseWeapon(ShopItem);
                SetNewSelectedIndex(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length);
                SetTraderItemDetails(SelectedItemIndex);
                ShopContainer.ActionScriptVoid("itemBought");
            }
            else
            {
                `log("Callback_BuyOrSellItem: SelectedItemIndex="$SelectedItemIndex, MyKFIM.bLogInventory);
                ItemInfo = OwnedItemList[SelectedItemIndex];
                `log("Callback_BuyOrSellItem: ItemInfo="$ItemInfo.DefaultItem.ClassName, MyKFIM.bLogInventory);
                MyKFPC.GetPurchaseHelper().SellWeapon(ItemInfo, SelectedItemIndex);

                SetNewSelectedIndex(OwnedItemList.length);
                SetPlayerItemDetails(SelectedItemIndex);
                PlayerInventoryContainer.ActionScriptVoid("itemSold");
            }
        }
        else if( SelectedList == TL_Shop )
        {
            ShopItem = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[SelectedItemIndex];
            MyKFPC.PlayTraderSelectItemDialog( !MyKFPC.GetPurchaseHelper().GetCanAfford( MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(ShopItem) ), !MyKFPC.GetPurchaseHelper().CanCarry( ShopItem ) );
        }
        RefreshItemComponents();
    }
}

stripped final function context(KFGFxMenu_Trader) Callback_BuyOrSellItemEx()
{
	local STraderItem ShopItem;
	local SItemInformation ItemInfo;
    local KFGFxObject_TraderItems TraderItems;
    
    TraderItems = `GetURI().bShouldDisableTraderLocking ? MyKFPC.GetPurchaseHelper().TraderItems : `GetURI().OriginalTraderItems;
	
	if( bCanBuyOrSellItem )
	{
		if( SelectedList == TL_Shop )
		{
			ShopItem = TraderItems.SaleItems[SelectedItemIndex];

			MyKFPC.GetPurchaseHelper().PurchaseWeapon(ShopItem);
			SetNewSelectedIndex(TraderItems.SaleItems.length);
	    	SetTraderItemDetails(SelectedItemIndex);
	    	ShopContainer.ActionScriptVoid("itemBought");
		}
		else
		{
			`log("Callback_BuyOrSellItem: SelectedItemIndex="$SelectedItemIndex, MyKFIM.bLogInventory);
			ItemInfo = OwnedItemList[SelectedItemIndex];
			`log("Callback_BuyOrSellItem: ItemInfo="$ItemInfo.DefaultItem.ClassName, MyKFIM.bLogInventory);
			MyKFPC.GetPurchaseHelper().SellWeapon(ItemInfo, SelectedItemIndex);

	   	    SetNewSelectedIndex(OwnedItemList.length);
			SetPlayerItemDetails(SelectedItemIndex);
			PlayerInventoryContainer.ActionScriptVoid("itemSold");
		}
	}
	else if( SelectedList == TL_Shop )
	{
		ShopItem = TraderItems.SaleItems[SelectedItemIndex];
		MyKFPC.PlayTraderSelectItemDialog( !MyKFPC.GetPurchaseHelper().GetCanAfford( MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(ShopItem) ), !MyKFPC.GetPurchaseHelper().CanCarry( ShopItem ) );
	}
	RefreshItemComponents();
}