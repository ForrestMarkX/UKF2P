class RadarFlipHelper extends Object within KFGFxWorld_WeaponRadar;

var float OriginalScreenX;

final function CheckForFlip()
{
    local ReplicationHelper RHI;
    local PlayerController PC;

    PC = GetPC();
    if( PC == None )
        return;
        
    RHI = `GetURI().GetPlayerChat(PC.PlayerReplicationInfo);
    if( RHI == None )
        return;
    
	if( RadarContainer != None )
	{
        if( OriginalScreenX == default.OriginalScreenX )
            OriginalScreenX = RadarContainer.GetFloat("x");
                
        if( RHI.GetHand() == HAND_Left )
        {
            RadarContainer.SetFloat("rotationY", -180.f);
            RadarContainer.SetFloat("x", OriginalScreenX + RadarContainer.GetFloat("width"));
        }
        else
        {
            RadarContainer.SetFloat("rotationY", 0.f);
            RadarContainer.SetFloat("x", OriginalScreenX);
        }
	}
}