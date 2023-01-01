class ExtendedHUD extends Object;

stripped final function context(UKFPHUDInteraction) InitializedEx()
{
    local byte i;
    local class<WeaponBobStyle> Style;

    ZEDIcons.Length = HUD.HUDClass.default.SpecialWaveIconPath.Length;
    for(i=0; i<HUD.HUDClass.default.SpecialWaveIconPath.Length; i++)
        ZEDIcons[i] = Texture(`SafeLoadObject(HUD.HUDClass.default.SpecialWaveIconPath[i], class'Texture'));
        
    Super(Interaction).Initialized();
    
    if( iConfigVersion <= 0 )
    {
        bEnableZEDTimeUI = true;
        bPingsEnabled = true;
        PingAlphaColor = 195;
        MaxPingIconSize = 32;
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 1 )
    {
        DoshThrowAmt = 50;
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 2 )
    {
        HUDAlpha = 100;
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 3 )
    {
        WaveInfoAlpha = 100;
        PlayerStatusAlpha = 100;
        PlayerBackpackAlpha = 100;
        BossHealthBarAlpha = 100;
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 4 )
    {
        //HUDScale = 1.f;
        iConfigVersion++;
    }
    
    if( iConfigVersion <= 5 )
    {
        bDisableLargeKillTicker = false;
        iConfigVersion++;
    }
    
    AlphaInverse = FMax(HUDAlpha / 100.f, 0.01f);
    ActualWaveInfoAlpha = WaveInfoAlpha / AlphaInverse;
    ActualPlayerStatusAlpha = PlayerStatusAlpha / AlphaInverse;
    ActualPlayerBackpackAlpha = PlayerBackpackAlpha / AlphaInverse;
    ActualBossHealthBarAlpha = BossHealthBarAlpha / AlphaInverse;
    
    for( i=0; i<BobStylesToLoad.Length; i++ )
    {
        Style = class<WeaponBobStyle>(`SafeLoadObject(BobStylesToLoad[i],class'Class'));
        if( Style != None )
            BobStyles.AddItem(Style);
    }
    
    SetupBobStyle();
    
    SaveConfig();
}

stripped function context(UKFPHUDInteraction.Initialized) Initialized()
{
    InitializedEx();
}

stripped final function context(UKFPHUDInteraction.SetupBobStyle) SetupBobStyle()
{
    if( WeaponBobStyle <= 0 || WeaponBobStyle > BobStyles.Length || ChatRep.MainRepInfo.GetEnforceVanilla() )
        CurrentBobClass = None;
    else
    {
        CurrentBobClass = New BobStyles[WeaponBobStyle-1];
        CurrentBobClass.WorldInfo = WorldInfo;
        CurrentBobClass.Init();
    }
}

stripped final function context(UKFPHUDInteraction) RefreshHUDAlpha()
{
    UpdateWidgetAlpha(HUD.HUDMovie.KFGXHUDManager, HUDAlpha);
    UpdateWidgetAlpha(HUD.HUDMovie.WaveInfoWidget, ActualWaveInfoAlpha);
    UpdateWidgetAlpha(HUD.HUDMovie.TraderCompassWidget, ActualWaveInfoAlpha);
    UpdateWidgetAlpha(HUD.HUDMovie.PlayerStatusContainer, ActualPlayerStatusAlpha);
    UpdateWidgetAlpha(HUD.HUDMovie.PlayerBackpackContainer, ActualPlayerBackpackAlpha);
    UpdateWidgetAlpha(HUD.HUDMovie.bossHealthBar, ActualBossHealthBarAlpha);
}

stripped final function context(UKFPHUDInteraction) UpdateWidgetAlpha(GFxObject Widget, float Alpha)
{
    local FWidgetAlpha Info;
    local int Index;
    
    Index = WidgetAlphas.Find('Widget', Widget);
    if( Index != INDEX_NONE )
        Info = WidgetAlphas[Index];
    else
    {
        Info.Widget = Widget;
        Info.Alpha = Widget.GetFloat("alpha");
        WidgetAlphas.AddItem(Info);
    }
    
    Widget.SetFloat("alpha", Info.Alpha * (Alpha / 100.f));
}

stripped final function context(UKFPHUDInteraction) UpdateWidgetScale(GFxObject Widget, float fForcedScale)
{
    local float X, Y;
    
    Widget.GetPosition(X, Y);
    Widget.SetFloat("scaleX", Widget.GetFloat("scaleX") * fForcedScale);
    Widget.SetFloat("scaleY", Widget.GetFloat("scaleY") * fForcedScale);
    Widget.SetPosition(X * fForcedScale, Y * fForcedScale);
}

stripped final function context(UKFPHUDInteraction) OnHUDRefreshed()
{
    RefreshHUDAlpha();
    WorldInfo.ForceGarbageCollection();
}

stripped final function context(UKFPHUDInteraction) RenderBackgroundHUD()
{
    KFPlayerOwner.GetPlayerViewPoint(PLCameraLoc,PLCameraRot);
    PLCameraDir = vector(PLCameraRot);
    
    ScaledBorderSize = FMax(ScreenScale(HUDBorderSize), 1.f);
    ScaledBorderSizeDouble = ScaledBorderSize * 2.f;

    if( bHasPacketLoss )
        DrawPacketLoss();
    if( WorldInfo.NetMode != NM_StandAlone && KFPlayerOwner.IsPaused() )
        DrawWorldPaused();
    
    if( KFPlayerOwner.bCinematicMode || !HUD.bShowHUD || KFPlayerOwner.Pawn == None )
        return;
    
    if( Statuses.Length > 0 )
        DrawStatusEffects();
}

stripped final function context(UKFPHUDInteraction) RenderForegroundHUD()
{
    if( bPingsEnabled && !ChatRep.MainRepInfo.bNoPings && PingLocations.Length > 0 )
        DrawPingLocations();
}

