class KFGameReplicationInfoProxy extends Object;

stripped simulated event context(KFGameReplicationInfo.PostBeginPlay) PostBeginPlay()
{
	local KFDoorActor Door;

	VoteCollector = new(Self) VoteCollectorClass;

	Super.PostBeginPlay();

	ConsoleGameSessionGuid = KFGameEngine(Class'Engine'.static.GetEngine()).ConsoleGameSessionGuid;

	foreach DynamicActors(class'KFDoorActor', Door)
		DoorList.AddItem(Door);

	if( WorldInfo.NetMode != NM_DedicatedServer && TraderDialogManagerClass != none )
		TraderDialogManager = Spawn(TraderDialogManagerClass);

	SetTimer(1.f, true);
	TraderItems = KFGFxObject_TraderItems(DynamicLoadObject(TraderItemsPath, class'KFGFxObject_TraderItems'));
    
    if( `GetURI() != None )
        `GetURI().InitGameReplicationInfo(self);
}