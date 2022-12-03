class MedicWeaponFlipHelper extends Object within KFGFxWorld_MedicOptics;

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
    
	if( OpticsContainer != None )
	{
        if( OriginalScreenX == default.OriginalScreenX )
            OriginalScreenX = OpticsContainer.GetFloat("x");
                
        if( RHI.GetHand() == HAND_Left )
        {
            OpticsContainer.SetFloat("rotationY", -180.f);
            OpticsContainer.SetFloat("x", OriginalScreenX + OpticsContainer.GetFloat("width"));
        }
        else
        {
            OpticsContainer.SetFloat("rotationY", 0.f);
            OpticsContainer.SetFloat("x", OriginalScreenX);
        }
	}
}