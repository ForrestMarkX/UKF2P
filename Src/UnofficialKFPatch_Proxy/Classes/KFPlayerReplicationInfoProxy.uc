class KFPlayerReplicationInfoProxy extends Object;

stripped simulated event context(KFPlayerReplicationInfo.PostBeginPlay) PostBeginPlay()
{
	Super.PostBeginPlay();

	if( Role == ROLE_Authority )
	{
		KFPlayerOwner = KFPlayerController( Owner );
		ResetSkipTrader();
	}
    
    NetUpdateFrequency = 5.f;
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerStartKickVote) ServerStartKickVote(PlayerReplicationInfo Kickee, PlayerReplicationInfo Kicker)
{
	local KFGameReplicationInfo KFGRI;
    
    if( Kicker != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.ServerStartVoteKick(Kickee, self);
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerCastKickVote) ServerCastKickVote(PlayerReplicationInfo PRI, bool bKick)
{
	local KFGameReplicationInfo KFGRI;
    
    if( PRI != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.RecieveVoteKick(self, bKick);
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerRequestSkipTraderVote) ServerRequestSkipTraderVote(PlayerReplicationInfo PRI)
{
	local KFGameReplicationInfo KFGRI;
    
    if( PRI != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.ServerStartVoteSkipTrader(self);
}

stripped reliable server function context(KFPlayerReplicationInfo.ServerCastSkipTraderVote) ServerCastSkipTraderVote(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	local KFGameReplicationInfo KFGRI;
    
    if( PRI != self )
        return;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != None )
		KFGRI.RecieveVoteSkipTrader(self, bSkipTrader);
}