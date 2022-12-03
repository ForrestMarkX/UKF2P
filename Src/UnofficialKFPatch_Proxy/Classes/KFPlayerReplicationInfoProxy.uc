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