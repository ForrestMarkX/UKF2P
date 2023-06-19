class PartyWidgetHelper extends Object;

var PartyWidgetHelper StaticReference;
var byte LobbyCurrentPage, LobbyMaxPage;
var string CycleListString;

final function Init()
{
    default.StaticReference = self;
    PartyWidgetHelper(`FindDefaultObject(class'PartyWidgetHelper')).StaticReference = self;
}

defaultproperties
{
    CycleListString="Next Page"
}