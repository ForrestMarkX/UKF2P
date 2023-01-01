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

stripped function context(KFGameInfo_Survival.NotifyTraderOpened) NotifyTraderOpened()
{
	local array<SequenceObject> AllTraderOpenedEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_TraderOpened TraderOpenedEvt;
	local Sequence GameSeq;
	local int i;
	
	`GetURI().NotifyWaveEnded();

	GameSeq = WorldInfo.GetGameSequence();
	if( GameSeq != None )
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderOpened', true, AllTraderOpenedEvents);
		for( i=0; i<AllTraderOpenedEvents.Length; i++ )
		{
			TraderOpenedEvt = KFSeqEvent_TraderOpened(AllTraderOpenedEvents[i]);
			if( TraderOpenedEvt != None )
			{
				TraderOpenedEvt.Reset();
				TraderOpenedEvt.SetWaveNum(WaveNum, WaveMax);
				if( MyKFGRI.IsFinalWave() && TraderOpenedEvt.OutputLinks.Length > 1 )
					OutputLinksToActivate.AddItem(1);
				else OutputLinksToActivate.AddItem(0);
				TraderOpenedEvt.CheckActivate(self, self,, OutputLinksToActivate);
			}
		}
	}
}

stripped function context(KFGameInfo_Survival.NotifyTraderClosed) NotifyTraderClosed()
{
	local KFSeqEvent_TraderClosed TraderClosedEvt;
	local array<SequenceObject> AllTraderClosedEvents;
	local Sequence GameSeq;
	local int i;
	
	`GetURI().NotifyWaveStarted();

	GameSeq = WorldInfo.GetGameSequence();
	if( GameSeq != None )
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderClosed', true, AllTraderClosedEvents);
		for( i=0; i<AllTraderClosedEvents.Length; ++i )
		{
			TraderClosedEvt = KFSeqEvent_TraderClosed(AllTraderClosedEvents[i]);
			if( TraderClosedEvt != None )
			{
				TraderClosedEvt.Reset();
				TraderClosedEvt.SetWaveNum(WaveNum, WaveMax);
				TraderClosedEvt.CheckActivate(self, self);
			}
		}
	}
}