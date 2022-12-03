class KFGFxObject_MenuProxy extends Object;

stripped function context(KFGFxObject_Menu.Callback_RequestTeamSwitch) Callback_RequestTeamSwitch()
{
	local KFPlayerController KFPC;
    
    if( class'PartyWidgetHelper'.default.StaticReference != None )
    {
        Callback_RequestPageChange();
        return;
    }
    
    KFPC = KFPlayerController(GetPC());
	if( KFPC != None )
		KFPC.RequestSwitchTeam();
}

stripped final function context(KFGFxObject_Menu) Callback_RequestPageChange()
{
	local PartyWidgetHelper WH;
    
    WH = class'PartyWidgetHelper'.default.StaticReference;
    if( WH.LobbyCurrentPage < WH.LobbyMaxPage )
        ++WH.LobbyCurrentPage;
    else WH.LobbyCurrentPage = 1;
}