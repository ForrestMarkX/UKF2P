class KFGFxWidget_PartyInGameProxy extends Object;

stripped function context(KFGFxWidget_PartyInGame.InitializeWidget) InitializeWidget()
{
    KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
    if( UseMultiPage() )
        PlayerSlots = 12;
        
	Super.InitializeWidget();

	SetReadyButtonVisibility(true);

	ReadyButton = GetObject("readyButton");
	EndlessPauseButton = GetObject("endlessPauseButton");

	MyKFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);
	
	if( KFGRI != None )
		StartCountdown(KFGRI.RemainingTime, false);		
	RefreshParty();
	UpdateReadyButtonVisibility();
	UpdateEndlessPauseButtonVisibility();
    SetupWidgetHelper();
    RefreshCycleButton();
}

stripped final function context(KFGFxWidget_PartyInGame) bool UseMultiPage()
{
    return `GetChatRep().RepMaxPlayers > 6 && !KFGRI.bVersusGame;
}

stripped final function context(KFGFxWidget_PartyInGame) SetupWidgetHelper()
{
    local PartyWidgetHelper WH;
    
    if( !UseMultiPage() )
        return;
 
    if( class'PartyWidgetHelper'.default.StaticReference != None )
        class'PartyWidgetHelper'.default.StaticReference = None;
    
	WH = New(self) class'PartyWidgetHelper';
    WH.Init();
}

stripped final function context(KFGFxWidget_PartyInGame) RefreshCycleButton()
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
    
    if( !UseMultiPage() )
        return;

	GetKFPRIArray(KFPRIArray);
	if( KFPRIArray.Length <= 0 || PlayerSlots <= 0 )
	{
		SetString("switchTeamsString", "NULL");
		return;
	}
    
	class'PartyWidgetHelper'.default.StaticReference.LobbyMaxPage = KFPRIArray.Length / PlayerSlots + Min(1, KFPRIArray.Length % PlayerSlots);

    SetString("switchTeamsString", class'PartyWidgetHelper'.default.CycleListString @ class'PartyWidgetHelper'.default.StaticReference.LobbyCurrentPage $ "/" $ class'PartyWidgetHelper'.default.StaticReference.LobbyMaxPage);
}

stripped function context(KFGFxWidget_PartyInGame.UpdateReadyButtonVisibility) UpdateReadyButtonVisibility()
{
	if( KFGRI == None )
		return;

	if( MyKFPRI == None )
		MyKFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);

	if( bReadyButtonVisible )
	{
		KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
		if ( KFGRI != None )
		{
            if( `GetChatRep() != None && `GetChatRep().UKFPInteraction != None )
            {
                if( `GetChatRep().UKFPInteraction.bHasPacketLoss )
                    SetPacketLoss();
                else RestoreMatchContainer();
            }
            
			if( KFGRI.bMatchHasBegun
				&& (MyKFPRI != None && MyKFPRI.bHasSpawnedIn && (KFGRI.bTraderIsOpen || KFGRI.bForceSkipTraderUI))
				&& !KFGRI.bMatchIsOver && MyKFPRI.GetTeamNum() != 255 )
			{
				bShowingSkipTrader = !MyKFPRI.bVotedToSkipTraderTime;
				if( bShowingSkipTrader && !ReadyButton.GetBool("visible") )
				{
					UpdateReadyButtonText();
					SetReadyButtonVisibility(true, false);
					ReadyButton.SetBool("selected", false);
				}
			}
			else
			{
				bShowingSkipTrader = false;
				UpdateReadyButtonText();
				
				if( KFGRI.bMatchHasBegun && !KFGRI.bMatchIsOver && MyKFPRI != None && !MyKFPRI.bReadyToPlay && !MyKFPRI.bHasSpawnedIn )
					SetReadyButtonVisibility(true);

				if( KFGRI.bMatchHasBegun || KFGRI.bMatchIsOver )
				{
					if( GetPC().PlayerReplicationInfo.bReadyToPlay || KFGRI.bMatchIsOver )
						SetReadyButtonVisibility(false);
				}
				else if( GetPC().WorldInfo.NetMode == NM_Standalone && MyKFPRI != None )
					MatchStartContainer.SetVisible(MyKFPRI.bReadyToPlay);

				SetBool("matchOver", KFGRI.bMatchIsOver);
			}
		}
	}
}

