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

stripped function context(KFGFxPostGameContainer_MapVote.LocalizeText) LocalizeText()
{
	local GFxObject TextObject;

	TextObject = CreateObject("Object");

	TextObject.SetString("yourVote", 	YourVoteString);
	TextObject.SetString("mapList", 	MapVoteString);
	TextObject.SetString("topVotes", 	TopVotesString);
	TextObject.SetString("returnText", 	class'KFCommon_LocalizedStrings'.default.BackString);

	SetObject("localizedText", TextObject);
}

stripped final function context(KFGFxPostGameContainer_MapVote) SetMapOptionsEx()
{
	local GFxObject MapList, MapObject;
	local int i, WeeklyIndex;
    local xVotingReplication RepInfo;
    local name MapName;
    local string Options;
	local bool IsWeeklyMode, IsBrokenTrader, IsBossRush, IsGunGame, bShouldSkipMaps;
    local class<GameInfo> GC;
    
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
            MapObject.SetBool("isGamemodeSelection", true);
            MapObject.SetString("textColor", "0xFBD2BF");
            MapList.SetElementObject(i, MapObject);
        }
    }
    else
    {
        GC = GetPC().WorldInfo.GRI.GameClass;
        if( GC == None )
            GC = class'GameInfo';
        
        Options = RepInfo.GameModes[class'MapVoteHelper'.default.StaticReference.CurrentPageIndex-1].Options;
        WeeklyIndex = GC.static.GetIntOption(Options, "CurrentWeekly", -1);
        
        IsWeeklyMode = class<KFGameInfo_WeeklySurvival>(DynamicLoadObject(GC.static.ParseOption(Options, "Game"), class'Class', true)) != None;
        IsBrokenTrader = WeeklyIndex == 11;
        IsBossRush = WeeklyIndex == 14;
        IsGunGame = WeeklyIndex == 16;
        
        bShouldSkipMaps = IsWeeklyMode && (IsBrokenTrader || IsBossRush || IsGunGame);
        
        for( i=0; i<RepInfo.Maps.Length; i++ )
        {
            MapName = name(RepInfo.Maps[i].MapName);
            if( (bShouldSkipMaps && (MapName == MapBiolapse || MapName == MapNightmare || MapName == MapPowerCore || MapName == MapDescent || MapName == MapKrampus)) || (IsWeeklyMode && IsBossRush && MapName == MapSteam) )
                continue;
                
			MapObject = CreateObject("Object");
			MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(RepInfo.Maps[i].MapName) );
			MapObject.SetString("mapSource", GetMapSource(RepInfo.Maps[i].MapName) );
			MapObject.SetInt("mapindex", i);
            MapObject.SetBool("isHeader", !(Left(RepInfo.Maps[i].MapName, 3) ~= "KF-"));
			MapList.SetElementObject(i, MapObject);
        }
    }
            
	SetObject("mapChoices", MapList);
    if( class'MapVoteHelper'.default.StaticReference.CurrentPageIndex > 0 )
        `TimerHelper.SetTimer(GetPC().WorldInfo.DeltaSeconds, false, 'LoadScrollingIndex', class'MapVoteHelper'.default.StaticReference);
}

stripped function context(KFGFxPostGameContainer_MapVote.SetMapOptions) SetMapOptions()
{
	local GFxObject MapList;
	local GFxObject MapObject;
	local int i, Counter;
	local array<string> ServerMapList;
	local KFGameReplicationInfo KFGRI;
	local bool IsWeeklyMode;
	local bool IsBoom, IsScavenger, IsBossRush, IsGunGame, IsContaminationMode, IsBountyHunt;
	local name MapName;

    if( class'xVotingReplication'.default.StaticReference != None )
        SetMapOptionsEx();
    else
    {
        KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

        Counter = 0;

        if (KFGRI != none && KFGRI.VoteCollector != none)
        {
            ServerMapList = KFGRI.VoteCollector.MapList;

            IsWeeklyMode = KFGRI.bIsWeeklyMode;

            IsBoom = false;
            IsScavenger = false;
            IsBossRush = false;
            IsGunGame = false;
            IsContaminationMode = false;
            IsBountyHunt = false;

            switch (KFGRI.CurrentWeeklyIndex)
            {
                case 0: IsBoom = true; break;
                case 11: IsScavenger = true; break;
                case 14: IsBossRush = true; break;
                case 16: IsGunGame = true; break;
                case 19: IsContaminationMode = true; break;
                case 20: IsBountyHunt = true; break;
            }

            MapList = CreateArray();

            for (i = 0; i < ServerMapList.length; i++)
            {
                MapName = name(ServerMapList[i]);

                if (IsWeeklyMode)
                {
                    if (MapName == MapSantas)
                    {
                        continue;
                    }
                }

                if (IsWeeklyMode && IsBoom)
                {
                    if (MapName == MapSteam)
                    {
                        continue;
                    }				
                }

                if (IsWeeklyMode && (IsScavenger || IsBossRush || IsGunGame))
                {
                    if (MapName == MapBiolapse || 
                        MapName == MapNightmare ||
                        MapName == MapPowerCore ||
                        MapName == MapDescent ||
                        MapName == MapKrampus)
                    {
                        continue;
                    }
                }

                if (IsWeeklyMode && IsContaminationMode)
                {
                    if (MapName == MapBiolapse || 
                        MapName == MapNightmare ||
                        MapName == MapPowerCore ||
                        MapName == MapDescent ||
                        MapName == MapKrampus ||
                        MapName == MapElysium ||
                        MapName == MapSantas)
                    {
                        continue;
                    }				
                }

                if (IsWeeklyMode && IsBountyHunt)
                {
                    if (MapName == MapBiolapse || 
                        MapName == MapNightmare ||
                        MapName == MapPowerCore ||
                        MapName == MapDescent ||
                        MapName == MapKrampus ||
                        MapName == MapElysium ||
                        MapName == MapSteam)
                    {
                        continue;
                    }				
                }			

                if (IsWeeklyMode && IsBossRush)
                {
                    if (MapName == MapSteam)
                    {
                        continue;
                    }
                }

                MapObject = CreateObject("Object");
                MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(ServerMapList[i]) );
                MapObject.SetString("mapSource", GetMapSource(ServerMapList[i]) );
                MapObject.SetInt("mapindex", i);
                MapObject.SetBool("isHeader", !(Left(ServerMapList[i], 3) ~= "KF-"));
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