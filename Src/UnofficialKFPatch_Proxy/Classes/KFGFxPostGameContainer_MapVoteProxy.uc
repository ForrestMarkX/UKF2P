class KFGFxPostGameContainer_MapVoteProxy extends Object;

stripped function context(KFGFxPostGameContainer_MapVote.Initialize) Initialize( KFGFxObject_Menu NewParentMenu )
{
	Super.Initialize( NewParentMenu );
	LocalizeText();
	SetMapOptions();
    SetupVoteHelper();
}

stripped final function context(KFGFxPostGameContainer_MapVote) SetupVoteHelper()
{
    local MapVoteHelper MVH;
    
	MVH = New(self) class'MapVoteHelper';
    MVH.Init();
}

stripped final function context(KFGFxPostGameContainer_MapVote) SetMapOptionsEx()
{
	local GFxObject MapList, MapObject;
	local int i;
    local xVotingReplication RepInfo;
    
    RepInfo = class'xVotingReplication'.default.StaticReference;
    if( RepInfo == None )
        return;
        
    MapList = CreateArray();    
    if( class'MapVoteHelper'.default.StaticReference.CurrentPageIndex == 0 )
    {
        for( i=0; i<RepInfo.GameModes.Length; i++ )
        {
            MapObject = CreateObject("Object");
            MapObject.SetString("label", RepInfo.GameModes[i].GameName @ "(" $ RepInfo.GameModes[i].GameShortName $ ")");
            MapObject.SetInt("mapindex", i);
            MapList.SetElementObject(i, MapObject);
        }
    }
    else
    {
        MapObject = CreateObject("Object");
        MapObject.SetString("label", "----------- >>>" @ class'KFCommon_LocalizedStrings'.default.ReturnString @ "<<< -----------");
        MapObject.SetInt("mapindex", 0);
        MapList.SetElementObject(0, MapObject);
        
        for( i=0; i<RepInfo.Maps.Length; i++ )
        {
			MapObject = CreateObject("Object");
			MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(RepInfo.Maps[i].MapName) );
			MapObject.SetString("mapSource", GetMapSource(RepInfo.Maps[i].MapName) );
			MapObject.SetInt("mapindex", i + 1);
			MapList.SetElementObject(i + 1, MapObject);
        }
    }
            
	SetObject("mapChoices", MapList);
}

stripped function context(KFGFxPostGameContainer_MapVote.SetMapOptions) SetMapOptions()
{
	local GFxObject MapList;
	local GFxObject MapObject;
	local int i, Counter;
	local array<string> ServerMapList;
	local KFGameReplicationInfo KFGRI;
	local bool IsWeeklyMode;
	local bool IsBrokenTrader;
	local bool IsBossRush;
	local bool IsGunGame;
	local bool bShouldSkipMaps;
	local name MapName;
    
    if( class'xVotingReplication'.default.StaticReference != None )
        SetMapOptionsEx();
    else
    {
        KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

        bShouldSkipMaps = false;
        Counter = 0;

        if( KFGRI != None && KFGRI.VoteCollector != None )
        {
            ServerMapList = KFGRI.VoteCollector.MapList;
            IsWeeklyMode = KFGRI.bIsWeeklyMode;
            IsBrokenTrader = KFGRI.CurrentWeeklyIndex == 11;
            IsBossRush = KFGRI.CurrentWeeklyIndex == 14;
            IsGunGame = KFGRI.CurrentWeeklyIndex == 16;

            bShouldSkipMaps = IsWeeklyMode && (IsBrokenTrader || IsBossRush || IsGunGame);

            MapList = CreateArray();

            for( i=0; i<ServerMapList.Length; i++ )
            {
                MapName = name(ServerMapList[i]);
                if ( bShouldSkipMaps && ( MapName == MapBiolapse || 
                                          MapName == MapNightmare ||
                                          MapName == MapPowerCore ||
                                          MapName == MapDescent ||
                                          MapName == MapKrampus))
                {
                    continue;
                }

                if( IsWeeklyMode && IsBossRush && MapName == MapSteam )
                    continue;

                MapObject = CreateObject("Object");
                MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(ServerMapList[i]) );
                MapObject.SetString("mapSource", GetMapSource(ServerMapList[i]) );
                MapObject.SetInt("mapindex", i);
                MapList.SetElementObject(Counter, MapObject);

                Counter++;
            }
        }

        SetObject("mapChoices", MapList);
    }
}

