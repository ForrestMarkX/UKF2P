class KFGameInfo_SurvivalProxy extends Object;

stripped function context(KFGameInfo_Survival.StartMatch) StartMatch()
{
    local KFPlayerController KFPC;
	
	WaveNum = 0;

	Super.StartMatch();
	
	`GetURI().NotifyMatchStarted();

	if( class'KFGameEngine'.static.CheckNoAutoStart() || class'KFGameEngine'.static.IsEditor() )
		GotoState('DebugSuspendWave');
	else GotoState('PlayingWave');

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
        KFPC.ClientMatchStarted();
}

stripped function context(KFGameInfo_Survival.StartWave) StartWave()
{
	local int WaveBuffer;
	local KFPlayerController KFPC;

	if( MyKFGRI.OpenedTrader != None )
	{
		MyKFGRI.CloseTrader();
		NotifyTraderClosed();
	}

	WaveBuffer = 0;
	WaveNum++;
	MyKFGRI.WaveNum = WaveNum;

	if( IsMapObjectiveEnabled() )
	{
		MyKFGRI.ClearPreviousObjective();
		if( MyKFGRI.StartNextObjective() )
			WaveBuffer = ObjectiveSpawnDelay;
	}

    SetupNextWave(WaveBuffer);

	NumAIFinishedSpawning = 0;
	NumAISpawnsQueued = 0;
	AIAliveCount = 0;
	MyKFGRI.bForceNextObjective = false;

	if( WorldInfo.NetMode != NM_DedicatedServer && Role == ROLE_Authority )
		MyKFGRI.UpdateHUDWaveCount();

	WaveStarted();
	MyKFGRI.NotifyWaveStart();
	MyKFGRI.AIRemaining = SpawnManager.WaveTotalAI;
	MyKFGRI.WaveTotalAICount = SpawnManager.WaveTotalAI;

	BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GetWaveStartMessage());

    SetupNextTrader();
	ResetAllPickups();

	`DialogManager.SetTraderTime( false );

	SetTimer( 5.f, false, nameof(PlayWaveStartDialog) );

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if( KFPC.GetPerk() != None )
			KFPC.GetPerk().OnWaveStart();
	}
    
    `GetURI().NotifyWaveStarted();
}

state TraderOpen
{
	stripped function context(KFGameInfo_Survival.TraderOpen.BeginState) BeginState( Name PreviousStateName )
	{
		local KFPlayerController KFPC;

		MyKFGRI.SetWaveActive(FALSE, GetGameIntensityForMusic());

		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			if( KFPC.GetPerk() != None )
				KFPC.GetPerk().OnWaveEnded();
			KFPC.ApplyPendingPerks();
		}

		StartHumans();
		OpenTrader();

		SetTimer(TimeBetweenWaves, false, 'CloseTraderTimer');
		
		`GetURI().NotifyWaveEnded();
	}
}

stripped function context(KFGameInfo_Survival.TryRestartGame) TryRestartGame()
{
    if( `GetURI().VotingHandler != None )
        return;
	RestartGame();
}

stripped final function context(KFGameInfo_Survival.ForceChangeLevel) ForceChangeLevel()
{
    if( `GetURI().VotingHandler != None )
        return;
    bGameRestarted = false;
    bChangeLevels = true;
    RestartGame();
}