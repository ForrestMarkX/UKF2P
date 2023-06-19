class KFGFxControlsContainer_KeybindingProxy extends Object;

stripped function context(KFGFxControlsContainer_Keybinding.Initialize) Initialize( KFGFxObject_Menu NewParentMenu )
{
	local GFxObject LocalizedObject;

	Super(KFGFxObject_Container).Initialize( NewParentMenu );

	Manager = NewParentMenu.Manager;

	LocalizedObject = CreateObject( "Object" );
	LocalizedObject.SetString("resetLabel", ResetString);
	LocalizedObject.SetString("applyLabel", ApplyString);
	SetObject("localizedText", LocalizedObject);

	LocalizedObject = CreateObject( "Object" );
	LocalizedObject.SetString("warningLabel", WarningString);
	LocalizedObject.SetString("rebindLabel", RebindString);
	LocalizedObject.SetString("clearedLabel", ClearedString);
	LocalizedObject.SetString("cancelLabel", CancelString);
	LocalizedObject.SetString("acceptLabel", AcceptString);
	SetObject("localizedPopup", LocalizedObject);
    
    UpdateCommandList();
 	
 	UpdateAllBindings();
}

stripped final simulated function context(KFGFxControlsContainer_Keybinding) UpdateCommandList()
{
    local int i;
    local FBindPages Info;
    local array<string> List;
    
    for( i=0; i<class'ReplicationHelper'.default.ModBindList.Length; i++ )
    {
        class'ReplicationHelper'.default.SavedModBindList.AddItem(class'ReplicationHelper'.default.ModBindList[i].BindCommand);

        Info.List.AddItem(class'ReplicationHelper'.default.ModBindList[i].BindCommand);
        if( i == 0 )
            class'ReplicationHelper'.default.Pages.AddItem(Info);
        else if( (i % 11) == 0 && (i+1) < class'ReplicationHelper'.default.ModBindList.Length )
        {
            class'ReplicationHelper'.default.Pages.AddItem(Info);
            
            Info.PageIndex++;
            Info.List.Length = 0;
        }
    }

 	InitalizeCommandList(MovementBindList);
 	InitalizeCommandList(InteractionBindList);
 	InitalizeCommandList(CombatBindList);
 	InitalizeCommandList(WeaponSelectBindList);
 	InitalizeCommandList(VoiceCommBindList);
    InitalizeCommandList(OtherBindList);
    
    if( class'ReplicationHelper'.default.Pages.Length == 1 )
        InitalizeCommandList(class'ReplicationHelper'.default.SavedModBindList);
    else
    {
        for( i=0; i<class'ReplicationHelper'.default.Pages.Length; i++ )
        {
            List = class'ReplicationHelper'.default.Pages[i].List;
            InitalizeCommandListMod(List, class'ReplicationHelper'.default.Pages[i].PageIndex);
            class'ReplicationHelper'.default.Pages[i].List = List;
        }
    }
}

stripped function context(KFGFxControlsContainer_Keybinding.InitalizeCommandList) InitalizeCommandList( out array<string> BindList )
{
	InitalizeCommandListEx(BindList);
}

stripped final simulated function context(KFGFxControlsContainer_Keybinding) InitalizeCommandListEx( out array<string> BindList )
{
	local byte i;
    local int Index;
	local GFxObject CommandSlot, DataProvider;

    DataProvider = CreateArray();
    DataProvider.SetInt("sectionIndex", TotalBindSections);
    DataProvider.SetString("bindingHeader", TotalBindSections >= MAX_SECTIONS ? "MODS" : SectionHeaders[TotalBindSections]); 
    DataProvider.SetString("pressKeyString", PressKeyString);
    for( i=0; i<BindList.Length; i++ )
    {
        CommandSlot = CreateObject( "Object" );
        if( TotalBindSections >= MAX_SECTIONS )
        {
            Index = class'ReplicationHelper'.default.ModBindList.Find('BindCommand', BindList[i]);
            if( Index != INDEX_NONE )
                CommandSlot.SetString("label", Caps(class'ReplicationHelper'.default.ModBindList[Index].BindName));
        }
        else CommandSlot.SetString("label",  Localize(SectionName, BindList[i], "KFGame"));

        DataProvider.SetElementObject(i, CommandSlot);			
    }
    
    TotalBindSections++;

    SetObject("commandList", DataProvider);
}

stripped final simulated function context(KFGFxControlsContainer_Keybinding) InitalizeCommandListMod( out array<string> BindList, int PageIndex )
{
	local byte i;
    local int Index;
	local GFxObject CommandSlot, DataProvider;
    
    DataProvider = CreateArray();
    DataProvider.SetInt("sectionIndex", TotalBindSections);
    DataProvider.SetString("bindingHeader", "MODS - PAGE"@PageIndex); 
    DataProvider.SetString("pressKeyString", PressKeyString);
    for( i=0; i<BindList.Length; i++ )
    {
        CommandSlot = CreateObject( "Object" );
        Index = class'ReplicationHelper'.default.ModBindList.Find('BindCommand', BindList[i]);
        if( Index != INDEX_NONE )
            CommandSlot.SetString("label", Caps(class'ReplicationHelper'.default.ModBindList[Index].BindName));

        DataProvider.SetElementObject(i, CommandSlot);			
    }
    
    TotalBindSections++;

    SetObject("commandList", DataProvider);
}