stripped function context(UKFPHUDInteraction.PostRender) PostRender(Canvas C)
{
    if( C.SizeX != SizeX || C.SizeY != SizeY )
    {
        SizeX = C.SizeX;
        SizeY = C.SizeY;
        
        if( bHUDSizeInitialized )
            RefreshHUD();
        else 
        {
            bHUDSizeInitialized = true;
            OnHUDRefreshed();
            
            if( ChatRep.RepMaxPlayers > 6 )
                UpdateWidgetScale(KFPlayerOwner.MyGFxManager.BackendStatusIndicatorWidget, 0.75f);
        }
    }
    
    if( ChatRep.MainRepInfo == None )
        return;
        
    Canvas = C;
    
    Canvas.EnableStencilTest(true);
    RenderForegroundHUD();
    Canvas.EnableStencilTest(false);
    RenderBackgroundHUD();
    
    Canvas = None;
}

stripped final function context(UKFPHUDInteraction) DrawWorldPaused()
{
	local float Sc,XL,YL,X,Y,BoxW,BoxH,BoxX,BoxY;
	local string S;
    
    Canvas.Font = class'KFGameEngine'.static.GetKFCanvasFont();
    Sc = GetResolutionScale() * 1.5f;
    
    BoxH = ScaledBorderSizeDouble;
    
    S = "G A M E   P A U S E D";
    
    Canvas.TextSize(S,XL,YL,Sc,Sc);
    
    BoxW = XL * 1.15f;
    BoxH += YL;
    
    BoxX = HUD.CenterX - (BoxW*0.5f);
    BoxY = HUD.CenterY - (BoxH*0.5f);
    
    if( CurrentPausedAlpha<255 )
        CurrentPausedAlpha = Min(CurrentPausedAlpha+5,255);
    
    Canvas.SetDrawColor(0, 0, 0, Min(200, CurrentPausedAlpha));
    Canvas.SetPos(BoxX, BoxY);
    Canvas.DrawRect(BoxW, BoxH);
    
    Canvas.DrawColor = HUD.RedColor;
    Canvas.DrawColor.A = CurrentPausedAlpha;
    
    X = (BoxX+ScaledBorderSizeDouble) + ((BoxW-(ScaledBorderSize*4)-XL)*0.5f);
    Y = BoxY + ((BoxH-YL)*0.5f) - (ScaledBorderSize*0.5f);
    DrawTextShadow(S, X, Y, 1, Sc);
}

stripped final function context(UKFPHUDInteraction) AddStatusEffectEx( coerce string UID, KFPawn_Human P, coerce string StatusName, Color Col, Texture2D Icon, float MaxValue, delegate<UKFPHUDInteraction.OnStatusThink> StatusThink )
{
    local FStatusIcon Status;
    local int i;
    
    Col.A *= PlayerStatusAlpha / 100.f;

    for( i=0; i<Statuses.Length; i++ )
    {
        if( Statuses[i].UID == UID )
        {
            Statuses[i].Name = StatusName;
            Statuses[i].Color = Col;
            Statuses[i].BackgroundColor = MakeColor(0, 0, 0, 163);
            Statuses[i].Icon = Icon;
            Statuses[i].MaxValue = MaxValue;
            Statuses[i].Value = MaxValue;
            Statuses[i].StatusThink = StatusThink;
            return;
        }
    }
    
    Status.UID = UID;
    Status.Name = StatusName;
    Status.Color = Col;
    Status.BackgroundColor = MakeColor(0, 0, 0, 163);
    Status.Icon = Icon;
    Status.MaxValue = MaxValue;
    Status.Value = MaxValue;
    Status.StatusThink = StatusThink;
    
    Statuses.AddItem(Status);
}

stripped final function context(UKFPHUDInteraction.AddStatusEffect) AddStatusEffect( coerce string UID, KFPawn_Human P, coerce string StatusName, Color Col, Texture2D Icon, float MaxValue, delegate<UKFPHUDInteraction.OnStatusThink> StatusThink )
{
    AddStatusEffectEx(UID, P, StatusName, Col, Icon, MaxValue, StatusThink);
}

