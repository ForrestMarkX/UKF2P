class MapVoteHelper extends Object within KFGFxPostGameContainer_MapVote;

var MapVoteHelper StaticReference;
var byte CurrentPageIndex;

final function Init()
{
    default.StaticReference = self;
}

final function ForceResetSelection()
{
    local GFxObject votedMapNameText;
    
    Outer.ActionScriptVoid("resetSelection");
    
    votedMapNameText = GetObject("votedMapNameText");
    if( votedMapNameText != None && InStr(votedMapNameText.GetString("text"), "---") != INDEX_NONE )
        votedMapNameText.SetString("text", "");
}