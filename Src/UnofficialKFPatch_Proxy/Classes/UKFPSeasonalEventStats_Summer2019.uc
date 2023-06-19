class UKFPSeasonalEventStats_Summer2019 extends UKFPSeasonalEventStats;

var int EndlessWaveRequired;

function Init(string MapName)
{
	bObjectiveIsValidForMap[0] = 0; // Complete Steam Fortress on Objective Hard or higher difficulty
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Steam Fortress
	bObjectiveIsValidForMap[2] = 0; // Complete Steam Fortress wave 15 on Endless Hard or higher difficulty
	bObjectiveIsValidForMap[3] = 0; // Complete Zed Landing on Objective Hard or higher difficulty
	bObjectiveIsValidForMap[4] = 0; // Complete Outpost on Objective Hard or higher difficulty

    if( InStr(MapName, "KF-SteamFortress", false, true) != INDEX_NONE )
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
	}
    else if( InStr(MapName, "KF-ZedLanding", false, true) != INDEX_NONE )
		bObjectiveIsValidForMap[3] = 1;
    else if( InStr(MapName, "KF-Outpost", false, true) != INDEX_NONE )
		bObjectiveIsValidForMap[4] = 1;
}

simulated function GrantEventItemsEx()
{
	if( IsEventObjectiveComplete(0) &&
		IsEventObjectiveComplete(1) &&
		IsEventObjectiveComplete(2) &&
		IsEventObjectiveComplete(3) &&
		IsEventObjectiveComplete(4) )
	{
		GrantEventItemEx(7439);
	}
}

simulated function OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if( ClassIsChildOf(GameClass, class'KFGameInfo_Objective') && Difficulty >= `DIFFICULTY_HARD )
	{
		if( bObjectiveIsValidForMap[4] != 0 )
			FinishedObjectiveEx(SEI_Summer, 4);
		else if( bObjectiveIsValidForMap[3] != 0 )
			FinishedObjectiveEx(SEI_Summer, 3);
		else if( bObjectiveIsValidForMap[0] != 0 )
			FinishedObjectiveEx(SEI_Summer, 0);
	}
    else if( bObjectiveIsValidForMap[1] != 0 && ClassIsChildOf(GameClass, class'KFGameInfo_WeeklySurvival') )
		FinishedObjectiveEx(SEI_Summer, 1);
}

simulated function OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	if( bObjectiveIsValidForMap[2] != 0 && WaveNum >= EndlessWaveRequired && ClassIsChildOf(GameClass, class'KFGameInfo_Endless') && Difficulty >= `DIFFICULTY_HARD )
		FinishedObjectiveEx(SEI_Summer, 2);
}

defaultproperties
{
	EndlessWaveRequired=15
}