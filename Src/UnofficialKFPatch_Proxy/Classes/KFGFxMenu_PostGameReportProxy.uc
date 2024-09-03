class KFGFxMenu_PostGameReportProxy extends Object;

stripped function context(KFGFxMenu_PostGameReport.Callback_MapVote) Callback_MapVote(int MapVoteIndex, bool bDoubleClick)
{
    Callback_MapVoteEx(MapVoteIndex, bDoubleClick);
}

stripped final function context(KFGFxMenu_PostGameReport) Callback_MapVoteEx(int MapVoteIndex, bool bDoubleClick)
{
    local xVotingReplication RepInfo;
    local MapVoteHelper MVH;
    local KFPlayerReplicationInfo KFPRI;
    
    RepInfo = class'xVotingReplication'.default.StaticReference;
    if( RepInfo == None )
    {
        KFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);
        KFPRI.CastMapVote(MapVoteIndex, bDoubleClick);
        return;
    }
    
    MVH = class'MapVoteHelper'.default.StaticReference;
    if( MVH.CurrentPageIndex > 0 )
    {
        if( MapVoteIndex == -1 )
        {
            MVH.CurrentPageIndex = 0;
            ResetSelection();
        }
        else 
        {
            RepInfo.ServerCastVote(MVH.CurrentPageIndex-1,MapVoteIndex,false);
            MVH.SelectedPageIndex = MVH.CurrentPageIndex;
        }
    }
    else 
    {
        if( RepInfo.GameModes[MapVoteIndex].GameName ~= " " )
            return;
            
        MVH.CurrentPageIndex = MapVoteIndex+1;
        MapVoteContainer.ActionScriptVoid("pageSelected");
        ResetSelection();
    }
}

stripped final function context(KFGFxMenu_PostGameReport) ResetSelection()
{
    MapVoteContainer.ActionScriptVoid("resetSelection");
    MapVoteContainer.SetMapOptions();
    
    `TimerHelper.SetTimer(GetPC().WorldInfo.DeltaSeconds*2.f, false, 'ForceResetSelection', class'MapVoteHelper'.default.StaticReference);
    
    if( class'MapVoteHelper'.default.StaticReference.SelectedPageIndex == class'MapVoteHelper'.default.StaticReference.CurrentPageIndex )
        MapVoteContainer.ActionScriptVoid("updateSelectedIndex");
}

stripped function context(KFGFxMenu_PostGameReport.Callback_TopMapClicked) Callback_TopMapClicked(int MapVoteIndex, bool bDoubleClick)
{
    Callback_TopMapClickedEx(MapVoteIndex, bDoubleClick);
}

stripped final function context(KFGFxMenu_PostGameReport) Callback_TopMapClickedEx(int MapVoteIndex, bool bDoubleClick)
{
    local string SearchString;
	local int GameIndex, SearchIndex, i;
    local xVotingReplication RepInfo;
    
    RepInfo = class'xVotingReplication'.default.StaticReference;
    if( RepInfo == None )
    {
        switch( MapVoteIndex )
        {
            case 0:
                SearchString = CurrentTopVoteObject.Map1Name;
                break;
            case 1:
                SearchString = CurrentTopVoteObject.Map2Name;
                break;
            case 2:
                SearchString = CurrentTopVoteObject.Map3Name;
                break;
        }

        SearchIndex = KFGameReplicationInfo(GetPC().WorldInfo.GRI).VoteCollector.MapList.Find(SearchString);
        Callback_MapVote(SearchIndex, bDoubleClick);
        
        return;
    }

	switch (MapVoteIndex)
	{
		case 0:
            SearchString = CurrentTopVoteObject.Map1Name;
			GameIndex = RepInfo.CurrentAdvancedTopVotes.Game1Index;
			break;
		case 1:
            SearchString = CurrentTopVoteObject.Map2Name;
			GameIndex = RepInfo.CurrentAdvancedTopVotes.Game2Index;
			break;
		case 2:
            SearchString = CurrentTopVoteObject.Map3Name;
			GameIndex = RepInfo.CurrentAdvancedTopVotes.Game3Index;
			break;
	}
    
    for( i=0; i<RepInfo.Maps.Length; i++ )
    {
        if( RepInfo.Maps[i].CycleIndex == RepInfo.GameModes[GameIndex].CycleIndex && RepInfo.Maps[i].MapName ~= SearchString )
            break;
    }
    
    RepInfo.ServerCastVote(GameIndex, i, false);
}