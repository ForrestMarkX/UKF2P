class WeaponFlipHelper extends Object within GFxMoviePlayer;

var float ScreenW, OriginalScreenX;
var GFxObject UIContainer;
var ReplicationHelper RHI;
var PlayerController PC;

final function Init()
{
	if( KFGFxWorld_MedicOptics(Outer) != None )
		UIContainer = KFGFxWorld_MedicOptics(Outer).OpticsContainer;
	else if( KFGFxMoviePlayer_World(Outer) != None )
		UIContainer = KFGFxMoviePlayer_World(Outer).MainComponent;
	else if( KFGFxWorld_WeaponRadar(Outer) != None )
		UIContainer = KFGFxWorld_WeaponRadar(Outer).RadarContainer;
		
	if( UIContainer == None )
		return;
		
	ScreenW = UIContainer.GetFloat("width");
	OriginalScreenX = UIContainer.GetFloat("x");
	
	PC = GetPC();
    if( PC == None )
        return;
	
    RHI = `GetURI().GetPlayerChat(PC.PlayerReplicationInfo);
    if( RHI == None )
        return;
			
	CheckForFlip();
	RHI.FlipHelpers.AddItem(self);
}

final function CheckForFlip()
{
	if( RHI.GetHand() == HAND_Left )
	{
		UIContainer.SetFloat("rotationY", -180.f);
		UIContainer.SetFloat("x", OriginalScreenX + ScreenW);
	}
	else 
	{
		UIContainer.SetFloat("rotationY", 0.f);
		UIContainer.SetFloat("x", OriginalScreenX);
	}
}