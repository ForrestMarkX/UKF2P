class KFPerk_FieldMedicProxy extends Object;

stripped function context(KFPerk_FieldMedic.CouldBeZedToxicCloud) bool CouldBeZedToxicCloud( class<KFDamageType> KFDT )
{
	return IsZedativeActive() && (IsDamageTypeOnPerk(KFDT) || ClassIsChildOf(KFDT, class'KFDT_Bludgeon_Doshinegun_Shot'));
}

stripped simulated function context(KFPerk_FieldMedic.ModifyMagSizeAndNumber) ModifyMagSizeAndNumber( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
	ModifyMagSizeAndNumberEx(KFW, MagazineCapacity, WeaponPerkClass, bSecondary, WeaponClassname);
}

stripped final simulated function context(KFPerk_FieldMedic) ModifyMagSizeAndNumberEx( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
	local float TempCapacity;
	local byte ItemIndex;
	local class<KFWeapon> WepClass;
	local class<KFWeaponDefinition> WeaponDef;
	
	if( KFW != None && (KFW.IsA('KFWeap_Rifle_HRGIncision') || KFW.IsA('KFWeap_HRG_MedicMissile')) )
		return;
	else if( KFW == None )
	{
		if( MyKFGRI != None && MyKFGRI.TraderItems != None && MyKFGRI.TraderItems.GetItemIndicesFromArche(ItemIndex, WeaponClassname) )
		{
			WeaponDef = MyKFGRI.TraderItems.SaleItems[ItemIndex].WeaponDef;
			if( WeaponDef != None )
			{
				WepClass = class<KFWeapon>(DynamicLoadObject(WeaponDef.default.WeaponClassPath, class'Class'));
				if( WepClass != None && (ClassIsChildOf(WepClass, class'KFWeap_Rifle_HRGIncision') || ClassIsChildOf(WepClass, class'KFWeap_HRG_MedicMissile')) )
					return;
			}
		}
	}

	TempCapacity = MagazineCapacity;
	if( IsWeaponOnPerk(KFW, WeaponPerkClass, Class) && (KFW == None || !KFW.bNoMagazine) && !bSecondary && IsCombatantActive() )
		TempCapacity += MagazineCapacity * GetSkillValue( PerkSkills[EMedicCombatant] );
	MagazineCapacity = Round( TempCapacity );
}