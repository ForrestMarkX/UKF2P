class KFPerk_FirebugProxy extends Object;

stripped simulated function context(KFPerk_Firebug.ModifyMagSizeAndNumber) ModifyMagSizeAndNumber( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
	ModifyMagSizeAndNumberEx(KFW, MagazineCapacity, WeaponPerkClass, bSecondary, WeaponClassname);
}

stripped final simulated function context(KFPerk_Firebug) ModifyMagSizeAndNumberEx( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
	local float TempCapacity;
	local byte ItemIndex;
	local class<KFWeapon> WepClass;
	local class<KFWeaponDefinition> WeaponDef;
	
	if( KFW != None && (KFW.IsA('KFWeap_Pistol_HRGScorcher') || KFW.IsA('KFWeap_HRG_Dragonbreath')) )
		return;
	else if( KFW == None )
	{
		if( MyKFGRI != None && MyKFGRI.TraderItems != None && MyKFGRI.TraderItems.GetItemIndicesFromArche(ItemIndex, WeaponClassname) )
		{
			WeaponDef = MyKFGRI.TraderItems.SaleItems[ItemIndex].WeaponDef;
			if( WeaponDef != None )
			{
				WepClass = class<KFWeapon>(DynamicLoadObject(WeaponDef.default.WeaponClassPath, class'Class'));
				if( WepClass != None && (ClassIsChildOf(WepClass, class'KFWeap_Pistol_HRGScorcher') || ClassIsChildOf(WepClass, class'KFWeap_HRG_Dragonbreath')) )
					return;
			}
		}
	}

	TempCapacity = MagazineCapacity;
	if( IsWeaponOnPerk(KFW, WeaponPerkClass, Class) && IsHighCapFuelTankActive() && (KFW == None || !KFW.bNoMagazine) )
		TempCapacity += MagazineCapacity * GetSkillValue( PerkSkills[EFirebugHighCapFuelTank] );

	MagazineCapacity = Round(TempCapacity);
}