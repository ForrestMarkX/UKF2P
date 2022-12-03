class KFGFxMoviePlayer_ManagerProxy extends Object;

stripped final function context(KFGFxMoviePlayer_Manager) PreInitMenus()
{
    local int i;
    
    for( i=0; i<WidgetPaths.Length; i++ )
    {
        if( WidgetPaths[i] ~= "../UI_Widgets/PartyWidget_SWF.swf" )
        {
            if( `GetChatRep().RepMaxPlayers > 6 )
                WidgetPaths[i] = "../UKFP_UI_HUD/UKFP_VersusLobbyWidget_SWF.swf";
            else WidgetPaths[i] = "../UKFP_UI_HUD/UKFP_PartyWidget_SWF.swf";
        }
        else if( WidgetPaths[i] ~= "../UI_Widgets/VersusLobbyWidget_SWF.swf" )
            WidgetPaths[i] = "../UKFP_UI_HUD/UKFP_VersusLobbyWidget_SWF.swf";
        else if( WidgetPaths[i] ~= "../ZedternalReborn_Menus/ZedternalLobby/LobbyGUI.swf" )
            WidgetPaths[i] = "../UKFP_UI_HUD/UKFP_ZedternalLobbyWidget_SWF.swf";
        else if( WidgetPaths[i] ~= "../UI_Widgets/MenuBarWidget_SWF.swf" )
            WidgetPaths[i] = "../UKFP_UI_HUD/MenuBarWidget_SWF.swf";
    }
    
    MenuSWFPaths[UI_PostGame].BaseSWFPath = "../UKFP_UI_HUD/PostGameMenu_SWF.swf";
}

stripped function context(KFGFxMoviePlayer_Manager.LaunchMenus) LaunchMenus( optional bool bForceSkipLobby )
{
	local GFxWidgetBinding WidgetBinding;
	local bool bSkippedLobby, bShowIIS;
	local KFGameViewportClient GVC;
	local KFPlayerController KFPC;
	local bool bShowMenuBg;
	local TextureMovie BGTexture;
	local OnlineSubsystem MyOnlineSub;
    
    PreInitMenus();

	GVC = KFGameViewportClient(GetGameViewportClient());
	KFPC = KFPlayerController(GetPC());

	bStatsInitialized = KFPC.HasReadStats();

	WidgetBinding.WidgetName = 'partyWidget';
	if( class'WorldInfo'.static.IsMenuLevel() )
	{
		WidgetBinding.WidgetClass = class'KFGFxWidget_PartyMainMenu';

		bShowIIS = GVC != None && !GVC.bSeenIIS;

		UpdateBackgroundMovie();

		BGTexture = (GetPC().WorldInfo.IsConsoleBuild() && bShowIIS) ? IISMovie : CurrentBackgroundMovie;

		bShowMenuBg = GVC.bSeenIIS || !GetPC().WorldInfo.IsConsoleBuild();
		ManagerObject.SetBool("backgroundVisible", bShowMenuBg);
		ManagerObject.SetBool("IISMovieVisible", !bShowMenuBg);

		BGTexture.Play();
	}
	else
	{
		bSkippedLobby = bForceSkipLobby || CheckSkipLobby();
		WidgetBinding.WidgetClass = InGamePartyWidgetClass;
		ManagerObject.SetBool("backgroundVisible", false);
		ManagerObject.SetBool("IISMovieVisible", false);

		if( bSkippedLobby )
			CurrentBackgroundMovie.Stop();
	}
	WidgetBindings.AddItem(WidgetBinding);

	switch( class'KFGameEngine'.static.GetPlatform() )
	{
		case PLATFORM_PC_DX10:
			WidgetBinding.WidgetName = 'optionsGraphicsMenu';
			WidgetBinding.WidgetClass = class'KFGFxOptionsMenu_Graphics_DX10';
			WidgetBindings.AddItem(WidgetBinding);
			break;
		default:
			WidgetBinding.WidgetName = 'optionsGraphicsMenu';
			WidgetBinding.WidgetClass = class'KFGFxOptionsMenu_Graphics';
			WidgetBindings.AddItem(WidgetBinding);
	}
	
	if( !bSkippedLobby )
	{
		LoadWidgets(WidgetPaths);
		if(class'WorldInfo'.static.IsConsoleBuild() && bShowIIS)
			OpenMenu(UI_IIS,false);
		else OpenMenu(UI_Start);

		AllowCloseMenu();

		if(GVC.bNeedDisconnectMessage)
		{
			`TimerHelper.SetTimer(0.1f, false, 'DelayedShowDisconnectMessage', self);
			GVC.bNeedDisconnectMessage = false;
		}
		else if(class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) && bCheckConnectionOnFirstLaunch)
		{
			bCheckConnectionOnFirstLaunch = false;
			MyOnlineSub = Class'GameEngine'.static.GetOnlineSubsystem();
			if(MyOnlineSub != None && MyOnlineSub.SystemInterface.GetCurrentConnectionStatus() != OSCS_Connected)
                `TimerHelper.SetTimer(0.1f, false, 'DelayedShowStartDisconnectMessage', self);
		}

		if(GVC.bHandlePlayTogether)
		{
			KFPC.OnGameDestroyedForPlayTogetherComplete('Party', true);
			GVC.bHandlePlayTogether = false;
		}
	}

	if( bForceSkipLobby )
	{
		bAfterLobby = true;
		CloseMenus(true);
	}

	if( !bSetGamma && !class'KFGameEngine'.static.CheckSkipGammaCheck() && CachedProfile != None && CachedProfile.AsyncState != OPAS_Read && !class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		ManagerObject.SetBool("bStartUpGamma", true);
		DelayedOpenPopup(EGamma, EDPPID_Gamma,"", Class'KFGFxOptionsMenu_Graphics'.default.AdjustGammaDescription, Class'KFGFxOptionsMenu_Graphics'.default.ResetGammaString, Class'KFGFxOptionsMenu_Graphics'.default.SetGammaString);
	}
}

stripped function context(KFGFxMoviePlayer_Manager.Init) Init(optional LocalPlayer LocPlay)
{
	local Vector2D ViewportSize;
	local GameViewportClient GVC;
	local float ScaleStage;
    
	class'KFUIDataStore_GameResource'.static.InitializeProviders();

	HUD = KFHUDBase(GetPC().myHUD);

	Super.Init( LocPlay );

	bCheckConnectionOnFirstLaunch = true;

	if( OnlineSub == None )
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if( OnlineSub != None )
		{
			OnlineLobby = OnlineSub.GetLobbyInterface();

			CachedProfile = KFProfileSettings( OnlineSub.PlayerInterface.GetProfileSettings( GetLP().ControllerId ) );
			if( CachedProfile != None )
				bSetGamma = CachedProfile.GetProfileBool( KFID_SetGamma );
		}
	}

	PlayfabInter = class'GameEngine'.static.GetPlayfabInterface();

	`TimerHelper.SetTimer(0.1, true, 'OneSecondLoop', self);
	SetTimingMode(TM_Real);

	GVC = GetGameViewportClient();
	if( GVC != None && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
	{
		GVC.GetViewportSize(ViewportSize);
		ScaleStage = class'Engine'.static.GetTitleSafeArea();
		SetViewport((ViewportSize.X-(ViewportSize.X*ScaleStage))/2,(ViewportSize.Y-(ViewportSize.Y*ScaleStage))/2,(ViewportSize.X*ScaleStage),(ViewportSize.Y*ScaleStage));
	}
	bUsingGamepad = class'WorldInfo'.static.IsConsoleBuild();
	UpdateDynamicIgnoreKeys();
}

stripped function context(KFGFxMoviePlayer_Manager.OnForceUpdate) OnForceUpdate()
{
	OneSecondLoop();
	`TimerHelper.SetTimer(0.1, true, 'OneSecondLoop', self);
}

stripped event context(KFGFxMoviePlayer_Manager.OnCleanup) OnCleanup()
{
	Super.OnCleanup();

	if( OnlineSub != none )
		OnlineSub.ClearAllInventoryReadCompleteDelegates();

	if( PlayfabInter != None )
		PlayfabInter.InventoryReadDelegates.Length = 0;
	GetGameViewportClient().HandleInputAxis = None;

    `GetURI().Cleanup();
}