stripped final function context(UKFPHUDInteraction) DrawStatusEffects()
{
    local int i, BoxSize;
    local float Sc, W, H, X, Y, BarSize, Delta, YOrig;
    local delegate<UKFPHUDInteraction.OnStatusThink> StatusThink;
    
    Canvas.Font = class'KFGameEngine'.static.GetKFCanvasFont();
    Sc = (GetResolutionScale() * 1.275f) * HUD.HUDMovie.HUDScale;
    
    BoxSize = ScreenScale(46) * HUD.HUDMovie.HUDScale;
    BarSize = (ScaledBorderSize * 1.25f) * HUD.HUDMovie.HUDScale;
    
    W = BoxSize + ScaledBorderSizeDouble;
    H = W;

	X = Canvas.ClipX * 0.016667f;
    YOrig = Canvas.ClipY * 0.8025f;
    if( HUD.HUDMovie.HUDScale != 1.f )
    {
        Y = YOrig + ((1.f - HUD.HUDMovie.HUDScale) * (Canvas.ClipY - YOrig));
        Y -= ScreenScale(22.5f) * (1.f - HUD.HUDMovie.HUDScale);
    }
    else Y = YOrig;

    for( i=0; i<Statuses.Length ; i++ )
    {
        StatusThink = Statuses[i].StatusThink;
        Statuses[i] = StatusThink(Statuses[i], HUD.RenderDelta);
        
        if( Statuses[i].Value > Statuses[i].LerpValue )
            Statuses[i].LerpValue = Statuses[i].Value;
        else if( Statuses[i].Value < Statuses[i].LerpValue )
            Statuses[i].LerpValue = `Approach(Statuses[i].LerpValue, Statuses[i].Value, HUD.RenderDelta * 30);

        if( Statuses[i].LerpValue <= 0 )
        {
            Delta = HUD.RenderDelta * 500;
            Statuses[i].Color.A = `Approach(Statuses[i].Color.A, 0, Delta);
            Statuses[i].BackgroundColor.A = `Approach(Statuses[i].BackgroundColor.A, 0, Delta);
            if( Statuses[i].Color.A <= 0 )
            {
                Statuses.Remove(i, 1);
                i--;
                continue;
            }
        }
        
        DrawBoxTimer(X, Y, W, H, BoxSize, BarSize, Statuses[i].LerpValue, Statuses[i].MaxValue, Statuses[i].Color, Statuses[i].BackgroundColor, Statuses[i].Icon, Statuses[i].Name, Sc);

        X += W + ((ScaledBorderSize*8)*HUD.HUDMovie.HUDScale);
        if( i < 5 ) Y -= (ScaledBorderSize * 1.5f) * HUD.HUDMovie.HUDScale;
    }
}

stripped final function context(UKFPHUDInteraction) DrawBoxTimer(float X, float Y, float W, float H, float BoxSize, float BarSize, float Value, float MaxValue, Color Col, Color BackgroundCol, optional Texture2D Icon, optional string S, optional float FontScale, optional Color FontColor)
{
    local float XL, YL, TextX, TextY;
    local int XS, YS;
    local Color BlankColor, OldDrawColor;

    Canvas.PreOptimizeDrawTiles(5, Canvas.DefaultTexture);
    
    Canvas.DrawColor = BackgroundCol;
    Canvas.SetPos(X + ((W-BoxSize) * 0.5f), Y + ((H-BoxSize) * 0.5f));
    Canvas.DrawRect(BoxSize, BoxSize);
    
    Canvas.DrawColor = Col;
    Canvas.SetPos(X + ((W+BoxSize)*0.5f), Y + (((H+BoxSize)*0.5f) - (BoxSize + BarSize) * GetBoxPercentage(Value, MaxValue, 0.75)));
    Canvas.DrawRect(BarSize, (BoxSize + BarSize) * GetBoxPercentage(Value, MaxValue, 0.75));
    Canvas.SetPos(X + ((W-BoxSize)*0.5f), Y + ((H+BoxSize)*0.5f));
    Canvas.DrawRect((BoxSize + BarSize) * GetBoxPercentage(Value, MaxValue, 0.5), BarSize);
    Canvas.SetPos(X + (((W-BoxSize)*0.5f) - BarSize), Y + ((H-BoxSize)*0.5f));
    Canvas.DrawRect(BarSize, (BoxSize + BarSize) * GetBoxPercentage(Value, MaxValue, 0.25));
    Canvas.SetPos(X + ((W+BoxSize)*0.5f) + ((BarSize - (BoxSize + (BarSize * 2))) * GetBoxPercentage(Value, MaxValue, 0)), Y + (((H-BoxSize)*0.5f) - BarSize));
    Canvas.DrawRect((BoxSize + BarSize) * GetBoxPercentage(Value, MaxValue, 0), BarSize);
    
    if( Icon != None )
    {
        Canvas.SetDrawColor(Col.R * 0.6 + 100, Col.G * 0.6 + 100, Col.B * 0.6 + 100, Col.A);
        Canvas.SetPos(X + ((W-BoxSize) * 0.5f), Y + ((H-BoxSize) * 0.5f));
        Canvas.DrawRect(BoxSize, BoxSize, Icon);
    }
    
    if( S != "" )
    {
        Canvas.TextSize(S,XL,YL,FontScale,FontScale);
        while( XL >= W )
        {
            FontScale -= 0.01f;
            Canvas.TextSize(S,XL,YL,FontScale,FontScale);
        }
        
        TextX = X + ((W-XL) * 0.5f);
        TextY = Y + ((H-YL) * 0.5f);
        
        if( FontColor != BlankColor )
        {
            OldDrawColor = FontColor;
            OldDrawColor.A = Col.A;
        }
        else OldDrawColor = Col;
            
        for( XS=-2; XS<=2; XS++ )
        {
            for( YS=-2; YS<=2; YS++ )
            {
                Canvas.SetPos(TextX + XS, TextY + YS);
                Canvas.SetDrawColor(0, 0, 0, OldDrawColor.A);
                Canvas.DrawText(S,, FontScale, FontScale);
                
                Canvas.SetPos(TextX, TextY);
                Canvas.DrawColor = OldDrawColor;
                Canvas.DrawText(S,, FontScale, FontScale);
            }
        }
    }
}

stripped final function context(UKFPHUDInteraction) float GetBoxPercentage( float Value, float MaxValue, float Add )
{
    local float MaxV;
    
    MaxV = (MaxValue * 0.25f);
    if( MaxV == 0.f )
        return 0.f;
        
    return FClamp((Value - MaxValue * Add) / MaxV, 0, 1);
}

stripped final function context(UKFPHUDInteraction) float ScreenScale( float Size, optional float MaxRes=1080.f )
{
    return Size * ( HUD.SizeY / MaxRes );
}

stripped final function context(UKFPHUDInteraction) float GetResolutionScale(optional bool NoUpscale = true)
{
    local float SW, SH, SX, SY, ResScale;
    
    SW = Canvas.ClipX;
    SH = Canvas.ClipY;
    SX = SW / 1920.f;
    SY = SH / 1080.f;

    if (SX > SY)
        ResScale = SY;
    else ResScale = SX;

    if (NoUpscale && ResScale > 1.f)
        return 1.f;

    return ResScale;
}

stripped final function context(UKFPHUDInteraction) bool CurrentPickupIsWeapon(KFPickupFactory_Item P)
{
	if( P.ItemPickups.Length == 0 )
		return false;
	return P.ItemPickups[ P.PickupIndex ].ItemClass.Name != P.ArmorClassName;
}

stripped final function context(UKFPHUDInteraction) bool CurrentPickupIsArmor(KFPickupFactory_Item P)
{
	if( P.ItemPickups.Length == 0 )
		return false;
	return P.ItemPickups[ P.PickupIndex ].ItemClass.Name == P.ArmorClassName;
}

stripped final function context(UKFPHUDInteraction) Color GetPingColorType(Actor A)
{
    local KFPickupFactory Pickup;
    local KFPickupFactory_Item ItemPickup;
    
    if( A.IsA('KFPawn_Monster') )
        return HUD.RedColor;
    else if( A.IsA('KFPickupFactory') )
    {
        Pickup = KFPickupFactory(A);
        ItemPickup = KFPickupFactory_Item(A);
        if( KFPickupFactory_Ammo(Pickup) != None )
            return HUD.YellowColor;
        else if( ItemPickup != None && CurrentPickupIsArmor(ItemPickup) )
            return MakeColor(0, 162, 255, 255);
        else return HUD.OrangeColor;
        
        return HUD.YellowColor;
    }
    else if( A.IsA('KFDroppedPickup') )
    {
        if( A.IsA('KFDroppedPickup_Cash') )
            return HUD.YellowColor;
        return HUD.OrangeColor;
    }
    else if( A.IsA('KFDoorActor') )
        return HUD.OrangeColor;
    else if( A.IsA('KFCollectibleActor') )
        return MakeColor(0, 255, 255, 255);
    else if( A.IsA('KFPawn_Scripted') )
        return MakeColor(0, 100, 210, 255);
    
    return HUD.GreenColor;
}

stripped final function context(UKFPHUDInteraction) Texture GetPingIconType(Actor A, out int TexSizeY, out int TexSizeX)
{
    local KFPickupFactory Pickup;
    local KFPickupFactory_Item ItemPickup;
    local Texture Tex;
    
    TexSizeX = 256;
    TexSizeY = 256;
    
    if( A.IsA('KFPawn_Monster') )
    {
        Tex = GetZEDIcon(class<KFPawn_Monster>(A.Class));
        TexSizeX = Tex.GetSurfaceWidth();
        TexSizeY = Tex.GetSurfaceHeight();
        return Tex;
    }
    else if( A.IsA('KFPickupFactory') )
    {
        Pickup = KFPickupFactory(A);
        ItemPickup = KFPickupFactory_Item(A);
        if( KFPickupFactory_Ammo(Pickup) != None )
            return AmmoPingTexture;
        else if( ItemPickup != None && CurrentPickupIsArmor(ItemPickup) )
            return ArmorPingTexture;
        else return WeaponPingTexture;
        
        return AmmoPingTexture;
    }
    else if( A.IsA('KFDroppedPickup') )
    {
        if( A.IsA('KFDroppedPickup_Cash') )
            return CashPingTexture;
        return WeaponPingTexture;
    }
    else if( A.IsA('KFDoorActor') )
        return DoorPingTexture;
    else if( A.IsA('KFCollectibleActor') )
        return CollectiblePingTexture;
    else if( A.IsA('KFPawn_Scripted') )
        return ObjectivePingTexture;
    
    return WorldPingTexture;
}

stripped final function context(UKFPHUDInteraction) Texture GetZEDIcon(class<KFPawn_Monster> A)
{
    if( A.static.IsABoss() )
        return BossIconTexture;
    else if( ClassIsChildOf(A, class'KFPawn_ZedClot_Alpha') )
        return ZEDIcons[AT_AlphaClot];
    else if( ClassIsChildOf(A, class'KFPawn_ZedClot_Slasher') )
        return ZEDIcons[AT_SlasherClot];
    else if( ClassIsChildOf(A, class'KFPawn_ZedClot_Cyst') )
        return ZEDIcons[AT_Clot];
    else if( ClassIsChildOf(A, class'KFPawn_ZedCrawler') )
        return ZEDIcons[AT_Crawler];
    else if( ClassIsChildOf(A, class'KFPawn_ZedGorefast') )
        return ZEDIcons[AT_GoreFast];
    else if( ClassIsChildOf(A, class'KFPawn_ZedStalker') )
        return ZEDIcons[AT_Stalker];
    else if( ClassIsChildOf(A, class'KFPawn_ZedScrake') )
        return ZEDIcons[AT_Scrake];
    else if( ClassIsChildOf(A, class'KFPawn_ZedFleshpound') )
        return ZEDIcons[AT_FleshPound];
    else if( ClassIsChildOf(A, class'KFPawn_ZedBloat') )
        return ZEDIcons[AT_Bloat];
    else if( ClassIsChildOf(A, class'KFPawn_ZedSiren') )
        return ZEDIcons[AT_Siren];
    else if( ClassIsChildOf(A, class'KFPawn_ZedHusk') )
        return ZEDIcons[AT_Husk];
    else if( ClassIsChildOf(A, class'KFPawn_ZedDAR_EMP') )
        return ZEDIcons[AT_EDAR_EMP];
    else if( ClassIsChildOf(A, class'KFPawn_ZedDAR_Laser') )
        return ZEDIcons[AT_EDAR_Laser];
    else if( ClassIsChildOf(A, class'KFPawn_ZedDAR_Rocket') )
        return ZEDIcons[AT_EDAR_Rocket];
        
    return ZEDPingTexture;
}

stripped final function context(UKFPHUDInteraction) string GetPingName(Actor A)
{
    local KFPickupFactory Pickup;
    local KFPickupFactory_Item ItemPickup;
    local KFDroppedPickup DroppedPickup;
    local byte ItemIndex;
    local string WeaponName;
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( A.IsA('KFPawn_Monster') )
        return KFPawn_Monster(A).static.GetLocalizedName();
    else if( A.IsA('KFPickupFactory') )
    {
        Pickup = KFPickupFactory(A);
        ItemPickup = KFPickupFactory_Item(Pickup);
        if( KFPickupFactory_Ammo(Pickup) != None )
            return "Ammo";
        else if( ItemPickup != None )
        {
            if( CurrentPickupIsArmor(ItemPickup) )
                return "Armor";
            else
            {
                if( KFGRI != None && GetItemIndicesFromArche(ItemIndex, ItemPickup.ItemPickups[ItemPickup.PickupIndex].ItemClass.Name) )
                    WeaponName = KFGRI.TraderItems.SaleItems[ItemIndex].WeaponDef.static.GetItemName();
                else WeaponName = ItemPickup.ItemPickups[ItemPickup.PickupIndex].ItemClass.default.ItemName;
            }
            
            return WeaponName;
        }
        
        return "Invalid";
    }
    else if( A.IsA('KFDroppedPickup') )
    {
        if( A.IsA('KFDroppedPickup_Cash') )
            return "Dosh";
            
        DroppedPickup = KFDroppedPickup(A);
        if( KFGRI != None && GetItemIndicesFromArche(ItemIndex, DroppedPickup.InventoryClass.Name) )
            WeaponName = KFGRI.TraderItems.SaleItems[ItemIndex].WeaponDef.static.GetItemName();
        else WeaponName = DroppedPickup.InventoryClass.default.ItemName;
        
        return WeaponName;
    }
    else if( A.IsA('KFDoorActor') )
        return "Door";
    else if( A.IsA('KFCollectibleActor') )
        return "Collectible";
    else if( A.IsA('KFPawn_Scripted') )
        return "Objective";
    
    return "Move To";
}

stripped final function context(UKFPHUDInteraction) bool CanActorBePinged(Actor A)
{
    return PingLocations.Find('A', A) == INDEX_NONE;
}

stripped final function context(UKFPHUDInteraction) DrawPingLocations()
{
    local float TimeSinceHit, Sc, OriginalSc, IconX, IconY, XL, YL, TextX, TextY, CollisionRadius, CollisionHeight;
    local vector ScreenPos, HitLoc, ZeroVect, CenterBBox;
    local int i, FadeAlpha;
    local string PingName, PingDist;
    local Color PingColor;
    
    Canvas.Font = class'KFGameEngine'.static.GetKFCanvasFont();
    OriginalSc = GetResolutionScale() * 0.95f;
    
    for( i=0; i<PingLocations.Length; i++ ) 
    {
        TimeSinceHit = `TimeSince(PingLocations[i].PingTime);
        if( PingLocations[i].A == None || (PingLocations[i].PRIOwner != None && PingLocations[i].PRIOwner.Team != KFPlayerOwner.PlayerReplicationInfo.Team) || (KFPawn_Monster(PingLocations[i].A) != None && ChatRep.CheckZEDCloaking(KFPawn_Monster(PingLocations[i].A))) || (KFPawn(PingLocations[i].A) != None && !KFPawn(PingLocations[i].A).IsAliveAndWell()) || TimeSinceHit > PingFadeTime )
        {
            PingLocations.Remove(i, 1);
            i--;
            continue;
        }
        
        if( PingLocations[i].A.bMovable )
        {
            if( KFDroppedPickup(PingLocations[i].A) != None )
                HitLoc = PingLocations[i].A.Location;
            else
            {
                PingLocations[i].A.GetBoundingCylinder(CollisionRadius, CollisionHeight);
                
                CenterBBox = vect(0, 0, 0);
                CenterBBox.Z = CollisionHeight * 0.25f;
                
                HitLoc = PingLocations[i].A.Location + CenterBBox;
            }
        }
        else HitLoc = PingLocations[i].HitLocation;
        
        if ( TimeSinceHit < PingFadeInTime )
            FadeAlpha = int((TimeSinceHit / PingFadeInTime) * PingAlphaColor);
        else if ( TimeSinceHit > PingFadeTime - PingFadeOutTime )
            FadeAlpha = int((1.0 - ((TimeSinceHit - (PingFadeTime - PingFadeOutTime)) / PingFadeOutTime)) * PingAlphaColor);
        else FadeAlpha = PingAlphaColor;
        
        PingColor = PingLocations[i].PingColor;
        PingColor.A = FadeAlpha;
        
        if( DrawDirectionalIndicator(HitLoc, PingLocations[i].PingTexture, PingLocations[i].MaxPingSize,, PingColor, PingLocations[i].PingName,, true, PingLocations[i].TexSizeX, PingLocations[i].TexSizeY) != ZeroVect || Normal(HitLoc - PLCameraLoc) dot Normal(PLCameraDir) < 0.1 )
            continue;
            
        Sc = OriginalSc;
        if( PingLocations[i].MaxPingSize != 32 )
            Sc *= PingLocations[i].MaxPingSize / 32.f;
            
        if( PingLocations[i].PingSize < PingLocations[i].MaxPingSize )
            PingLocations[i].PingSize += PingLocations[i].MaxPingSize / 6.f;
            
        ScreenPos = Canvas.Project(HitLoc);
        
        IconX = ScreenPos.X-(PingLocations[i].PingSize*0.5f);
        IconY = ScreenPos.Y-(PingLocations[i].PingSize*0.5f);
        
        Canvas.DrawColor = HUD.BlackColor;
        Canvas.DrawColor.A = FadeAlpha;
        Canvas.SetPos(IconX + 1, IconY + 1);
        Canvas.DrawTile(PingLocations[i].PingTexture, PingLocations[i].PingSize, PingLocations[i].PingSize, 0, 0, PingLocations[i].TexSizeX, PingLocations[i].TexSizeY);
            
        Canvas.DrawColor = PingColor;
        Canvas.SetPos(IconX, IconY);
        Canvas.DrawTile(PingLocations[i].PingTexture, PingLocations[i].PingSize, PingLocations[i].PingSize, 0, 0, PingLocations[i].TexSizeX, PingLocations[i].TexSizeY);
        
        PingName = PingLocations[i].PingName;
        Canvas.TextSize(PingName, XL, YL, Sc, Sc);
        
        TextX = IconX + ((PingLocations[i].PingSize-XL)*0.5f);
        TextY = IconY + PingLocations[i].PingSize;
        
        DrawTextShadow(PingName, TextX, TextY, 1, Sc);
        
        TextY = TextY + YL;
        
        PingDist = int(VSize(HitLoc - PLCameraLoc) / 100.f)$"m";
        Canvas.TextSize(PingDist, XL, YL, Sc, Sc);
        
        TextX = IconX + ((PingLocations[i].PingSize-XL)*0.5f);
        
        DrawTextShadow(PingDist, TextX, TextY, 1, Sc);
    }
}