stripped final simulated function context(KFGFxWidget_PartyInGame) SetPacketLoss()
{
    local UKFPHUDInteraction UKFPInteraction;
    local GFxObject matchOverNotification, textField;
    
    UKFPInteraction = `GetChatRep().UKFPInteraction;
    if( UKFPInteraction == None )
        return;
        
    matchOverNotification = GetObject("matchOverNotification");
    if( matchOverNotification == None )
        return;
        
    matchOverNotification.SetString("text", Localize("Notifications", "ConnectionLostTitle", "KFGameConsole"));
    textField = matchOverNotification.GetObject("textField");
    if( textField != None )
        textField.SetInt("textColor", 0xED0800);
    
    SetBool("matchOver", true);
    SetReadyButtonVisibility(false);
}

stripped final simulated function context(KFGFxWidget_PartyInGame) RestoreMatchContainer()
{
    local UKFPHUDInteraction UKFPInteraction;
    local GFxObject matchOverNotification, textField;
    
    UKFPInteraction = `GetChatRep().UKFPInteraction;
    if( UKFPInteraction == None )
        return;
        
    matchOverNotification = GetObject("matchOverNotification");
    if( matchOverNotification == None )
        return;
        
    matchOverNotification.SetString("text", MatchOverString);
    textField = matchOverNotification.GetObject("textField");
    if( textField != None )
        textField.SetInt("textColor", 0xFFFFFF);
}

stripped function context(KFGFxWidget_PartyInGame.OneSecondLoop) OneSecondLoop()
{
	if( KFGRI == None )
		KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
	RefreshParty();
	UpdateReadyButtonVisibility();
	UpdateEndlessPauseButtonVisibility();
    RefreshCycleButton();
}

stripped final function context(KFGFxWidget_PartyInGame) int GetOffsetRefreshParty(int Slots)
{
	local byte i;
    local PartyWidgetHelper WH;

    WH = class'PartyWidgetHelper'.default.StaticReference;
	if( WH != None )
	{
		for( i=WH.LobbyCurrentPage-1; i>0; --i )
		{
			if( i * PlayerSlots < Slots )
				return i * PlayerSlots;
			else --WH.LobbyCurrentPage;
		}
	}

	return 0;
}

stripped function context(KFGFxWidget_PartyInGame.RefreshParty) RefreshParty()
{
    RefreshPartyEx();
}

stripped final function context(KFGFxWidget_PartyInGame) RefreshPartyEx()
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local int SlotIndex, OffsetIndex;
	local GFxObject DataProvider;
    
	if( !Manager.bStatsInitialized )
		return;

	Super.RefreshParty();

	GetKFPRIArray( KFPRIArray );
	if( KFPRIArray.Length <= 0 )
	 	return;

	if( PartyChatWidget != None )
		PartyChatWidget.SetLobbyChatVisible(KFPRIArray.Length > 1);

	UpdateInLobby(KFPRIArray.Length > 1);		

	OccupiedSlots = KFPRIArray.Length;
    if( !UseMultiPage() )
        OffsetIndex = 0;
    else OffsetIndex = GetOffsetRefreshParty(KFPRIArray.Length);
	
    DataProvider = CreateArray();
	for( SlotIndex=0; SlotIndex<PlayerSlots; ++SlotIndex )
	{
		if( SlotIndex + OffsetIndex < KFPRIArray.Length )
			DataProvider.SetElementObject(SlotIndex, RefreshSlot(SlotIndex, KFPRIArray[SlotIndex + OffsetIndex]));
	}
    
    if( UseMultiPage() )
        SetBool("bInParty", false);
    else SetBool("bInParty", bInLobby || ( GetPC().WorldInfo.NetMode != NM_Standalone ));
    
	SetObject("squadInfo", DataProvider);
	UpdateSoloSquadText();
}

stripped final function context(KFGFxWidget_PartyInGame) int GetPageOffset()
{
    local PartyWidgetHelper WH;
    
    if( !UseMultiPage() )
        return 0;

    WH = class'PartyWidgetHelper'.default.StaticReference;
	if( WH != None )
		return (WH.LobbyCurrentPage - 1) * PlayerSlots;
	else return 0;
}

stripped function context(KFGFxWidget_PartyInGame.ToggelMuteOnPlayer) ToggelMuteOnPlayer(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local UniqueNetId PlayerNetID;
	local PlayerController PC;

	PC = GetPC();
	GetKFPRIArray( KFPRIArray );

	if( KFPRIArray.Length <= 0 )
	 	return;

    SlotIndex += GetPageOffset();
	if( KFPRIArray.Length > SlotIndex )
	{
		PlayerNetID = KFPRIArray[SlotIndex].UniqueId;
		if(PC.IsPlayerMuted(PlayerNetID))
		{
			PC.ServerUnMutePlayer(PlayerNetID, !class'WorldInfo'.static.IsConsoleBuild());
			if( MemberSlots[SlotIndex].MemberSlotObject != None )
				MemberSlots[SlotIndex].MemberSlotObject.SetBool("isMuted",false);
		}
		else
		{
			PC.ServerMutePlayer(PlayerNetID, !class'WorldInfo'.static.IsConsoleBuild());
			if( MemberSlots[SlotIndex].MemberSlotObject != None )
				MemberSlots[SlotIndex].MemberSlotObject.SetBool("isMuted",true);
		}
	}
    
	Super.ToggelMuteOnPlayer(SlotIndex);
}

