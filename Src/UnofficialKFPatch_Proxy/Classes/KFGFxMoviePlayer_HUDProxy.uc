class KFGFxMoviePlayer_HUDProxy extends Object;

stripped function context(KFGFxMoviePlayer_HUD.ShowKillMessage) ShowKillMessage(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, optional bool bDeathMessage=false, optional Object OptionalObject)
{
    ShowKillMessageEx(PRI1, PRI2, bDeathMessage, OptionalObject);
}

stripped final function context(KFGFxMoviePlayer_HUD) ShowKillMessageEx(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, optional bool bDeathMessage=false, optional Object OptionalObject)
{
    local GFxObject DataObject;
    local bool bHumanDeath;
    local string KilledName, KillerName, KilledIconpath, KillerIconPath;
    local string KillerTextColor, KilledTextColor;
    local class<KFPawn_Monster> KFPM;
    local KFPlayerReplicationInfo KFPRI;
    
    if( KFPC == None )
        return;

    KFPM = class<KFPawn_Monster>(OptionalObject);

    if( KFGXHUDManager != None )
    {
        if( bDeathMessage )
        {
            if( KFPM != None )
            {
                KillerName=KFPM.static.GetLocalizedName();
                KillerTextColor=ZEDTeamTextColor;
                KillerIconpath="img://"$class'KFPerk_Monster'.static.GetPerkIconPath();
            }
        }
        else
        {
            if( KFPM != None )
            {
                KilledName=KFPM.static.GetLocalizedName();
                bHumanDeath=false;
            }
            else if( PRI1 != None )
            {
                if( PRI1.GetTeamNum() == 255 )
                {
                    KillerTextColor=ZEDTeamTextColor;
                    KillerIconpath="img://"$class'KFPerk_Monster'.static.GetPerkIconPath();
                }
                else
                {
                    KillerTextColor=HumanTeamTextColor;
                    KFPRI = KFPlayerReplicationInfo(PRI1);
                    if( KFPRI != None && KFPRI.CurrentPerkClass != None )
                        KillerIconpath="img://"$KFPRI.CurrentPerkClass.static.GetPerkIconPath();
                }
                KillerName=PRI1.PlayerName;
            }
        }

        if( PRI2 != None )
        {
            if( PRI2.GetTeamNum() == class'KFTeamInfo_Human'.default.TeamIndex )
            {
                bHumanDeath=true;
                KilledTextColor=HumanTeamTextColor;
            }
            else
            {
                KilledTextColor=ZEDTeamTextColor;
                bHumanDeath=false;
            }
            KilledName=PRI2.PlayerName;
            
            KFPRI = KFPlayerReplicationInfo(PRI2);
            if( KFPRI != None && KFPRI.CurrentPerkClass != None )
                KilledIconpath="img://"$KFPRI.CurrentPerkClass.static.GetPerkIconPath();
        }

        DataObject=CreateObject("Object");

        DataObject.SetBool("humanDeath", bHumanDeath);

        DataObject.SetString("killedName", KilledName);
        DataObject.SetString("killedTextColor", KilledTextColor);
        DataObject.SetString("killedIcon", KilledIconpath);
        
        DataObject.SetString("skullIcon", "img://UKFP_UI_Shared.AssetLib_I32");
        
        DataObject.SetString("killerName", KillerName);
        DataObject.SetString("killerTextColor", KillerTextColor);
        DataObject.SetString("killerIcon", KillerIconpath);

        DataObject.SetString("text", KillerName@KilledName);

        KFGXHUDManager.SetObject("newBark", DataObject);
    }
}

stripped function context(KFGFxMoviePlayer_HUD.TickHud) TickHud(float DeltaTime)
{
    local bool bGunGameVisibility, bVIPModeVisibility;

    if( KFPC == None )
        return;
	
	if( WaveInfoWidget != None )
		WaveInfoWidget.TickHUD(DeltaTime);

    if( !KFPC.MyHUD.bShowHUD )
        return;

    if( bUsingGamepad != KFPC.PlayerInput.bUsingGamepad )
    {
        bUsingGamepad=KFPC.PlayerInput.bUsingGamepad;
        UpdateUsingGamepad();
        UpdateWeaponSelect();
    }

    if( BossHealthBar != None )
        BossHealthBar.TickHud( DeltaTime );

    if( MapTextWidget != None )
        MapTextWidget.TickHud( UpdateInterval );

    if( MapCounterTextWidget != None )
        MapCounterTextWidget.TickHud( UpdateInterval );

    if( SpectatorInfoWidget != None )
        SpectatorInfoWidget.TickHud( DeltaTime );

    if( !bIsSpectating )
    {
        if( PlayerStatusContainer != None )
            PlayerStatusContainer.TickHud( DeltaTime );

        if( PlayerBackpackContainer != None )
            PlayerBackpackContainer.TickHud( DeltaTime );
    }

    if( TraderCompassWidget != None )
        TraderCompassWidget.TickHUD( DeltaTime);

    if( GfxScoreBoardPlayer != None )
        GfxScoreBoardPlayer.TickHud(DeltaTime);

    if( GunGameWidget != None )
    {
        bGunGameVisibility = KFPC.CanUseGunGame();

        if( bGunGameVisibility )
            bGunGameVisibility = KFPC.Pawn.Health > 0;
    
        if( bGunGameVisibility != bLastGunGameVisibility )
        {
            GunGameWidget.UpdateGunGameVisibility(bGunGameVisibility);
            bLastGunGameVisibility = bGunGameVisibility;
        }
    }

    if( VIPWidget != None )
    {
        bVIPModeVisibility = KFPC.CanUseVIP();

        if( bVIPModeVisibility != bLastVIPVisibility )
        {
            VIPWidget.UpdateVIPVisibility(bVIPModeVisibility);
            bLastVIPVisibility = bVIPModeVisibility;
        }
    }
}