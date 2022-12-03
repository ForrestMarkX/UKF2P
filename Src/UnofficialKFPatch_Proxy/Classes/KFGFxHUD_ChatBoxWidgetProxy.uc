class KFGFxHUD_ChatBoxWidgetProxy extends Object;

stripped function context(KFGFxHUD_ChatBoxWidget.AddChatMessage) AddChatMessage(string NewMessage, string HexVal)
{
    NewMessage = "<font color=\"#"$HexVal$"\">"$NewMessage$"</font>";
	ActionScriptVoid("addChatMessage");
}

stripped function context(KFGFxHUD_ChatBoxWidget.SetDataObjects) SetDataObjects( array<GFxObject> DataObjects)
{
    local byte i;
    
    if( DataObjects.Length > 1000000 )
    {
        DataObjects.Length = 0;
        return;
    }
    
    while( DataObjects.Length > 255 )
        DataObjects.Remove(0, 1);

    for( i=0; i<DataObjects.Length; i++ )
        AddChatMessage(DataObjects[i].GetString("text"), DataObjects[i].GetString("color"));
}