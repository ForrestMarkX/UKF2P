class KFPerkOriginal extends Object;

static simulated function bool IsWeaponOnPerk( KFWeapon W, optional array < class<KFPerk> > WeaponPerkClass, optional class<KFPerk> InstigatorPerkClass, optional name WeaponClassName );
static function bool IsDamageTypeOnPerk( class<KFDamageType> KFDT );
static function bool IsDamageTypeOnThisPerk( class<KFDamageType> KFDT, class<KFPerk> PerkClass );
static function class<KFPerk> GetPerkFromDamageCauser( Actor WeaponActor, class<KFPerk> InstigatorPerkClass );
static function bool IsDual9mm( KFWeapon KFW );
static function bool IsFAMAS( KFWeapon KFW );
static function bool IsBlastBrawlers( KFWeapon KFW );
static function bool IsDoshinegun( KFWeapon KFW );
static function bool IsHRGCrossboom( KFWeapon KFW );
static function bool IsAutoTurret( KFWeapon KFW );
static function bool IsHRGBallisticBouncer( KFWeapon KFW );