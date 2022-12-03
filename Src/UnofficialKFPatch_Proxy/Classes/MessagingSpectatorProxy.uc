class MessagingSpectatorProxy extends Object;

stripped reliable client event context(MessagingSpectator.TeamMessage) TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
	local delegate<ReceiveMessage> RM;
    
	if( Type == 'TeamSay' ) 
        return;
    
	if( Type != 'Say' && Type != 'TeamSay' && Type != 'none' )
		`Log("Received message that is not 'say' or 'teamsay'. Type="$Type$" Message= "$s);

    S = `StripHTMLFromString(S);

	foreach Receivers(RM)
		RM(PRI, S, Type);
	if( ReceiveMessage != None )
		ReceiveMessage(PRI, S, Type);
}