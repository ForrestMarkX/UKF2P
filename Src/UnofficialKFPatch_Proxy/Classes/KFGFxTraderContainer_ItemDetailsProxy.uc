class KFGFxTraderContainer_ItemDetailsProxy extends Object;

stripped function context(KFGFxTraderContainer_ItemDetails.SetPlayerItemDetails) SetPlayerItemDetails(out STraderItem TraderItem, int ItemPrice, optional int UpgradeLevel = INDEX_NONE)
{
	local GFxObject ItemData;
	local int CanAffordIndex, CanCarryIndex;

	KFPC.GetPurchaseHelper().CanUpgrade(TraderItem, CanCarryIndex, CanAffordIndex);

	ItemData = CreateObject("Object");

	ItemData.SetInt("price", ItemPrice);
	ItemData.SetBool("bUsingBuyLabel", false);

	ItemData.SetString("buyOrSellLabel", SellString);
	ItemData.SetString("cannotBuyOrSellLabel", CannotSellString);

	ItemData.SetBool("bCanUpgrade", !`GetURI().bShouldDisableUpgrades);
	ItemData.SetBool("bCanBuyUpgrade", CanAffordIndex > 0);
	ItemData.SetBool("bCanCarryUpgrade", CanCarryIndex > 0);

	if( UpgradeLevel > INDEX_NONE )
	{
		if( TraderItem.WeaponDef.static.GetUpgradePrice(UpgradeLevel) == INDEX_NONE )
		{
			ItemData.SetInt("upgradePrice", 0);
			ItemData.SetInt("upgradeWeight", 0);
			ItemData.SetBool("bCanUpgrade", false);
		}
		else
		{
			ItemData.SetInt("upgradePrice", TraderItem.WeaponDef.static.GetUpgradePrice(UpgradeLevel));
			ItemData.SetInt("upgradeWeight", TraderItem.WeaponUpgradeWeight[UpgradeLevel + 1] - TraderItem.WeaponUpgradeWeight[UpgradeLevel]);
		}
	}
	else
	{
		ItemData.SetInt("upgradePrice", 0);
		ItemData.SetInt("upgradeWeight", 0);
	}
	ItemData.SetInt("weaponTier", UpgradeLevel);

	ItemData.SetBool("bCanCarry", true);
	ItemData.SetBool("bCanBuyOrSell", KFPC.GetPurchaseHelper().IsSellable(TraderItem));
	ItemData.SetBool("bHideStats", (TraderItem.WeaponStats.Length == 0));

	ItemData.SetBool("bCanFavorite", true);

	SetGenericItemDetails(TraderItem, ItemData, UpgradeLevel);
}

stripped function context(KFGFxTraderContainer_ItemDetails.SetGenericItemDetails) SetGenericItemDetails(const out STraderItem TraderItem, out GFxObject ItemData, optional int UpgradeLevel = INDEX_NONE)
{
    if( `GetChatRep().bUseEnhancedTraderMenu )
        SetGenericItemDetailsAdvanced(TraderItem, ItemData, UpgradeLevel);
    else SetGenericItemDetailsEx(TraderItem, ItemData, UpgradeLevel);
}

