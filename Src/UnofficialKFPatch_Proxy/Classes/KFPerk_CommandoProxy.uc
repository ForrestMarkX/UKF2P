class KFPerk_CommandoProxy extends Object;

stripped simulated function context(KFPerk_Commando.ModifyMagSizeAndNumber) ModifyMagSizeAndNumber( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
	ModifyMagSizeAndNumberEx(KFW, MagazineCapacity, WeaponPerkClass, bSecondary, WeaponClassname);
}

stripped final simulated function context(KFPerk_Commando) ModifyMagSizeAndNumberEx( KFWeapon KFW, out int MagazineCapacity, optional array< Class<KFPerk> > WeaponPerkClass, optional bool bSecondary=false, optional name WeaponClassname )
{
	local float TempCapacity;
	local byte ItemIndex;
	local class<KFWeapon> WepClass;
	local class<KFWeaponDefinition> WeaponDef;

	TempCapacity = MagazineCapacity;
	
	if( IsAutoTurret(KFW) )
		return;
	else if( KFW == None )
	{
		if( MyKFGRI != None && MyKFGRI.TraderItems != None && MyKFGRI.TraderItems.GetItemIndicesFromArche(ItemIndex, WeaponClassname) )
		{
			WeaponDef = MyKFGRI.TraderItems.SaleItems[ItemIndex].WeaponDef;
			if( WeaponDef != None )
			{
				WepClass = class<KFWeapon>(DynamicLoadObject(WeaponDef.default.WeaponClassPath, class'Class'));
				if( WepClass != None && ClassIsChildOf(WepClass, class'KFWeap_Autoturret') )
					return;
			}
		}
	}

	if( (!bSecondary || IsFAMAS(KFW)) && IsWeaponOnPerk(KFW, WeaponPerkClass, Class) && (KFW == None || !KFW.bNoMagazine) )
	{
		if( IsLargeMagActive() )
			TempCapacity += MagazineCapacity * GetSkillValue( PerkSkills[ECommandoLargeMags] );
		if( IsEatLeadActive() )
			TempCapacity += MagazineCapacity * GetSkillValue( PerkSkills[ECommandoEatLead] );
	}

	
	MagazineCapacity = Round(TempCapacity);
}