stripped final function context(UKFPHUDInteraction) Vector DrawDirectionalIndicator(Vector Loc, Texture Mat, float IconSize, optional float FontMult=1.f, optional Color DrawColor=class'HUD'.default.WhiteColor, optional string Text, optional bool bDrawBackground, optional bool bOnlyDrawDir, optional int ForceXSize, optional int ForceYSize)
{
    local rotator R;
    local vector V,X,Zero;
    local float XS,YS,FontScalar,BoxW,BoxH,BoxX,BoxY;
    local Canvas.FontRenderInfo FI;
    local bool bWasStencilEnabled;
    local int TexSizeX, TexSizeY;

    FI.bClipText = true;
    Canvas.Font = class'KFGameEngine'.static.GetKFCanvasFont();
    FontScalar = GetResolutionScale() * FontMult;
    
    X = PLCameraDir;
    
    TexSizeX = ForceXSize > 0 ? ForceXSize : int(Mat.GetSurfaceWidth());
    TexSizeY = ForceYSize > 0 ? ForceYSize : int(Mat.GetSurfaceHeight());
    
    // First see if on screen.
    V = Loc - PLCameraLoc;
    if( (V Dot X)>0.997 ) // Front of camera.
    {
        V = Canvas.Project(Loc+vect(0,0,1.055));
        if( V.X>0 && V.Y>0 && V.X<Canvas.ClipX && V.Y<Canvas.ClipY ) // Within screen bounds.
        {
            if( bOnlyDrawDir )
                return Zero;
                
            Canvas.EnableStencilTest(true);
            
            Canvas.DrawColor = HUD.PlayerBarShadowColor;
            Canvas.DrawColor.A = DrawColor.A;
            Canvas.SetPos(V.X-(IconSize*0.5)+1,V.Y-IconSize+1);
            Canvas.DrawTile(Mat,IconSize,IconSize,0,0,TexSizeX,TexSizeY);

            Canvas.DrawColor = DrawColor;
            Canvas.SetPos(V.X-(IconSize*0.5),V.Y-IconSize);
            Canvas.DrawTile(Mat,IconSize,IconSize,0,0,TexSizeX,TexSizeY);
            
            if( Text != "" )
            {
                Canvas.TextSize(Text,XS,YS,FontScalar,FontScalar);
                
                if( bDrawBackground )
                {
                    BoxW = XS+8.f;
                    BoxH = YS+8.f;
                    
                    BoxX = V.X - (BoxW*0.5);
                    BoxY = V.Y - IconSize - BoxH;
                    
                    Canvas.SetDrawColor(0, 0, 0, 100);
                    Canvas.SetPos(BoxX, BoxY);
                    Canvas.DrawRect(BoxW, BoxH);

                    Canvas.DrawColor = HUD.WhiteColor;
                    Canvas.SetPos(BoxX + (BoxW*0.5f) - (XS*0.5f), BoxY + (BoxH*0.5f) - (YS*0.5f));
                    Canvas.DrawText(Text,, FontScalar, FontScalar, FI);
                }
                else
                {
                    Canvas.DrawColor = HUD.WhiteColor;
                    DrawTextShadow(Text, V.X-(XS*0.5), V.Y-IconSize-YS-4.f, 1, FontScalar);
                }
            }
            
            Canvas.EnableStencilTest(false);
            return V;
        }
    }
    
    bWasStencilEnabled = Canvas.bStencilEnabled;
    if( bWasStencilEnabled )
        Canvas.EnableStencilTest(false);
    
    // Draw the material towards the location.
    // First transform offset to local screen space.
    V = (Loc - PLCameraLoc) << PLCameraRot;
    V.X = 0;
    V = Normal(V);

    // Check pitch.
    R.Yaw = rotator(V).Pitch;
    if( V.Y>0 ) // Must flip pitch
        R.Yaw = 32768-R.Yaw;
    R.Yaw+=16384;

    // Check screen edge location.
    V = FindEdgeIntersection(V.Y,-V.Z,IconSize);
    
    // Draw material.
    Canvas.DrawColor = HUD.PlayerBarShadowColor;
    Canvas.DrawColor.A = DrawColor.A;
    Canvas.SetPos(V.X+1,V.Y+1);
    Canvas.DrawRotatedTile(Mat,R,IconSize,IconSize,0,0,TexSizeX,TexSizeY);
            
    Canvas.DrawColor = DrawColor;
    Canvas.SetPos(V.X,V.Y);
    Canvas.DrawRotatedTile(Mat,R,IconSize,IconSize,0,0,TexSizeX,TexSizeY);
    
    if( bWasStencilEnabled )
        Canvas.EnableStencilTest(true);
    
    return V;
}