stripped final function context(KFGFxTraderContainer_ItemDetails) SetGenericItemDetailsAdvanced(const out STraderItem TraderItem, out GFxObject ItemData, optional int UpgradeLevel = INDEX_NONE)
{
	local int i, StatIndex, UpgradeStatValue, SecondaryFireDamage, FinalMaxSpareAmmoCount, FinalMagazineCapacity, FinalSecondaryMagazineCapacity, FinalMaxSecondarySpareAmmoCount, UpgradeMaxSpareAmmoCount, UpgradeMagazineCapacity, UpgradeSecondaryMagazineCapacity, UpgradeMaxSecondarySpareAmmoCount;
    local string StatValue, AfflictionType;
    local class<KFWeapon> KFW;
    local class<KFDamageType> DamageType;
    local GFxObject StatsObject, StatObject;
    local KFPerk CurrentPerk;
    local Texture2D SecondaryFireIcon;
    local bool bStatUpgraded, bUsePerc;
    
    KFW = class<KFWeapon>(DynamicLoadObject(TraderItem.WeaponDef.default.WeaponClassPath, class'Class'));
    SecondaryFireIcon = KFW.default.SecondaryAmmoTexture != class'KFWeapon'.default.SecondaryAmmoTexture ? KFW.default.SecondaryAmmoTexture : KFW.default.FireModeIconPaths[1];

 	ItemData.SetString("type", TraderItem.WeaponDef.static.GetItemName());
 	ItemData.SetString("name", TraderItem.WeaponDef.static.GetItemCategory());
 	ItemData.SetString("description", TraderItem.WeaponDef.static.GetItemDescription());
    
	CurrentPerk = KFPlayerController(GetPC()).CurrentPerk;
	if( CurrentPerk != None )
	{
		FinalMaxSpareAmmoCount = TraderItem.MaxSpareAmmo;
		FinalMagazineCapacity = TraderItem.MagazineCapacity;

		CurrentPerk.ModifyMagSizeAndNumber(None, FinalMagazineCapacity, TraderItem.AssociatedPerkClasses,, TraderItem.ClassName);
		CurrentPerk.ModifyMaxSpareAmmoAmount(None, FinalMaxSpareAmmoCount, TraderItem);

        if( KFW.default.WeaponFireTypes[1] != EWFT_None )
        {
            FinalSecondaryMagazineCapacity = KFW.default.MagazineCapacity[1];
            FinalMaxSecondarySpareAmmoCount = KFW.default.SpareAmmoCapacity[1];
            
            CurrentPerk.ModifyMagSizeAndNumber(None, FinalSecondaryMagazineCapacity, TraderItem.AssociatedPerkClasses, true, TraderItem.ClassName);
            CurrentPerk.ModifyMaxSpareAmmoAmount(None, FinalMaxSecondarySpareAmmoCount, TraderItem, true);
        }
	}
	else
	{
		FinalMaxSpareAmmoCount = TraderItem.MaxSpareAmmo;
		FinalMagazineCapacity = TraderItem.MagazineCapacity;
        
        if( KFW.default.WeaponFireTypes[1] != EWFT_None )
        {
            FinalSecondaryMagazineCapacity = KFW.default.MagazineCapacity[1];
            FinalMaxSecondarySpareAmmoCount = KFW.default.SpareAmmoCapacity[1];
        }
	}

    if( FinalMaxSpareAmmoCount <= 0 && FinalMagazineCapacity > 0 )
        ItemData.SetString("ammoCapacity", string(FinalMagazineCapacity));
    else if( FinalMagazineCapacity <= 0 && FinalMaxSpareAmmoCount > 0 )
        ItemData.SetString("ammoCapacity", string(FinalMaxSpareAmmoCount));
    else ItemData.SetString("ammoCapacity", FinalMagazineCapacity$"/"$FinalMaxSpareAmmoCount);
    
    if( UpgradeLevel != INDEX_NONE )
    {
        UpgradeMagazineCapacity = KFW.static.GetUpgradedStatValue(FinalMagazineCapacity, EWUS_MagCapacity0, UpgradeLevel);
        UpgradeMaxSpareAmmoCount = KFW.static.GetUpgradedStatValue(FinalMaxSpareAmmoCount, EWUS_SpareCapacity0, UpgradeLevel);
        if( FinalMagazineCapacity != UpgradeMagazineCapacity || FinalMaxSpareAmmoCount != UpgradeMaxSpareAmmoCount )
            ItemData.SetString("primaryAmmoUpgrade", UpgradeMagazineCapacity$"/"$UpgradeMaxSpareAmmoCount);
        else ItemData.SetString("primaryAmmoUpgrade", "");
    }
    else ItemData.SetString("primaryAmmoUpgrade", "");

    ItemData.SetString("primaryAmmoIcon", "img://"$PathName(KFW.default.FireModeIconPaths[0]));
    
    if( KFW.default.WeaponFireTypes[1] != EWFT_None )
    {
        if( FinalSecondaryMagazineCapacity > 0 || FinalMaxSecondarySpareAmmoCount > 0 )
        {
            if( FinalMaxSecondarySpareAmmoCount <= 0 && FinalSecondaryMagazineCapacity > 0 )
                ItemData.SetString("secondaryAmmoCapacity", "("$FinalSecondaryMagazineCapacity$")");
            else if( FinalSecondaryMagazineCapacity <= 0 && FinalMaxSecondarySpareAmmoCount > 0 )
                ItemData.SetString("secondaryAmmoCapacity", "("$FinalMaxSecondarySpareAmmoCount$")");
            else ItemData.SetString("secondaryAmmoCapacity", "("$FinalSecondaryMagazineCapacity$"/"$FinalMaxSecondarySpareAmmoCount$")");
            
            if( UpgradeLevel != INDEX_NONE )
            {
                UpgradeSecondaryMagazineCapacity = KFW.static.GetUpgradedStatValue(FinalSecondaryMagazineCapacity, EWUS_MagCapacity1, UpgradeLevel);
                UpgradeMaxSecondarySpareAmmoCount = KFW.static.GetUpgradedStatValue(FinalMaxSecondarySpareAmmoCount, EWUS_SpareCapacity1, UpgradeLevel);
                if( FinalSecondaryMagazineCapacity != UpgradeSecondaryMagazineCapacity || FinalMaxSecondarySpareAmmoCount != UpgradeMaxSecondarySpareAmmoCount )
                    ItemData.SetString("secondaryAmmoUpgrade", "("$UpgradeSecondaryMagazineCapacity$"/"$UpgradeMaxSecondarySpareAmmoCount$")");
                else ItemData.SetString("secondaryAmmoUpgrade", "");
            }
        }
        ItemData.SetString("secondaryAmmoIcon", "img://"$PathName(SecondaryFireIcon));
    }
    else ItemData.SetString("secondaryAmmoUpgrade", "");

    ItemData.SetInt("weight", KFW.default.InventorySize);
    if( UpgradeLevel > INDEX_NONE )
        ItemData.SetInt("upgradeWeight", TraderItem.WeaponUpgradeWeight[UpgradeLevel]);

	ItemData.SetBool("bIsFavorite", MyTraderMenu.GetIsFavorite(TraderItem.ClassName));

 	ItemData.SetString("texturePath", "img://"$TraderItem.WeaponDef.static.GetImagePath());
 	if( TraderItem.AssociatedPerkClasses.length > 0 && TraderItem.AssociatedPerkClasses[0] != none )
 	{
 		ItemData.SetString("perkIconPath", "img://"$TraderItem.AssociatedPerkClasses[0].static.GetPerkIconPath());
 		if( TraderItem.AssociatedPerkClasses.Length > 1 && !`GetURI().bShouldDisableCrossPerk )
 			ItemData.SetString("perkIconPathSecondary", "img://"$TraderItem.AssociatedPerkClasses[1].static.GetPerkIconPath());
	}
	else ItemData.SetString("perkIconPath", "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath);

    if( TraderItem.WeaponStats.Length > 0 )
    {
        StatsObject = CreateObject("Object");
        StatsObject.SetString("firemodeName", class'KFGFxHUD_WeaponSelectWidget'.default.PrimaryString);
        StatsObject.SetString("firemodeIcon", "img://"$PathName(KFW.default.FireModeIconPaths[0]));

        StatIndex = 0;
        for( i=0; i<TraderItem.WeaponStats.Length && i<6; i++ )
        {
            if( TraderItem.WeaponStats[i].StatValue <= 0 || TraderItem.WeaponStats[i].StatType == TWS_HealAmount || TraderItem.WeaponStats[i].StatType == TWS_RechargeTime || TraderItem.WeaponStats[i].StatType == TWS_Block || TraderItem.WeaponStats[i].StatType == TWS_Parry )
                continue;

            if( TraderItem.WeaponStats[i].StatType == TWS_Damage )
            {
                DamageType = class<KFDamageType>(KFW.default.InstantHitDamageTypes[0]);
                if( DamageType != None )
                {
                    if( DamageType.default.BleedPower > 0 || class<KFDT_Bleeding>(DamageType) != None )
                        AfflictionType = "<font color=\"#FC1E1E\" face=\"MIcon\">"$`GetMIconChar("water")$"</font> ";
                    else if( DamageType.default.BurnPower > 0 || class<KFDT_Fire>(DamageType) != None )
                        AfflictionType = "<font color=\"#FC7B25\" face=\"MIcon\">"$`GetMIconChar("fire")$"</font> ";
                    else if( DamageType.default.PoisonPower > 0 || class<KFDT_Toxic>(DamageType) != None )
                        AfflictionType = "<font color=\"#00FF00\" face=\"MIcon\">"$`GetMIconChar("flask")$"</font> ";
                    else if( DamageType.default.EMPPower > 0 || class<KFDT_EMP>(DamageType) != None )
                        AfflictionType = "<font color=\"#7A40BD\" face=\"MIcon\">"$`GetMIconChar("lightning-bolt")$"</font> ";
                    else if( DamageType.default.FreezePower > 0 || class<KFDT_Freeze>(DamageType) != None )
                        AfflictionType = "<font color=\"#00B7EC\" face=\"MIcon\">"$`GetMIconChar("snowflake")$"</font> ";
                }
            }

            StatObject = CreateObject("Object");
            StatObject.SetString("statTitle", AfflictionType $ GetLocalizedStatString(TraderItem.WeaponStats[i].StatType));
            StatObject.SetInt("statValue", TraderItem.WeaponStats[i].StatValue);
            if( UpgradeLevel > INDEX_NONE )
            {
                switch( TraderItem.WeaponStats[i].StatType )
                {
                    case TWS_Damage:
                        UpgradeStatValue = KFW.static.GetUpgradedStatValue(TraderItem.WeaponStats[i].StatValue, EWUS_Damage0, UpgradeLevel);
                        break;
                    case TWS_Penetration:
                        UpgradeStatValue = KFW.static.GetUpgradedStatValue(TraderItem.WeaponStats[i].StatValue, EWUS_Penetration0, UpgradeLevel);
                        break;
                    default:
                        UpgradeStatValue = 0;
                        break;
                }
                
                if( UpgradeStatValue > TraderItem.WeaponStats[i].StatValue )
                    StatObject.SetInt("statNextValue", UpgradeStatValue);
                else StatObject.SetInt("statNextValue", 0);
            }
            else StatObject.SetInt("statNextValue", 0);
            
            StatsObject.SetObject("itemStat_"$StatIndex, StatObject);
            
            StatIndex++;
            UpgradeStatValue = 0;
            AfflictionType = "";
        }

        ItemData.SetObject("primaryAmmoStats", StatsObject);
        
        StatsObject = CreateObject("Object");
        StatsObject.SetString("firemodeName", class'KFGFxHUD_WeaponSelectWidget'.default.SecondaryString);

        if( KFW.default.WeaponFireTypes[1] != EWFT_None )
        {
            SecondaryFireDamage = CalcSecondaryWeaponDamage(KFW);
            
            StatsObject.SetString("firemodeIcon", "img://"$PathName(SecondaryFireIcon));
            
            StatIndex = 0;
            for( i=0; i<TraderItem.WeaponStats.Length && i<6; i++ )
            {
                switch( TraderItem.WeaponStats[i].StatType )
                {
                    case TWS_Damage:
                        DamageType = class<KFDamageType>(KFW.default.InstantHitDamageTypes[1]);
                        if( DamageType != None )
                        {
                            if( DamageType.default.BleedPower > 0 || class<KFDT_Bleeding>(DamageType) != None )
                                AfflictionType = "<font color=\"#FC1E1E\" face=\"MIcon\">"$`GetMIconChar("water")$"</font> ";
                            else if( DamageType.default.BurnPower > 0 || class<KFDT_Fire>(DamageType) != None )
                                AfflictionType = "<font color=\"#FC7B25\" face=\"MIcon\">"$`GetMIconChar("fire")$"</font> ";
                            else if( DamageType.default.PoisonPower > 0 || class<KFDT_Toxic>(DamageType) != None )
                                AfflictionType = "<font color=\"#00FF00\" face=\"MIcon\">"$`GetMIconChar("flask")$"</font> ";
                            else if( DamageType.default.EMPPower > 0 || class<KFDT_EMP>(DamageType) != None )
                                AfflictionType = "<font color=\"#7A40BD\" face=\"MIcon\">"$`GetMIconChar("lightning-bolt")$"</font> ";
                            else if( DamageType.default.FreezePower > 0 || class<KFDT_Freeze>(DamageType) != None )
                                AfflictionType = "<font color=\"#00B7EC\" face=\"MIcon\">"$`GetMIconChar("snowflake")$"</font> ";
                        }
                        StatValue = string(SecondaryFireDamage);
                        break;
                    case TWS_Range:
                        StatValue = string(TraderItem.WeaponDef.default.EffectiveRange);
                        break;
                    case TWS_Penetration:
                        StatValue = string(int(KFW.default.PenetrationPower[1]));
                        break;
                    case TWS_RateOfFire:
                        StatValue = string(int(60.f / KFW.default.FireInterval[1]));
                        break;
                    case TWS_HealAmount:
                        StatValue = string(int(TraderItem.WeaponStats[i].StatValue));
                        break;
                    case TWS_Block:
                        if( class<KFWeap_MeleeBase>(KFW) != None )
                            StatValue = int(class<KFWeap_MeleeBase>(KFW).default.BlockDamageMitigation * 100.f)$"%";
                        else StatValue = "0";
                        break;
                    case TWS_Parry:
                        if( class<KFWeap_MeleeBase>(KFW) != None )
                            StatValue = int(class<KFWeap_MeleeBase>(KFW).default.ParryDamageMitigationPercent * 100.f)$"%";
                        else StatValue = "0";
                        break;
                }
                
                if( int(StatValue) <= 0 )
                    continue;
                    
                StatObject = CreateObject("Object");
                StatObject.SetString("statTitle", AfflictionType $ GetLocalizedStatString(TraderItem.WeaponStats[i].StatType));
                StatObject.SetString("statValue", StatValue);
                if( UpgradeLevel > INDEX_NONE )
                {
                    switch( TraderItem.WeaponStats[i].StatType )
                    {
                        case TWS_Damage:
                            UpgradeStatValue = KFW.static.GetUpgradedStatValue(SecondaryFireDamage, EWUS_Damage1, UpgradeLevel);
                            bStatUpgraded = UpgradeStatValue > SecondaryFireDamage;
                            break;
                        case TWS_Penetration:
                            UpgradeStatValue = KFW.static.GetUpgradedStatValue(KFW.default.PenetrationPower[1], EWUS_Penetration1, UpgradeLevel);
                            bStatUpgraded = UpgradeStatValue > KFW.default.PenetrationPower[1];
                            break;
                        case TWS_HealAmount:
                            UpgradeStatValue = KFW.static.GetUpgradedStatValue(TraderItem.WeaponStats[i].StatValue, EWUS_Heal, UpgradeLevel);
                            bStatUpgraded = UpgradeStatValue > TraderItem.WeaponStats[i].StatValue;
                            break;
                        case TWS_RechargeTime:
                            UpgradeStatValue = KFW.static.GetUpgradedStatValue(TraderItem.WeaponStats[i].StatValue, EWUS_HealFullRecharge, UpgradeLevel);
                            bStatUpgraded = UpgradeStatValue > TraderItem.WeaponStats[i].StatValue;
                            break;
                        case TWS_Block:
                            UpgradeStatValue = KFW.static.GetUpgradedStatValue(TraderItem.WeaponStats[i].StatValue, EWUS_BlockDmgMitigation, UpgradeLevel);
                            bStatUpgraded = UpgradeStatValue > TraderItem.WeaponStats[i].StatValue;
                            bUsePerc = true;
                            break;
                        case TWS_Parry:
                            UpgradeStatValue = KFW.static.GetUpgradedStatValue(TraderItem.WeaponStats[i].StatValue, EWUS_ParryDmgMitigation, UpgradeLevel);
                            bStatUpgraded = UpgradeStatValue > TraderItem.WeaponStats[i].StatValue;
                            bUsePerc = true;
                            break;
                        default:
                            UpgradeStatValue = 0;
                            bStatUpgraded = false;
                            break;
                    }
                    
                    if( bStatUpgraded )
                    {
                        if( bUsePerc )
                            StatObject.SetString("statNextValue", int(UpgradeStatValue * 100.f)$"%");
                        else StatObject.SetInt("statNextValue", UpgradeStatValue);
                    }
                    else StatObject.SetInt("statNextValue", 0);
                }
                else StatObject.SetInt("statNextValue", 0);
                
                StatsObject.SetObject("itemStat_"$StatIndex, StatObject);
                
                StatIndex++;
                UpgradeStatValue = 0;
                AfflictionType = "";
                bStatUpgraded = false;
                bUsePerc = false;
            }
        }
        else
        {
            StatsObject.SetString("firemodeIcon", "img://UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Negative");
        }
        
        ItemData.SetObject("secondaryAmmoStats", StatsObject);
    }

 	SetObject("itemData", ItemData);
}

stripped final static simulated function context(KFGFxTraderContainer_ItemDetails) float CalcSecondaryWeaponDamage(class<KFWeapon> KFW)
{
	local float BaseDamage, DoTDamage;
	local class<KFDamageType> DamageType;

	BaseDamage = KFW.default.InstantHitDamage[1];

	DamageType = class<KFDamageType>(KFW.default.InstantHitDamageTypes[DEFAULT_FIREMODE]);
	if( DamageType != None && DamageType.default.DoT_Type != DOT_None )
		DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);

	return BaseDamage * KFW.default.NumPellets[1] + DoTDamage;
}

stripped final function context(KFGFxTraderContainer_ItemDetails) SetGenericItemDetailsEx(const out STraderItem TraderItem, out GFxObject ItemData, optional int UpgradeLevel = INDEX_NONE)
{
	local KFPerk CurrentPerk;
	local int FinalMaxSpareAmmoCount;
	local int FinalMagazineCapacity;
	local float DamageValue;
	local float NextDamageValue;
    local string AfflictionType;
    local class<KFWeapon> KFW;
    local class<KFDamageType> DamageType;
    
    KFW = class<KFWeapon>(DynamicLoadObject(TraderItem.WeaponDef.default.WeaponClassPath, class'Class'));

	if( TraderItem.WeaponStats.Length >= TWS_Damage && TraderItem.WeaponStats.Length > 0 )
	{
		DamageValue = TraderItem.WeaponStats[TWS_Damage].StatValue * (UpgradeLevel > INDEX_NONE ? TraderItem.WeaponUpgradeDmgMultiplier[UpgradeLevel] : 1.0f);
		SetDetailsVisible("damage", true);
		ItemData.SetInt("damageValue", DamageValue);
		ItemData.SetInt("damagePercent", (FMin(DamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f);

		if( (UpgradeLevel + 1) < 6 )
		{
			NextDamageValue = TraderItem.WeaponStats[TWS_Damage].StatValue * TraderItem.WeaponUpgradeDmgMultiplier[UpgradeLevel + 1];
			ItemData.SetInt("damageUpgradePercent", (FMin(NextDamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f);
		}
		else
		{
			NextDamageValue = DamageValue;
			ItemData.SetInt("damageUpgradePercent", (FMin(DamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f);
		}
        
        if( KFW != None )
        {
            DamageType = class<KFDamageType>(KFW.default.InstantHitDamageTypes[KFW.const.DEFAULT_FIREMODE]);
            if( DamageType != None )
            {
                if( DamageType.default.BleedPower > 0 || class<KFDT_Bleeding>(DamageType) != None )
                    AfflictionType = "<font color=\"#FC1E1E\" face=\"MIcon\">"$`GetMIconChar("water")$"</font> ";
                else if( DamageType.default.BurnPower > 0 || class<KFDT_Fire>(DamageType) != None )
                    AfflictionType = "<font color=\"#FC7B25\" face=\"MIcon\">"$`GetMIconChar("fire")$"</font> ";
                else if( DamageType.default.PoisonPower > 0 || class<KFDT_Toxic>(DamageType) != None )
                    AfflictionType = "<font color=\"#00FF00\" face=\"MIcon\">"$`GetMIconChar("flask")$"</font> ";
                else if( DamageType.default.EMPPower > 0 || class<KFDT_EMP>(DamageType) != None )
                    AfflictionType = "<font color=\"#7A40BD\" face=\"MIcon\">"$`GetMIconChar("lightning-bolt")$"</font> ";
                else if( DamageType.default.FreezePower > 0 || class<KFDT_Freeze>(DamageType) != None )
                    AfflictionType = "<font color=\"#00B7EC\" face=\"MIcon\">"$`GetMIconChar("snowflake")$"</font> ";
            }
        }
        
        SetDetailsText("damage", AfflictionType $ GetLocalizedStatString(TraderItem.WeaponStats[TWS_Damage].StatType) @ "<b>[" @ int(DamageValue) @ "]</b>");
	}
	else SetDetailsVisible("damage", false);

	if( TraderItem.WeaponStats.Length >= TWS_Penetration )
	{
		SetDetailsVisible("penetration", true);
		SetDetailsText("penetration", GetLocalizedStatString(TraderItem.WeaponStats[TWS_Penetration].StatType) $ (TraderItem.TraderFilter != FT_Melee ? " <b>[" @ int(TraderItem.WeaponStats[TWS_Penetration].StatValue) @ "]</b>" : ""));
		if( TraderItem.TraderFilter != FT_Melee )
		{
			ItemData.SetInt("penetrationValue", TraderItem.WeaponStats[TWS_Penetration].StatValue);
			ItemData.SetInt("penetrationPercent", (FMin(TraderItem.WeaponStats[TWS_Penetration].StatValue / GetStatMax(TraderItem.WeaponStats[TWS_Penetration].StatType), 1.f) ** 0.5f) * 100.f);
		}
		else SetDetailsVisible("penetration", false);
	}
	else SetDetailsVisible("penetration", false);

	if( TraderItem.WeaponStats.Length >= TWS_RateOfFire )
	{
		SetDetailsVisible("fireRate", true);
		SetDetailsText("fireRate", GetLocalizedStatString(TraderItem.WeaponStats[TWS_RateOfFire].StatType) $ (TraderItem.TraderFilter != FT_Melee ? " <b>[" @ int(TraderItem.WeaponStats[TWS_RateOfFire].StatValue) @ "]</b>" : ""));
		if( TraderItem.TraderFilter != FT_Melee )
		{
			ItemData.SetInt("fireRateValue", TraderItem.WeaponStats[TWS_RateOfFire].StatValue);
			ItemData.SetInt("fireRatePercent", FMin(TraderItem.WeaponStats[TWS_RateOfFire].StatValue / GetStatMax(TraderItem.WeaponStats[TWS_RateOfFire].StatType), 1.f) * 100.f);
		}
		else SetDetailsVisible("fireRate", false);
	}
	else SetDetailsVisible("fireRate", false);

	if( TraderItem.WeaponStats.Length >= TWS_Range )
	{
		SetDetailsVisible("accuracy", true);
		SetDetailsText("accuracy", GetLocalizedStatString(TraderItem.WeaponStats[TWS_Range].StatType) @ "<b>[" @ int(TraderItem.WeaponStats[TWS_Range].StatValue) @ "]</b>");
		ItemData.SetInt("accuracyValue", TraderItem.WeaponStats[TWS_Range].StatValue);
		ItemData.SetInt("accuracyPercent", FMin(TraderItem.WeaponStats[TWS_Range].StatValue / GetStatMax(TraderItem.WeaponStats[TWS_Range].StatType), 1.f) * 100.f);
	}
	else SetDetailsVisible("accuracy", false);

 	ItemData.SetString("type", TraderItem.WeaponDef.static.GetItemName());
 	ItemData.SetString("name", TraderItem.WeaponDef.static.GetItemCategory());
 	ItemData.SetString("description", TraderItem.WeaponDef.static.GetItemDescription());

	CurrentPerk = KFPlayerController(GetPC()).CurrentPerk;
	if( CurrentPerk != None )
	{
		FinalMaxSpareAmmoCount = TraderItem.MaxSpareAmmo;
		FinalMagazineCapacity = TraderItem.MagazineCapacity;

		CurrentPerk.ModifyMagSizeAndNumber(None, FinalMagazineCapacity, TraderItem.AssociatedPerkClasses,, TraderItem.ClassName);

		CurrentPerk.ModifyMaxSpareAmmoAmount(None, FinalMaxSpareAmmoCount, TraderItem,);
		FinalMaxSpareAmmoCount += FinalMagazineCapacity;
	}
	else
	{
		FinalMaxSpareAmmoCount = TraderItem.MaxSpareAmmo;
		FinalMagazineCapacity = TraderItem.MagazineCapacity;
	}

 	ItemData.SetInt("ammoCapacity", FinalMaxSpareAmmoCount);
 	ItemData.SetInt("magSizeValue", FinalMagazineCapacity);

	ItemData.SetInt("weight", MyTraderMenu.GetDisplayedBlocksRequiredFor(TraderItem));

	ItemData.SetBool("bIsFavorite", MyTraderMenu.GetIsFavorite(TraderItem.ClassName));

 	ItemData.SetString("texturePath", "img://"$TraderItem.WeaponDef.static.GetImagePath());
 	if( TraderItem.AssociatedPerkClasses.length > 0 && TraderItem.AssociatedPerkClasses[0] != none )
 	{
 		ItemData.SetString("perkIconPath", "img://"$TraderItem.AssociatedPerkClasses[0].static.GetPerkIconPath());
 		if( TraderItem.AssociatedPerkClasses.Length > 1 && !`GetURI().bShouldDisableCrossPerk )
 			ItemData.SetString("perkIconPathSecondary", "img://"$TraderItem.AssociatedPerkClasses[1].static.GetPerkIconPath());
	}
	else ItemData.SetString("perkIconPath", "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath);

 	SetObject("itemData", ItemData);
}

stripped function context(KFGFxTraderContainer_ItemDetails.SetDetailsText) SetDetailsText(string DetailName, string NewName)
{
	if( DetailsContainer != None )
		DetailsContainer.GetObject(DetailName$"Title").SetString("htmlText", NewName);
}