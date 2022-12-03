class BasicWebAdminUserProxy extends Object;

stripped protected function context(BasicWebAdminUser.linkPlayerController) linkPlayerController(string Username)
{
	if( PC != None )
	{
		if( PC.PlayerReplicationInfo.PlayerName == Username )
			return;
		PC.ClearReceiver(ReceiveMessage);
		PC = none;
	}
    
	foreach WorldInfo.AllControllers(class'MessagingSpectator', PC)
	{
		if( PC.IsA(PCClass.Name) && PC.PlayerReplicationInfo.PlayerName == Username )
		{
			PC.AddReceiver(ReceiveMessage);
			return;
		}
	}

	PC = WorldInfo.Spawn(PCClass);
	PC.PlayerReplicationInfo.PlayerName = Username;
	PC.PlayerReplicationInfo.bAdmin = true;
	PC.PlayerReplicationInfo.bBot = true;
	PC.AddReceiver(ReceiveMessage);
}