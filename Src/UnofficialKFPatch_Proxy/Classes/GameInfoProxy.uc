class GameInfoProxy extends Object;

stripped function context(GameInfo.GenericPlayerInitialization) GenericPlayerInitialization(Controller C)
{
	local PlayerController PC;

	PC = PlayerController(C);
	if (PC != None)
	{
		UpdateBestNextHosts();
		UpdateGameplayMuteList(PC);

		PC.ClientSetHUD(HudType);
		PC.ClientSetSecondaryHUD(SecondaryHudType);

		ReplicateStreamingStatus(PC);

		if( CoverReplicatorBase != None )
			PC.SpawnCoverReplicator();

		PC.ClientSetOnlineStatus();
	}

	if( BaseMutator != None )
		BaseMutator.NotifyLogin(C);
    if( `GetURI() != None )
        `GetURI().NotifyLogin(C);
}

stripped function context(GameInfo.Logout) Logout( Controller Exiting )
{
	local PlayerController PC;
	local int PCIndex;

	PC = PlayerController(Exiting);
	if( PC != None )
	{
		if( AccessControl != None && AccessControl.AdminLogout(PlayerController(Exiting)) )
			AccessControl.AdminExited( PlayerController(Exiting) );

		if ( PC.PlayerReplicationInfo.bOnlySpectator )
			NumSpectators--;
		else
		{
			if (WorldInfo.IsInSeamlessTravel() || PC.HasClientLoadedCurrentWorld())
				NumPlayers--;
			else NumTravellingPlayers--;
            
			if (WorldInfo.IsEOSDedicatedServer() && PC.bIsEosPlayer)
				NumEosPlayers--;
                
			UpdateGameSettingsCounts();
		}

		if( bUsingArbitration && bHasArbitratedHandshakeBegun && !bHasEndGameHandshakeBegun )
			`Log("Player "$PC.PlayerReplicationInfo.PlayerName$" has dropped");

		UnregisterPlayer(PC);

		if( bUsingArbitration )
		{
			PCIndex = ArbitrationPCs.Find(PC);
			if( PCIndex != INDEX_NONE )
				ArbitrationPCs.Remove(PCIndex,1);
		}
	}

	if( BaseMutator != None )
		BaseMutator.NotifyLogout(Exiting);
    if( `GetURI() != None )
        `GetURI().NotifyLogout(Exiting);
        
	if( PC != None )
		UpdateNetSpeeds();
}

stripped function context(GameInfo.NotifyKilled) NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	local Controller C;

    if( `GetURI() != None )
        `GetURI().ScoreKill(Killer, Killed, KilledPawn, damageType);

	foreach WorldInfo.AllControllers(class'Controller', C)
		C.NotifyKilled(Killer, Killed, KilledPawn, damageType);
}

stripped function context(GameInfo.PickupQuery) bool PickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup)
{
	local byte bAllowPickup;
    
	if( `GetURI() != None && `GetURI().OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup) )
		return bool(bAllowPickup);

	if( BaseMutator != None && BaseMutator.OverridePickupQuery(Other, ItemClass, Pickup, bAllowPickup) )
		return bool(bAllowPickup);

	if( Other.InvManager == None )
		return false;
	else return Other.InvManager.HandlePickupQuery(ItemClass, Pickup);
}

stripped function context(GameInfo.ProcessServerTravel) ProcessServerTravel(string URL, optional bool bAbsolute)
{
	local PlayerController LocalPlayer;
	local bool bSeamless;
	local string NextMap, EncodedPlayerName;
	local Guid NextMapGuid;
	local int OptionStart;
    
	bLevelChange = true;
	EndLogging("mapchange");

	bSeamless = (bUseSeamlessTravel && WorldInfo.TimeSeconds < 172800.0f); // 172800 seconds == 48 hours

	if (InStr(Caps(URL), "?RESTART") != INDEX_NONE)
	{
		NextMap = string(WorldInfo.GetPackageName());
	}
	else
	{
		OptionStart = InStr(URL, "?");
		if (OptionStart == INDEX_NONE)
		{
			NextMap = URL;
		}
		else
		{
			NextMap = Left(URL, OptionStart);
		}
	}
    
	NextMap = CheckNextMap(NextMap);
	if (OptionStart == INDEX_NONE)
	{
		URL = NextMap;
	}
	else
	{
		URL = NextMap $ Right(URL, Len(URL)-OptionStart);
	}

	NextMapGuid = GetPackageGuid(name(NextMap));

	LocalPlayer = ProcessClientTravel(NextMap, NextMapGuid, bSeamless, bAbsolute);

	`Log(URL,,'ProcessServerTravel');
    
	WorldInfo.NextURL = URL;
    
	if( WorldInfo.NetMode == NM_ListenServer && LocalPlayer != None )
	{
		// is this necessary or can we assume the DefaultURL name is valid?
		EncodedPlayerName = LocalPlayer.GetDefaultURL("Name");
		class'GameEngine'.static.EncodeURLString(EncodedPlayerName);

		WorldInfo.NextURL $= "?Team="$LocalPlayer.GetDefaultURL("Team")
							$"?Name="$EncodedPlayerName
							$"?Class="$LocalPlayer.GetDefaultURL("Class")
							$"?Character="$LocalPlayer.GetDefaultURL("Character");
	}

	if( AccessControl != None )
		AccessControl.NotifyServerTravel(bSeamless);

	ClearOnlineDelegates();

	if( bSeamless )
	{
		WorldInfo.SeamlessTravel(WorldInfo.NextURL, bAbsolute);
		WorldInfo.NextURL = "";
	}
	else if( WorldInfo.NetMode != NM_DedicatedServer && WorldInfo.NetMode != NM_ListenServer )
	{
		WorldInfo.NextSwitchCountdown = 0.0;
	}
}