stripped function context(KFGFxPostGameContainer_MapVote.RecieveTopMaps) RecieveTopMaps(const out TopVotes VoteObject)
{
	local GFxObject MapList;
	local KFGameReplicationInfo KFGRI;
    
    if( class'xVotingReplication'.default.StaticReference != None )
    {
        RecieveTopMapsEx(MapList, VoteObject);
        return;
    }

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	if( KFGRI != None && KFGRI.VoteCollector != None )
	{
		MapList = CreateArray();
		if( VoteObject.Map1Name != "" && VoteObject.Map1Votes > 0 )
			MapList.SetElementObject(0, IndexToTopMapObject(VoteObject.Map1Name, VoteObject.Map1Votes));	
		if( VoteObject.Map2Name != "" && VoteObject.Map2Votes > 0 )
			MapList.SetElementObject(1, IndexToTopMapObject(VoteObject.Map2Name, VoteObject.Map2Votes));	
		if( VoteObject.Map3Name != "" && VoteObject.Map3Votes > 0 )
			MapList.SetElementObject(2, IndexToTopMapObject(VoteObject.Map3Name, VoteObject.Map3Votes));	
	}

	SetObject("currentVotes", MapList);
}

stripped final function context(KFGFxPostGameContainer_MapVote) RecieveTopMapsEx(GFxObject MapList, const out TopVotes VoteObject)
{
    local xVotingReplication RepInfo;
    
    RepInfo = class'xVotingReplication'.default.StaticReference;
    
    MapList = CreateArray();
    if( VoteObject.Map1Name != "" && VoteObject.Map1Votes > 0 )
        MapList.SetElementObject(0, IndexToTopMapObjectEx(RepInfo, 0, VoteObject.Map1Name, VoteObject.Map1Votes));
    if( VoteObject.Map2Name != "" && VoteObject.Map2Votes > 0 )
        MapList.SetElementObject(1, IndexToTopMapObjectEx(RepInfo, 1, VoteObject.Map2Name, VoteObject.Map2Votes));	
    if( VoteObject.Map3Name != "" && VoteObject.Map3Votes > 0 )
        MapList.SetElementObject(2, IndexToTopMapObjectEx(RepInfo, 2, VoteObject.Map3Name, VoteObject.Map3Votes));	

	SetObject("currentVotes", MapList);
}

stripped final function context(KFGFxPostGameContainer_MapVote) GFxObject IndexToTopMapObjectEx(xVotingReplication RepInfo, int Index, string MapName, int VoteCount)
{
	local GFxObject MapObject;
    local string ShortGMS;
    
    switch( Index )
    {
        case 0:
            ShortGMS = "("$RepInfo.GameModes[RepInfo.CurrentAdvancedTopVotes.Game1Index].GameShortName$")";
            break;
        case 1:
            ShortGMS = "("$RepInfo.GameModes[RepInfo.CurrentAdvancedTopVotes.Game2Index].GameShortName$")";
            break;
        case 2:
            ShortGMS = "("$RepInfo.GameModes[RepInfo.CurrentAdvancedTopVotes.Game3Index].GameShortName$")";
            break;
    }

	MapObject = CreateObject("Object");
	MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(MapName)@ShortGMS);
	MapObject.SetString("secondaryText", String(VoteCount));
	MapObject.SetString("mapSource", GetMapSource(MapName));
		
	return MapObject;
}