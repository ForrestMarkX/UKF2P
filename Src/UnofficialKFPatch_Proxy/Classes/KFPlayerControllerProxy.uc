class KFPlayerControllerProxy extends Object;

stripped reliable client function context(KFPlayerController.ClientTriggerWeaponContentLoad) ClientTriggerWeaponContentLoad(class<KFWeapon> WeaponClass) 
{ 
	if( WeaponClass != None ) 
		class'UKFPReplicationInfo'.static.StaticLoadWeaponAssets(WeaponClass); 
} 

stripped event context(KFPlayerController.PreClientTravel) PreClientTravel( string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel )
{
	ResetMusicStateForTravel();

	Super.PreClientTravel(PendingURL, TravelType, bIsSeamlessTravel);

	if( TravelType == TRAVEL_Relative && !bIsSeamlessTravel )
		ShowPreClientTravelMovie(PendingURL);

	DestroyOnlineGame();
    
    if( WorldInfo.NetMode != NM_DedicatedServer && `GetURI() != None )
        `GetURI().PreClientTravel(self, PendingURL, TravelType, bIsSeamlessTravel);
}

stripped function context(KFPlayerController.EnterZedTime) EnterZedTime()
{
	local KFPawn KFP;
	local KFPerk MyPerk;
	local bool bPartialZedTime;

	MyPerk = GetPerk();
	if( MyPerk != None )
		MyPerk.NotifyZedTimeStarted();

	KFP = KFPawn(Pawn);
	if( KFP != None )
	{
		KFP.bUnaffectedByZedTime = !IsAffectedByZedTime();
		bPartialZedTime = KFP.bUnaffectedByZedTime;

		if( bPartialZedTime )
			StartPartialZedTimeSightCounter();
	}

    ApplyZedTimeStatus();
	ClientEnterZedTime(bPartialZedTime);
}

stripped function context(KFPlayerController.CompleteZedTime) CompleteZedTime()
{
    ClientCompleteZedTime();
    UpdateZedTimeStatus();
}

stripped final function context(KFPlayerController) UpdateZedTimeStatus()
{
    local ReplicationHelper CRI;
    
    CRI = `GetURI().GetPlayerChat(PlayerReplicationInfo);
    if( CRI == None )
        return;
    CRI.ZedTimeExtensionsUsed = 0;
}

stripped final function context(KFPlayerController) ApplyZedTimeStatus()
{
    local ReplicationHelper CRI;
    local KFGameInfo_Survival KFGI;
    
    CRI = `GetURI().GetPlayerChat(PlayerReplicationInfo);
    if( CRI == None )
        return;
    KFGI = KFGameInfo_Survival(WorldInfo.Game);
    CRI.ApplyZedTimeStatus(CRI.ZedTimeExtensionsUsed++, KFGI.ZedTimeRemaining);
}

stripped function context(KFPlayerController.RecieveChatMessage) RecieveChatMessage(PlayerReplicationInfo PRI, string ChatMessage, name Type, optional float MsgLifeTime)
{
	if( MyGFxHUD.HudChatBox != None )
	{
		if( PRI.bAdmin )
		{
            if( PRI.PlayerName ~= "Admin" )
                ChatMessage = ChatMessage;
            else ChatMessage = class'KFLocalMessage'.default.AdminString@ChatMessage;
            
			MyGFxHUD.HudChatBox.AddChatMessage(ChatMessage, class'KFLocalMessage'.default.PriorityColor);
		}
		else MyGFxHUD.HudChatBox.AddChatMessage(ChatMessage, class'KFLocalMessage'.default.SayColor);
	}
}

stripped final simulated function context(KFPlayerController) string GetNameHexColor(PlayerReplicationInfo PRI, optional name Type)
{
    if( PRI.bOnlySpectator )
        return "FFFF00";
    else if( PRI.GetTeamNum() == 0 )
        return "00BFFF";
    else if( PRI.GetTeamNum() == 255 )
        return "C80000";
    return class'KFLocalMessage'.default.SayColor;
}

stripped simulated final function context(KFPlayerController) TeamMessageEx( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime )
{
    local string Msg,ChatChan,DeadString,IconString,PlayerIcon,ChatMessage,PlayerName;
    local KFPlayerReplicationInfo KFPRI;
    local bool bWebAdmin;

    if( MyGFxHUD == None || MyGFxManager == None || PRI == None || (PRI.Team != None && Type == 'TeamSay' && PRI.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex) )
        return;

    if( Type == MusicMessageType )
        MyGFxHUD.MusicNotification.ShowSongInfo(S);
    
    if( Player == None )
        return;
        
    `Print( "("$Type$") "$class'ReplicationHelper'.static.StripHTMLFromString((( ( Type == 'Say' ) || ( Type == 'TeamSay' ) ) && ( PRI != None )) ? PRI.GetHumanReadableName()$": "$S : S) );
         
    if( Type == 'Event' || Type == 'None' || Type == 'Connection' )
    {
        if( Type == 'Connection' )
            IconString = "<font color=\"#438DFF\" face=\"MIcon\">"$`GetMIconChar("account")@"</font>";
        else if( Type == 'Event' )
            IconString = "<font color=\"#FFFF00\" face=\"MIcon\">"$`GetMIconChar("information")@"</font>";
        else IconString = "<font color=\"#00FF00\" face=\"MIcon\">"$`GetMIconChar("server")@"</font>";
            
        if( MyGFxHUD.HudChatBox != None )
        {
            Msg = IconString$S;
            if( MyGFxManager.PartyWidget != None && !MyGFxManager.PartyWidget.ReceiveMessage(Msg) )
                return;
            if( MyGFxManager.PostGameMenu != None )
                MyGFxManager.PostGameMenu.ReceiveMessage(Msg);
            MyGFxHUD.HudChatBox.AddChatMessage(Msg, class'KFLocalMessage'.default.EventColor);
        }
    }
    else if( Type != MusicMessageType )
    {
        KFPRI = KFPlayerReplicationInfo(PRI);
        if( KFPRI != None && KFPRI.PlayerHealthPercent <= 0 && !PRI.bOnlySpectator )
        {
            PlayerIcon = "<font color=\"#FF0000\" face=\"MIcon\">"$`GetMIconChar("skull-outline")@"</font>";
            DeadString = "<font color=\"#FF0000\">*DEAD* </font>";
        }
        
        if( PRI.bAdmin && PRI.bBot )
        {
            bWebAdmin = true;
            PlayerName = PRI.PlayerName ~= "Admin" ? "WebAdmin" : PRI.PlayerName;
        }
        else PlayerName = PRI.PlayerName;
        
        PlayerName = Repl(PlayerName, "<", "[");
        PlayerName = Repl(PlayerName, ">", "]");
        
        if( PRI.bAdmin )
            PlayerIcon $= "<font color=\"#FFFF00\" face=\"MIcon\">"$(bWebAdmin ? `GetMIconChar("server-security") : `GetMIconChar("shield-outline"))@"</font>";
        else PlayerIcon $= "<font color=\"#00BFFF\" face=\"MIcon\">"$`GetMIconChar("account")@"</font>";
        
        if( !bWebAdmin )
        {
            ChatChan = GetChatChannel(Type, PRI);
            if( ChatChan != "" )
            {
                ChatChan = Repl(ChatChan, "<", "[");
                ChatChan = Repl(ChatChan, ">", "]");
                ChatChan = "<font color=\"#"$(Type == 'TeamSay' ? class'KFLocalMessage'.default.TeamSayColor : class'KFLocalMessage'.default.SayColor)$"\">"$ChatChan@"</font>";
            }
        }
        
        ChatMessage = ChatChan$(PlayerIcon != "" ? PlayerIcon : "")$DeadString$"<font color=\"#"$GetNameHexColor(PRI, Type)$"\">"$PlayerName$"</font><font color=\"#FFFFFF\">: "$S$"</font>";
        if( class'WorldInfo'.static.IsMenuLevel() )
            ChatMessage = S;

        if( MyGFxManager.PartyWidget != None && !MyGFxManager.PartyWidget.ReceiveMessage(ChatMessage) )
            return;
        if( MyGFxManager.PostGameMenu != None )
            MyGFxManager.PostGameMenu.ReceiveMessage(ChatMessage);
        RecieveChatMessage(PRI, ChatMessage, Type, MsgLifeTime);
    }
}

stripped reliable client event context(KFPlayerController.TeamMessage) TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime )
{
    TeamMessageEx(PRI, S, Type, MsgLifeTime);
}