stripped final function context(UKFPHUDInteraction) vector FindEdgeIntersection( float XDir, float YDir, float ClampSize )
{
    local vector V;
    local float TimeXS,TimeYS,SX,SY;

    // First check for paralell lines.
    if( Abs(XDir)<0.001f )
    {
        V.X = Canvas.ClipX*0.5f;
        if( YDir>0.f )
            V.Y = Canvas.ClipY-ClampSize;
        else V.Y = ClampSize;
    }
    else if( Abs(YDir)<0.001f )
    {
        V.Y = Canvas.ClipY*0.5f;
        if( XDir>0.f )
            V.X = Canvas.ClipX-ClampSize;
        else V.X = ClampSize;
    }
    else
    {
        SX = Canvas.ClipX*0.5f;
        SY = Canvas.ClipY*0.5f;

        // Look for best intersection axis.
        TimeXS = Abs((SX-ClampSize) / XDir);
        TimeYS = Abs((SY-ClampSize) / YDir);
        
        if( TimeXS<TimeYS ) // X axis intersects first.
        {
            V.X = TimeXS*XDir;
            V.Y = TimeXS*YDir;
        }
        else
        {
            V.X = TimeYS*XDir;
            V.Y = TimeYS*YDir;
        }
        
        // Transform axis to screen center.
        V.X += SX;
        V.Y += SY;
    }
    return V;
}

