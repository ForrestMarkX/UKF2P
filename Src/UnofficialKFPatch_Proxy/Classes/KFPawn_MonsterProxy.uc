class KFPawn_MonsterProxy extends Object;

stripped simulated event context(KFPawn_Monster.PreBeginPlay) PreBeginPlay()
{
	local KFPawn_Monster KFPM;
	local bool bArchAlreadyLoaded;
    
	CheckShouldAlwaysBeRelevant();
	DefaultCollisionRadius = CylinderComponent.default.CollisionRadius;

	Super.PreBeginPlay();

    CharacterMonsterArch = KFCharacterInfo_Monster(`GetURI().GetSeasonalCharacterArch(Class));
    if( CharacterMonsterArch == None )
        CharacterMonsterArch = KFCharacterInfo_Monster(`SafeLoadObject(MonsterArchPath, class'KFCharacterInfo_Monster'));
	if( CharacterMonsterArch == None )
		LastChanceLoad();
    
	if( IsA('KFPawn_ZedScrake') && !`GetURI().CurrentNormalSummerSCAnims && CharacterMonsterArch != None && CharacterMonsterArch.GetPackageName() == 'SUMMER_ZED_ARCH' && CharacterMonsterArch.AnimSets.Length > 3 )
		CharacterMonsterArch.AnimSets.Remove(3, 2);
	else if( IsA('KFPawn_ZedGorefast') && CharacterMonsterArch != None && CharacterMonsterArch.GetPackageName() == 'SUMMER_ZED_ARCH' )
		CharacterMonsterArch.PhysAsset = PhysicsAsset'UKFP_SUMMER_ZED_Gorefast_PHYS.SUMMER_Gorefast_Rig_Optimized_Physics';
	else if( IsA('KFPawn_ZedGorefastDualBlade') && CharacterMonsterArch != None && CharacterMonsterArch.GetPackageName() == 'SUMMER_ZED_ARCH' )
		CharacterMonsterArch.PhysAsset = PhysicsAsset'UKFP_SUMMER_ZED_Gorefast2_PHY.SUMMER_Gorefast2_Rig_Master_Physics';
    
	SetCharacterArch(CharacterMonsterArch, true);
	if( CharacterArch == None )
	{
		`Log("Failed to find character info for KFMonsterPawn!",,Class.Name);
		Destroy();
	}
    
	NormalGroundSpeed = default.GroundSpeed;
	NormalSprintSpeed = default.SprintSpeed;

	if( ArmorInfoClass != None )
		ArmorInfo = new(self) ArmorInfoClass;
}

stripped simulated function context(KFPawn_Monster.PlayHeadAsplode) PlayHeadAsplode()
{
	local KFGoreManager GoreManager;
	local name BoneName;

	if( HitZones[HZI_Head].bPlayedInjury )
		return;

	if( (bTearOff || bPlayedDeath) && TimeOfDeath > 0 && `TimeSince(TimeOfDeath) > 0.75 )
		return;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != None && GoreManager.AllowHeadless() && !bIsGoreMesh && !bDisableHeadless )
		ForceSwitchToGoreMesh(GoreManager);

	if( bIsGoreMesh && GoreManager != None )
	{
        BoneName = HitZones[HZI_Head].BoneName;
		GoreManager.CrushBone( self, BoneName );
        SoundGroupArch.PlayHeadPopSounds( self, mesh.GetBoneLocation(BoneName) );
		HitZones[HZI_Head].bPlayedInjury = true;
	}

	SpawnHeadShotFX(KFPlayerReplicationInfo(HitFxInfo.DamagerPRI));
}

stripped final simulated function context(KFPawn_Monster) ForceSwitchToGoreMesh(KFGoreManager GoreManager)
{
	local byte OldRepBleedInflateMatParam;
	
	OldRepBleedInflateMatParam = RepBleedInflateMatParam;
	RepBleedInflateMatParam = 0;
	SwitchToGoreMesh();
	RepBleedInflateMatParam = OldRepBleedInflateMatParam;
	
	ReplicatedEvent('RepBleedInflateMatParam');
}

stripped static event context(KFPawn_Monster.GetAIPawnClassToSpawn) class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	local WorldInfo WI;
    
	if( `GetURI() != None && `GetURI().bForceDisableEDARs && (ClassIsChildOf(default.Class, class'KFPawn_ZedHusk') || ClassIsChildOf(default.Class, class'KFPawn_ZedStalker')) )
        return default.Class;

	WI = class'WorldInfo'.static.GetWorldInfo();
	if( default.ElitePawnClass.length > 0 && default.DifficultySettings != none && fRand() < default.DifficultySettings.static.GetSpecialSpawnChance(KFGameReplicationInfo(WI.GRI)) )
		return default.ElitePawnClass[Rand(default.ElitePawnClass.length)];
        
	return default.Class;
}