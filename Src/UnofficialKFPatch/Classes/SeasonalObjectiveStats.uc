class SeasonalObjectiveStats extends Info;

var transient KFPlayerController PCOwner;
var transient ReplicationHelper CRI;
var transient SeasonalObjectiveData SaveData;
var transient bool bDataLoaded;
var transient byte SeasonalIndex;
var transient string DataDir;

var int SeasonalEventStatsMax1, SeasonalEventStatsMax2, SeasonalEventStatsMax3, SeasonalEventStatsMax4, SeasonalEventStatsMax5;

struct FSeasonalStats
{
    var int SeasonalEventStats1, SeasonalEventStats2, SeasonalEventStats3, SeasonalEventStats4, SeasonalEventStats5;
};
var repnotify FSeasonalStats SeasonalStats;

replication
{
    if( true )
        SeasonalStats;
}

simulated function ReplicatedEvent(name VarName)
{
    switch( VarName )
    {
        case 'SeasonalStats':
            if( !bDataLoaded )
            {
                OnSeasonalDataLoaded();
                bDataLoaded = true;
            }

            CRI.bForceObjectiveRefresh = true;
            if( PCOwner.MyGFxManager != None && PCOwner.MyGFxManager.StartMenu != None && PCOwner.MyGFxManager.StartMenu.MissionObjectiveContainer != None )
                PCOwner.MyGFxManager.StartMenu.MissionObjectiveContainer.FullRefresh();
            else SetTimer(WorldInfo.DeltaSeconds, false, 'WaitForUI');
                
            break;
    }
    
    Super.ReplicatedEvent(VarName);
}

simulated function WaitForUI()
{
    ReplicatedEvent('SeasonalStats');
}