stripped final function context(UKFPHUDInteraction) bool GetItemIndicesFromArche( out byte ItemIndex, name WeaponClassName )
{
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if( KFGRI == None || KFGRI.TraderItems == None )
        return false;
        
    return KFGRI.TraderItems.GetItemIndicesFromArche(ItemIndex, WeaponClassName);
}

stripped final function context(UKFPHUDInteraction) DrawTextShadow( coerce string S, float X, float Y, float ShadowSize, optional float Scale=1.f, optional FontRenderInfo FRI  )
{
    local Color OldDrawColor;
    
    OldDrawColor = Canvas.DrawColor;
    
    Canvas.SetPos(X + ShadowSize, Y + ShadowSize);
    Canvas.SetDrawColor(0, 0, 0, OldDrawColor.A);
    Canvas.DrawText(S,, Scale, Scale, FRI);
    
    Canvas.SetPos(X, Y);
    Canvas.DrawColor = OldDrawColor;
    Canvas.DrawText(S,, Scale, Scale, FRI);
}

stripped final function context(UKFPHUDInteraction) DrawPacketLoss()
{
	local float Sc,XL,YL,X,Y,BoxW,BoxH,BoxX,BoxY,AlphaMult;
	local string S;
    local byte Alpha;
    
    if( KFPlayerOwner.bCinematicMode || !HUD.bShowHUD )
        return;

    Canvas.Font = class'KFGameEngine'.static.GetKFCanvasFont();
    Sc = GetResolutionScale();
    Sc *= 1.25f;
    
    AlphaMult = HUDAlpha / 100.f;
    Alpha = 255 * AlphaMult;
    
    BoxH = ScaledBorderSizeDouble;
    
    S = Localize("Notifications", "ConnectionLostTitle", "KFGameConsole");
    
    Canvas.TextSize(S,XL,YL,Sc,Sc);
    
    BoxW = XL * 1.15f;
    BoxH += YL;
    
    BoxX = (Canvas.ClipX-BoxW-(ScaledBorderSize*4));
    BoxY = ScaledBorderSize*4;
    
    if( CurrentPacketLossAlpha<Alpha )
        CurrentPacketLossAlpha = Min(CurrentPacketLossAlpha+5,Alpha);
    
    Canvas.SetDrawColor(0, 0, 0, Min(135, CurrentPacketLossAlpha));
    Canvas.SetPos(BoxX, BoxY);
    Canvas.DrawRect(BoxW, BoxH);
    
    Canvas.DrawColor = HUD.RedColor;
    Canvas.DrawColor.A = CurrentPacketLossAlpha;
    
    X = (BoxX+ScaledBorderSizeDouble) + ((BoxW-(ScaledBorderSize*4)-XL)*0.5f);
    Y = BoxY + ((BoxH-YL)*0.5f) - (ScaledBorderSize*0.5f);
    DrawTextShadow(S, X, Y, int(Canvas.ClipY / 360.f), Sc);
}

