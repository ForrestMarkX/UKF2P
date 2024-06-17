class LocalPlayerProxy extends Object;

stripped function context(LocalPlayer.Cleanup) Cleanup(optional bool bExit)
{
	if( GamePlayers[0] == self )
	{
		if( CachedAuthInt != None )
		{
			CachedAuthInt.ClearClientAuthRequestDelegate(ProcessClientAuthRequest);
			CachedAuthInt.ClearServerAuthResponseDelegate(ProcessServerAuthResponse);
			CachedAuthInt.ClearServerAuthCompleteDelegate(OnServerAuthComplete);
			CachedAuthInt.ClearClientAuthEndSessionRequestDelegate(ProcessClientAuthEndSessionRequest);
			CachedAuthInt.ClearServerConnectionCloseDelegate(OnServerConnectionClose);

			if( bExit )
			{
				CachedAuthInt.EndAllLocalClientAuthSessions();
				CachedAuthInt.EndAllRemoteServerAuthSessions();
			}
		}

		CachedAuthInt = None;
		bPendingServerAuth = False;
	}
    
    `GetURI().Cleanup();
}