stripped simulated event context(KFPlayerController.GetSeasonalStateName) name GetSeasonalStateName()
{
	local int EventId;
	local KFMapInfo KFMI;
	local bool bIsWWLWeekly;
	local KFGameReplicationInfo KFGRI;
    
    if( `GetURI().bNoEventSkins )
        return 'No_Event';
	
	EventId = class'KFGameEngine'.static.GetSeasonalEventID();
	KFMI = KFMapInfo(WorldInfo.GetMapInfo());
	if( KFMI != None )
		KFMI.ModifySeasonalEventId(EventId);

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	bIsWWLWeekly = KFGRI != none && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 12;
	if( bIsWWLWeekly )
		return 'No_Event'; 
        
	switch( EventId % 10 )
	{
		case SEI_Summer:
			return 'Summer_Sideshow';
		case SEI_Fall:
			return 'Fall';
		case SEI_Winter:
			return 'Winter';
		case SEI_Spring:
			return 'Spring';
		default:
			return 'No_Event';
	}

    return 'No_Event';
}

stripped reliable client event context(KFPlayerController.ReceiveLocalizedMessage) ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local string TempMessage;

	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.GRI == None )
		return;
        
	if( class<KFLocalMessage_Game>(Message) != None && MyGFxHUD != none )
	{
		TempMessage = class<KFLocalMessage_Game>(Message).static.GetString(switch, true, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		if( TempMessage != "" )
		{
			MyGFxHUD.ShowNonCriticalMessage(TempMessage);
			if( Switch == KMT_Killed || Switch == KMT_Suicide )
			{
				if( Switch == KMT_Suicide )
				{
					if( RelatedPRI_2.GetTeamNum() == 255 && RelatedPRI_2.UniqueID == PlayerReplicationInfo.UniqueID )
						class'KFMusicStingerHelper'.static.PlayZedPlayerSuicideStinger( self );

					if( RelatedPRI_2.GetTeamNum() == class'KFTeamInfo_Human'.default.TeamIndex && RelatedPRI_2.GetTeamNum() == PlayerReplicationInfo.GetTeamNum() )
					{
						if( RelatedPRI_2.UniqueID == PlayerReplicationInfo.UniqueID )
							ReceiveLocalizedMessage( class'KFLocalMessage_Priority', GMT_Died, RelatedPRI_1, RelatedPRI_2, OptionalObject );
						else class'KFMusicStingerHelper'.static.PlayTeammateDeathStinger( self );
					}
				}
				else if( Switch == KMT_Killed )
				{
					if( RelatedPRI_2.GetTeamNum() == class'KFTeamInfo_Human'.default.TeamIndex && RelatedPRI_2.GetTeamNum() == PlayerReplicationInfo.GetTeamNum() )
					{
						if( RelatedPRI_2.UniqueID == PlayerReplicationInfo.UniqueID )
							ReceiveLocalizedMessage( class'KFLocalMessage_Priority', GMT_Died, RelatedPRI_1, RelatedPRI_2, OptionalObject );
						else class'KFMusicStingerHelper'.static.PlayTeammateDeathStinger( self );
					}
				}

				MyGFxHUD.ShowKillMessage( RelatedPRI_1, RelatedPRI_2, true, OptionalObject );
			}
		}

		if( Switch == GMT_ReceivedAmmoFrom || Switch == GMT_ReceivedGrenadesFrom )
			PlayAKEvent( class'KFPerk_Support'.static.GetReceivedAmmoSound() );
		else if( Switch == GMT_ReceivedArmorFrom )
			PlayAKEvent( class'KFPerk_Support'.static.GetReceivedArmorSound() );
		else if( Switch == GMT_ReceivedAmmoAndArmorFrom )
			PlayAKEvent( class'KFPerk_Support'.static.GetReceivedAmmoAndArmorSound() );
	}
	else if( class<KFLocalMessage_PlayerKills>(Message) != None && MyGFxHUD != None )
	{
		if( Switch == KMT_PlayerKillPlayer || (bShowKillTicker && Switch == KMT_PLayerKillZed) )
		{
			if( Switch == KMT_PlayerKillPlayer )
			{
				if( RelatedPRI_2.GetTeamNum() == class'KFTeamInfo_Human'.default.TeamIndex )
				{
					if( RelatedPRI_1.GetTeamNum() == 255 )
						class'KFMusicStingerHelper'.static.PlayZedKillHumanStinger( Self );
					else if( RelatedPRI_2.GetTeamNum() == PlayerReplicationInfo.GetTeamNum() )
					{
						if(RelatedPRI_2.UniqueID == PlayerReplicationInfo.UniqueID)
							class'KFMusicStingerHelper'.static.PlayPlayerDiedStinger( Self );
						else class'KFMusicStingerHelper'.static.PlayTeammateDeathStinger( Self );
					}
				}
				else if( RelatedPRI_2.UniqueID == PlayerReplicationInfo.UniqueID )
                    class'KFMusicStingerHelper'.static.PlayZedPlayerKilledStinger( Self );
			}
			MyGFxHUD.ShowKillMessage( RelatedPRI_1, RelatedPRI_2, false, OptionalObject );
		}
	}
    else if( class<KFLocalMessage_VoiceComms>(Message) != None )
    {
        KFPlayerReplicationInfo(RelatedPRI_1).SetCurrentVoiceCommsRequest(Switch);
        TeamMessage(RelatedPRI_1, class<KFLocalMessage_VoiceComms>(Message).default.VoiceCommsOptionStrings[Switch], 'Voice');
    }
	else Super.ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

stripped reliable server function context(KFPlayerController.ServerPause) ServerPause()
{
	if( WorldInfo.Game.AllowPausing(self) )
	{
		if( !IsPaused() )
		{
			SetPause(true);
            `GetURI().Broadcast("<font color=\"#FFFF44\" face=\"MIcon\">"$`GetMIconChar("pause")$"</font> <font color=\"#FFFF44\">"$PlayerReplicationInfo.GetHumanReadableName()$"</font> <font color=\"#FF4444\">paused</font> <font color=\"#FFFFFF\">the game!</font>");
		}
        else 
        {
            SetPause(false);
            `GetURI().Broadcast("<font color=\"#FFFF44\" face=\"MIcon\">"$`GetMIconChar("play")$"</font> <font color=\"#FFFF44\">"$PlayerReplicationInfo.GetHumanReadableName()$"</font> <font color=\"#44FF44\">unpaused</font> <font color=\"#FFFFFF\">the game!</font>");
        }
    }
}

stripped reliable client function context(KFPlayerController.ClientWonGame) ClientWonGame( string MapName, byte Difficulty, byte GameLength, byte bCoop )
{
	if( WorldInfo.NetMode != NM_DedicatedServer && IsLocalPlayerController() )
		StatsWrite.OnGameWon( `GetURI().CurrentMapName, Difficulty, GameLength, bCoop, GetPerk().class );
}

stripped reliable client function context(KFPlayerController.ClientGameOver) ClientGameOver(string MapName, byte Difficulty, byte GameLength, byte bCoop, byte FinalWaveNum)
{
	if( WorldInfo.NetMode != NM_DedicatedServer && IsLocalPlayerController() )
		StatsWrite.OnGameEnd(`GetURI().CurrentMapName, Difficulty, GameLength, FinalWaveNum, bCoop, GetPerk().class);
}

stripped reliable client event context(KFPlayerController.OnAllMapCollectiblesFound) OnAllMapCollectiblesFound(string MapName)
{
	MyGFxHUD.ShowNonCriticalMessage( Localize("KFMapInfo", "FoundAllCollectiblesString", "KFGame") );
	PostAkEvent( AllMapCollectiblesFoundEvent );
    CheckOverrideCollectibles(`GetURI().CurrentMapName);
	if( StatsWrite != None )
		StatsWrite.CheckCollectibleAchievement(`GetURI().CurrentMapName);
}

stripped final simulated function context(KFPlayerController) CheckOverrideCollectibles(string MapName)
{
    local int i;
    local UKFPReplicationInfo URI;
    
    URI = `GetURI();
    for( i=0; i<URI.CollectibleAchIDForMap.Length; i++ )
    {
        if( URI.CollectibleAchIDForMap[i].Map ~= MapName )
        {
            ClientUnlockAchievement(URI.CollectibleAchIDForMap[i].ID);
            break;
        }
    }
}

stripped simulated function context(KFPlayerController.SeasonalEventIsValid) bool SeasonalEventIsValid()
{
	return (`GetChatRep() != None && `GetChatRep().SeasonalObjectiveStats != None) || (StatsWrite != None && StatsWrite.SeasonalEventIsValid());
}

stripped function context(KFPlayerController.GetSeasonalEventStatInfo) GetSeasonalEventStatInfo(int StatIdx, out int CurrentValue, out int MaxValue)
{
    if( `GetChatRep() != None && `GetChatRep().SeasonalObjectiveStats != None )
    {
        CurrentValue = `GetChatRep().SeasonalObjectiveStats.GetCurrentObjectStat(StatIdx);
        MaxValue = `GetChatRep().SeasonalObjectiveStats.GetCurrentObjectMaxStat(StatIdx);
        return;
    }
    
    if( StatsWrite == None )
        return;
    
	CurrentValue = StatsWrite.GetSeasonalEventStatValue(StatIdx);
	MaxValue = StatsWrite.GetSeasonalEventStatMaxValue(StatIdx);
}