stripped function context(KFGFxControlsContainer_Keybinding.UpdateAllBindings) UpdateAllBindings()
{
    UpdateAllBindingsEx();
}

stripped final simulated function context(KFGFxControlsContainer_Keybinding) UpdateAllBindingsEx()
{
    local int i;
    local array<string> List;

	UpdateBindList( MovementBindList, 0 );
 	UpdateBindList( InteractionBindList, 1 );
 	UpdateBindList( CombatBindList, 2 );
 	UpdateBindList( WeaponSelectBindList, 3 );
 	UpdateBindList( VoiceCommBindList, 4 );
    UpdateBindList( OtherBindList, 5 );
    
    if( class'ReplicationHelper'.default.Pages.Length == 1 )
        UpdateBindList( class'ReplicationHelper'.default.SavedModBindList, MAX_SECTIONS );
    else
    {
        for( i=0; i<class'ReplicationHelper'.default.Pages.Length; i++ )
        {
            List = class'ReplicationHelper'.default.Pages[i].List;
            UpdateBindList(List, (MAX_SECTIONS-1) + class'ReplicationHelper'.default.Pages[i].PageIndex);
            class'ReplicationHelper'.default.Pages[i].List = List;
        }
    }

	Manager.UpdateDynamicIgnoreKeys();
}

stripped function context(KFGFxControlsContainer_Keybinding.SetKeyBind) SetKeyBind(KeyBind NewKeyBind)
{
    SetKeyBindEx(NewKeyBind);
}

stripped final simulated function context(KFGFxControlsContainer_Keybinding) SetKeyBindEx(KeyBind NewKeyBind)
{
	local KFPlayerInput KFInput;
	local string OldKeyCommand;
    local int Index;

	if( KFPlayerInput(GetPC().PlayerInput) == None )
		return;

	if( NewKeyBind.Name == 'Escape' )
	{
		UpdateAllBindings();
		return;
	}

	if( (NewKeyBind.Name == 'XboxTypeS_A' || NewKeyBind.Name == 'LeftMouseButton') && Manager.IsFocusIgnoreKey(BindCommand))
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, default.WarningString, NewKeyBind.Name @default.IgnoredKeyString, class'KFCommon_LocalizedStrings'.default.OKString);	
		UpdateAllBindings();
		return;
	}

	KFInput = KFPlayerInput( GetPC().PlayerInput );
	Index = KFInput.GetBindingsIndex( NewKeyBind );
    if( Index != INDEX_NONE )
        OldKeyCommand = KFInput.Bindings[Index].Command;
        
	if( NewKeyBind.Name != 'Delete' && OldKeyCommand != "" && OldKeyCommand != BindCommand )
	{
		PendingKeyBind = NewKeyBind;
		OldKeyBind.Command = OldKeyCommand;
		OldKeyBind.Name = 'Delete';
		SetConflictMessage( string(NewKeyBind.Name), OldKeyCommand, BindCommand, CurrentlySelectedSection );
	}
	else
	{
		KFInput.BindKey( NewKeyBind, BindCommand, false );
		UpdateAllBindings();
	}
}

stripped function context(KFGFxControlsContainer_Keybinding.SetConflictMessage) SetConflictMessage( String KeyString, String OldCommand, String NewCommand, byte SelectedSection )
{
    SetConflictMessageEx(KeyString, OldCommand, NewCommand, SelectedSection);
}

stripped final simulated function context(KFGFxControlsContainer_Keybinding) SetConflictMessageEx( String KeyString, String OldCommand, String NewCommand, byte SelectedSection )
{
    local int Index;
    local string Cmd;

	KeyString = Repl(KeyAlreadyBoundString, "%x%", KeyString, true);
    
    Index = class'ReplicationHelper'.default.ModBindList.Find('BindCommand', OldCommand);
    if( Index != INDEX_NONE )
        OldCommand = class'ReplicationHelper'.default.ModBindList[Index].BindName;
    else
    {
        Cmd = Localize(SectionName, OldCommand, "KFGame");
        if( InStr(Cmd, "KFGame.LocalizedControls", false, true) == INDEX_NONE )
            OldCommand =  Cmd;
    }
    
    Index = class'ReplicationHelper'.default.ModBindList.Find('BindCommand', NewCommand);
    if( Index != INDEX_NONE )
        NewCommand = class'ReplicationHelper'.default.ModBindList[Index].BindName;
    else
    {
        Cmd = Localize(SectionName, NewCommand, "KFGame");
        if( InStr(Cmd, "KFGame.LocalizedControls", false, true) == INDEX_NONE )
            NewCommand =  Cmd;
    }

	ActionscriptVoid("setConflictMessage");
}