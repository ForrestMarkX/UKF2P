class KFGFxHudWrapperProxy extends Object;

stripped function context(KFGFxHudWrapper.CreateHUDMovie) CreateHUDMovie(optional bool bForce)
{
	if( HudMovie != None && !bForce )
        return;

	HudMovie = new HUDClass;
    HudMovie.SetMovieInfo(SwfMovie(`SafeLoadObject("UKFP_UI_HUD.InGameHUD_SWF", class'SwfMovie')));
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
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