stripped event context(GameInfo.PreLogin) PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string ErrorMessage)
{
	local bool bSpectator;
	local bool bPerfTesting;

	if( WorldInfo.NetMode != NM_Standalone && bUsingArbitration && bHasArbitratedHandshakeBegun )
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".ArbitrationMessage";
		return;
	}

	if( AccessControl != None && AccessControl.IsIDBanned(UniqueId) )
	{
		`Log(Address@"is banned, rejecting...");
		ErrorMessage = "Engine.AccessControl.SessionBanned";
		return;
	}


	bPerfTesting = ( ParseOption( Options, "AutomatedPerfTesting" ) ~= "1" );
	bSpectator = bPerfTesting || ( ParseOption( Options, "SpectatorOnly" ) ~= "1" ) || ( ParseOption( Options, "CauseEvent" ) ~= "FlyThrough" );

	if( AccessControl != None )
		AccessControl.PreLogin(Options, Address, UniqueId, bSupportsAuth, ErrorMessage, bSpectator);
    if( `GetURI() != None )
        `GetURI().PreLogin(Options, Address, UniqueId, bSupportsAuth, ErrorMessage, bSpectator);
}

stripped function context(GameInfo.Killed) Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
    if( KilledPlayer != None && KilledPlayer.bIsPlayer )
	{
		KilledPlayer.PlayerReplicationInfo.IncrementDeaths();
		KilledPlayer.PlayerReplicationInfo.SetNetUpdateTime(FMin(KilledPlayer.PlayerReplicationInfo.NetUpdateTime, WorldInfo.TimeSeconds + 0.3 * FRand()));
		BroadcastDeathMessage(Killer, KilledPlayer, damageType);
	}

    if( KilledPlayer != None )
		ScoreKill(Killer, KilledPlayer);

	DiscardInventory(KilledPawn, Killer);
    NotifyKilled(Killer, KilledPlayer, KilledPawn, damageType);
    
    if( KFPawn_Human(KilledPawn) != None )
        `GetURI().NotifyPlayerDied(KFPawn_Human(KilledPawn), KFPlayerController(KilledPlayer), Killer, damageType);
}

stripped function context(GameInfo.ReduceDamage) ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo)
{
	local int OriginalDamage;

	OriginalDamage = Damage;

	if( Injured.PhysicsVolume.bNeutralZone || Injured.InGodMode() )
	{
		Damage = 0;
		return;
	}

	if( BaseMutator != None )
		BaseMutator.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
    if( KFPawn_Monster(Injured) != None )
        `GetURI().OnZEDTakeDamage(KFPawn_Monster(Injured), Damage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);
}