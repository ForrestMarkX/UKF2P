class KFPawn_MonsterProxy extends Object;

stripped simulated event context(KFPawn_Monster.PreBeginPlay) PreBeginPlay()
{
	PreBeginPlayEx();
}

stripped final simulated event context(KFPawn_Monster) PreBeginPlayEx()
{
    local PhysicsAsset PhysAsset;
    local int i, Index;
    local AnimSet ScrakeWalkAnim, ScrakeAttackAnim;
    
	CheckShouldAlwaysBeRelevant();
	DefaultCollisionRadius = CylinderComponent.default.CollisionRadius;

	Super.PreBeginPlay();

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        CharacterMonsterArch = KFCharacterInfo_Monster(`GetURI().GetSeasonalCharacterArch(Class));
        if( CharacterMonsterArch == None )
            CharacterMonsterArch = KFCharacterInfo_Monster(`SafeLoadObject(MonsterArchPath, class'KFCharacterInfo_Monster'));
        if( CharacterMonsterArch == None )
            LastChanceLoad();
    }
    else
    {
        CharacterMonsterArch = KFCharacterInfo_Monster(`SafeLoadObject(MonsterArchPath, class'KFCharacterInfo_Monster'));
        if( CharacterMonsterArch == None )
            LastChanceLoad();
    }
    
    CharacterMonsterArch = new(self) class'KFCharacterInfo_Monster' (CharacterMonsterArch);

	if( IsA('KFPawn_ZedScrake') && CharacterMonsterArch != None && CharacterMonsterArch.GetPackageName() == 'SUMMER_ZED_ARCH' )
    {
        ScrakeWalkAnim = AnimSet(DynamicLoadObject("SUMMER_ZED_Scrake_ANIM.SUMMER_Monkey_anim_Walk", class'AnimSet'));
        ScrakeAttackAnim = AnimSet(DynamicLoadObject("SUMMER_ZED_Scrake_ANIM.SUMMER_Scrake_anim_Attacks", class'AnimSet'));
        
        if( !`GetURI().CurrentNormalSummerSCAnims )
        {
            CharacterMonsterArch.AnimSets.RemoveItem(ScrakeWalkAnim);
            CharacterMonsterArch.AnimSets.RemoveItem(ScrakeAttackAnim);
        }
        else
        {
            Index = CharacterMonsterArch.AnimSets.Find(ScrakeWalkAnim);
            if( Index == INDEX_NONE )
                CharacterMonsterArch.AnimSets.AddItem(ScrakeWalkAnim);
                
            Index = CharacterMonsterArch.AnimSets.Find(ScrakeAttackAnim);
            if( Index == INDEX_NONE )
                CharacterMonsterArch.AnimSets.AddItem(ScrakeAttackAnim);
        }
    }
	else if( (IsA('KFPawn_ZedGorefast') || IsA('KFPawn_ZedGorefastDualBlade')) && CharacterMonsterArch != None && CharacterMonsterArch.GetPackageName() == 'SUMMER_ZED_ARCH' )
    {
        CharacterMonsterArch.PhysAsset = new(self) class'PhysicsAsset' (CharacterMonsterArch.PhysAsset);
        PhysAsset = CharacterMonsterArch.PhysAsset;
        for( i=0; i<PhysAsset.BodySetup.Length; i++ )
        {
            if( PhysAsset.BodySetup[i].BoneName == 'hips' || PhysAsset.BodySetup[i].BoneName == 'Spine' || PhysAsset.BodySetup[i].BoneName == 'Spine1' )
            {
                Index = PhysAsset.BodySetup[i].AggGeom.SphylElems.Find('HitZoneName', 'rblade');
                while( Index != INDEX_NONE )
                {
                    PhysAsset.BodySetup[i].AggGeom.SphylElems.Remove(Index, 1);
                    Index = PhysAsset.BodySetup[i].AggGeom.SphylElems.Find('HitZoneName', 'rblade');
                }
            }
        }
    }

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

stripped function context(KFPawn_Monster.GetAIPawnClassToSpawn) class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	local WorldInfo WI;
	local KFGameReplicationInfo KFGRI;

	WI = class'WorldInfo'.static.GetWorldInfo();
	KFGRI = KFGameReplicationInfo(WI.GRI);

    if( `GetURI().bForceDisableEDARs && (ClassIsChildOf(default.Class, class'KFPawn_ZedHusk') || ClassIsChildOf(default.Class, class'KFPawn_ZedStalker')) )
        return default.Class;
    else if( `GetURI().bForceDisableGorefiends && ClassIsChildOf(default.Class, class'KFPawn_ZedGorefast') && !ClassIsChildOf(default.Class, class'KFPawn_ZedGorefastDualBlade') )
        return default.Class;
    else if( `GetURI().bForceDisableRioters && ClassIsChildOf(default.Class, class'KFPawn_ZedClot_Alpha') && !ClassIsChildOf(default.Class, class'KFPawn_ZedClot_AlphaKing') )
        return default.Class;
        
    if( KFGameInfo(WI.Game) != None && `GetURI().bForceDisableQPs && ClassIsChildOf(default.Class, class'KFPawn_ZedFleshpoundMini') && !KFGameReplicationInfo(WI.GRI).IsBossWave() )
        return KFGameInfo(WI.Game).GetAISpawnType(AT_Scrake);

    if( KFGRI != None && !KFGRI.IsContaminationMode() )
    {
        if( default.ElitePawnClass.Length > 0 && default.DifficultySettings != None && fRand() < default.DifficultySettings.static.GetSpecialSpawnChance(KFGameReplicationInfo(WI.GRI)) )
        {
            if( KFGameInfo(WI.Game) != None && `GetURI().bForceDisableGasCrawlers && ClassIsChildOf(default.Class, class'KFPawn_ZedCrawler') && !ClassIsChildOf(default.Class, class'KFPawn_ZedCrawlerKing') )
                return KFGameInfo(WI.Game).GetAISpawnType(AT_Stalker);
            return default.ElitePawnClass[Rand(default.ElitePawnClass.Length)];
        }
    }
        
	return default.Class;
}