simulated function OnSeasonalDataLoaded()
{
    if( `GetURI() == None )
    {
        SetTimer(0.01f, true, 'WaitForReplicationInfo');
        return;
    }
    `GetURI().FunctionProxy.OnSeasonalDataLoaded(PCOwner, CRI);
}

simulated function WaitForReplicationInfo()
{
    if( `GetURI() == None )
        return;
    
    ClearTimer('WaitForReplicationInfo');
    OnSeasonalDataLoaded();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if( Role < ROLE_Authority )
    {
        CRI = `GetChatRep();
        PCOwner = KFPlayerController(GetALocalPlayerController());
        SetOwner(PCOwner);
    }
    else 
    {
        PCOwner = KFPlayerController(Owner);
        CRI = `GetURI().GetPlayerChat(PCOwner.PlayerReplicationInfo);
        if( WorldInfo.NetMode == NM_StandAlone )
            DataDir = "../../KFGame/SeasonalStatsData.usa";
        else DataDir = Repl("../../KFGame/Script/SeasonalSaveData/%s.dat","%s",class'GameEngine'.static.GetOnlineSubsystem().UniqueNetIdToInt64(PCOwner.PlayerReplicationInfo.UniqueId));
    }
}

function LoadObjectiveData(int Index)
{
    if( SaveData != None )
    {
        SaveObjectiveData();
        SaveData = None;
    }
    
    SaveData = new class'SeasonalObjectiveData';
    if( class'Engine'.static.BasicLoadObject(SaveData,DataDir,false,0) )
    {
        if( SaveData.SeasonalStats.Length > Index )
            SeasonalStats = SaveData.SeasonalStats[Index];
        else SaveData.SeasonalStats.Length = Index+1;
        
        SeasonalIndex = Index;
        bDataLoaded = true;
        bForceNetUpdate = true;
        
        if( WorldInfo.NetMode != NM_DedicatedServer )
            ReplicatedEvent('SeasonalStats');
    }
}

function SaveObjectiveData()
{
    SaveData.SeasonalStats[SeasonalIndex] = SeasonalStats;
    class'Engine'.static.BasicSaveObject(SaveData,DataDir,false,0);
}

simulated function int GetCurrentObjectStat(int Index)
{
    switch( Index )
    {
        case 0:
            return SeasonalStats.SeasonalEventStats1;
        case 1:
            return SeasonalStats.SeasonalEventStats2;
        case 2:
            return SeasonalStats.SeasonalEventStats3;
        case 3:
            return SeasonalStats.SeasonalEventStats4;
        case 4:
            return SeasonalStats.SeasonalEventStats5;
    }
    
    return 0;
}

simulated function int GetCurrentObjectMaxStat(int Index)
{
    switch( Index )
    {
        case 0:
            return SeasonalEventStatsMax1;
        case 1:
            return SeasonalEventStatsMax2;
        case 2:
            return SeasonalEventStatsMax3;
        case 3:
            return SeasonalEventStatsMax4;
        case 4:
            return SeasonalEventStatsMax5;
    }
    
    return 0;
}

simulated function IncrementCurrentObjectStat(int Index, int Value)
{
    switch( Index )
    {
        case 0:
            SeasonalStats.SeasonalEventStats1 += Value;
            break;
        case 1:
            SeasonalStats.SeasonalEventStats2 += Value;
            break;
        case 2:
            SeasonalStats.SeasonalEventStats3 += Value;
            break;
        case 3:
            SeasonalStats.SeasonalEventStats4 += Value;
            break;
        case 4:
            SeasonalStats.SeasonalEventStats5 += Value;
            break;
    }
    
    if( WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_ListenServer )
        ReplicatedEvent('SeasonalStats');
    
    if( Role < ROLE_Authority )
        ServerIncrementCurrentObjectStat(Index, Value);
}

simulated function ResetCurrentObjectStat(int Index)
{
    switch( Index )
    {
        case 0:
            SeasonalStats.SeasonalEventStats1 = 0;
            break;
        case 1:
            SeasonalStats.SeasonalEventStats2 = 0;
            break;
        case 2:
            SeasonalStats.SeasonalEventStats3 = 0;
            break;
        case 3:
            SeasonalStats.SeasonalEventStats4 = 0;
            break;
        case 4:
            SeasonalStats.SeasonalEventStats5 = 0;
            break;
    }
    
    if( WorldInfo.NetMode == NM_StandAlone || WorldInfo.NetMode == NM_ListenServer )
        ReplicatedEvent('SeasonalStats');
    
    if( Role < ROLE_Authority )
        ServerResetCurrentObjectStat(Index);
}

simulated function bool IsEventObjectiveComplete(int ObjectiveIndex)
{
    switch( ObjectiveIndex )
    {
        case 0:
            if( SeasonalEventStatsMax1 == 0 )
                return SeasonalStats.SeasonalEventStats1 > 0;
            return SeasonalStats.SeasonalEventStats1 >= SeasonalEventStatsMax1;
        case 1:
            if( SeasonalEventStatsMax2 == 0 )
                return SeasonalStats.SeasonalEventStats2 > 0;
            return SeasonalStats.SeasonalEventStats2 >= SeasonalEventStatsMax2;
        case 2:
            if( SeasonalEventStatsMax3 == 0 )
                return SeasonalStats.SeasonalEventStats3 > 0;
            return SeasonalStats.SeasonalEventStats3 >= SeasonalEventStatsMax3;
        case 3:
            if( SeasonalEventStatsMax4 == 0 )
                return SeasonalStats.SeasonalEventStats4 > 0;
            return SeasonalStats.SeasonalEventStats4 >= SeasonalEventStatsMax4;
        case 4:
            if( SeasonalEventStatsMax5 == 0 )
                return SeasonalStats.SeasonalEventStats5 > 0;
            return SeasonalStats.SeasonalEventStats5 >= SeasonalEventStatsMax5;
    }
    
    return false;
}

private reliable server function ServerIncrementCurrentObjectStat(int Index, int Value)
{
    IncrementCurrentObjectStat(Index, Value);
}

private reliable server function ServerResetCurrentObjectStat(int Index)
{
    ResetCurrentObjectStat(Index);
}

simulated function Destroyed()
{
    Super.Destroyed();
    if( Role == ROLE_Authority )
        SaveObjectiveData();
}

defaultproperties
{
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=3
    
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
}