class KFPerkProxy extends Object;

stripped static simulated function context(KFPerk.IsWeaponOnPerk) bool IsWeaponOnPerk( KFWeapon W, optional array < class<KFPerk> > WeaponPerkClass, optional class<KFPerk> InstigatorPerkClass, optional name WeaponClassName )
{
    return IsWeaponOnActualPerk(W, WeaponPerkClass, InstigatorPerkClass, WeaponClassName);
}

stripped final simulated static function context(KFPerk) bool IsWeaponOnActualPerk( KFWeapon W, optional array < class<KFPerk> > WeaponPerkClass, optional class<KFPerk> InstigatorPerkClass, optional name WeaponClassName )
{
    local int i;

	if( W != None )
        return W.static.AllowedForAllPerks() || ClassIsChildOf(default.Class, W.static.GetWeaponPerkClass( InstigatorPerkClass ));
	else if( WeaponPerkClass.Length > 0 )
    {
        if( `GetURI().bShouldDisableCrossPerk )
        {
            if( ClassIsChildOf(default.Class, WeaponPerkClass[0]) )
                return true;
        }
        else
        {
            for( i=0; i<WeaponPerkClass.Length; i++ )
            {
                if( ClassIsChildOf(default.Class, WeaponPerkClass[i]) )
                    return true;
            }
        }
    }

	return false;
}

stripped static function context(KFPerk.IsDamageTypeOnPerk) bool IsDamageTypeOnPerk( class<KFDamageType> KFDT )
{
    return IsDamageTypeOnActualPerk(KFDT);
}

stripped final simulated static function context(KFPerk) bool IsDamageTypeOnActualPerk( class<KFDamageType> KFDT )
{
    local int i;

	if( KFDT != None )
	{
        if( KFDT.default.ModifierPerkList.Length <= 0 )
            return false;

        if( `GetURI().bShouldDisableCrossPerk )
        {
            if( ClassIsChildOf(default.Class, KFDT.default.ModifierPerkList[0]) )
                return true;
        }
        else
        {
            for( i=0; i<KFDT.default.ModifierPerkList.Length; i++ )
            {
                if( ClassIsChildOf(default.Class, KFDT.default.ModifierPerkList[i]) )
                    return true;
            }
        }
	}

	return false;
}

stripped static function context(KFPerk.IsDamageTypeOnThisPerk) bool IsDamageTypeOnThisPerk( class<KFDamageType> KFDT, class<KFPerk> PerkClass )
{
    return IsDamageTypeOnThisActualPerk(KFDT, PerkClass);
}

stripped final simulated static function context(KFPerk) bool IsDamageTypeOnThisActualPerk( class<KFDamageType> KFDT, class<KFPerk> PerkClass )
{
    local int i;
    
	if( KFDT != None )
	{
        if( KFDT.default.ModifierPerkList.Length <= 0 )
            return false;
            
        if( `GetURI().bShouldDisableCrossPerk )
        {
            if( ClassIsChildOf(PerkClass, KFDT.default.ModifierPerkList[0]) )
                return true;
        }
        else
        {
            for( i=0; i<KFDT.default.ModifierPerkList.Length; i++ )
            {
                if( ClassIsChildOf(PerkClass, KFDT.default.ModifierPerkList[i]) )
                    return true;
            }
        }
	}

	return false;
}

stripped static function context(KFPerk.GetPerkFromDamageCauser) class<KFPerk> GetPerkFromDamageCauser( Actor WeaponActor, class<KFPerk> InstigatorPerkClass )
{
	local KFWeapon KFW;
	local KFProjectile KFPrj;
	local KFSprayActor KFSpray;
    
	KFW = KFWeapon(WeaponActor);
    
	if( WeaponActor != None && KFW == None )
	{
        KFPrj = KFProjectile(WeaponActor);
		if( KFPrj != None && KFPrj.AssociatedPerkClass == None )
			KFW = KFWeapon(WeaponActor.Owner);
		else if( KFPrj != None )
			return GetPerkTypeCastFromClass(GetPerkFromProjectile(WeaponActor));
		else if( WeaponActor.IsA( 'KFSprayActor' ) )
		{
			KFSpray = KFSprayActor(WeaponActor);
			if (ClassIsChildOf(KFSpray.MyDamageType, class'KFDT_Fire') || ClassIsChildOf(KFSpray.MyDamageType, class'KFDT_Microwave'))
				return GetPerkTypeCastFromClass(class'KFPerk_Firebug');
			else if (ClassIsChildOf(KFSpray.MyDamageType, class'KFDT_Freeze'))
				return GetPerkTypeCastFromClass(class'KFPerk_Survivalist');
			else if (ClassIsChildOf(KFSpray.MyDamageType, class'KFDT_Toxic'))
				return GetPerkTypeCastFromClass(class'KFPerk_FieldMedic');
		}
		else if( WeaponActor.IsA( 'KFDoorActor' ) )
			return GetPerkTypeCastFromClass(class'KFPerk_Demolitionist');
	}

	if( KFW != None )
		return GetPerkTypeCastFromClass(KFW.static.GetWeaponPerkClass(InstigatorPerkClass));

	return None;
}

stripped final simulated static function context(KFPerk) class<KFPerk> GetPerkTypeCastFromClass( class<KFPerk> InPerkClass )
{
    local UKFPReplicationInfo URI;
    
    URI = `GetURI();
    if( URI != None )
        return URI.GetPerkTypeCastFromClass(InPerkClass);
        
    return InPerkClass;
}

stripped static function context(KFPerk.IsDual9mm) bool IsDual9mm( KFWeapon KFW )
{
	return KFW != None && (KFW.IsA('KFWeap_Pistol_Dual9mm') || KFW.IsA('KFWeap_HRG_93R_Dual'));
}

stripped static function context(KFPerk.IsHRG93R) bool IsHRG93R( KFWeapon KFW )
{
	return KFW != None && (KFW.IsA('KFWeap_HRG_93R') || KFW.IsA('KFWeap_HRG_93R_Dual'));
}

stripped static function context(KFPerk.IsFAMAS) bool IsFAMAS( KFWeapon KFW )
{
	return KFW != None && KFW.IsA('KFWeap_AssaultRifle_FAMAS');
}

stripped static function context(KFPerk.IsBlastBrawlers) bool IsBlastBrawlers( KFWeapon KFW )
{
	return KFW != None && KFW.IsA('KFWeap_HRG_BlastBrawlers');
}

stripped static function context(KFPerk.IsDoshinegun) bool IsDoshinegun( KFWeapon KFW )
{
	return KFW != None && KFW.IsA('KFWeap_AssaultRifle_Doshinegun');
}

stripped static function context(KFPerk.IsHRGCrossboom) bool IsHRGCrossboom( KFWeapon KFW )
{
	return KFW != none && KFW.IsA('KFWeap_HRG_Crossboom');
}

stripped static function context(KFPerk.IsAutoTurret) bool IsAutoTurret( KFWeapon KFW )
{
	return KFW != none && KFW.IsA('KFWeap_AutoTurret');
}

stripped static function context(KFPerk.IsHRGBallisticBouncer) bool IsHRGBallisticBouncer( KFWeapon KFW )
{
    return KFW != None && KFW.IsA('KFWeap_HRG_BallisticBouncer');
}