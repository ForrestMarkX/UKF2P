class KFPlayerReplicationInfoOriginal extends Object;

simulated event PostBeginPlay();
reliable server function ServerStartKickVote(PlayerReplicationInfo Kickee, PlayerReplicationInfo Kicker);
reliable server function ServerCastKickVote(PlayerReplicationInfo PRI, bool bKick);
reliable server function ServerRequestSkipTraderVote(PlayerReplicationInfo PRI);
reliable server function ServerCastSkipTraderVote(PlayerReplicationInfo PRI, bool bSkipTrader);