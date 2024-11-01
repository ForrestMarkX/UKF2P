class FunctionProxy extends ProxyInfo;

var bool bInitSuccess, bFunctionsRestored;
var int OldWeeklyEventIndex;

function Init()
{
    local KFPlayerController PC;
    local class<KFGFxMoviePlayer_Manager> MyGFxManagerClass;

    if( default.bInitSuccess )
        return;
    
    if( WorldInfo.NetMode != NM_Client )
    {
        AccessControlOriginal.NotifyServerTravel = AccessControl.NotifyServerTravel;
        AccessControl.NotifyServerTravel = AccessControlProxy.NotifyServerTravel;
        PlayerControllerOriginal.ServerSay = PlayerController.ServerSay;
        PlayerController.ServerSay = PlayerControllerProxy.ServerSay;
        PlayerControllerOriginal.ServerTeamSay = PlayerController.ServerTeamSay;
        PlayerController.ServerTeamSay = PlayerControllerProxy.ServerTeamSay;
        PlayerControllerOriginal.ServerCamera = PlayerController.ServerCamera;
        PlayerController.ServerCamera = PlayerControllerProxy.ServerCamera;
        GameInfoOriginal.GenericPlayerInitialization = GameInfo.GenericPlayerInitialization;
        GameInfo.GenericPlayerInitialization = GameInfoProxy.GenericPlayerInitialization;
        GameInfoOriginal.Logout = GameInfo.Logout;
        GameInfo.Logout = GameInfoProxy.Logout;
        GameInfoOriginal.NotifyKilled = GameInfo.NotifyKilled;
        GameInfo.NotifyKilled = GameInfoProxy.NotifyKilled;
        GameInfoOriginal.PickupQuery = GameInfo.PickupQuery;
        GameInfo.PickupQuery = GameInfoProxy.PickupQuery;
        GameInfoOriginal.ProcessServerTravel = GameInfo.ProcessServerTravel;
        GameInfo.ProcessServerTravel = GameInfoProxy.ProcessServerTravel;
        GameInfoOriginal.PreLogin = GameInfo.PreLogin;
        GameInfo.PreLogin = GameInfoProxy.PreLogin;
        GameInfoOriginal.Killed = GameInfo.Killed;
        GameInfo.Killed = GameInfoProxy.Killed;
        GameInfoOriginal.ReduceDamage = GameInfo.ReduceDamage;
        GameInfo.ReduceDamage = GameInfoProxy.ReduceDamage;
        KFGameInfoOriginal.ReplicateWelcomeScreen = KFGameInfo.ReplicateWelcomeScreen;
        KFGameInfo.ReplicateWelcomeScreen = KFGameInfoProxy.ReplicateWelcomeScreen;
        KFGameInfoOriginal.ModifyAIDoshValueForPlayerCount = KFGameInfo.ModifyAIDoshValueForPlayerCount;
        KFGameInfo.ModifyAIDoshValueForPlayerCount = KFGameInfoProxy.ModifyAIDoshValueForPlayerCount;
        KFGameInfoOriginal.GetFriendlyNameForCurrentGameMode = KFGameInfo.GetFriendlyNameForCurrentGameMode;
        KFGameInfo.GetFriendlyNameForCurrentGameMode = KFGameInfoProxy.GetFriendlyNameForCurrentGameMode;
        KFGameInfoOriginal.GetGameModeNumFromClass = KFGameInfo.GetGameModeNumFromClass;
        KFGameInfo.GetGameModeNumFromClass = KFGameInfoProxy.GetGameModeNumFromClass;
        KFGameInfoOriginal.GetGameModeFriendlyNameFromClass = KFGameInfo.GetGameModeFriendlyNameFromClass;
        KFGameInfo.GetGameModeFriendlyNameFromClass = KFGameInfoProxy.GetGameModeFriendlyNameFromClass;
        KFGameInfoOriginal.CreateOutbreakEvent = KFGameInfo.CreateOutbreakEvent;
        KFGameInfo.CreateOutbreakEvent = KFGameInfoProxy.CreateOutbreakEvent;
        KFGameInfoOriginal.UpdateGameSettings = KFGameInfo.UpdateGameSettings;
        KFGameInfo.UpdateGameSettings = KFGameInfoProxy.UpdateGameSettings;
        KFGameInfoOriginal.ScoreMonsterKill = KFGameInfo.ScoreMonsterKill;
        KFGameInfo.ScoreMonsterKill = KFGameInfoProxy.ScoreMonsterKill;
        KFGameInfoOriginal.DistributeMoneyAndXP = KFGameInfo.DistributeMoneyAndXP;
        KFGameInfo.DistributeMoneyAndXP = KFGameInfoProxy.DistributeMoneyAndXP;
        KFGameInfoOriginal.GetSpecificBossClass = KFGameInfo.GetSpecificBossClass;
        KFGameInfo.GetSpecificBossClass = KFGameInfoProxy.GetSpecificBossClass;
        KFGameInfoOriginal.GetAdjustedAIDoshValue = KFGameInfo.GetAdjustedAIDoshValue;
        KFGameInfo.GetAdjustedAIDoshValue = KFGameInfoProxy.GetAdjustedAIDoshValue;
        KFGameInfoOriginal.GetGameInfoSpawnRateMod = KFGameInfo.GetGameInfoSpawnRateMod;
        KFGameInfo.GetGameInfoSpawnRateMod = KFGameInfoProxy.GetGameInfoSpawnRateMod;
        KFGameInfoOriginal.GetTotalWaveCountScale = KFGameInfo.GetTotalWaveCountScale;
        KFGameInfo.GetTotalWaveCountScale = KFGameInfoProxy.GetTotalWaveCountScale;
        KFGameInfo_SurvivalOriginal.StartMatch = KFGameInfo_Survival.StartMatch;
        KFGameInfo_Survival.StartMatch = KFGameInfo_SurvivalProxy.StartMatch;
        KFGameInfo_SurvivalOriginal.NotifyTraderOpened = KFGameInfo_Survival.NotifyTraderOpened;
        KFGameInfo_Survival.NotifyTraderOpened = KFGameInfo_SurvivalProxy.NotifyTraderOpened;
        KFGameInfo_SurvivalOriginal.NotifyTraderClosed = KFGameInfo_Survival.NotifyTraderClosed;
        KFGameInfo_Survival.NotifyTraderClosed = KFGameInfo_SurvivalProxy.NotifyTraderClosed;
        KFGameInfo_SurvivalOriginal.Timer = KFGameInfo_Survival.Timer;
        KFGameInfo_Survival.Timer = KFGameInfo_SurvivalProxy.Timer;
        KFGameInfo_SurvivalOriginal.TryRestartGame = KFGameInfo_Survival.TryRestartGame;
        KFGameInfo_Survival.TryRestartGame = KFGameInfo_SurvivalProxy.TryRestartGame;
        KFGameInfo_SurvivalOriginal.ForceChangeLevel = KFGameInfo_Survival.ForceChangeLevel;
        KFGameInfo_Survival.ForceChangeLevel = KFGameInfo_SurvivalProxy.ForceChangeLevel;
        KFGameInfo_WeeklySurvivalOriginal.UsesModifiedDifficulty = KFGameInfo_WeeklySurvival.UsesModifiedDifficulty;
        KFGameInfo_WeeklySurvival.UsesModifiedDifficulty = KFGameInfo_WeeklySurvivalProxy.UsesModifiedDifficulty;
        KFGameInfo_EndlessOriginal.TrySetNextWaveSpecial = KFGameInfo_Endless.TrySetNextWaveSpecial;
        KFGameInfo_Endless.TrySetNextWaveSpecial = KFGameInfo_EndlessProxy.TrySetNextWaveSpecial;
        KFGameReplicationInfoOriginal.PostBeginPlay = KFGameReplicationInfo.PostBeginPlay;
        KFGameReplicationInfo.PostBeginPlay = KFGameReplicationInfoProxy.PostBeginPlay;
        KFPlayerControllerOriginal.EnterZedTime = KFPlayerController.EnterZedTime;
        KFPlayerController.EnterZedTime = KFPlayerControllerProxy.EnterZedTime;
        KFPlayerControllerOriginal.CompleteZedTime = KFPlayerController.CompleteZedTime;
        KFPlayerController.CompleteZedTime = KFPlayerControllerProxy.CompleteZedTime;
        KFPlayerControllerOriginal.ServerPause = KFPlayerController.ServerPause;
        KFPlayerController.ServerPause = KFPlayerControllerProxy.ServerPause;
        KFDroppedPickupOriginal.SetPickupMesh = KFDroppedPickup.SetPickupMesh;  
        KFDroppedPickup.SetPickupMesh = KFDroppedPickupProxy.SetPickupMesh;
        KFDroppedPickupOriginal.Destroyed = KFDroppedPickup.Destroyed;  
        KFDroppedPickup.Destroyed = KFDroppedPickupProxy.Destroyed;
        KFDroppedPickupOriginal.GiveTo = KFDroppedPickup.GiveTo;  
        KFDroppedPickup.GiveTo = KFDroppedPickupProxy.GiveTo;
        KFDroppedPickupOriginal.Pickup.BeginState = KFDroppedPickup.Pickup.BeginState;  
        KFDroppedPickup.Pickup.BeginState = KFDroppedPickupProxy.Pickup.BeginState;
        ActorOriginal.FellOutOfWorld = Actor.FellOutOfWorld;  
        Actor.FellOutOfWorld = ActorProxy.FellOutOfWorld;
        KFPawn_HumanOriginal.PossessedBy = KFPawn_Human.PossessedBy;
        KFPawn_Human.PossessedBy = KFPawn_HumanProxy.PossessedBy;
        KFPawn_HumanOriginal.Tick = KFPawn_Human.Tick;
        KFPawn_Human.Tick = KFPawn_HumanProxy.Tick;
        DroppedPickupOriginal.Landed = DroppedPickup.Landed;  
        DroppedPickup.Landed = DroppedPickupProxy.Landed;
        BasicWebAdminUserOriginal.linkPlayerController = BasicWebAdminUser.linkPlayerController;  
        BasicWebAdminUser.linkPlayerController = BasicWebAdminUserProxy.linkPlayerController;
        KFAISpawnManagerOriginal.GetMaxMonsters = KFAISpawnManager.GetMaxMonsters;  
        KFAISpawnManager.GetMaxMonsters = KFAISpawnManagerProxy.GetMaxMonsters;
        KFInventoryManagerOriginal.ServerThrowMoney = KFInventoryManager.ServerThrowMoney;  
        KFInventoryManager.ServerThrowMoney = KFInventoryManagerProxy.ServerThrowMoney;
        KFInventoryManagerOriginal.DiscardInventory = KFInventoryManager.DiscardInventory;  
        KFInventoryManager.DiscardInventory = KFInventoryManagerProxy.DiscardInventory;
        KFInventory_MoneyOriginal.DropFrom = KFInventory_Money.DropFrom;  
        KFInventory_Money.DropFrom = KFInventory_MoneyProxy.DropFrom;
        KFGameDifficultyInfoOriginal.GetNumPlayersModifier = KFGameDifficultyInfo.GetNumPlayersModifier;
        KFGameDifficultyInfo.GetNumPlayersModifier = KFGameDifficultyInfoProxy.GetNumPlayersModifier;
        KFAIControllerOriginal.FindNewEnemy = KFAIController.FindNewEnemy;
        KFAIController.FindNewEnemy = KFAIControllerProxy.FindNewEnemy;
        KFMonsterDifficultyInfoOriginal.GetSpecialSpawnChance = KFMonsterDifficultyInfo.GetSpecialSpawnChance;
        KFMonsterDifficultyInfo.GetSpecialSpawnChance = KFMonsterDifficultyInfoProxy.GetSpecialSpawnChance;
        KFAIController_ZedFleshpoundOriginal.SpawnEnraged = KFAIController_ZedFleshpound.SpawnEnraged;
        KFAIController_ZedFleshpound.SpawnEnraged = KFAIController_ZedFleshpoundProxy.SpawnEnraged;
        KFPawn_MonsterOriginal.GetAIPawnClassToSpawn = KFPawn_Monster.GetAIPawnClassToSpawn;
        KFPawn_Monster.GetAIPawnClassToSpawn = KFPawn_MonsterProxy.GetAIPawnClassToSpawn;
        KFOutbreakEventOriginal.UpdateGRI = KFOutbreakEvent.UpdateGRI;
        KFOutbreakEvent.UpdateGRI = KFOutbreakEventProxy.UpdateGRI;
    }
    
    KFPawn_HumanOriginal.UpdateActiveSkillsPath = KFPawn_Human.UpdateActiveSkillsPath;  
    KFPawn_Human.UpdateActiveSkillsPath = KFPawn_HumanProxy.UpdateActiveSkillsPath;
    KFPerk_BerserkerOriginal.SetSuccessfullParry = KFPerk_Berserker.SetSuccessfullParry;  
    KFPerk_Berserker.SetSuccessfullParry = KFPerk_BerserkerProxy.SetSuccessfullParry;
    KFPerk_BerserkerOriginal.ParryTimer = KFPerk_Berserker.ParryTimer;  
    KFPerk_Berserker.ParryTimer = KFPerk_BerserkerProxy.ParryTimer;
    KFPawnOriginal.PostBeginPlay = KFPawn.PostBeginPlay;
    KFPawn.PostBeginPlay = KFPawnProxy.PostBeginPlay;
    KFPawnOriginal.SetWeaponAttachmentFromWeaponClass = KFPawn.SetWeaponAttachmentFromWeaponClass;
    KFPawn.SetWeaponAttachmentFromWeaponClass = KFPawnProxy.SetWeaponAttachmentFromWeaponClass;
    KFPlayerControllerOriginal.ClientTriggerWeaponContentLoad = KFPlayerController.ClientTriggerWeaponContentLoad;
    KFPlayerController.ClientTriggerWeaponContentLoad = KFPlayerControllerProxy.ClientTriggerWeaponContentLoad;
    KFPlayerControllerOriginal.PreClientTravel = KFPlayerController.PreClientTravel;
    KFPlayerController.PreClientTravel = KFPlayerControllerProxy.PreClientTravel;
    KFPlayerControllerOriginal.GetAllowSeasonalSkins = KFPlayerController.GetAllowSeasonalSkins;
    KFPlayerController.GetAllowSeasonalSkins = KFPlayerControllerProxy.GetAllowSeasonalSkins;
    KFPlayerControllerOriginal.GetSeasonalStateName = KFPlayerController.GetSeasonalStateName;
    KFPlayerController.GetSeasonalStateName = KFPlayerControllerProxy.GetSeasonalStateName;
    KFWeaponOriginal.PreBeginPlay = KFWeapon.PreBeginPlay;
    KFWeapon.PreBeginPlay = KFWeaponProxy.PreBeginPlay;
    KFWeaponOriginal.GivenTo = KFWeapon.GivenTo;
    KFWeapon.GivenTo = KFWeaponProxy.GivenTo;
    KFWeaponOriginal.ClientGivenTo = KFWeapon.ClientGivenTo;
    KFWeapon.ClientGivenTo = KFWeaponProxy.ClientGivenTo;
    KFWeaponOriginal.AttachWeaponTo = KFWeapon.AttachWeaponTo;
    KFWeapon.AttachWeaponTo = KFWeaponProxy.AttachWeaponTo;
    KFWeaponOriginal.GetWeaponAttachmentTemplate = KFWeapon.GetWeaponAttachmentTemplate;  
    KFWeapon.GetWeaponAttachmentTemplate = KFWeaponProxy.GetWeaponAttachmentTemplate;
    KFWeaponOriginal.HandleRecoil = KFWeapon.HandleRecoil;  
    KFWeapon.HandleRecoil = KFWeaponProxy.HandleRecoil;
    KFWeaponOriginal.GetWeaponPerkClass = KFWeapon.GetWeaponPerkClass;  
    KFWeapon.GetWeaponPerkClass = KFWeaponProxy.GetWeaponPerkClass;
    KFWeaponOriginal.SyncCurrentAmmoCount = KFWeapon.SyncCurrentAmmoCount;
    KFWeapon.SyncCurrentAmmoCount = KFWeaponProxy.SyncCurrentAmmoCount;
    KFSprayActorOriginal.BeginSpray = KFSprayActor.BeginSpray;  
    KFSprayActor.BeginSpray = KFSprayActorProxy.BeginSpray;
    KFWeap_FlameBaseOriginal.WeaponEquipping.BeginState = KFWeap_FlameBase.WeaponEquipping.BeginState;  
    KFWeap_FlameBase.WeaponEquipping.BeginState = KFWeap_FlameBaseProxy.WeaponEquipping.BeginState;
    KFWeap_FlameBaseOriginal.ChangeVisibility = KFWeap_FlameBase.ChangeVisibility;  
    KFWeap_FlameBase.ChangeVisibility = KFWeap_FlameBaseProxy.ChangeVisibility;
    KFWeap_Pistol_AF2011Original.SpawnProjectile = KFWeap_Pistol_AF2011.SpawnProjectile;
    KFWeap_Pistol_AF2011.SpawnProjectile = KFWeap_Pistol_AF2011Proxy.SpawnProjectile;
    KFPawn_MonsterOriginal.PreBeginPlay = KFPawn_Monster.PreBeginPlay;
    KFPawn_Monster.PreBeginPlay = KFPawn_MonsterProxy.PreBeginPlay;
    KFPawn_MonsterOriginal.PlayHeadAsplode = KFPawn_Monster.PlayHeadAsplode;
    KFPawn_Monster.PlayHeadAsplode = KFPawn_MonsterProxy.PlayHeadAsplode;
    PawnOriginal.InFreeCam = Pawn.InFreeCam;
    Pawn.InFreeCam = PawnProxy.InFreeCam;
    PawnOriginal.StartFire = Pawn.StartFire;
    Pawn.StartFire = PawnProxy.StartFire;
    KFProj_RicochetStickBulletOriginal.Stick = KFProj_RicochetStickBullet.Stick;
    KFProj_RicochetStickBullet.Stick = KFProj_RicochetStickBulletProxy.Stick;
    KFProj_Grenade_GravityImploderAltOriginal.ImplodingState.AbsorbEnemies = KFProj_Grenade_GravityImploderAlt.ImplodingState.AbsorbEnemies;
    KFProj_Grenade_GravityImploderAlt.ImplodingState.AbsorbEnemies = KFProj_Grenade_GravityImploderAltProxy.ImplodingState.AbsorbEnemies;
    KFGFxObject_TraderItemsOriginal.GetItemIndicesFromArche = KFGFxObject_TraderItems.GetItemIndicesFromArche;
    KFGFxObject_TraderItems.GetItemIndicesFromArche = KFGFxObject_TraderItemsProxy.GetItemIndicesFromArche;
    ChatLogOriginal.ReceiveMessage = ChatLog.ReceiveMessage;
    ChatLog.ReceiveMessage = ChatLogProxy.ReceiveMessage;
    MessagingSpectatorOriginal.TeamMessage = MessagingSpectator.TeamMessage;
    MessagingSpectator.TeamMessage = MessagingSpectatorProxy.TeamMessage;
    KFProj_ExplosiveSubmunition_HX25Original.PrepareExplosionTemplate = KFProj_ExplosiveSubmunition_HX25.PrepareExplosionTemplate;
    KFProj_ExplosiveSubmunition_HX25.PrepareExplosionTemplate = KFProj_ExplosiveSubmunition_HX25Proxy.PrepareExplosionTemplate;
    KFProj_ExplosiveSubmunition_HX25Original.AllowNuke = KFProj_ExplosiveSubmunition_HX25.AllowNuke;
    KFProj_ExplosiveSubmunition_HX25.AllowNuke = KFProj_ExplosiveSubmunition_HX25Proxy.AllowNuke;
    KFProj_Explosive_HRG_KaboomstickOriginal.PrepareExplosionTemplate = KFProj_Explosive_HRG_Kaboomstick.PrepareExplosionTemplate;
    KFProj_Explosive_HRG_Kaboomstick.PrepareExplosionTemplate = KFProj_Explosive_HRG_KaboomstickProxy.PrepareExplosionTemplate;
    KFProj_Explosive_HRG_KaboomstickOriginal.AllowNuke = KFProj_Explosive_HRG_Kaboomstick.AllowNuke;
    KFProj_Explosive_HRG_Kaboomstick.AllowNuke = KFProj_Explosive_HRG_KaboomstickProxy.AllowNuke;
    KFCharacterInfo_HumanOriginal.SetBodyMeshAndSkin = KFCharacterInfo_Human.SetBodyMeshAndSkin;
    KFCharacterInfo_Human.SetBodyMeshAndSkin = KFCharacterInfo_HumanProxy.SetBodyMeshAndSkin;
    KFCharacterInfo_HumanOriginal.SetHeadMeshAndSkin = KFCharacterInfo_Human.SetHeadMeshAndSkin;
    KFCharacterInfo_Human.SetHeadMeshAndSkin = KFCharacterInfo_HumanProxy.SetHeadMeshAndSkin;
    KFPlayerReplicationInfoOriginal.PostBeginPlay = KFPlayerReplicationInfo.PostBeginPlay;
    KFPlayerReplicationInfo.PostBeginPlay = KFPlayerReplicationInfoProxy.PostBeginPlay;
    KFPerkOriginal.IsWeaponOnPerk = KFPerk.IsWeaponOnPerk;
    KFPerk.IsWeaponOnPerk = KFPerkProxy.IsWeaponOnPerk;
    KFPerkOriginal.IsDamageTypeOnPerk = KFPerk.IsDamageTypeOnPerk;
    KFPerk.IsDamageTypeOnPerk = KFPerkProxy.IsDamageTypeOnPerk;
    KFPerkOriginal.IsDamageTypeOnThisPerk = KFPerk.IsDamageTypeOnThisPerk;
    KFPerk.IsDamageTypeOnThisPerk = KFPerkProxy.IsDamageTypeOnThisPerk;
    KFPerkOriginal.GetPerkFromDamageCauser = KFPerk.GetPerkFromDamageCauser;
    KFPerk.GetPerkFromDamageCauser = KFPerkProxy.GetPerkFromDamageCauser;
    KFPerkOriginal.IsDual9mm = KFPerk.IsDual9mm;
    KFPerk.IsDual9mm = KFPerkProxy.IsDual9mm;
    KFPerkOriginal.IsHRG93R = KFPerk.IsHRG93R;
    KFPerk.IsHRG93R = KFPerkProxy.IsHRG93R;
    KFPerkOriginal.IsFAMAS = KFPerk.IsFAMAS;
    KFPerk.IsFAMAS = KFPerkProxy.IsFAMAS;
    KFPerkOriginal.IsBlastBrawlers = KFPerk.IsBlastBrawlers;
    KFPerk.IsBlastBrawlers = KFPerkProxy.IsBlastBrawlers;
    KFPerkOriginal.IsDoshinegun = KFPerk.IsDoshinegun;
    KFPerk.IsDoshinegun = KFPerkProxy.IsDoshinegun;
    KFPerkOriginal.IsHRGCrossboom = KFPerk.IsHRGCrossboom;
    KFPerk.IsHRGCrossboom = KFPerkProxy.IsHRGCrossboom;
    KFPerkOriginal.IsAutoTurret = KFPerk.IsAutoTurret;
    KFPerk.IsAutoTurret = KFPerkProxy.IsAutoTurret;
    KFPerkOriginal.IsHRGBallisticBouncer = KFPerk.IsHRGBallisticBouncer;
    KFPerk.IsHRGBallisticBouncer = KFPerkProxy.IsHRGBallisticBouncer;
    KFPerk_FirebugOriginal.ModifyMagSizeAndNumber = KFPerk_Firebug.ModifyMagSizeAndNumber;
    KFPerk_Firebug.ModifyMagSizeAndNumber = KFPerk_FirebugProxy.ModifyMagSizeAndNumber;
    KFPerk_FieldMedicOriginal.CouldBeZedToxicCloud = KFPerk_FieldMedic.CouldBeZedToxicCloud;
    KFPerk_FieldMedic.CouldBeZedToxicCloud = KFPerk_FieldMedicProxy.CouldBeZedToxicCloud;
    KFPerk_FieldMedicOriginal.ModifyMagSizeAndNumber = KFPerk_FieldMedic.ModifyMagSizeAndNumber;
    KFPerk_FieldMedic.ModifyMagSizeAndNumber = KFPerk_FieldMedicProxy.ModifyMagSizeAndNumber;
    KFPerk_CommandoOriginal.ModifyMagSizeAndNumber = KFPerk_Commando.ModifyMagSizeAndNumber;
    KFPerk_Commando.ModifyMagSizeAndNumber = KFPerk_CommandoProxy.ModifyMagSizeAndNumber;
    MutatorOriginal.PreBeginPlay = Mutator.PreBeginPlay;
    Mutator.PreBeginPlay = MutatorProxy.PreBeginPlay;
    KFAutoPurchaseHelperOriginal.CanUpgrade = KFAutoPurchaseHelper.CanUpgrade;
    KFAutoPurchaseHelper.CanUpgrade = KFAutoPurchaseHelperProxy.CanUpgrade;
    KFPawn_ZedHansBaseOriginal.PossessedBy = KFPawn_ZedHansBase.PossessedBy;
    KFPawn_ZedHansBase.PossessedBy = KFPawn_ZedHansBaseProxy.PossessedBy;
    
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		KFWeaponOriginal.SetPosition = KFWeapon.SetPosition;  
		KFWeapon.SetPosition = KFWeaponProxy.SetPosition;
        KFCharacterInfo_HumanOriginal.DetachConflictingAttachments = KFCharacterInfo_Human.DetachConflictingAttachments;
        KFCharacterInfo_Human.DetachConflictingAttachments = KFCharacterInfo_HumanProxy.DetachConflictingAttachments;
        KFGFxMoviePlayer_ManagerOriginal.LaunchMenus = KFGFxMoviePlayer_Manager.LaunchMenus;
        KFGFxMoviePlayer_Manager.LaunchMenus = KFGFxMoviePlayer_ManagerProxy.LaunchMenus;
        KFGFxMoviePlayer_ManagerOriginal.Init = KFGFxMoviePlayer_Manager.Init;
        KFGFxMoviePlayer_Manager.Init = KFGFxMoviePlayer_ManagerProxy.Init;
        KFGFxMoviePlayer_ManagerOriginal.OnForceUpdate = KFGFxMoviePlayer_Manager.OnForceUpdate;
        KFGFxMoviePlayer_Manager.OnForceUpdate = KFGFxMoviePlayer_ManagerProxy.OnForceUpdate;
        KFGFxMenu_GearOriginal.Callback_AttachmentNumbered = KFGFxMenu_Gear.Callback_AttachmentNumbered;
        KFGFxMenu_Gear.Callback_AttachmentNumbered = KFGFxMenu_GearProxy.Callback_AttachmentNumbered;
        KFGFxMenu_GearOriginal.CheckForCustomizationPawn = KFGFxMenu_Gear.CheckForCustomizationPawn;
        KFGFxMenu_Gear.CheckForCustomizationPawn = KFGFxMenu_GearProxy.CheckForCustomizationPawn;
        KFGFxMenu_GearOriginal.OnClose = KFGFxMenu_Gear.OnClose;
        KFGFxMenu_Gear.OnClose = KFGFxMenu_GearProxy.OnClose;
        KFGFxMenu_GearOriginal.Callback_Emote = KFGFxMenu_Gear.Callback_Emote;
        KFGFxMenu_Gear.Callback_Emote = KFGFxMenu_GearProxy.Callback_Emote;
        KFPawnOriginal.OnAnimEnd = KFPawn.OnAnimEnd;
        KFPawn.OnAnimEnd = KFPawnProxy.OnAnimEnd;
        KFGFxWidget_MenuBarOriginal.CanUseGearButton = KFGFxWidget_MenuBar.CanUseGearButton;
        KFGFxWidget_MenuBar.CanUseGearButton = KFGFxWidget_MenuBarProxy.CanUseGearButton;
        KFPlayerControllerOriginal.RecieveChatMessage = KFPlayerController.RecieveChatMessage;
        KFPlayerController.RecieveChatMessage = KFPlayerControllerProxy.RecieveChatMessage;
        KFPlayerControllerOriginal.TeamMessage = KFPlayerController.TeamMessage;
        KFPlayerController.TeamMessage = KFPlayerControllerProxy.TeamMessage;
        KFPlayerControllerOriginal.ReceiveLocalizedMessage = KFPlayerController.ReceiveLocalizedMessage;
        KFPlayerController.ReceiveLocalizedMessage = KFPlayerControllerProxy.ReceiveLocalizedMessage;
        KFPlayerControllerOriginal.ClientWonGame = KFPlayerController.ClientWonGame;
        KFPlayerController.ClientWonGame = KFPlayerControllerProxy.ClientWonGame;
        KFPlayerControllerOriginal.ClientGameOver = KFPlayerController.ClientGameOver;
        KFPlayerController.ClientGameOver = KFPlayerControllerProxy.ClientGameOver;
        KFPlayerControllerOriginal.OnWaveComplete = KFPlayerController.OnWaveComplete;
        KFPlayerController.OnWaveComplete = KFPlayerControllerProxy.OnWaveComplete;
        KFPlayerControllerOriginal.IsEventObjectiveComplete = KFPlayerController.IsEventObjectiveComplete;
        KFPlayerController.IsEventObjectiveComplete = KFPlayerControllerProxy.IsEventObjectiveComplete;
        KFPlayerControllerOriginal.OnAllMapCollectiblesFound = KFPlayerController.OnAllMapCollectiblesFound;
        KFPlayerController.OnAllMapCollectiblesFound = KFPlayerControllerProxy.OnAllMapCollectiblesFound;
        KFPlayerControllerOriginal.SeasonalEventIsValid = KFPlayerController.SeasonalEventIsValid;
        KFPlayerController.SeasonalEventIsValid = KFPlayerControllerProxy.SeasonalEventIsValid;
        KFPlayerControllerOriginal.GetSeasonalEventStatInfo = KFPlayerController.GetSeasonalEventStatInfo;
        KFPlayerController.GetSeasonalEventStatInfo = KFPlayerControllerProxy.GetSeasonalEventStatInfo;
        KFGFxPerksContainer_SelectionOriginal.UpdatePerkSelection = KFGFxPerksContainer_Selection.UpdatePerkSelection;
        KFGFxPerksContainer_Selection.UpdatePerkSelection = KFGFxPerksContainer_SelectionProxy.UpdatePerkSelection;
        PlayerControllerOriginal.Say = PlayerController.Say;
        PlayerController.Say = PlayerControllerProxy.Say;
        PlayerControllerOriginal.TeamSay = PlayerController.TeamSay;
        PlayerController.TeamSay = PlayerControllerProxy.TeamSay;
        KFGFxHUD_PlayerStatusOriginal.TickHud = KFGFxHUD_PlayerStatus.TickHud;
        KFGFxHUD_PlayerStatus.TickHud = KFGFxHUD_PlayerStatusProxy.TickHud;
        KFInventoryManagerOriginal.ThrowMoney = KFInventoryManager.ThrowMoney;
        KFInventoryManager.ThrowMoney = KFInventoryManagerProxy.ThrowMoney;
        KFGFxControlsContainer_KeybindingOriginal.Initialize = KFGFxControlsContainer_Keybinding.Initialize;
        KFGFxControlsContainer_Keybinding.Initialize = KFGFxControlsContainer_KeybindingProxy.Initialize;
        KFGFxControlsContainer_KeybindingOriginal.UpdateAllBindings = KFGFxControlsContainer_Keybinding.UpdateAllBindings;
        KFGFxControlsContainer_Keybinding.UpdateAllBindings = KFGFxControlsContainer_KeybindingProxy.UpdateAllBindings;
        KFGFxControlsContainer_KeybindingOriginal.SetKeyBind = KFGFxControlsContainer_Keybinding.SetKeyBind;
        KFGFxControlsContainer_Keybinding.SetKeyBind = KFGFxControlsContainer_KeybindingProxy.SetKeyBind;
        KFGFxControlsContainer_KeybindingOriginal.SetConflictMessage = KFGFxControlsContainer_Keybinding.SetConflictMessage;
        KFGFxControlsContainer_Keybinding.SetConflictMessage = KFGFxControlsContainer_KeybindingProxy.SetConflictMessage;
        KFGFxControlsContainer_KeybindingOriginal.InitalizeCommandList = KFGFxControlsContainer_Keybinding.InitalizeCommandList;
        KFGFxControlsContainer_Keybinding.InitalizeCommandList = KFGFxControlsContainer_KeybindingProxy.InitalizeCommandList;
        KFGFxWidget_PartyInGameOriginal.InitializeWidget = KFGFxWidget_PartyInGame.InitializeWidget;
        KFGFxWidget_PartyInGame.InitializeWidget = KFGFxWidget_PartyInGameProxy.InitializeWidget;
        KFGFxWidget_PartyInGameOriginal.UpdateReadyButtonVisibility = KFGFxWidget_PartyInGame.UpdateReadyButtonVisibility;
        KFGFxWidget_PartyInGame.UpdateReadyButtonVisibility = KFGFxWidget_PartyInGameProxy.UpdateReadyButtonVisibility;
        KFGFxWidget_PartyInGameOriginal.OneSecondLoop = KFGFxWidget_PartyInGame.OneSecondLoop;
        KFGFxWidget_PartyInGame.OneSecondLoop = KFGFxWidget_PartyInGameProxy.OneSecondLoop;
        KFGFxWidget_PartyInGameOriginal.RefreshParty = KFGFxWidget_PartyInGame.RefreshParty;
        KFGFxWidget_PartyInGame.RefreshParty = KFGFxWidget_PartyInGameProxy.RefreshParty;
        KFGFxWidget_PartyInGameOriginal.ToggelMuteOnPlayer = KFGFxWidget_PartyInGame.ToggelMuteOnPlayer;
        KFGFxWidget_PartyInGame.ToggelMuteOnPlayer = KFGFxWidget_PartyInGameProxy.ToggelMuteOnPlayer;
        KFGFxWidget_PartyInGameOriginal.ViewProfile = KFGFxWidget_PartyInGame.ViewProfile;
        KFGFxWidget_PartyInGame.ViewProfile = KFGFxWidget_PartyInGameProxy.ViewProfile;
        KFGFxWidget_PartyInGameOriginal.AddFriend = KFGFxWidget_PartyInGame.AddFriend;
        KFGFxWidget_PartyInGame.AddFriend = KFGFxWidget_PartyInGameProxy.AddFriend;
        KFGFxWidget_PartyInGameOriginal.KickPlayer = KFGFxWidget_PartyInGame.KickPlayer;
        KFGFxWidget_PartyInGame.KickPlayer = KFGFxWidget_PartyInGameProxy.KickPlayer;
        KFGFxWidget_PartyInGameOriginal.RefreshSlot = KFGFxWidget_PartyInGame.RefreshSlot;
        KFGFxWidget_PartyInGame.RefreshSlot = KFGFxWidget_PartyInGameProxy.RefreshSlot;
        KFGFxStartContainer_InGameOverviewOriginal.ShowWelcomeScreen = KFGFxStartContainer_InGameOverview.ShowWelcomeScreen;
        KFGFxStartContainer_InGameOverview.ShowWelcomeScreen = KFGFxStartContainer_InGameOverviewProxy.ShowWelcomeScreen;
        ConsoleOriginal.ConsoleCommand = Console.ConsoleCommand;
        Console.ConsoleCommand = ConsoleProxy.ConsoleCommand;
        KFGFxHudWrapperOriginal.CreateHUDMovie = KFGFxHudWrapper.CreateHUDMovie;
        KFGFxHudWrapper.CreateHUDMovie = KFGFxHudWrapperProxy.CreateHUDMovie;
        KFGFxHudWrapperOriginal.LocalizedMessage = KFGFxHudWrapper.LocalizedMessage;
        KFGFxHudWrapper.LocalizedMessage = KFGFxHudWrapperProxy.LocalizedMessage;
        KFGFXHudWrapper_VersusOriginal.CreateHUDMovie = KFGFXHudWrapper_Versus.CreateHUDMovie;
        KFGFXHudWrapper_Versus.CreateHUDMovie = KFGFXHudWrapper_VersusProxy.CreateHUDMovie;
        KFGFxMoviePlayer_HUDOriginal.ShowKillMessage = KFGFxMoviePlayer_HUD.ShowKillMessage;
        KFGFxMoviePlayer_HUD.ShowKillMessage = KFGFxMoviePlayer_HUDProxy.ShowKillMessage;
        KFGFxMoviePlayer_HUDOriginal.TickHud = KFGFxMoviePlayer_HUD.TickHud;
        KFGFxMoviePlayer_HUD.TickHud = KFGFxMoviePlayer_HUDProxy.TickHud;
        KFOnlineStatsWriteOriginal.AddToKills = KFOnlineStatsWrite.AddToKills;
        KFOnlineStatsWrite.AddToKills = KFOnlineStatsWriteProxy.AddToKills;
        KFPlayerInputOriginal.ApplyForceLookAtPawn = KFPlayerInput.ApplyForceLookAtPawn;
        KFPlayerInput.ApplyForceLookAtPawn = KFPlayerInputProxy.ApplyForceLookAtPawn;
        KFCharacterInfo_HumanOriginal.SetBodySkinMaterial = KFCharacterInfo_Human.SetBodySkinMaterial;
        KFCharacterInfo_Human.SetBodySkinMaterial = KFCharacterInfo_HumanProxy.SetBodySkinMaterial;
        KFCharacterInfo_HumanOriginal.SetHeadSkinMaterial = KFCharacterInfo_Human.SetHeadSkinMaterial;
        KFCharacterInfo_Human.SetHeadSkinMaterial = KFCharacterInfo_HumanProxy.SetHeadSkinMaterial;
        KFCharacterInfo_HumanOriginal.SetAttachmentSkinMaterial = KFCharacterInfo_Human.SetAttachmentSkinMaterial;
        KFCharacterInfo_Human.SetAttachmentSkinMaterial = KFCharacterInfo_HumanProxy.SetAttachmentSkinMaterial;
        KFCharacterInfo_HumanOriginal.SetWeeklyCowboyAttachmentSkinMaterial = KFCharacterInfo_Human.SetWeeklyCowboyAttachmentSkinMaterial;
        KFCharacterInfo_Human.SetWeeklyCowboyAttachmentSkinMaterial = KFCharacterInfo_HumanProxy.SetWeeklyCowboyAttachmentSkinMaterial;
        KFCharacterInfo_HumanOriginal.SetAttachmentMesh = KFCharacterInfo_Human.SetAttachmentMesh;
        KFCharacterInfo_Human.SetAttachmentMesh = KFCharacterInfo_HumanProxy.SetAttachmentMesh;
        KFCharacterInfo_HumanOriginal.SetAttachmentMeshAndSkin = KFCharacterInfo_Human.SetAttachmentMeshAndSkin;
        KFCharacterInfo_Human.SetAttachmentMeshAndSkin = KFCharacterInfo_HumanProxy.SetAttachmentMeshAndSkin;
        KFCharacterInfo_HumanOriginal.SetArmsMeshAndSkin = KFCharacterInfo_Human.SetArmsMeshAndSkin;
        KFCharacterInfo_Human.SetArmsMeshAndSkin = KFCharacterInfo_HumanProxy.SetArmsMeshAndSkin;
        KFGFxHUD_ScoreboardWidgetOriginal.InitializeHUD = KFGFxHUD_ScoreboardWidget.InitializeHUD;
        KFGFxHUD_ScoreboardWidget.InitializeHUD = KFGFxHUD_ScoreboardWidgetProxy.InitializeHUD;
        KFGFxPerksContainer_DetailsOriginal.UpdateAndGetCurrentWeaponIndexes = KFGFxPerksContainer_Details.UpdateAndGetCurrentWeaponIndexes;
        KFGFxPerksContainer_Details.UpdateAndGetCurrentWeaponIndexes = KFGFxPerksContainer_DetailsProxy.UpdateAndGetCurrentWeaponIndexes;
        KFGFxHUD_ChatBoxWidgetOriginal.AddChatMessage = KFGFxHUD_ChatBoxWidget.AddChatMessage;
        KFGFxHUD_ChatBoxWidget.AddChatMessage = KFGFxHUD_ChatBoxWidgetProxy.AddChatMessage;
        KFGFxHUD_ChatBoxWidgetOriginal.SetDataObjects = KFGFxHUD_ChatBoxWidget.SetDataObjects;
        KFGFxHUD_ChatBoxWidget.SetDataObjects = KFGFxHUD_ChatBoxWidgetProxy.SetDataObjects;
        KFGFxObject_MenuOriginal.Callback_RequestTeamSwitch = KFGFxObject_Menu.Callback_RequestTeamSwitch;
        KFGFxObject_Menu.Callback_RequestTeamSwitch = KFGFxObject_MenuProxy.Callback_RequestTeamSwitch;
        KFWeaponOriginal.GetMuzzleLoc = KFWeapon.GetMuzzleLoc;
        KFWeapon.GetMuzzleLoc = KFWeaponProxy.GetMuzzleLoc;
        KFWeaponOriginal.PostInitAnimTree = KFWeapon.PostInitAnimTree;
        KFWeapon.PostInitAnimTree = KFWeaponProxy.PostInitAnimTree;
        KFWeap_DualBaseOriginal.GetLeftMuzzleLoc = KFWeap_DualBase.GetLeftMuzzleLoc;
        KFWeap_DualBase.GetLeftMuzzleLoc = KFWeap_DualBaseProxy.GetLeftMuzzleLoc;
        GFxMoviePlayerOriginal.Init = GFxMoviePlayer.Init;
        GFxMoviePlayer.Init = GFxMoviePlayerProxy.Init;
        KFWeap_ScopedBaseOriginal.OnZoomInFinished = KFWeap_ScopedBase.OnZoomInFinished;
        KFWeap_ScopedBase.OnZoomInFinished = KFWeap_ScopedBaseProxy.OnZoomInFinished;
        KFWeap_ScopedBaseOriginal.ZoomOut = KFWeap_ScopedBase.ZoomOut;
        KFWeap_ScopedBase.ZoomOut = KFWeap_ScopedBaseProxy.ZoomOut;
        KFGFxPostGameContainer_MapVoteOriginal.Initialize = KFGFxPostGameContainer_MapVote.Initialize;
        KFGFxPostGameContainer_MapVote.Initialize = KFGFxPostGameContainer_MapVoteProxy.Initialize;
        KFGFxPostGameContainer_MapVoteOriginal.LocalizeText = KFGFxPostGameContainer_MapVote.LocalizeText;
        KFGFxPostGameContainer_MapVote.LocalizeText = KFGFxPostGameContainer_MapVoteProxy.LocalizeText;
        KFGFxPostGameContainer_MapVoteOriginal.SetMapOptions = KFGFxPostGameContainer_MapVote.SetMapOptions;
        KFGFxPostGameContainer_MapVote.SetMapOptions = KFGFxPostGameContainer_MapVoteProxy.SetMapOptions;
        KFGFxPostGameContainer_MapVoteOriginal.RecieveTopMaps = KFGFxPostGameContainer_MapVote.RecieveTopMaps;
        KFGFxPostGameContainer_MapVote.RecieveTopMaps = KFGFxPostGameContainer_MapVoteProxy.RecieveTopMaps;
        KFGFxMenu_PostGameReportOriginal.Callback_MapVote = KFGFxMenu_PostGameReport.Callback_MapVote;
        KFGFxMenu_PostGameReport.Callback_MapVote = KFGFxMenu_PostGameReportProxy.Callback_MapVote;
        KFGFxMenu_PostGameReportOriginal.Callback_TopMapClicked = KFGFxMenu_PostGameReport.Callback_TopMapClicked;
        KFGFxMenu_PostGameReport.Callback_TopMapClicked = KFGFxMenu_PostGameReportProxy.Callback_TopMapClicked;
        KFGFxSpecialEventObjectivesContainerOriginal.HasObjectiveStatusChanged = KFGFxSpecialEventObjectivesContainer.HasObjectiveStatusChanged;
        KFGFxSpecialEventObjectivesContainer.HasObjectiveStatusChanged = KFGFxSpecialEventObjectivesContainerProxy.HasObjectiveStatusChanged;
        KFGFxMenu_StartGameOriginal.GetSpecialEventClass = KFGFxMenu_StartGame.GetSpecialEventClass;
        KFGFxMenu_StartGame.GetSpecialEventClass = KFGFxMenu_StartGameProxy.GetSpecialEventClass;
        PawnOriginal.GetActorEyesViewPoint = Pawn.GetActorEyesViewPoint;
        Pawn.GetActorEyesViewPoint = PawnProxy.GetActorEyesViewPoint;
        KFPawnOriginal.WeaponBob = KFPawn.WeaponBob;
        KFPawn.WeaponBob = KFPawnProxy.WeaponBob;
        KFPawnOriginal.PlayWeaponSwitch = KFPawn.PlayWeaponSwitch;
        KFPawn.PlayWeaponSwitch = KFPawnProxy.PlayWeaponSwitch;
        KFPawnOriginal.SetSprinting = KFPawn.SetSprinting;
        KFPawn.SetSprinting = KFPawnProxy.SetSprinting;
        KFPawnOriginal.DoJump = KFPawn.DoJump;
        KFPawn.DoJump = KFPawnProxy.DoJump;
        KFGoreManagerOriginal.AddCorpse = KFGoreManager.AddCorpse;
        KFGoreManager.AddCorpse = KFGoreManagerProxy.AddCorpse;
        KFGFxTraderContainer_StoreOriginal.IsItemFiltered = KFGFxTraderContainer_Store.IsItemFiltered;
        KFGFxTraderContainer_Store.IsItemFiltered = KFGFxTraderContainer_StoreProxy.IsItemFiltered;
        KFGFxTraderContainer_StoreOriginal.SetItemInfo = KFGFxTraderContainer_Store.SetItemInfo;
        KFGFxTraderContainer_Store.SetItemInfo = KFGFxTraderContainer_StoreProxy.SetItemInfo;
        KFGFxMenu_TraderOriginal.RefreshShopItemList = KFGFxMenu_Trader.RefreshShopItemList;
        KFGFxMenu_Trader.RefreshShopItemList = KFGFxMenu_TraderProxy.RefreshShopItemList;
        KFGFxMenu_TraderOriginal.SetTraderItemDetails = KFGFxMenu_Trader.SetTraderItemDetails;
        KFGFxMenu_Trader.SetTraderItemDetails = KFGFxMenu_TraderProxy.SetTraderItemDetails;
        KFGFxMenu_TraderOriginal.Callback_FavoriteItem = KFGFxMenu_Trader.Callback_FavoriteItem;
        KFGFxMenu_Trader.Callback_FavoriteItem = KFGFxMenu_TraderProxy.Callback_FavoriteItem;
        KFGFxMenu_TraderOriginal.Callback_BuyOrSellItem = KFGFxMenu_Trader.Callback_BuyOrSellItem;
        KFGFxMenu_Trader.Callback_BuyOrSellItem = KFGFxMenu_TraderProxy.Callback_BuyOrSellItem;
        KFGFxTraderContainer_ItemDetailsOriginal.SetPlayerItemDetails = KFGFxTraderContainer_ItemDetails.SetPlayerItemDetails;
        KFGFxTraderContainer_ItemDetails.SetPlayerItemDetails = KFGFxTraderContainer_ItemDetailsProxy.SetPlayerItemDetails;
        KFGFxTraderContainer_ItemDetailsOriginal.SetGenericItemDetails = KFGFxTraderContainer_ItemDetails.SetGenericItemDetails;
        KFGFxTraderContainer_ItemDetails.SetGenericItemDetails = KFGFxTraderContainer_ItemDetailsProxy.SetGenericItemDetails;
        KFGFxTraderContainer_ItemDetailsOriginal.SetDetailsText = KFGFxTraderContainer_ItemDetails.SetDetailsText;
        KFGFxTraderContainer_ItemDetails.SetDetailsText = KFGFxTraderContainer_ItemDetailsProxy.SetDetailsText;
        KFGFxMissionObjectivesContainerOriginal.ShowShouldSpecialEvent = KFGFxMissionObjectivesContainer.ShowShouldSpecialEvent;
        KFGFxMissionObjectivesContainer.ShowShouldSpecialEvent = KFGFxMissionObjectivesContainerProxy.ShowShouldSpecialEvent;

        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnMapObjectiveDeactivated = KFOnlineStatsWrite.SeasonalEventStats_OnMapObjectiveDeactivated;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnMapCollectibleFound = KFOnlineStatsWrite.SeasonalEventStats_OnMapCollectibleFound;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnHitTaken = KFOnlineStatsWrite.SeasonalEventStats_OnHitTaken;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnHitGiven = KFOnlineStatsWrite.SeasonalEventStats_OnHitGiven;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnZedKilled = KFOnlineStatsWrite.SeasonalEventStats_OnZedKilled;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnZedKilledByHeadshot = KFOnlineStatsWrite.SeasonalEventStats_OnZedKilledByHeadshot;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnBossDied = KFOnlineStatsWrite.SeasonalEventStats_OnBossDied;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnTriggerUsed = KFOnlineStatsWrite.SeasonalEventStats_OnTriggerUsed;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnTryCompleteObjective = KFOnlineStatsWrite.SeasonalEventStats_OnTryCompleteObjective;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnWeaponPurchased = KFOnlineStatsWrite.SeasonalEventStats_OnWeaponPurchased;
        KFOnlineStatsWriteOriginal.SeasonalEventStats_OnAfflictionCaused = KFOnlineStatsWrite.SeasonalEventStats_OnAfflictionCaused;

        PC = KFPlayerController(WorldInfo.GetALocalPlayerController());
        if( PC != None )
        {
            if( KFGFxHudWrapper(PC.myHUD) != None )
            {
                KFGFxHudWrapper(PC.myHUD).RemoveMovies();
                KFGFxHudWrapper(PC.myHUD).CreateHUDMovie(true);
            }
                
            if( PC.MyGFxManager != None )
            {
                MyGFxManagerClass = PC.MyGFxManager.Class;
                PC.MyGFxManager.Close();
                PC.MyGFxManager = None;
                PC.ClientSetFrontEnd(MyGFxManagerClass);
            }
        }
        
        KFGFxMoviePlayer_ManagerOriginal.OnCleanup = KFGFxMoviePlayer_Manager.OnCleanup;
        KFGFxMoviePlayer_Manager.OnCleanup = KFGFxMoviePlayer_ManagerProxy.OnCleanup;
    }
    
    default.bInitSuccess = true;
}

