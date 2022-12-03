class KFGoreManagerProxy extends Object;

stripped simulated function context(KFGoreManager.AddCorpse) AddCorpse(KFPawn NewCorpse)
{
    LimitedAddCorpse(NewCorpse);
}

stripped final simulated function context(KFGoreManager) LimitedAddCorpse(KFPawn NewCorpse)
{
    local byte CurrentMaxBodies;
    local UKFPReplicationInfo URI;
    
    URI = `GetURI();
    if( URI != None && URI.GetEnforceVanilla() )
        CurrentMaxBodies = Clamp(MaxDeadBodies, 4, 12);
    else CurrentMaxBodies = MaxDeadBodies;
    
	if ( CorpsePool.Length >= CurrentMaxBodies )
		MakeRoomForCorpse(NewCorpse);

	if ( CorpsePool.Length < CurrentMaxBodies )
	{
		NewCorpse.LifeSpan = 0.f;
		CorpsePool.AddItem(NewCorpse);
	}
	else DeleteCorpse(NewCorpse);
}