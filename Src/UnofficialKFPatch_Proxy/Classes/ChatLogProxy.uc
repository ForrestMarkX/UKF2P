class ChatLogProxy extends Object;

stripped function context(ChatLog.ReceiveMessage) ReceiveMessage( PlayerReplicationInfo Sender, string Msg, name Type )
{
	local string UniqueId;
	local int TeamIndex;
    
    Msg = `StripHTMLFromString(Msg);
    
	if( Writer == None )
		CreateFileWriter();

	if( Sender == None )
	{
		Writer.Logf(TimeStamp()$Tab$""$Tab$""$Tab$Type$Tab$INDEX_NONE$Tab$Msg);
		return;
	}
    
	UniqueId = class'OnlineSubsystem'.static.UniqueNetIdToString(Sender.UniqueId);
	if( Sender.Team == None )
		TeamIndex = INDEX_NONE;
	else TeamIndex = Sender.Team.TeamIndex;

	Writer.Logf(TimeStamp() $ Tab $ class'WebAdminUtils'.static.translitText(Sender.PlayerName) $ Tab $ UniqueId $ Tab $ Type $ Tab $ TeamIndex $ Tab $ class'WebAdminUtils'.static.translitText(Msg));
}