function Cleanup()
{
    if( default.bFunctionsRestored )
        return;
    
    if( WorldInfo.NetMode != NM_Client )
    {
        AccessControl.NotifyServerTravel = AccessControlOriginal.NotifyServerTravel;
        PlayerController.ServerSay = PlayerControllerOriginal.ServerSay;
        PlayerController.ServerTeamSay = PlayerControllerOriginal.ServerTeamSay;
        PlayerController.ServerCamera = PlayerControllerOriginal.ServerCamera;
        GameInfo.GenericPlayerInitialization = GameInfoOriginal.GenericPlayerInitialization;
        GameInfo.Logout = GameInfoOriginal.Logout;
        GameInfo.NotifyKilled = GameInfoOriginal.NotifyKilled;
        GameInfo.PickupQuery = GameInfoOriginal.PickupQuery;
        GameInfo.ProcessServerTravel = GameInfoOriginal.ProcessServerTravel;
        GameInfo.PreLogin = GameInfoOriginal.PreLogin;
        GameInfo.Killed = GameInfoOriginal.Killed;
        GameInfo.ReduceDamage = GameInfoOriginal.ReduceDamage;
        KFGameInfo.ReplicateWelcomeScreen = KFGameInfoOriginal.ReplicateWelcomeScreen;
        KFGameInfo.ModifyAIDoshValueForPlayerCount = KFGameInfoOriginal.ModifyAIDoshValueForPlayerCount;
        KFGameInfo.GetFriendlyNameForCurrentGameMode = KFGameInfoOriginal.GetFriendlyNameForCurrentGameMode;
        KFGameInfo.GetGameModeNumFromClass = KFGameInfoOriginal.GetGameModeNumFromClass;
        KFGameInfo.GetGameModeFriendlyNameFromClass = KFGameInfoOriginal.GetGameModeFriendlyNameFromClass;
        KFGameInfo.CreateOutbreakEvent = KFGameInfoOriginal.CreateOutbreakEvent;
        KFGameInfo.UpdateGameSettings = KFGameInfoOriginal.UpdateGameSettings;
        KFGameInfo.ScoreMonsterKill = KFGameInfoOriginal.ScoreMonsterKill;
        KFGameInfo.DistributeMoneyAndXP = KFGameInfoOriginal.DistributeMoneyAndXP;
        KFGameInfo.GetSpecificBossClass = KFGameInfoOriginal.GetSpecificBossClass;
        KFGameInfo.GetAdjustedAIDoshValue = KFGameInfoOriginal.GetAdjustedAIDoshValue;
        KFGameInfo.GetGameInfoSpawnRateMod = KFGameInfoOriginal.GetGameInfoSpawnRateMod;
        KFGameInfo.GetTotalWaveCountScale = KFGameInfoOriginal.GetTotalWaveCountScale;
        KFGameInfo_Survival.StartMatch = KFGameInfo_SurvivalOriginal.StartMatch;
        KFGameInfo_Survival.NotifyTraderOpened = KFGameInfo_SurvivalOriginal.NotifyTraderOpened;
        KFGameInfo_Survival.NotifyTraderClosed = KFGameInfo_SurvivalOriginal.NotifyTraderClosed;
        KFGameInfo_Survival.Timer = KFGameInfo_SurvivalOriginal.Timer;
        KFGameInfo_Survival.TryRestartGame = KFGameInfo_SurvivalOriginal.TryRestartGame;
        KFGameInfo_Survival.ForceChangeLevel = KFGameInfo_SurvivalOriginal.ForceChangeLevel;
        KFGameInfo_WeeklySurvival.UsesModifiedDifficulty = KFGameInfo_WeeklySurvivalOriginal.UsesModifiedDifficulty;
        KFGameInfo_Endless.TrySetNextWaveSpecial = KFGameInfo_EndlessOriginal.TrySetNextWaveSpecial;
        KFGameReplicationInfo.PostBeginPlay = KFGameReplicationInfoOriginal.PostBeginPlay;
        KFPlayerController.EnterZedTime = KFPlayerControllerOriginal.EnterZedTime;
        KFPlayerController.CompleteZedTime = KFPlayerControllerOriginal.CompleteZedTime;
        KFPlayerController.ServerPause = KFPlayerControllerOriginal.ServerPause;
        KFDroppedPickup.SetPickupMesh = KFDroppedPickupOriginal.SetPickupMesh;
        KFDroppedPickup.Destroyed = KFDroppedPickupOriginal.Destroyed;
        KFDroppedPickup.GiveTo = KFDroppedPickupOriginal.GiveTo;
        KFDroppedPickup.Pickup.BeginState = KFDroppedPickupOriginal.Pickup.BeginState;
        Actor.FellOutOfWorld = ActorOriginal.FellOutOfWorld;
        KFPawn_Human.PossessedBy = KFPawn_HumanOriginal.PossessedBy;
        KFPawn_Human.Tick = KFPawn_HumanOriginal.Tick;
        DroppedPickup.Landed = DroppedPickupOriginal.Landed;
        BasicWebAdminUser.linkPlayerController = BasicWebAdminUserOriginal.linkPlayerController;  
        KFAISpawnManager.GetMaxMonsters = KFAISpawnManagerOriginal.GetMaxMonsters; 
        KFInventoryManager.ServerThrowMoney = KFInventoryManagerOriginal.ServerThrowMoney;
        KFInventoryManager.DiscardInventory = KFInventoryManagerOriginal.DiscardInventory;
        KFInventory_Money.DropFrom = KFInventory_MoneyOriginal.DropFrom;
        KFGameDifficultyInfo.GetNumPlayersModifier = KFGameDifficultyInfoOriginal.GetNumPlayersModifier;
        KFAIController.FindNewEnemy = KFAIControllerOriginal.FindNewEnemy;
        KFMonsterDifficultyInfo.GetSpecialSpawnChance = KFMonsterDifficultyInfoOriginal.GetSpecialSpawnChance;
        KFAIController_ZedFleshpound.SpawnEnraged = KFAIController_ZedFleshpoundOriginal.SpawnEnraged;
        KFPawn_Monster.GetAIPawnClassToSpawn = KFPawn_MonsterOriginal.GetAIPawnClassToSpawn;
        KFOutbreakEvent.UpdateGRI = KFOutbreakEventOriginal.UpdateGRI;
    }
    
    KFPawn_Human.UpdateActiveSkillsPath = KFPawn_HumanOriginal.UpdateActiveSkillsPath;
    KFPerk_Berserker.SetSuccessfullParry = KFPerk_BerserkerOriginal.SetSuccessfullParry;
    KFPerk_Berserker.ParryTimer = KFPerk_BerserkerOriginal.ParryTimer;
    KFPawn.PostBeginPlay = KFPawnOriginal.PostBeginPlay;
    KFPawn.SetWeaponAttachmentFromWeaponClass = KFPawnOriginal.SetWeaponAttachmentFromWeaponClass;
    KFPlayerController.ClientTriggerWeaponContentLoad = KFPlayerControllerOriginal.ClientTriggerWeaponContentLoad;
    KFPlayerController.PreClientTravel = KFPlayerControllerOriginal.PreClientTravel;
    KFPlayerController.GetAllowSeasonalSkins = KFPlayerControllerOriginal.GetAllowSeasonalSkins;
    KFPlayerController.GetSeasonalStateName = KFPlayerControllerOriginal.GetSeasonalStateName;
    KFWeapon.PreBeginPlay = KFWeaponOriginal.PreBeginPlay;
    KFWeapon.GivenTo = KFWeaponOriginal.GivenTo;
    KFWeapon.ClientGivenTo = KFWeaponOriginal.ClientGivenTo;
    KFWeapon.AttachWeaponTo = KFWeaponOriginal.AttachWeaponTo;
    KFWeapon.GetWeaponAttachmentTemplate = KFWeaponOriginal.GetWeaponAttachmentTemplate;
    KFWeapon.HandleRecoil = KFWeaponOriginal.HandleRecoil;  
    KFWeapon.GetWeaponPerkClass = KFWeaponOriginal.GetWeaponPerkClass;
    KFWeapon.SyncCurrentAmmoCount = KFWeaponOriginal.SyncCurrentAmmoCount;
    KFSprayActor.BeginSpray = KFSprayActorOriginal.BeginSpray;
    KFWeap_FlameBase.WeaponEquipping.BeginState = KFWeap_FlameBaseOriginal.WeaponEquipping.BeginState;
    KFWeap_FlameBase.ChangeVisibility = KFWeap_FlameBaseOriginal.ChangeVisibility;
    KFWeap_Pistol_AF2011.SpawnProjectile = KFWeap_Pistol_AF2011Original.SpawnProjectile;
    KFPawn_Monster.PreBeginPlay = KFPawn_MonsterOriginal.PreBeginPlay;
    KFPawn_Monster.PlayHeadAsplode = KFPawn_MonsterOriginal.PlayHeadAsplode;
    Pawn.InFreeCam = PawnOriginal.InFreeCam;
    Pawn.StartFire = PawnOriginal.StartFire;
    KFProj_RicochetStickBullet.Stick = KFProj_RicochetStickBulletOriginal.Stick;
    KFProj_Grenade_GravityImploderAlt.ImplodingState.AbsorbEnemies = KFProj_Grenade_GravityImploderAltOriginal.ImplodingState.AbsorbEnemies;
    KFGFxObject_TraderItems.GetItemIndicesFromArche = KFGFxObject_TraderItemsOriginal.GetItemIndicesFromArche;
    ChatLog.ReceiveMessage = ChatLogOriginal.ReceiveMessage;
    MessagingSpectator.TeamMessage = MessagingSpectatorOriginal.TeamMessage;
    KFProj_ExplosiveSubmunition_HX25.PrepareExplosionTemplate = KFProj_ExplosiveSubmunition_HX25Original.PrepareExplosionTemplate;
    KFProj_ExplosiveSubmunition_HX25.AllowNuke = KFProj_ExplosiveSubmunition_HX25Original.AllowNuke;
    KFProj_Explosive_HRG_Kaboomstick.PrepareExplosionTemplate = KFProj_Explosive_HRG_KaboomstickOriginal.PrepareExplosionTemplate;
    KFProj_Explosive_HRG_Kaboomstick.AllowNuke = KFProj_Explosive_HRG_KaboomstickOriginal.AllowNuke;
    KFCharacterInfo_Human.SetBodyMeshAndSkin = KFCharacterInfo_HumanOriginal.SetBodyMeshAndSkin;
    KFCharacterInfo_Human.SetHeadMeshAndSkin = KFCharacterInfo_HumanOriginal.SetHeadMeshAndSkin;
    KFPlayerReplicationInfo.PostBeginPlay = KFPlayerReplicationInfoOriginal.PostBeginPlay;
    KFPerk.IsWeaponOnPerk = KFPerkOriginal.IsWeaponOnPerk;
    KFPerk.IsDamageTypeOnPerk = KFPerkOriginal.IsDamageTypeOnPerk;
    KFPerk.IsDamageTypeOnThisPerk = KFPerkOriginal.IsDamageTypeOnThisPerk;
    KFPerk.GetPerkFromDamageCauser = KFPerkOriginal.GetPerkFromDamageCauser;
    KFPerk.IsDual9mm = KFPerkOriginal.IsDual9mm;
    KFPerk.IsHRG93R = KFPerkOriginal.IsHRG93R;
    KFPerk.IsFAMAS = KFPerkOriginal.IsFAMAS;
    KFPerk.IsBlastBrawlers = KFPerkOriginal.IsBlastBrawlers;
    KFPerk.IsDoshinegun = KFPerkOriginal.IsDoshinegun;
    KFPerk.IsHRGCrossboom = KFPerkOriginal.IsHRGCrossboom;
    KFPerk.IsAutoTurret = KFPerkOriginal.IsAutoTurret;
    KFPerk.IsHRGBallisticBouncer = KFPerkOriginal.IsHRGBallisticBouncer;
    KFPerk_Firebug.ModifyMagSizeAndNumber = KFPerk_FirebugOriginal.ModifyMagSizeAndNumber;
    KFPerk_FieldMedic.CouldBeZedToxicCloud = KFPerk_FieldMedicOriginal.CouldBeZedToxicCloud;
    KFPerk_FieldMedic.ModifyMagSizeAndNumber = KFPerk_FieldMedicOriginal.ModifyMagSizeAndNumber;
    KFPerk_Commando.ModifyMagSizeAndNumber = KFPerk_CommandoOriginal.ModifyMagSizeAndNumber;
    Mutator.PreBeginPlay = MutatorOriginal.PreBeginPlay;
    KFAutoPurchaseHelper.CanUpgrade = KFAutoPurchaseHelperOriginal.CanUpgrade;
    KFPawn_ZedHansBase.PossessedBy = KFPawn_ZedHansBaseOriginal.PossessedBy;
    
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		KFWeapon.SetPosition = KFWeaponOriginal.SetPosition;
        KFCharacterInfo_Human.DetachConflictingAttachments = KFCharacterInfo_HumanOriginal.DetachConflictingAttachments;
        KFGFxMoviePlayer_Manager.LaunchMenus = KFGFxMoviePlayer_ManagerOriginal.LaunchMenus;
        KFGFxMoviePlayer_Manager.Init = KFGFxMoviePlayer_ManagerOriginal.Init;
        KFGFxMoviePlayer_Manager.OnForceUpdate = KFGFxMoviePlayer_ManagerOriginal.OnForceUpdate;
        KFGFxMenu_Gear.Callback_AttachmentNumbered = KFGFxMenu_GearOriginal.Callback_AttachmentNumbered;
        KFGFxMenu_Gear.CheckForCustomizationPawn = KFGFxMenu_GearOriginal.CheckForCustomizationPawn;
        KFGFxMenu_Gear.OnClose = KFGFxMenu_GearOriginal.OnClose;
        KFGFxMenu_Gear.Callback_Emote = KFGFxMenu_GearOriginal.Callback_Emote;
        KFPawn.OnAnimEnd = KFPawnOriginal.OnAnimEnd;
        KFGFxWidget_MenuBar.CanUseGearButton = KFGFxWidget_MenuBarOriginal.CanUseGearButton;
        KFPlayerController.RecieveChatMessage = KFPlayerControllerOriginal.RecieveChatMessage;
        KFPlayerController.TeamMessage = KFPlayerControllerOriginal.TeamMessage;
        KFPlayerController.ReceiveLocalizedMessage = KFPlayerControllerOriginal.ReceiveLocalizedMessage;
        KFPlayerController.ClientWonGame = KFPlayerControllerOriginal.ClientWonGame;
        KFPlayerController.ClientGameOver = KFPlayerControllerOriginal.ClientGameOver;
        KFPlayerController.OnWaveComplete = KFPlayerControllerOriginal.OnWaveComplete;
        KFPlayerController.IsEventObjectiveComplete = KFPlayerControllerOriginal.IsEventObjectiveComplete;
        KFPlayerController.OnAllMapCollectiblesFound = KFPlayerControllerOriginal.OnAllMapCollectiblesFound;
        KFPlayerController.SeasonalEventIsValid = KFPlayerControllerOriginal.SeasonalEventIsValid;
        KFPlayerController.GetSeasonalEventStatInfo = KFPlayerControllerOriginal.GetSeasonalEventStatInfo;
        KFGFxPerksContainer_Selection.UpdatePerkSelection = KFGFxPerksContainer_SelectionOriginal.UpdatePerkSelection;
        PlayerController.Say = PlayerControllerOriginal.Say;
        PlayerController.TeamSay = PlayerControllerOriginal.TeamSay;
        KFGFxHUD_PlayerStatus.TickHud = KFGFxHUD_PlayerStatusOriginal.TickHud;
        KFInventoryManager.ThrowMoney = KFInventoryManagerOriginal.ThrowMoney;
        KFGFxControlsContainer_Keybinding.Initialize = KFGFxControlsContainer_KeybindingOriginal.Initialize;
        KFGFxControlsContainer_Keybinding.UpdateAllBindings = KFGFxControlsContainer_KeybindingOriginal.UpdateAllBindings;
        KFGFxControlsContainer_Keybinding.SetKeyBind = KFGFxControlsContainer_KeybindingOriginal.SetKeyBind;
        KFGFxControlsContainer_Keybinding.SetConflictMessage = KFGFxControlsContainer_KeybindingOriginal.SetConflictMessage;
        KFGFxControlsContainer_Keybinding.InitalizeCommandList = KFGFxControlsContainer_KeybindingOriginal.InitalizeCommandList;
        KFGFxWidget_PartyInGame.InitializeWidget = KFGFxWidget_PartyInGameOriginal.InitializeWidget;
        KFGFxWidget_PartyInGame.UpdateReadyButtonVisibility = KFGFxWidget_PartyInGameOriginal.UpdateReadyButtonVisibility;
        KFGFxWidget_PartyInGame.OneSecondLoop = KFGFxWidget_PartyInGameOriginal.OneSecondLoop;
        KFGFxWidget_PartyInGame.RefreshParty = KFGFxWidget_PartyInGameOriginal.RefreshParty;
        KFGFxWidget_PartyInGame.ToggelMuteOnPlayer = KFGFxWidget_PartyInGameOriginal.ToggelMuteOnPlayer;
        KFGFxWidget_PartyInGame.ViewProfile = KFGFxWidget_PartyInGameOriginal.ViewProfile;
        KFGFxWidget_PartyInGame.AddFriend = KFGFxWidget_PartyInGameOriginal.AddFriend;
        KFGFxWidget_PartyInGame.KickPlayer = KFGFxWidget_PartyInGameOriginal.KickPlayer;
        KFGFxWidget_PartyInGame.RefreshSlot = KFGFxWidget_PartyInGameOriginal.RefreshSlot;
        KFGFxStartContainer_InGameOverview.ShowWelcomeScreen = KFGFxStartContainer_InGameOverviewOriginal.ShowWelcomeScreen;
        Console.ConsoleCommand = ConsoleOriginal.ConsoleCommand;
        KFGFxHudWrapper.CreateHUDMovie = KFGFxHudWrapperOriginal.CreateHUDMovie;
        KFGFxHudWrapper.LocalizedMessage = KFGFxHudWrapperOriginal.LocalizedMessage;
        KFGFXHudWrapper_Versus.CreateHUDMovie = KFGFXHudWrapper_VersusOriginal.CreateHUDMovie;
        KFGFxMoviePlayer_HUD.ShowKillMessage = KFGFxMoviePlayer_HUDOriginal.ShowKillMessage;
        KFGFxMoviePlayer_HUD.TickHud = KFGFxMoviePlayer_HUDOriginal.TickHud;
        KFOnlineStatsWrite.AddToKills = KFOnlineStatsWriteOriginal.AddToKills;
        KFPlayerInput.ApplyForceLookAtPawn = KFPlayerInputOriginal.ApplyForceLookAtPawn;
        KFCharacterInfo_Human.SetBodySkinMaterial = KFCharacterInfo_HumanOriginal.SetBodySkinMaterial;
        KFCharacterInfo_Human.SetHeadSkinMaterial = KFCharacterInfo_HumanOriginal.SetHeadSkinMaterial;
        KFCharacterInfo_Human.SetAttachmentSkinMaterial = KFCharacterInfo_HumanOriginal.SetAttachmentSkinMaterial;
        KFCharacterInfo_Human.SetWeeklyCowboyAttachmentSkinMaterial = KFCharacterInfo_HumanOriginal.SetWeeklyCowboyAttachmentSkinMaterial;
        KFCharacterInfo_Human.SetAttachmentMesh = KFCharacterInfo_HumanOriginal.SetAttachmentMesh;
        KFCharacterInfo_Human.SetAttachmentMeshAndSkin = KFCharacterInfo_HumanOriginal.SetAttachmentMeshAndSkin;
        KFCharacterInfo_Human.SetArmsMeshAndSkin = KFCharacterInfo_HumanOriginal.SetArmsMeshAndSkin;
        KFGFxHUD_ScoreboardWidget.InitializeHUD = KFGFxHUD_ScoreboardWidgetOriginal.InitializeHUD;
        KFGFxPerksContainer_Details.UpdateAndGetCurrentWeaponIndexes = KFGFxPerksContainer_DetailsOriginal.UpdateAndGetCurrentWeaponIndexes;
        KFGFxHUD_ChatBoxWidget.AddChatMessage = KFGFxHUD_ChatBoxWidgetOriginal.AddChatMessage;
        KFGFxHUD_ChatBoxWidget.SetDataObjects = KFGFxHUD_ChatBoxWidgetOriginal.SetDataObjects;
        KFGFxObject_Menu.Callback_RequestTeamSwitch = KFGFxObject_MenuOriginal.Callback_RequestTeamSwitch;
        KFWeapon.GetMuzzleLoc = KFWeaponOriginal.GetMuzzleLoc;
        KFWeapon.PostInitAnimTree = KFWeaponOriginal.PostInitAnimTree;
        KFWeap_DualBase.GetLeftMuzzleLoc = KFWeap_DualBaseOriginal.GetLeftMuzzleLoc;
        GFxMoviePlayer.Init = GFxMoviePlayerOriginal.Init;
        KFWeap_ScopedBase.OnZoomInFinished = KFWeap_ScopedBaseOriginal.OnZoomInFinished;
        KFWeap_ScopedBase.ZoomOut = KFWeap_ScopedBaseOriginal.ZoomOut;
        KFGFxPostGameContainer_MapVote.Initialize = KFGFxPostGameContainer_MapVoteOriginal.Initialize;
        KFGFxPostGameContainer_MapVote.LocalizeText = KFGFxPostGameContainer_MapVoteOriginal.LocalizeText;
        KFGFxPostGameContainer_MapVote.SetMapOptions = KFGFxPostGameContainer_MapVoteOriginal.SetMapOptions;
        KFGFxPostGameContainer_MapVote.RecieveTopMaps = KFGFxPostGameContainer_MapVoteOriginal.RecieveTopMaps;
        KFGFxMenu_PostGameReport.Callback_MapVote = KFGFxMenu_PostGameReportOriginal.Callback_MapVote;
        KFGFxMenu_PostGameReport.Callback_TopMapClicked = KFGFxMenu_PostGameReportOriginal.Callback_TopMapClicked;
        KFGFxSpecialEventObjectivesContainer.HasObjectiveStatusChanged = KFGFxSpecialEventObjectivesContainerOriginal.HasObjectiveStatusChanged;
        KFGFxMenu_StartGame.GetSpecialEventClass = KFGFxMenu_StartGameOriginal.GetSpecialEventClass;
        Pawn.GetActorEyesViewPoint = PawnOriginal.GetActorEyesViewPoint;
        KFPawn.WeaponBob = KFPawnOriginal.WeaponBob;
        KFPawn.PlayWeaponSwitch = KFPawnOriginal.PlayWeaponSwitch;
        KFPawn.SetSprinting = KFPawnOriginal.SetSprinting;
        KFPawn.DoJump = KFPawnOriginal.DoJump;
        KFGoreManager.AddCorpse = KFGoreManagerOriginal.AddCorpse;
        KFGFxTraderContainer_Store.IsItemFiltered = KFGFxTraderContainer_StoreOriginal.IsItemFiltered;
        KFGFxTraderContainer_Store.SetItemInfo = KFGFxTraderContainer_StoreOriginal.SetItemInfo;
        KFGFxMenu_Trader.RefreshShopItemList = KFGFxMenu_TraderOriginal.RefreshShopItemList;
        KFGFxMenu_Trader.SetTraderItemDetails = KFGFxMenu_TraderOriginal.SetTraderItemDetails;
        KFGFxMenu_Trader.Callback_FavoriteItem = KFGFxMenu_TraderOriginal.Callback_FavoriteItem;
        KFGFxMenu_Trader.Callback_BuyOrSellItem = KFGFxMenu_TraderOriginal.Callback_BuyOrSellItem;
        KFGFxTraderContainer_ItemDetails.SetPlayerItemDetails = KFGFxTraderContainer_ItemDetailsOriginal.SetPlayerItemDetails;
        KFGFxTraderContainer_ItemDetails.SetGenericItemDetails = KFGFxTraderContainer_ItemDetailsOriginal.SetGenericItemDetails;
        KFGFxTraderContainer_ItemDetails.SetDetailsText = KFGFxTraderContainer_ItemDetailsOriginal.SetDetailsText;
        KFGFxMissionObjectivesContainer.ShowShouldSpecialEvent = KFGFxMissionObjectivesContainerOriginal.ShowShouldSpecialEvent;

        KFOnlineStatsWrite.SeasonalEventStats_OnMapObjectiveDeactivated = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnMapObjectiveDeactivated;
        KFOnlineStatsWrite.SeasonalEventStats_OnMapCollectibleFound = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnMapCollectibleFound;
        KFOnlineStatsWrite.SeasonalEventStats_OnHitTaken = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnHitTaken;
        KFOnlineStatsWrite.SeasonalEventStats_OnHitGiven = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnHitGiven;
        KFOnlineStatsWrite.SeasonalEventStats_OnZedKilled = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnZedKilled;
        KFOnlineStatsWrite.SeasonalEventStats_OnZedKilledByHeadshot = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnZedKilledByHeadshot;
        KFOnlineStatsWrite.SeasonalEventStats_OnBossDied = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnBossDied;
        KFOnlineStatsWrite.SeasonalEventStats_OnTriggerUsed = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnTriggerUsed;
        KFOnlineStatsWrite.SeasonalEventStats_OnTryCompleteObjective = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnTryCompleteObjective;
        KFOnlineStatsWrite.SeasonalEventStats_OnWeaponPurchased = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnWeaponPurchased;
        KFOnlineStatsWrite.SeasonalEventStats_OnAfflictionCaused = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnAfflictionCaused;

        KFGFxMoviePlayer_Manager.OnCleanup = KFGFxMoviePlayer_ManagerOriginal.OnCleanup;

        ForceSeasonalEvent(SET_None);
    }
    
    if( WorldInfo.NetMode == NM_StandAlone )
    {
        if( `GetChatRep() != None && `GetChatRep().SeasonalObjectiveStats != None )
            `GetChatRep().SeasonalObjectiveStats.SaveObjectiveData();
    }
     
    default.bFunctionsRestored = true;
}

function ForceUpdateWeeklyIndex(int WeeklyIndex)
{
    local KFPlayerController KFPC;
    local KFGameEngine KFEngine;
    
    KFEngine = KFGameEngine(class'Engine'.static.GetEngine());
    if( OldWeeklyEventIndex == INDEX_NONE )
        OldWeeklyEventIndex = KFEngine.default.WeeklyEventIndex;
        
    KFEngine.default.WeeklyEventIndex = WeeklyIndex == -1 ? OldWeeklyEventIndex : WeeklyIndex;
    KFEngine.WeeklyEventIndex = KFEngine.default.WeeklyEventIndex;
    
    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        KFPC = KFPlayerController(WorldInfo.GetALocalPlayerController());
        if( KFPC == None )
            return;

        if( KFPC.MyGFxManager != None && KFPC.MyGFxManager.GearMenu != None )
            KFPC.MyGFxManager.GearMenu.ForceWeeklyCowboyHat();
        if( KFEngine.default.WeeklyEventIndex > 0 && KFPC.StatsWrite != None && KFPC.StatsWrite.CanCacheWeeklyEvent() )
            KFPC.StatsWrite.UpdateWeeklyEventState();
    }
}

function bool IsReadSuccessful(KFPlayerController PC)
{
	if( PC != None && PC.StatsWrite != None )
		return PC.StatsWrite.bReadSuccessful;
	return false;
}

final function OnGameWon(KFPlayerController PC, string MapName, byte Difficulty, byte GameLength, byte bCoop, class<KFPerk> PerkClass)
{
    if( PC.StatsWrite.SeasonalEvent != None )
        PC.StatsWrite.SeasonalEvent.OnGameWon(WorldInfo.GRI.GameClass, Difficulty, GameLength, bool(bCoop));
}

final function OnGameEnd(KFPlayerController PC, string MapName, byte Difficulty, byte GameLength, byte EndingWaveNum, byte bCoop, class<KFPerk> PerkClass)
{
    if( PC.StatsWrite.SeasonalEvent != None )
        PC.StatsWrite.SeasonalEvent.OnGameEnd(WorldInfo.GRI.GameClass);
}

final function OnWaveComplete(KFPlayerController PC, int CurrentWave)
{
    if( PC.StatsWrite.SeasonalEvent != None )
        PC.StatsWrite.SeasonalEvent.OnWaveCompleted(WorldInfo.GRI.GameClass, KFGameReplicationInfo(WorldInfo.GRI).GameDifficulty, CurrentWave);
}

final function OnAllMapCollectiblesFound(KFPlayerController PC)
{
    if( UKFPSeasonalEventStats(PC.StatsWrite.SeasonalEvent) != None )
        UKFPSeasonalEventStats(PC.StatsWrite.SeasonalEvent).OnAllMapCollectiblesFound();
}

function OnSeasonalDataLoaded(KFPlayerController PC, ReplicationHelper CRI)
{
    if( PC.StatsWrite != None && UKFPSeasonalEventStats(PC.StatsWrite.SeasonalEvent) != None )
        UKFPSeasonalEventStats(PC.StatsWrite.SeasonalEvent).OnDataLoaded();
}

final function WaitForEngine()
{
    if( class'Engine'.static.GetEngine() != None )
    {
        ForceSeasonalEvent(`GetURI().CurrentForcedSeasonalEventDate);
        `GetURI().ClearTimer('WaitForEngine', self);
    }
}

function ForceSeasonalEvent(ESeasonalEventType Type)
{
    local KFGameEngine KFEngine;
    local KFPlayerController PC;
    
    KFEngine = KFGameEngine(class'Engine'.static.GetEngine());
    if( KFEngine == None )
    {
        `GetURI().SetTimer(0.01f, true, 'WaitForEngine', self);
        return;
    }

    if( Type == SET_None )
    {
        PC = KFPlayerController(WorldInfo.GetALocalPlayerController());
        if( PC != None && PC.StatsWrite != None )
            PC.StatsWrite.SeasonalEvent = None;
        
        KFEngine.default.SeasonalEventId = `GetURI().InitialSeasonalEventDate;
        KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;

        KFOnlineStatsWrite.SeasonalEventStats_OnMapObjectiveDeactivated = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnMapObjectiveDeactivated;
        KFOnlineStatsWrite.SeasonalEventStats_OnMapCollectibleFound = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnMapCollectibleFound;
        KFOnlineStatsWrite.SeasonalEventStats_OnHitTaken = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnHitTaken;
        KFOnlineStatsWrite.SeasonalEventStats_OnHitGiven = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnHitGiven;
        KFOnlineStatsWrite.SeasonalEventStats_OnZedKilled = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnZedKilled;
        KFOnlineStatsWrite.SeasonalEventStats_OnZedKilledByHeadshot = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnZedKilledByHeadshot;
        KFOnlineStatsWrite.SeasonalEventStats_OnBossDied = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnBossDied;
        KFOnlineStatsWrite.SeasonalEventStats_OnTriggerUsed = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnTriggerUsed;
        KFOnlineStatsWrite.SeasonalEventStats_OnTryCompleteObjective = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnTryCompleteObjective;
        KFOnlineStatsWrite.SeasonalEventStats_OnWeaponPurchased = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnWeaponPurchased;
        KFOnlineStatsWrite.SeasonalEventStats_OnAfflictionCaused = KFOnlineStatsWriteOriginal.SeasonalEventStats_OnAfflictionCaused;
        
        return;
    }
    
    KFOnlineStatsWrite.SeasonalEventStats_OnMapObjectiveDeactivated = KFOnlineStatsWriteProxy.SeasonalEventStats_OnMapObjectiveDeactivated;
    KFOnlineStatsWrite.SeasonalEventStats_OnMapCollectibleFound = KFOnlineStatsWriteProxy.SeasonalEventStats_OnMapCollectibleFound;
    KFOnlineStatsWrite.SeasonalEventStats_OnHitTaken = KFOnlineStatsWriteProxy.SeasonalEventStats_OnHitTaken;
    KFOnlineStatsWrite.SeasonalEventStats_OnHitGiven = KFOnlineStatsWriteProxy.SeasonalEventStats_OnHitGiven;
    KFOnlineStatsWrite.SeasonalEventStats_OnZedKilled = KFOnlineStatsWriteProxy.SeasonalEventStats_OnZedKilled;
    KFOnlineStatsWrite.SeasonalEventStats_OnZedKilledByHeadshot = KFOnlineStatsWriteProxy.SeasonalEventStats_OnZedKilledByHeadshot;
    KFOnlineStatsWrite.SeasonalEventStats_OnBossDied = KFOnlineStatsWriteProxy.SeasonalEventStats_OnBossDied;
    KFOnlineStatsWrite.SeasonalEventStats_OnTriggerUsed = KFOnlineStatsWriteProxy.SeasonalEventStats_OnTriggerUsed;
    KFOnlineStatsWrite.SeasonalEventStats_OnTryCompleteObjective = KFOnlineStatsWriteProxy.SeasonalEventStats_OnTryCompleteObjective;
    KFOnlineStatsWrite.SeasonalEventStats_OnWeaponPurchased = KFOnlineStatsWriteProxy.SeasonalEventStats_OnWeaponPurchased;
    KFOnlineStatsWrite.SeasonalEventStats_OnAfflictionCaused = KFOnlineStatsWriteProxy.SeasonalEventStats_OnAfflictionCaused;
    
    switch( Type )
    {
        case SET_Xmas2018:
        case SET_Xmas2019:
        case SET_Xmas2020:
        case SET_Xmas2021:
        case SET_Xmas2022:
            KFEngine.default.SeasonalEventId = int(SEI_Winter);
            KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
            break;
        case SET_Spring2019:
        case SET_Spring2020:
        case SET_Spring2021:
            KFEngine.default.SeasonalEventId = int(SEI_Spring);
            KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
            break;
        case SET_Summer2019:
        case SET_Summer2020:
        case SET_Summer2021:
        case SET_Summer2022:
        case SET_Summer2023:
            KFEngine.default.SeasonalEventId = int(SEI_Summer);
            KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
            break;
        case SET_Fall2018:
        case SET_Fall2019:
        case SET_Fall2020:
        case SET_Fall2021:
        case SET_Fall2022:
        case SET_Fall2023:
            KFEngine.default.SeasonalEventId = int(SEI_Fall);
            KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
            break;
    }
    
    `GetURI().SetTimer(0.25f, true, 'CheckSeasonalUpdate', self);
}

