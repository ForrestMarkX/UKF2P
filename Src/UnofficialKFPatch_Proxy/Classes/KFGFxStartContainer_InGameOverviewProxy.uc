class KFGFxStartContainer_InGameOverviewProxy extends Object;

stripped function context(KFGFxStartContainer_InGameOverview.ShowWelcomeScreen) ShowWelcomeScreen()
{
	local KFGameReplicationInfo KFGRI;
	local WorldInfo WI;

	if( ServerWelcomeScreen == None )
		return;

	WI = class'WorldInfo'.static.GetWorldInfo();
	if( WI != None && WI.NetMode != NM_Client )
		return;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	if( KFGRI == None )
		return;

	if( KFGRI.ServerAdInfo.BannerLink != "" && !GetPC().WorldInfo.IsConsoleBuild() )
	{
        if( `GetChatRep() != None )
            ServerWelcomeScreen.SetString("messageOfTheDay", Repl(`GetChatRep().ServerMOTD, "@nl@", Chr(10)));

        if( ImageDownloader == None )
            ImageDownloader = new(Outer) class'KFHTTPImageDownloader';
            
        ImageDownloader.DownloadImageFromURL(KFGRI.ServerAdInfo.BannerLink, ImageDownloadComplete);
        
		ServerWelcomeScreen.SetString("clanMotto", KFGRI.ServerAdInfo.ClanMotto);
		ServerWelcomeScreen.SetString("serverName", WI.GRI.ServerName);
        ServerWelcomeScreen.SetString("serverIP", KFGRI.ServerAdInfo.WebsiteLink);
	}
}