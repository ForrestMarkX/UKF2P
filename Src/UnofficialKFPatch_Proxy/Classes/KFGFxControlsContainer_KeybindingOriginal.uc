class KFGFxControlsContainer_KeybindingOriginal extends Object;

function Initialize( KFGFxObject_Menu NewParentMenu );
function UpdateAllBindings();
function SetKeyBind(KeyBind NewKeyBind);
function SetConflictMessage( String KeyString, String OldCommand, String NewCommand, byte SelectedSection );
function InitalizeCommandList( out array<string> BindList );