final function CheckSeasonalUpdate()
{
    local KFGameEngine KFEngine;
    
    KFEngine = KFGameEngine(class'Engine'.static.GetEngine());
    if( KFEngine.default.SeasonalEventId <= SEI_None )
    {
        switch( `GetURI().CurrentForcedSeasonalEventDate )
        {
            case SET_Xmas2018:
            case SET_Xmas2019:
            case SET_Xmas2020:
            case SET_Xmas2021:
            case SET_Xmas2022:
                KFEngine.default.SeasonalEventId = int(SEI_Winter);
                KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
                break;
            case SET_Spring2019:
            case SET_Spring2020:
            case SET_Spring2021:
                KFEngine.default.SeasonalEventId = int(SEI_Spring);
                KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
                break;
            case SET_Summer2019:
            case SET_Summer2020:
            case SET_Summer2021:
            case SET_Summer2022:
            case SET_Summer2023:
                KFEngine.default.SeasonalEventId = int(SEI_Summer);
                KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
                break;
            case SET_Fall2018:
            case SET_Fall2019:
            case SET_Fall2020:
            case SET_Fall2021:
            case SET_Fall2022:
            case SET_Fall2023:
                KFEngine.default.SeasonalEventId = int(SEI_Fall);
                KFEngine.default.LoadedSeasonalEventId = KFEngine.default.SeasonalEventId;
                break;
        }
    }
}

function CheckSpecialEventID(KFPlayerController PC)
{
    local int Year, Month;
    
    if( `GetURI().CurrentForcedSeasonalEventDate != SET_None )
    {
        `GetURI().GetYearAndMonthFromEvent(Year, Month);
        UpdateSpecialEventState(PC, Year, Month);
    }
    else 
    {
        PC.StatsWrite.UpdateSpecialEventState();
        
        `GetChatRep().bForceObjectiveRefresh = true;
        if( PC.MyGFxManager != None && PC.MyGFxManager.StartMenu != None && PC.MyGFxManager.StartMenu.MissionObjectiveContainer != None )
        {
            PC.MyGFxManager.StartMenu.MissionObjectiveContainer.UpdateSpecialEventActive();
            PC.MyGFxManager.StartMenu.MissionObjectiveContainer.FullRefresh();
        }
    }
}

final function UpdateSpecialEventState(KFPlayerController PC, int Year, int Month)
{
    local UKFPSeasonalEventStats FSE;
    
    switch( Year )
    {
        case 2018:
            switch( Month )
            {
                case 12:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Xmas2018';
                    break;
                case 10:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Fall2018';
                    break;
            }
            break;
        case 2019:
            switch( Month )
            {
                case 12:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Xmas2019';
                    break;
                case 3:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Spring2019';
                    break;
                case 7:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Summer2019';
                    break;
                case 10:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Fall2019';
                    break;
            }
            break;
        case 2020:
            switch( Month )
            {
                case 12:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Xmas2020';
                    break;
                case 3:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Spring2020';
                    break;
                case 7:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Summer2020';
                    break;
                case 10:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Fall2020';
                    break;
            }
            break;
        case 2021:
            switch( Month )
            {
                case 12:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Xmas2021';
                    break;
                case 3:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Spring2021';
                    break;
                case 7:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Summer2021';
                    break;
                case 10:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Fall2021';
                    break;
            }
            break;
        case 2022:
            switch( Month )
            {
                case 7:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Summer2022';
                    break;
                case 10:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Fall2022';
                    break;
                case 12:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Xmas2022';
                    break;
            }
            break;
        case 2023:
            switch( Month )
            {
                case 7:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Summer2023';
                    break;
                case 10:
                    PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Fall2023';
                    break;
                case 12:
                    //PC.StatsWrite.SeasonalEvent = new(PC.StatsWrite) class'UKFPSeasonalEventStats_Xmas2022';
                    break;
            }
            break;
    }

    FSE = UKFPSeasonalEventStats(PC.StatsWrite.SeasonalEvent);
    if( FSE != None )
    {
        FSE.CRI = `GetChatRep();
        FSE.Init(`GetURI().CurrentMapName != "" ? `GetURI().CurrentMapName : WorldInfo.GetMapName(true));
        
        FSE.CRI.bForceObjectiveRefresh = true;
        if( PC.MyGFxManager != None && PC.MyGFxManager.StartMenu != None && PC.MyGFxManager.StartMenu.MissionObjectiveContainer != None )
        {
            PC.MyGFxManager.StartMenu.MissionObjectiveContainer.UpdateSpecialEventActive();
            PC.MyGFxManager.StartMenu.MissionObjectiveContainer.FullRefresh();
        }
    }
}

function int GetSeasonalEventID(KFGameEngine Engine)
{
    return Engine.default.SeasonalEventId;
}

defaultproperties
{
}