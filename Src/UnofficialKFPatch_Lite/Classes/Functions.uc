class Functions extends Object;

stripped simulated event context(Actor.FellOutOfWorld) ActorFellOutOfWorld(class<DamageType> dmgType)
{
    if( Role == ROLE_Authority && IsA('DroppedPickup') )
    {
        PickupFellOutOfWorld();
        return;
    }
    
	SetPhysics(PHYS_None);
	SetHidden(True);
	SetCollision(false,false);
	Destroy();
}

stripped final function context(DroppedPickup) PickupFellOutOfWorld()
{
    local KFGameReplicationInfo GRI;
    local KFTraderTrigger Trader;
    local vector BoxExtent, HitLocation;
    local int NumLoops;
    local float CollisionRadius, CollisionHeight;

    if( Instigator != None )
    {
        Instigator.GetBoundingCylinder(CollisionRadius, CollisionHeight);
        HitLocation = Instigator.Location + (CollisionHeight * vect(0, 0, 0.5f));
        SetLocation(HitLocation);
        if( Location != HitLocation )
        {
            SetPhysics(PHYS_None);
            SetHidden(True);
            SetCollision(false,false);
            Destroy();
        }
    }
    else
    {
        GRI = KFGameReplicationInfo(WorldInfo.GRI);
        if( GRI.NextTrader != None )
            Trader = GRI.NextTrader;
        else Trader = GRI.OpenedTrader;
        
        if( Trader != None && Trader.TraderMeshActor != None )
        {
            GetBoundingCylinder(CollisionRadius, CollisionHeight);
            
            BoxExtent.X = CollisionRadius;
            BoxExtent.Y = CollisionRadius;
            BoxExtent.Z = CollisionHeight;
            
            HitLocation = Trader.TraderMeshActor.Location;
            while( true )
            {
                if( NumLoops >= 1000 )
                {
                    `Warn("Failed to find a location for "$self$" 1000 times!");
                    SetLocation(HitLocation);
                    break;
                }
                
                if( FindSpot(BoxExtent, HitLocation) )
                {
                    SetLocation(HitLocation);
                    break;
                }
                
                NumLoops++;
            }
            
            if( Location != HitLocation )
            {
                SetPhysics(PHYS_None);
                SetHidden(True);
                SetCollision(false,false);
                Destroy();
            }
        }
    }
}

stripped event context(DroppedPickup.Landed) PickupLanded(Vector HitNormal, Actor FloorActor)
{
	bForceNetUpdate = TRUE;
	bNetDirty = true;
	NetUpdateFrequency = 8.f;

	AddToNavigation();
}

stripped reliable private final server function context(KFPlayerController.MixerGiveAmmo) MixerGiveAmmo(string ControlId, string TransactionId, int Amount, int Cooldown, optional string Username)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerGiveArmor) MixerGiveArmor(string ControlId, string TransactionId, int Amount, int Cooldown, string Username)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerGiveDosh) MixerGiveDosh(string ControlId, string TransactionId, int Amount, int Cooldown, string Username)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerGiveGrenades) MixerGiveGrenades(string ControlId, string TransactionId, int Amount, int Cooldown, string Username)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerHealUser) MixerHealUser(string ControlId, string TransactionId, int Amount, int Cooldown, string Username)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerCauseZedTime) MixerCauseZedTime(string ControlId, string TransactionId, int Amount, int Cooldown, string Username)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerEnrageZeds) MixerEnrageZeds(string ControlId, string TransactionId, int Radius, int Cooldown, string Username)
{
    return;
}

stripped simulated private final function context(KFPlayerController.MixerPukeUser) MixerPukeUser(string ControlId, string TransactionId, float PukeLength, int Cooldown, string UserName)
{
    return;
}

stripped reliable private final server function context(KFPlayerController.MixerSpawnZed) MixerSpawnZed(string ControlId, string TransactionId, string ZedClass, int Amount, int Cooldown, string UserName)
{
    return;
}

stripped reliable server function context(KFPlayerController.SkipLobby) SkipLobby()
{
    return;
}

stripped reliable server function context(KFPlayerController.ServerSetEnablePurchases) ServerSetEnablePurchases(bool bEnalbe)
{
	local KFInventoryManager KFIM;

    if( !KFGameReplicationInfo(WorldInfo.GRI).bTraderIsOpen )
        return;

	if( Role == ROLE_Authority && Pawn != none )
	{
		KFIM = KFInventoryManager(Pawn.InvManager);
		KFIM.bServerTraderMenuOpen = bEnalbe;
	}
	bClientTraderMenuOpen = bEnalbe;
}

stripped simulated event context(KFPlayerReplicationInfo.PostBeginPlay) PRIPostBeginPlay()
{
	Super.PostBeginPlay();

	if( Role == ROLE_Authority )
	{
		KFPlayerOwner = KFPlayerController( Owner );
		ResetSkipTrader();
	}
    
    NetUpdateFrequency = 5.f;
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerStartKickVote) ServerStartKickVote(PlayerReplicationInfo Kickee, PlayerReplicationInfo Kicker)
{
	local KFGameReplicationInfo KFGRI;

    if( Kicker != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.ServerStartVoteKick(Kickee, self);
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerCastKickVote) ServerCastKickVote(PlayerReplicationInfo PRI, bool bKick)
{
	local KFGameReplicationInfo KFGRI;

    if( PRI != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.RecieveVoteKick(self, bKick);
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerRequestSkipTraderVote) ServerRequestSkipTraderVote(PlayerReplicationInfo PRI)
{
	local KFGameReplicationInfo KFGRI;

    if( PRI != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.ServerStartVoteSkipTrader(self);
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerCastSkipTraderVote) ServerCastSkipTraderVote(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	local KFGameReplicationInfo KFGRI;

    if( PRI != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.RecieveVoteSkipTrader(self, bSkipTrader);
}

stripped function context(KFPawn.JumpOffPawn) JumpOffPawn()
{
	local float Theta;

	if( Base == None || Base.Location.Z > Location.Z )
		return;
        
    if( KFPawn_ZedCrawler(Base) != None )
    {
        KFPawn_ZedCrawler(Base).Knockdown(Base.Velocity * 3, vect(1, 1, 1), Base.Location, 1000, 100);
        SetPhysics(PHYS_Falling);
        return;
    }

	Theta = 2.f * PI * FRand();
	SetPhysics(PHYS_Falling);

	if( Controller != None && !IsHumanControlled() )
	{
		Velocity.X += Cos(Theta) * (750 + CylinderComponent.CollisionRadius);
		Velocity.Y += Sin(Theta) * (750 + CylinderComponent.CollisionRadius);
		if( VSize2D(Velocity) > 2.0 * FMax(500.0, GroundSpeed) )
			Velocity = 2.0 * FMax(500.0, GroundSpeed) * Normal(Velocity);
		Velocity.Z = 400;

		AirControl = 0.05f;
		SetTimer(1.0, false, nameof(RestoreAirControlTimer));
	}
	else
	{
		Velocity.X += Cos(Theta) * (150 + CylinderComponent.CollisionRadius);
		Velocity.Y += Sin(Theta) * (150 + CylinderComponent.CollisionRadius);
		if( VSize2D(Velocity) > FMax(500.0, GroundSpeed) )
			Velocity = FMax(500.0, GroundSpeed) * Normal(Velocity);
		Velocity.Z = 200;
	}
}

stripped event context(KFAIController.FindNewEnemy) bool FindNewEnemy()
{
    local Pawn PotentialEnemy, BestEnemy;
    local float BestDist, NewDist;
    local int BestEnemyZedCount;
    local int PotentialEnemyZedCount;
    local bool bUpdateBestEnemy;

    if( Pawn == None )
        return false;
 
    BestDist = MaxInt;
    foreach WorldInfo.AllPawns( class'Pawn', PotentialEnemy )
    {
        if( !PotentialEnemy.IsAliveAndWell() || Pawn.IsSameTeam(PotentialEnemy) || !PotentialEnemy.CanAITargetThisPawn(self) )
            continue;

        NewDist = VSizeSq(PotentialEnemy.Location - Pawn.Location);
        if( BestEnemy == None || BestDist > NewDist )
        {
            BestEnemyZedCount = INDEX_None;
            bUpdateBestEnemy = true;
        }
        else
        {
            if( BestEnemyZedCount == INDEX_None )
                BestEnemyZedCount = NumberOfZedsTargetingPawn(BestEnemy);

            PotentialEnemyZedCount = NumberOfZedsTargetingPawn( PotentialEnemy );
            if( PotentialEnemyZedCount < BestEnemyZedCount )
            {
                BestEnemyZedCount = PotentialEnemyZedCount;
                bUpdateBestEnemy = true;
            }
        }

        if( bUpdateBestEnemy )
        {
            BestEnemy = PotentialEnemy;
            BestDist = NewDist;
            bUpdateBestEnemy = false;
        }
    }
 
    if( Enemy != None && BestEnemy != None && BestEnemy == Enemy )
        return false;
        
    if( BestEnemy != None )
    {
        ChangeEnemy(BestEnemy);
        return HasValidEnemy();
    }
 
    return false;
}

stripped function context(KFGameInfo_Survival.StartMatch) StartMatch()
{
    local KFPlayerController KFPC;

	WaveNum = 0;

	Super.StartMatch();
	
	`GetMut().NotifyMatchStarted();

	if( class'KFGameEngine'.static.CheckNoAutoStart() || class'KFGameEngine'.static.IsEditor() )
		GotoState('DebugSuspendWave');
	else GotoState('PlayingWave');

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
        KFPC.ClientMatchStarted();
}

stripped function context(KFGameInfo_Survival.NotifyTraderOpened) NotifyTraderOpened()
{
	local array<SequenceObject> AllTraderOpenedEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_TraderOpened TraderOpenedEvt;
	local Sequence GameSeq;
	local int i;

	`GetMut().NotifyWaveEnded();

	GameSeq = WorldInfo.GetGameSequence();
	if( GameSeq != None )
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderOpened', true, AllTraderOpenedEvents);
		for( i=0; i<AllTraderOpenedEvents.Length; i++ )
		{
			TraderOpenedEvt = KFSeqEvent_TraderOpened(AllTraderOpenedEvents[i]);
			if( TraderOpenedEvt != None )
			{
				TraderOpenedEvt.Reset();
				TraderOpenedEvt.SetWaveNum(WaveNum, WaveMax);
				if( MyKFGRI.IsFinalWave() && TraderOpenedEvt.OutputLinks.Length > 1 )
					OutputLinksToActivate.AddItem(1);
				else OutputLinksToActivate.AddItem(0);
				TraderOpenedEvt.CheckActivate(self, self,, OutputLinksToActivate);
			}
		}
	}
}

stripped function context(KFGameInfo_Survival.NotifyTraderClosed) NotifyTraderClosed()
{
	local KFSeqEvent_TraderClosed TraderClosedEvt;
	local array<SequenceObject> AllTraderClosedEvents;
	local Sequence GameSeq;
	local int i;

	`GetMut().NotifyWaveStarted();

	GameSeq = WorldInfo.GetGameSequence();
	if( GameSeq != None )
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderClosed', true, AllTraderClosedEvents);
		for( i=0; i<AllTraderClosedEvents.Length; ++i )
		{
			TraderClosedEvt = KFSeqEvent_TraderClosed(AllTraderClosedEvents[i]);
			if( TraderClosedEvt != None )
			{
				TraderClosedEvt.Reset();
				TraderClosedEvt.SetWaveNum(WaveNum, WaveMax);
				TraderClosedEvt.CheckActivate(self, self);
			}
		}
	}
}

stripped unreliable server function context(PlayerController.ServerSay) ServerSay( string Msg )
{
	local PlayerController PC;

	if( PlayerReplicationInfo.bAdmin && Left(Msg,1) == "#" )
	{
		Msg = Right(Msg,Len(Msg)-1);
		foreach WorldInfo.AllControllers(class'PlayerController', PC)
			PC.ClientAdminMessage(Msg);
		return;
	}

    if( Left(Msg,1) == "!" && `GetMut().ProcessChatMessage(Mid(Msg, 1), Self) )
        return;
	WorldInfo.Game.Broadcast(self, Msg, 'Say');
}

stripped unreliable server function context(PlayerController.ServerTeamSay) ServerTeamSay( string Msg )
{
	LastActiveTime = WorldInfo.TimeSeconds;

	if( !WorldInfo.GRI.GameClass.default.bTeamGame )
	{
		Say(Msg);
		return;
	}

    if( Left(Msg,1) == "!" && `GetMut().ProcessChatMessage(Mid(Msg, 1), Self, true) )
        return;
    WorldInfo.Game.BroadcastTeam(self, Msg, 'TeamSay');
}

stripped static function context(KFGameInfo.GetSpecificBossClass) class<KFPawn_Monster> GetSpecificBossClass(int Index, KFMapInfo MapInfo = none)
{
	return GetSpecificBossClassEx(Index, MapInfo);
}

stripped final static function context(KFGameInfo) class<KFPawn_Monster> GetSpecificBossClassEx(int Index, KFMapInfo MapInfo = none)
{
	local array< class<KFPawn_Monster> > ClassList;
    local UKFPMutator Mut;

	ClassList = default.AIBossClassList;
	if( MapInfo != None )
		MapInfo.ModifyGameClassBossAIClassList(ClassList);

	if( Index < 0 || Index >= ClassList.Length )
		return None;
        
    Mut = `GetMut();
    if( Mut != None && (MapInfo == None || !MapInfo.bOverrideSurvivalBoss) )
    {
        Mut.GetAllowedBossList(ClassList);
        if( Index >= ClassList.Length )
            Index = Rand(ClassList.Length);
    }

	return ClassList[Index];
}

stripped function context(KFGameInfo_Endless.TrySetNextWaveSpecial) bool GameTrySetNextWaveSpecial()
{
	return `GetMut().TrySetNextWaveSpecial();
}

stripped simulated event context(KFGameReplicationInfo.PostBeginPlay) GRIPostBeginPlay()
{
	local KFDoorActor Door;

	VoteCollector = new(Self) VoteCollectorClass;

	Super.PostBeginPlay();

	ConsoleGameSessionGuid = KFGameEngine(Class'Engine'.static.GetEngine()).ConsoleGameSessionGuid;

	foreach DynamicActors(class'KFDoorActor', Door)
		DoorList.AddItem(Door);

	if( WorldInfo.NetMode != NM_DedicatedServer && TraderDialogManagerClass != none )
		TraderDialogManager = Spawn(TraderDialogManagerClass);

	SetTimer(1.f, true);
	TraderItems = KFGFxObject_TraderItems(DynamicLoadObject(TraderItemsPath, class'KFGFxObject_TraderItems'));
    
    if( `GetMut() != None )
        `GetMut().InitGameReplicationInfo(self);
}

stripped simulated function context(KFDroppedPickup.SetPickupMesh) SetPickupMesh(PrimitiveComponent NewPickupMesh)
{
	local ActorComponent Comp;
	local SkeletalMeshComponent SkelMC;
	local StaticMeshComponent StaticMC;
	local KFGameInfo KFGI;

    NetUpdateFrequency = 10.f;

	if( Role == ROLE_Authority )
	{
		if( Inventory != None && Inventory.IsA('KFWeapon') )
		{
			SkinItemId = KFWeapon(Inventory).SkinItemId;
            bEmptyPickup = !KFWeapon(Inventory).HasAnyAmmo();
			bUpgradedPickup = KFWeapon(Inventory).CurrentWeaponUpgradeIndex > 0;
		}
        
        Lifespan = FMax(`GetMut().CurrentPickupLifespan, 0);
        if( Lifespan == 0 )
            Lifespan = MaxInt;

        SetTimer(Lifespan, false, 'TryFadeOut');

        AddPickupToList();
	}

	if( NewPickupMesh != None )
	{
		if( CollisionComponent == None || CollisionComponent.Class != NewPickupMesh.Class )
		{
			Comp = new(self) NewPickupMesh.Class(NewPickupMesh);
			MyMeshComp = MeshComponent(Comp);
			AttachComponent(Comp);
			MyCylinderComp = CylinderComponent(CollisionComponent);
			AlignMeshToCylinder();

			CollisionComponent = PrimitiveComponent(Comp);
		}
		else Comp = CollisionComponent;

		if( class<KFWeapon>(InventoryClass) != None )
			StaticMeshComponent(MyMeshComp).SetStaticMesh(GetPickupMesh(class<KFWeapon>(InventoryClass)));

		CollisionComponent.SetScale3D(NewPickupMesh.Scale3D);

		CollisionComponent.SetBlockRigidBody(TRUE);
		CollisionComponent.SetActorCollision(TRUE,FALSE);
		CollisionComponent.SetRBChannel( RBCC_Pickup );
		CollisionComponent.SetRBCollidesWithChannel( RBCC_Default, TRUE );
		if( !bIgnoreBlockingVolumes )
			CollisionComponent.SetRBCollidesWithChannel( RBCC_BlockingVolume, TRUE );
            
		CollisionComponent.SetNotifyRigidBodyCollision( TRUE );
		CollisionComponent.ScriptRigidBodyCollisionThreshold = 100;
		CollisionComponent.WakeRigidBody();

		SkelMC = SkeletalMeshComponent(CollisionComponent);
		if( SkelMC != None )
		{
			SkelMC.bUpdateSkelWhenNotRendered=FALSE;
			SkelMC.bComponentUseFixedSkelBounds=FALSE;

			SkelMC.PhysicsWeight = 1.f;
			SkelMC.SetHasPhysicsAssetInstance(TRUE);
			if( Role == ROLE_Authority )
				SetPhysics(PHYS_RigidBody);

			SkelMC.PhysicsAssetInstance.SetAllBodiesFixed(false);

			bCallRigidBodyWakeEvents = true;
		}
		else
		{
			StaticMC = StaticMeshComponent(CollisionComponent);
			if (StaticMC != none && bEnableStaticMeshRBPhys)
			{
				CollisionComponent.InitRBPhys();
				if( Role == ROLE_Authority && CollisionComponent.BodyInstance != None )
					SetPhysics(PHYS_RigidBody);

				bCallRigidBodyWakeEvents = true;

				MyMeshComp.SetRBLinearVelocity(Velocity);
				Velocity = vect(0,0,0);
			}
		}

		SetPickupSkin(SkinItemId);
	}
}

stripped event context(KFDroppedPickup.Destroyed) PickupDestroyed()
{
    RemovePickupFromList();
    
    Super.Destroyed();

    Inventory.Destroy();
    Inventory = None;
}

stripped final function context(KFDroppedPickup) AddPickupToList()
{
    local UKFPMutator Mut;
    local int Index;
    local FPlayerPickups Info;

    if( Instigator == None )
        return;
    
    Mut = `GetMut();
    if( Mut == None )
        return;
        
    Index = Mut.PlayerPickups.Find('PRI', Instigator.PlayerReplicationInfo);
    if( Index == INDEX_NONE )
    {
        Info.PRI = Instigator.PlayerReplicationInfo;
        Info.OwnerSteamID = Mut.OnlineSub.UniqueNetIdToInt64(Instigator.PlayerReplicationInfo.UniqueId);
        Info.OwnerName = Instigator.PlayerReplicationInfo.PlayerName;
        Info.Pickups.AddItem(self);
        Mut.PlayerPickups.AddItem(Info);
    }
    else Mut.PlayerPickups[Index].Pickups.AddItem(self);
}

stripped final function context(KFDroppedPickup) RemovePickupFromList()
{
    local UKFPMutator Mut;
    local int i, j;
    
    Mut = `GetMut();
    if( Mut == None )
        return;
        
    for( i=0; i<Mut.PlayerPickups.Length; i++ )
    {
        if( Mut.PlayerPickups[i].PRI == None )
        {
            Mut.PlayerPickups.Remove(i, 1);
            continue;
        }
        
        for( j=0; j<Mut.PlayerPickups[i].Pickups.Length; j++ )
        {
            if( Mut.PlayerPickups[i].Pickups[j] == self )
            {
                Mut.PlayerPickups[i].Pickups.Remove(j, 1);
                break;
            }
        }
    }
}

stripped function context(KFPawn_Monster.GetAIPawnClassToSpawn) class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	local WorldInfo WI;
	local KFGameReplicationInfo KFGRI;

	WI = class'WorldInfo'.static.GetWorldInfo();
	KFGRI = KFGameReplicationInfo(WI.GRI);

    if( `GetMut().bForceDisableEDARs && (ClassIsChildOf(default.Class, class'KFPawn_ZedHusk') || ClassIsChildOf(default.Class, class'KFPawn_ZedStalker')) )
        return default.Class;
        
    if( KFGameInfo(WI.Game) != None && `GetMut().bForceDisableQPs && ClassIsChildOf(default.Class, class'KFPawn_ZedFleshpoundMini') && !KFGameReplicationInfo(WI.GRI).IsBossWave() )
        return KFGameInfo(WI.Game).GetAISpawnType(AT_Scrake);

    if( KFGRI != None && !KFGRI.IsContaminationMode() )
    {
        if( default.ElitePawnClass.Length > 0 && default.DifficultySettings != None && fRand() < default.DifficultySettings.static.GetSpecialSpawnChance(KFGameReplicationInfo(WI.GRI)) )
        {
            if( KFGameInfo(WI.Game) != None && `GetMut().bForceDisableGasCrawlers && ClassIsChildOf(default.Class, class'KFPawn_ZedCrawler') && !ClassIsChildOf(default.Class, class'KFPawn_ZedCrawlerKing') )
                return KFGameInfo(WI.Game).GetAISpawnType(AT_Stalker);
            return default.ElitePawnClass[Rand(default.ElitePawnClass.Length)];
        }
    }
        
	return default.Class;
}

stripped function context(KFAIController_ZedFleshpound.SpawnEnraged) bool SpawnEnraged()
{
    return SpawnEnragedEx();
}

stripped final function context(KFAIController_ZedFleshpound) bool SpawnEnragedEx()
{
    local UKFPMutator Mut;

    Mut = `GetMut();
    if( Mut != None && Mut.bForceDisableRageSpawns && !MyKFPawn.IsABoss() )
        return false;
    
    RagePlugin.DoSpawnRage();
    return true;
}

stripped function context(KFAISpawnManager.GetMaxMonsters) int GetMaxMonsters()
{
	local int LivingPlayerCount;
	local int Difficulty;

	LivingPlayerCount = Clamp(GetLivingPlayerCount() - 1, 0, 5);
	Difficulty = Clamp(GameDifficulty, 0, 3);
    
    if( `GetMut() != None && `GetMut().CurrentMaxMonsters > 0 )
        return Max(`GetMut().CurrentMaxMonsters, PerDifficultyMaxMonsters[Difficulty].MaxMonsters[LivingPlayerCount]);
	return PerDifficultyMaxMonsters[Difficulty].MaxMonsters[LivingPlayerCount];
}

stripped function context(KFGameDifficultyInfo.GetNumPlayersModifier) float GetNumPlayersModifier( const out NumPlayerMods PlayerSetting, byte NumLivingPlayers )
{
	local float StartingLerp, LerpRate;

	NumLivingPlayers = Max(`GetMut().CurrentFakePlayers, NumLivingPlayers);

	if( `KF_MAX_PLAYERS > NumLivingPlayers )
	 	return PlayerSetting.PlayersMod[Max(NumLivingPlayers - 1, 0)];

    StartingLerp = PlayerSetting.PlayersMod[ `KF_MAX_PLAYERS - 1 ];
	LerpRate = (NumLivingPlayers - `KF_MAX_PLAYERS) / (32.f - `KF_MAX_PLAYERS);
	return Lerp( StartingLerp, PlayerSetting.ModCap, LerpRate );
}

stripped function context(KFGameInfo.ModifyAIDoshValueForPlayerCount) ModifyAIDoshValueForPlayerCount( out float ModifiedValue )
{
	local float DoshMod;

	DoshMod = FMax(`GetMut().CurrentFakePlayers, GetNumPlayers());
    DoshMod = DoshMod / DifficultyInfo.GetPlayerNumMaxAIModifier(DoshMod);
	ModifiedValue *= DoshMod;
}

stripped function context(KFGameInfo.GetAdjustedAIDoshValue) float GetAdjustedAIDoshValue( class<KFPawn_Monster> MonsterClass )
{
	local float TempValue;

	if( !ShouldOverrideDoshOnKill(MonsterClass, TempValue) )
		TempValue = MonsterClass.static.GetDoshValue();
		
	TempValue *= DifficultyInfo.GetKillCashModifier();
	ModifyAIDoshValueForPlayerCount( TempValue );
	TempValue *= GameLengthDoshScale[GameLength];
	TempValue *= FClamp(`GetMut().CurrentDoshKillMultiplier, 0.f, 1.f);
	
    KFMapInfo(WorldInfo.GetMapInfo()).ModifyAIDoshValue(TempValue);

	return TempValue;
}

stripped function context(KFGameInfo.GetGameInfoSpawnRateMod) float GetGameInfoSpawnRateMod()
{
	local float SpawnRateMod;

	SpawnRateMod = 1.f;

	if( OutbreakEvent != None )
	{
		if( OutbreakEvent.ActiveEvent.SpawnRateMultiplier > 0.f )
			SpawnRateMod *= 1.f / OutbreakEvent.ActiveEvent.SpawnRateMultiplier;
		else SpawnRateMod = 0.0f;
	}

	if( MyKFGRI != None )
		SpawnRateMod *= MyKFGRI.GetMapObjectiveSpawnRateMod();

	return SpawnRateMod * FMax(`GetMut().CurrentSpawnRateMultiplier, 1.f);
}

stripped function context(KFGameInfo.GetTotalWaveCountScale) float GetTotalWaveCountScale()
{
    return GetTotalWaveCountScaleEx();
}

stripped final function context(KFGameInfo) float GetTotalWaveCountScaleEx()
{
    local float CurrentScale;

	if( MyKFGRI.IsBossWave() )
		return 1.f;

	if( OutbreakEvent != None && OutbreakEvent.ActiveEvent.WaveAICountScale.Length > 0 )
        CurrentScale = GetLivingPlayerCount() > OutbreakEvent.ActiveEvent.WaveAICountScale.Length ? OutbreakEvent.ActiveEvent.WaveAICountScale[OutbreakEvent.ActiveEvent.WaveAICountScale.Length - 1] : OutbreakEvent.ActiveEvent.WaveAICountScale[GetLivingPlayerCount() - 1];
    else CurrentScale = 1.f;

	return CurrentScale * FMax(`GetMut().CurrentWaveCountMultiplier, 1.f);
}

stripped event context(KFGameInfo_Survival.Timer) GameTimer()
{
	Super.Timer();

	if( SpawnManager != None )
		SpawnManager.Update();
	if( GameConductor != None && !`GetMut().bBypassGameConductor )
		GameConductor.TimerUpdate();
}

stripped final simulated function context(KFInventoryManager) DiscardInventoryEx()
{
	local Inventory Inv;
	local KFPawn KFP;
	local UKFPMutator Mut;

	Mut = `GetMut();
    if( Mut == None || !Mut.bServerDropAllWepsOnDeath )
    {
        foreach InventoryActors(class'Inventory', Inv)
        {
            if( Instigator.Weapon != Inv )
                Inv.bDropOnDeath = false;
        }
    }

	Super.DiscardInventory();

	KFP = KFPawn(Instigator);
	if( KFP != None )
		KFP.MyKFWeapon = None;
}

stripped simulated event context(KFInventoryManager.DiscardInventory) DiscardInventory()
{
	DiscardInventoryEx();
}

stripped reliable server function context(KFInventoryManager.ServerThrowMoney) ServerThrowMoney()
{
    local Inventory Inv;

    if( CheckDoshSpam() )
        return;
        
	if( Instigator != None )
	{
		foreach InventoryActors(class'Inventory', Inv)
		{
			if( Inv.DroppedPickupClass == class'KFDroppedPickup_Cash' )
			{
				Instigator.TossInventory(Inv);
				return;
			}
		}
	}
}

final function context(KFInventoryManager) bool CheckDoshSpam()
{
	local UKFPMutator Mut;
    local FPlayerConfig Info;
    local int Index;

	Mut = `GetMut();
    if( Mut.GetPlayerConfig(Instigator.PlayerReplicationInfo, Info, Index) )
        return false;
        
	if( Info.MoneyTossTime>WorldInfo.RealTimeSeconds )
	{
		if( Info.MoneyTossCount>=(Mut.CurrentMaxDoshSpamAmount > 0 ? Mut.CurrentMaxDoshSpamAmount : 15) )
			return true;
		++Mut.PlayerConfigs[Index].MoneyTossCount;
		Mut.PlayerConfigs[Index].MoneyTossTime = FMax(Info.MoneyTossTime,WorldInfo.RealTimeSeconds+0.5);
	}
	else
	{
		Mut.PlayerConfigs[Index].MoneyTossCount = 0;
		Mut.PlayerConfigs[Index].MoneyTossTime = WorldInfo.RealTimeSeconds+1;
	}
    
    return false;
}

stripped function context(KFGameInfo.GetFriendlyNameForCurrentGameMode) string GetFriendlyNameForCurrentGameMode()
{
	return GetGameModeFriendlyNameFromClass( PathName(default.Class) );
}

stripped static function context(KFGameInfo.GetGameModeNumFromClass) int GetGameModeNumFromClass( string GameModeClassString )
{
    return GetActualGamemodeNum(GameModeClassString);
}

stripped static function context(KFGameInfo.GetGameModeFriendlyNameFromClass) string GetGameModeFriendlyNameFromClass( string GameModeClassString )
{
	return default.GameModes[Max(GetActualGamemodeNum(GameModeClassString), 0)].FriendlyName;
}

stripped final static function context(KFGameInfo) int GetActualGamemodeNum(string GameModeClassString)
{
    local int i;
    local class<KFGameInfo> GIC;

    for( i=default.GameModes.Length-1; i>=0; i-- )
    {
        GIC = class<KFGameInfo>(DynamicLoadObject(default.GameModes[i].ClassNameAndPath, Class'Class'));
        if( GIC != None && ClassIsChildOf(default.Class, GIC) )
            return i;
    }
    
    return INDEX_NONE;
}

stripped function context(KFGameInfo.CreateOutbreakEvent) CreateOutbreakEvent()
{
	if( OutbreakEventClass != None && OutbreakEvent == None )
		OutbreakEvent = new(self) OutbreakEventClass;
}

stripped event context(Mutator.PreBeginPlay) MutPreBeginPlay()
{
    GenerateMutatorEntry(Class.Name, PathName(Class));
	if ( !MutatorIsAllowed() )
		Destroy();
}

stripped final function context(Mutator) GenerateMutatorEntry(name ClassName, string ClassPath)
{
    local KFMutatorSummary MutatorSummary;
    local array<string> Names, Groups;
    local int i;
    local bool bFoundConfig;

    GetPerObjectConfigSections(class'KFMutatorSummary', Names);
    for (i = 0; i < Names.Length; i++)
    {
        if( InStr(Names[i], string(ClassName),, true) != INDEX_NONE )
        {
            bFoundConfig = true;
            break;
        }
    }
    
    if( !bFoundConfig )
    {
        Groups.AddItem("Mutators");
        
        MutatorSummary = New(None, string(ClassName)) class'KFMutatorSummary';
        MutatorSummary.ClassName = ClassPath;
        MutatorSummary.GroupNames = Groups;
        MutatorSummary.SaveConfig();
    }
}

stripped function context(KFGameInfo.ReplicateWelcomeScreen) ReplicateWelcomeScreen()
{
	local WorldInfo WI;

	WI = class'WorldInfo'.static.GetWorldInfo();
	if( WI.NetMode != NM_DedicatedServer )
		return;

	if( MyKFGRI != None )
	{
		MyKFGRI.ServerAdInfo.BannerLink = BannerLink;
		MyKFGRI.ServerAdInfo.ServerMOTD = Repl(`GetMut().GetServerMOTD(ServerMOTD), "@nl@", Chr(10));
		MyKFGRI.ServerAdInfo.WebsiteLink = WebsiteLink;
		MyKFGRI.ServerAdInfo.ClanMotto = ClanMotto;
	}
}

stripped function context(KFGameInfo.Tick) GameInfoTick( float DeltaTime )
{
    `GetMut().TickActor(DeltaTime);
    if( ZedTimeRemaining > 0.f )
		TickZedTime(DeltaTime);
}