stripped final function context(UKFPHUDInteraction) AddActorPingEx(PlayerReplicationInfo PRI, Actor A, Vector HitLocation, bool bHitWorld)
{
    local FPingLocation Info;
    local int TexSizeX, TexSizeY;
    
    if( !bPingsEnabled )
        return;
    
    if( (!bHitWorld && !CanActorBePinged(A)) || PingAlphaColor <= 0 || MaxPingIconSize <= 0 )
        return;
        
    `Print(PRI.PlayerName @ "has pinged" @ GetPingName(A));
    
    Info.A = A;
    Info.PingTime = WorldInfo.TimeSeconds;
    Info.PingTexture = GetPingIconType(A, TexSizeX, TexSizeY);
    Info.PingColor = GetPingColorType(A);
    Info.PingName = GetPingName(A);
    Info.MaxPingSize = ScreenScale(MaxPingIconSize);
    Info.bHitWorld = bHitWorld;
    Info.HitLocation = HitLocation;
    Info.TexSizeX = TexSizeX;
    Info.TexSizeY = TexSizeY;
    Info.PRIOwner = PRI;

    PingLocations.AddItem(Info);
    
    KFPlayerOwner.PlayAkEvent(AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Check_A_01');
}

stripped final function context(UKFPHUDInteraction.AddActorPing) AddActorPing(PlayerReplicationInfo PRI, Actor A, Vector HitLocation, bool bHitWorld)
{
    AddActorPingEx(PRI, A, HitLocation, bHitWorld);
}

stripped final function context(UKFPHUDInteraction) RefreshHUD()
{
    local array<GFxObject> ChatHistory;

    WidgetAlphas.Length = 0;
    ChatHistory = HUD.HUDMovie.HudChatBox.GetDataObjects();
    if( HUD.HUDMovie != None )
        HUD.RemoveMovies();
    HUD.CreateHUDMovie(true);
    HUD.HUDMovie.HudChatBox.SetDataObjects(ChatHistory);
    
    OnHUDRefreshed();
}

stripped final function context(UKFPHUDInteraction.SetNoHRG) SetNoHRG(bool B)
{
    bFilterHRGWeapons = B;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction) SetBobStyleEx(int Style)
{
    local Pawn P;
    local KFWeapon KFW;
    
    if( ChatRep.MainRepInfo.GetEnforceVanilla() )
        return;
    
    WeaponBobStyle = Style;
    SetupBobStyle();
    SaveConfig();
    
    P = KFPlayerOwner.Pawn;
    if( P != None )
    {
        KFW = KFWeapon(P.Weapon);
        if( KFW != None )
        {
            KFW.bUseAdditiveMoveAnim = (CurrentBobClass != None && (WeaponHand == HAND_Centered || CurrentBobClass.bForceDisableAdditiveBobAnimation)) ? false : KFW.default.bUseAdditiveMoveAnim;
            KFW.ToggleAdditiveBobAnim(KFW.bUseAdditiveMoveAnim);
        }
    }
}

stripped final function context(UKFPHUDInteraction.SetBobStyle) SetBobStyle(int Style)
{
    SetBobStyleEx(Style);
}

stripped final function context(UKFPHUDInteraction.SetWeaponHand) SetWeaponHand(string S)
{
    if( ChatRep.MainRepInfo.GetEnforceVanilla() )
        return;
        
    if( S ~= "0" || S ~= "right" || S ~= "r" )
        WeaponHand = HAND_Right;
    else if( S ~= "1" || S ~= "left" || S ~= "l" )
        WeaponHand = HAND_Left;
    else if( S ~= "2" || S ~= "center" || S ~= "c" )
        WeaponHand = HAND_Centered;
    else WeaponHand = HAND_Right;
    
	ChatRep.OnPlayerHandsChanged();
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction) ToggleCameraModeEx()
{
    local bool bBehindView;
    
    if( KFPlayerOwner.Pawn == None || KFPlayerOwner.IsBossCameraMode() || ChatRep.MainRepInfo.bServerDisableTP )
        return;
        
    bBehindView = KFPlayerOwner.PlayerCamera.CameraStyle!='FirstPerson';
    KFPlayerOwner.ServerCamera(bBehindView ? 'FirstPerson' : 'ThirdPerson');
    if( !class'KFGameEngine'.static.IsCrosshairEnabled() )
        HUD.bDrawCrosshair = !bBehindView;
}

stripped final function context(UKFPHUDInteraction.ToggleCameraMode) ToggleCameraMode()
{
    ToggleCameraModeEx();
}

stripped final function context(UKFPHUDInteraction.SetHUDScale) SetHUDScale(float Scale)
{
    if( HUD.HUDMovie.default.HUDScale == Scale )
        return;
    HUD.HUDMovie.default.HUDScale = Scale;
    HUD.HUDMovie.StaticSaveConfig();
    RefreshHUD();
}

stripped final function context(UKFPHUDInteraction.SetOtherHUDAlpha) SetOtherHUDAlpha(byte Alpha)
{
    HUDAlpha = Min(Alpha, 100);
    AlphaInverse = FMax(HUDAlpha / 100.f, 0.01f);
    ActualWaveInfoAlpha = WaveInfoAlpha / AlphaInverse;
    ActualPlayerStatusAlpha = PlayerStatusAlpha / AlphaInverse;
    ActualPlayerBackpackAlpha = PlayerBackpackAlpha / AlphaInverse;
    ActualBossHealthBarAlpha = BossHealthBarAlpha / AlphaInverse;
    RefreshHUDAlpha();
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetWaveInfoAlpha) SetWaveInfoAlpha(byte Alpha)
{
    WaveInfoAlpha = Min(Alpha, 100);
    ActualWaveInfoAlpha = WaveInfoAlpha / AlphaInverse;
    RefreshHUDAlpha();
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetPlayerStatusAlpha) SetPlayerStatusAlpha(byte Alpha)
{
    PlayerStatusAlpha = Min(Alpha, 100);
    ActualPlayerStatusAlpha = PlayerStatusAlpha / AlphaInverse;
    RefreshHUDAlpha();
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetPlayerBackpackAlpha) SetPlayerBackpackAlpha(byte Alpha)
{
    PlayerBackpackAlpha = Min(Alpha, 100);
    ActualPlayerBackpackAlpha = PlayerBackpackAlpha / AlphaInverse;
    RefreshHUDAlpha();
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetBossHealthBarAlpha) SetBossHealthBarAlpha(byte Alpha)
{
    BossHealthBarAlpha = Min(Alpha, 100);
    ActualBossHealthBarAlpha = BossHealthBarAlpha / AlphaInverse;
    RefreshHUDAlpha();
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.ThrowMoney) ThrowMoney(int Amount)
{
    if( ChatRep.CheckDoshSpam() )
        return;
	ChatRep.ServerThrowMoney(Amount == 0 ? DoshThrowAmt : Amount);
}

stripped final function context(UKFPHUDInteraction.SetDoshThrowAmount) SetDoshThrowAmount(int Amount)
{
    DoshThrowAmt = Amount;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetDropProtection) SetDropProtection(bool B)
{
    bDropProtection = B;
    SaveConfig();
    
    ChatRep.ServerSetDropProtection(bDropProtection);
}

stripped final function context(UKFPHUDInteraction.SetLargeKillTicker) SetLargeKillTicker(bool B)
{
    bDisableLargeKillTicker = !B;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetZEDTimeEnabled) SetZEDTimeEnabled(bool B)
{
    bEnableZEDTimeUI = B;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetPingsEnabled) SetPingsEnabled(bool B)
{
    bPingsEnabled = B;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetPingAlpha) SetPingAlpha(byte Alpha)
{
    PingAlphaColor = Alpha;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction.SetPingSize) SetPingSize(float Size)
{
    MaxPingIconSize = Size;
    SaveConfig();
}

stripped final function context(UKFPHUDInteraction) PingLocationEx()
{
    local vector HitLocation, HitNormal, TraceStart, TraceEnd, CenterBBox;
    local Actor HitActor;
    local TraceHitInfo HitInfo;
    local bool bPingSpam, bHitWorld;
    local float CollisionRadius, CollisionHeight;
    
    if( !bPingsEnabled || ChatRep.MainRepInfo == None )
        return;
        
    if( ChatRep.MainRepInfo.bNoPings )
    {
        ChatRep.WriteToChat("Pinging is disabled on this server!", "FF0000");
        return;
    }
    
    bPingSpam = ChatRep.CheckPingSpam();
    if( bPingSpam || KFPlayerOwner.PlayerReplicationInfo.bOnlySpectator || !KFPlayerReplicationInfo(KFPlayerOwner.PlayerReplicationInfo).bHasSpawnedIn || PingAlphaColor <= 0 || KFPlayerOwner.Pawn == None )
    {
        if( bPingSpam )
            ChatRep.WriteToChat("You can no longer ping! Please wait"@int(ChatRep.PingTime-WorldInfo.TimeSeconds)@"seconds before trying again!", "FF0000");
        return;
    }
    
    TraceStart = KFPlayerOwner.PlayerCamera.CameraCache.POV.Location;
    TraceEnd = KFPlayerOwner.PlayerCamera.CameraCache.POV.Location + vector(KFPlayerOwner.PlayerCamera.CameraCache.POV.Rotation) * 10000.f;
    
    foreach KFPlayerOwner.TraceActors(Class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart, vect(8, 8, 8), HitInfo, KFPlayerOwner.TRACEFLAG_Bullet)
    {
        if( KFPawn_Human(HitActor) != None || KFWeldableComponent(HitActor) != None || (KFPawn_Monster(HitActor) != None && (!KFPawn_Monster(HitActor).default.bLargeZed || ChatRep.CheckZEDCloaking(KFPawn_Monster(HitActor)))) || (KFPawn(HitActor) != None && !KFPawn(HitActor).IsAliveAndWell()) )
            continue;
        
        bHitWorld = HitInfo.LevelIndex != INDEX_NONE || HitActor.bWorldGeometry;
        if( !bHitWorld || KFCollectibleActor(HitActor) != None )
        {
            if( !CanActorBePinged(HitActor) )
            {
                if( ChatRep.PingCount > 0 )
                    ChatRep.PingCount--;
                break;
            }
             
            if( KFDroppedPickup(HitActor) != None )
                HitLocation = HitActor.Location;
            else
            {
                HitActor.GetBoundingCylinder(CollisionRadius, CollisionHeight);
                
                CenterBBox = vect(0, 0, 0);
                CenterBBox.Z = CollisionHeight * 0.25f;
                
                HitLocation = HitActor.Location + CenterBBox;
            }
            
            if( KFPickupFactory(HitActor) != None && KFPickupFactory(HitActor).bPickupHidden )
                continue;
        }
        
        ChatRep.ServerPingLocation(HitActor, HitLocation, bHitWorld);
        break;
    }
}

stripped final function context(UKFPHUDInteraction.PingLocation) PingLocation()
{
    PingLocationEx();
}