class KFGFxHudWrapperProxy extends Object;

stripped function context(KFGFxHudWrapper.CreateHUDMovie) CreateHUDMovie(optional bool bForce)
{
	if( HudMovie != None && !bForce )
        return;

	HudMovie = new HUDClass;
    HudMovie.SetMovieInfo(SwfMovie'UKFP_UI_HUD.UKFP_InGameHUD_SWF');
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
    
    HudMovie.SpecialWaveIconPath[AT_FleshpoundMini] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_FP";
    HudMovie.SpecialWaveIconPath[AT_EliteClot] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_Clot";
    HudMovie.SpecialWaveIconPath[AT_EliteCrawler] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_Crawler";
    HudMovie.SpecialWaveIconPath[AT_EliteGoreFast] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_Gorefast";
    HudMovie.SpecialWaveIconPath[AT_EDAR_EMP] = "Spring_UI.UI_Objectives_Spring_DAR01";
    HudMovie.SpecialWaveIconPath[AT_EDAR_Laser] = "Spring_UI.UI_Objectives_Spring_DAR03";
    HudMovie.SpecialWaveIconPath[AT_EDAR_Rocket] = "Spring_UI.UI_Objectives_Spring_DAR05";

    HudMovie.SpecialWaveLocKey[AT_FleshpoundMini] = "KFPawn_ZedFleshPoundMini";
    HudMovie.SpecialWaveLocKey[AT_EliteClot] = "KFPawn_ZedClot_AlphaKing";
    HudMovie.SpecialWaveLocKey[AT_EliteCrawler] = "KFPawn_ZedCrawlerKing";
    HudMovie.SpecialWaveLocKey[AT_EliteGoreFast] = "KFPawn_ZedGorefastDualBlade";
    HudMovie.SpecialWaveLocKey[AT_EDAR_EMP] = "KFPawn_ZedDAR_EMP";
    HudMovie.SpecialWaveLocKey[AT_EDAR_Laser] = "KFPawn_ZedDAR_Laser";
    HudMovie.SpecialWaveLocKey[AT_EDAR_Rocket] = "KFPawn_ZedDAR_Rocket";
}

stripped function context(KFGFxHudWrapper.LocalizedMessage) LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	PlayerReplicationInfo	RelatedPRI_2,
	string					MessageString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	Color					DrawColor,
	optional object			OptionalObject
)
{
	local KFPlayerController KFPC;
	local string HexClr;
	local class<KFLocalMessage>  KFLocalMessageClass;
    
    if( MessageString == "" )
        return;

	KFPC = KFPlayerController(PlayerOwner);
    if( !InMessageClass.default.bIsSpecial )
    {
	    AddConsoleMessage( MessageString, InMessageClass, RelatedPRI_1 );
		return;
    }
    
	if( bMessageBeep && InMessageClass.default.bBeep )
		PlayerOwner.PlayBeepSound();

    KFLocalMessageClass = class<KFLocalMessage>(InMessageClass);
    if( KFLocalMessageClass != None )
        HexClr = KFLocalMessageClass.static.GetHexColor(Switch);
    else if( InMessageClass == class'GameMessage' )
        HexClr = class'KFLocalMessage'.default.ConnectionColor;
        
    if( KFPC.MyGFxManager != None && KFPC.MyGFxManager.PartyWidget != None )
    	KFPC.MyGFxManager.PartyWidget.ReceiveMessage(MessageString, HexClr);
        
    KFLocalMessageClass = class<KFLocalMessage>(InMessageClass);
    if( KFLocalMessageClass != None )
        HexClr = KFLocalMessageClass.static.GetHexColor(Switch);
    else HexClr = class'KFLocalMessage'.default.ConnectionColor;
        
    if( class<GameMessage>(InMessageClass) != None )
        MessageString = class'UKFPGameMessage'.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject);
   
    if( HudMovie != None && HudMovie.HudChatBox != None )
    	HudMovie.HudChatBox.AddChatMessage(MessageString, HexClr);
}