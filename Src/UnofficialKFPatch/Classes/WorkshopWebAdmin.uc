class WorkshopWebAdmin extends WebApplication;
    
function Init()
{
    Super.Init();
    WorldInfo.Spawn(class'WorkshopTool');
}

defaultproperties
{
}