class MutatorProxy extends Object;

stripped event context(Mutator.PreBeginPlay) PreBeginPlay()
{
    GenerateMutatorEntry(Class.Name, PathName(Class));
	if ( !MutatorIsAllowed() )
		Destroy();
}

stripped final function context(Mutator) GenerateMutatorEntry(name ClassName, string ClassPath)
{
    local KFMutatorSummary MutatorSummary;
    local array<string> Names, Groups;
    local int i;
    local bool bFoundConfig;
    
    GetPerObjectConfigSections(class'KFMutatorSummary', Names);
    for (i = 0; i < Names.Length; i++)
    {
        if( InStr(Names[i], string(ClassName),, true) != INDEX_NONE )
        {
            bFoundConfig = true;
            break;
        }
    }
    
    if( !bFoundConfig )
    {
        Groups.AddItem("Mutators");
        
        MutatorSummary = New(None, string(ClassName)) class'KFMutatorSummary';
        MutatorSummary.ClassName = ClassPath;
        MutatorSummary.GroupNames = Groups;
        MutatorSummary.SaveConfig();
    }
}