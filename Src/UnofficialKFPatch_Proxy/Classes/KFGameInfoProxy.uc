class KFGameInfoProxy extends Object;

stripped function context(KFGameInfo.ReplicateWelcomeScreen) ReplicateWelcomeScreen()
{
	local WorldInfo WI;

	WI = class'WorldInfo'.static.GetWorldInfo();

	if( WI.NetMode != NM_DedicatedServer )
		return;

	if(MyKFGRI != none)
	{
		MyKFGRI.ServerAdInfo.BannerLink = BannerLink;
		MyKFGRI.ServerAdInfo.WebsiteLink = WebsiteLink;
		MyKFGRI.ServerAdInfo.ClanMotto = ClanMotto;
	}
}

stripped event context(KFGameInfo.PreLogin) PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string ErrorMessage)
{
	local bool bSpectator;
	local bool bPerfTesting;
	local string DesiredDifficulty, DesiredWaveLength, DesiredGameMode;
    
	if( ParseOption(Options, "Name") != "" )
		`Log("Player"@ParseOption(Options, "Name")@"("$`ConvertUIDToSteamID(UniqueId)$") is connecting to the server. ["$Address$"]",, 'Join Log');
    else 
	{
		RejectLogin(PauseLogin(), "Invalid Connection!");
		ErrorMessage = "Invalid Connection!";
		`Log("Player"@Address@"("$`ConvertUIDToSteamID(UniqueId)$") is connecting to the server",, 'Join Log');
	}

	if( WorldInfo.NetMode != NM_Standalone && bUsingArbitration && bHasArbitratedHandshakeBegun )
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".ArbitrationMessage";
		return;
	}

	if( AccessControl != None && AccessControl.IsIDBanned(UniqueId) )
	{
		`Log(Address@"is banned, rejecting...");
		ErrorMessage = "<Strings:KFGame.KFLocalMessage.BannedFromServerString>";
		return;
	}

	if( WorldInfo.NetMode == NM_DedicatedServer && !HasOption( Options, "bJoinViaInvite" ) )
	{
		DesiredDifficulty = ParseOption( Options, "Difficulty" );
		if( !bIsVersusGame && GametypeChecksDifficulty() && DesiredDifficulty != "" && int(DesiredDifficulty) != GameDifficulty )
		{
			`Log("Got bad difficulty"@DesiredDifficulty@"expected"@GameDifficulty);
			ErrorMessage = "Server No longer available. Mismatch difficulty.";
			return;
		}

		DesiredWaveLength = ParseOption( Options, "GameLength" );

		if( !bIsEndlessGame && !bIsVersusGame && GametypeChecksWaveLength() && DesiredWaveLength != "" && int(DesiredWaveLength) != GameLength && int(DesiredWaveLength) != 127 && int(DesiredWaveLength) != INDEX_NONE )
		{
			`Log("Got bad wave length"@DesiredWaveLength@"expected"@GameLength);
			ErrorMessage = "Server No longer available. Mismatch GameLength.";
			return;
		}

		DesiredGameMode = ParseOption( Options, "Game" );
		if( DesiredGameMode != "" && !(DesiredGameMode ~= GetFullGameModePath()) )
		{
			`Log("Got bad game mode"@DesiredGameMode@"expected"@GetFullGameModePath());
			ErrorMessage = "Server No longer available. Mismatch DesiredGameMode.";
			return;
		}
	}

	bPerfTesting = (ParseOption( Options, "AutomatedPerfTesting" ) ~= "1");
	bSpectator = bPerfTesting || (ParseOption( Options, "SpectatorOnly") ~= "1" ) || (ParseOption( Options, "CauseEvent" ) ~= "FlyThrough");

	if( AccessControl != None )
		AccessControl.PreLogin(Options, Address, UniqueId, bSupportsAuth, ErrorMessage, bSpectator);
        
    if( ErrorMessage != "" )
        `Broadcast("<font color=\"#438DFF\" face=\"MIcon\">"$`GetMIconChar("account")@"</font><font color=\"#"$class'KFLocalMessage'.default.EventColor$"\">"$ParseOption(Options, "Name")@"is connecting");
}

stripped function context(KFGameInfo.ModifyAIDoshValueForPlayerCount) ModifyAIDoshValueForPlayerCount( out float ModifiedValue )
{
	local float DoshMod;

    DoshMod = `GetURI().GetEffectivePlayerCount(GetNumPlayers()) / DifficultyInfo.GetPlayerNumMaxAIModifier(GetNumPlayers());
	ModifiedValue *= DoshMod;
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
        GIC = class<KFGameInfo>(`SafeLoadObject(default.GameModes[i].ClassNameAndPath, Class'Class'));
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

stripped static function context(KFGameInfo.PreloadGlobalContentClasses) PreloadGlobalContentClasses()
{
	return;
}

stripped function context(KFGameInfo.UpdateGameSettings) UpdateGameSettings()
{
	local name SessionName;
	local KFOnlineGameSettings KFGameSettings;

	Super.UpdateGameSettings();

	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer )
	{
		if( GameInterface != None )
		{
			SessionName = PlayerReplicationInfoClass.default.SessionName;
			if( PlayfabInter != None && PlayfabInter.GetGameSettings() != None )
				KFGameSettings = KFOnlineGameSettings(PlayfabInter.GetGameSettings());
			else KFGameSettings = KFOnlineGameSettings(GameInterface.GetGameSettings(SessionName));				

			if( KFGameSettings != None )
				KFGameSettings.bNoSeasonalSkins = AllowSeasonalSkinsIndex == 1 || `GetURI().bNoEventSkins || `GetURI().GetEnforceVanilla();
		}
	}
}