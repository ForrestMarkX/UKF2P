class DummyMoviePlayer extends KFGFxMoviePlayer_Manager;

function Init(optional LocalPlayer LocPlay)
{
	Super(GFxMoviePlayer).Init( LocPlay );
}

function OnCleanup()
{
    `GetMut().Cleanup();
	Super.OnCleanup();
}

function SetMenusOpen(bool bIsOpen)
{
	SetMovieCanReceiveInput(false);
}

function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent);
function OnClose();

defaultproperties
{
	bDisplayWithHudOff=false
	bAllowInput=false
	bAllowFocus=false
	bCaptureInput=false
	bCaptureMouseInput=false
}