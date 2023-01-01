class ConsoleProxy extends Object;

stripped function context(Console.ConsoleCommand) ConsoleCommand(string Command)
{
	if( !`GetChatRep().bDoNotSaveConsoleHistory )
	{
		if( (HistoryTop == 0) ? !(History[MaxHistory - 1] ~= Command) : !(History[HistoryTop - 1] ~= Command) )
		{
			PurgeCommandFromHistory(Command);

			History[HistoryTop] = Command;
			HistoryTop = (HistoryTop+1) % MaxHistory;

			if( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
				HistoryBot = (HistoryBot+1) % MaxHistory;
		}
		HistoryCur = HistoryTop;

		SaveConfig();

		OutputText("\n>>>" @ Command @ "<<<");
	}
    
    if( `GetChatRep().ExecuteCommand(Command) )
		return;

	if( ConsoleTargetPlayer != None )
		ConsoleTargetPlayer.Actor.ConsoleCommand(Command);
	else if( GamePlayers.Length > 0 && GamePlayers[0].Actor != None )
		GamePlayers[0].Actor.ConsoleCommand(Command);
	else Outer.ConsoleCommand(Command);
}