class PlayerControllerProxy extends Object;

stripped final simulated function context(PlayerController) SayEx( string Msg )
{
    local string StrippedMsg;
    
    StrippedMsg = `StripHTMLFromString(Msg);
    if( Len(StrippedMsg) > 128 )
    {
        `GetChatRep().WriteToChat("Message is too long "$Len(StrippedMsg)$"/128 characters", "FF0000");
        return;
    }
        
    if( Left(StrippedMsg,1) == "!" && `GetURI().ClientProcessChatMessage(Mid(StrippedMsg, 1), Self) )
        return;
        
	if( AllowTextMessage(StrippedMsg) )
		ServerSay(`FormatMIcon(Msg));
}

stripped exec function context(PlayerController.Say) Say( string Msg )
{
    SayEx(Msg);
}

stripped final simulated function context(PlayerController) TeamSayEx( string Msg )
{
    local string StrippedMsg;
    
    StrippedMsg = `StripHTMLFromString(Msg);
    if( Len(StrippedMsg) > 128 )
    {
        `GetChatRep().WriteToChat("Message is too long "$Len(StrippedMsg)$"/128 characters", "FF0000");
        return;
    }
        
    if( Left(StrippedMsg,1) == "!" && `GetURI().ClientProcessChatMessage(Mid(StrippedMsg, 1), Self, true) )
        return;
        
	if( AllowTextMessage(StrippedMsg) )
		ServerTeamSay(`FormatMIcon(Msg));
}

stripped exec function context(PlayerController.TeamSay) TeamSay( string Msg )
{
    TeamSayEx(Msg);
}

stripped unreliable server function context(PlayerController.ServerSay) ServerSay( string Msg )
{
	local PlayerController PC;

	if( PlayerReplicationInfo.bAdmin && Left(Msg,1) == "#" )
	{
		Msg = Right(Msg,Len(Msg)-1);
		foreach WorldInfo.AllControllers(class'PlayerController', PC)
			PC.ClientAdminMessage(Msg);
		return;
	}

    if( Left(Msg,1) == "!" && `GetURI().ProcessChatMessage(Mid(Msg, 1), Self) )
        return;
	WorldInfo.Game.Broadcast(self, Msg, 'Say');
}

stripped unreliable server function context(PlayerController.ServerTeamSay) ServerTeamSay( string Msg )
{
	LastActiveTime = WorldInfo.TimeSeconds;

	if( !WorldInfo.GRI.GameClass.default.bTeamGame )
	{
		Say(Msg);
		return;
	}

    if( Left(Msg,1) == "!" && `GetURI().ProcessChatMessage(Mid(Msg, 1), Self, true) )
        return;
    WorldInfo.Game.BroadcastTeam(self, Msg, 'TeamSay');
}

stripped reliable server function context(PlayerController.ServerCamera) ServerCamera( name NewMode )
{
	if( NewMode == '1st' )
    	NewMode = 'FirstPerson';
    else if( NewMode == '3rd' )
    	NewMode = 'ThirdPerson';
	SetCameraMode( NewMode );
}