stripped function context(KFGFxWidget_PartyInGame.ViewProfile) ViewProfile(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	GetKFPRIArray( KFPRIArray );

	if( KFPRIArray.Length <= 0 || OnlineSub == None || OnlineSub.PlayerInterfaceEx == None )
	 	return;

    SlotIndex += GetPageOffset();
	if( KFPRIArray.Length > SlotIndex )
	{
		if( GetPC().WorldInfo.IsConsoleBuild(CONSOLE_Orbis) )
			OnlineSub.PlayerInterfaceEx.ShowGamerCardUIByUsername(GetLP().ControllerId,KFPRIArray[SlotIndex].PlayerName);
		else OnlineSub.PlayerInterfaceEx.ShowGamerCardUI(GetLP().ControllerId,KFPRIArray[SlotIndex].UniqueId);

		`Log("View PLAYER profile: "@KFPRIArray[SlotIndex].PlayerName);
	}
}

stripped function context(KFGFxWidget_PartyInGame.AddFriend) AddFriend(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local LocalPlayer LocPlayer;

	GetKFPRIArray( KFPRIArray );

	LocPlayer = LocalPlayer(GetPC().Player);
	if( LocPlayer == None )
		return;

	if( KFPRIArray.Length <= 0 )
	 	return;

    SlotIndex += GetPageOffset();
	if( SlotIndex < KFPRIArray.Length )
	{
		if( OnlineSub.IsFriend(LocPlayer.ControllerId,KFPRIArray[SlotIndex].UniqueId))
		{
			if( !OnlineSub.RemoveFriend( LocPlayer.ControllerId, KFPRIArray[SlotIndex].UniqueId ) )
				`Log("Failed to remove friend!");
		}
		else
		{
			if( !OnlineSub.AddFriend( LocPlayer.ControllerId, KFPRIArray[SlotIndex].UniqueId ) )
				`Log("Failed to add friend!");
		}
	}
}

stripped function context(KFGFxWidget_PartyInGame.KickPlayer) KickPlayer(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;

	GetKFPRIArray( KFPRIArray );	

	if( KFPRIArray.Length <= 0 )
	 	return;

    SlotIndex += GetPageOffset();
	if( SlotIndex < KFPRIArray.Length )
		KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo).ServerStartKickVote(KFPRIArray[SlotIndex], GetPC().PlayerReplicationInfo);	
}

stripped function context(KFGFxWidget_PartyInGame.RefreshSlot) GFxObject RefreshSlot(int SlotIndex, KFPlayerReplicationInfo KFPRI)
{
	local string PlayerName;	
	local UniqueNetId AdminId;
	local bool bIsLeader;
	local bool bIsMyPlayer;
	local PlayerController PC;
	local GFxObject PlayerInfoObject, PerkIconObject;
	local string AvatarPath;

	PlayerInfoObject = CreateObject("Object");

	PC = GetPC();

	if( OnlineLobby != None )
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
	
	bIsLeader = (KFPRI.UniqueId == AdminId && AdminId != ZeroUniqueId);
	PlayerInfoObject.SetBool("bLeader", bIsLeader);
    
	bIsMyPlayer = PC.PlayerReplicationInfo.UniqueId == KFPRI.UniqueId;
	MemberSlots[SlotIndex].PlayerUID = KFPRI.UniqueId;
	MemberSlots[SlotIndex].PRI = KFPRI;
	MemberSlots[SlotIndex].PerkClass = KFPRI.CurrentPerkClass;
	MemberSlots[SlotIndex].PerkLevel = String(KFPRI.GetActivePerkLevel());
	MemberSlots[SlotIndex].PrestigeLevel = String(KFPRI.GetActivePerkPrestigeLevel());
	
	PlayerInfoObject.SetBool("myPlayer", bIsMyPlayer);

	if( MemberSlots[SlotIndex].PerkClass != None )
	{
        if( `GetChatRep().RepMaxPlayers > 6 )
            PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel);
        else PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel@MemberSlots[SlotIndex].PerkClass.default.PerkName);

		PerkIconObject = CreateObject("Object");
		PerkIconObject.SetString("perkIcon", "img://"$MemberSlots[SlotIndex].PerkClass.static.GetPerkIconPath());
		PerkIconObject.SetString("prestigeIcon", MemberSlots[SlotIndex].PerkClass.static.GetPrestigeIconPath(KFPRI.GetActivePerkPrestigeLevel()));

		PlayerInfoObject.SetObject("perkImageSource", PerkIconObject);
	}

	if( !bIsMyPlayer )
		PlayerInfoObject.SetBool("muted", PC.IsPlayerMuted(KFPRI.UniqueId));	
	
	PlayerName = KFPRI.PlayerName;
	PlayerInfoObject.SetString("playerName", PlayerName);

	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
		AvatarPath = KFPC.GetPS4Avatar(PlayerName);
	else AvatarPath = KFPC.GetSteamAvatar(KFPRI.UniqueId);

	if( AvatarPath != "" )
		PlayerInfoObject.SetString("profileImageSource", "img://"$AvatarPath);
	if( KFGRI != None )
		PlayerInfoObject.SetBool("ready", KFPRI.bReadyToPlay && !KFGRI.bMatchHasBegun);

	return PlayerInfoObject;
}