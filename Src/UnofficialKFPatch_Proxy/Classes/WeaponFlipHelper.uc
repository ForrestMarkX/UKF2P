class WeaponFlipHelper extends Object within KFGFxMoviePlayer_World;

var float OriginalScreenX, OriginalChargeX, OriginalIntegrityX, OriginalIntegrityTitleX;

final function CheckForFlip()
{
    local ReplicationHelper RHI;
    local PlayerController PC;
    local GFxObject TextContainer, IntegrityContainer, IntegrityTitleContainer;

    PC = GetPC();
    if( PC == None )
        return;
        
    RHI = `GetURI().GetPlayerChat(PC.PlayerReplicationInfo);
    if( RHI == None )
        return;
    
	if( MainComponent != None )
	{
        if( KFGFxWorld_C4Screen(Outer) != None )
        {
            TextContainer = MainComponent.GetObject("bars");
            if( TextContainer != None )
            {
                if( OriginalScreenX == default.OriginalScreenX )
                    OriginalScreenX = TextContainer.GetFloat("x");
                        
                if( RHI.GetHand() == HAND_Left )
                {
                    TextContainer.SetFloat("rotationY", -180.f);
                    TextContainer.SetFloat("x", OriginalScreenX + TextContainer.GetFloat("mcWidth"));
                }
                else
                {
                    TextContainer.SetFloat("rotationY", 0.f);
                    TextContainer.SetFloat("x", OriginalScreenX);
                }
            }
        }
        else if( KFGFxWorld_WelderScreen(Outer) != None )
        {
            TextContainer = MainComponent.GetObject("txtCharge");
            IntegrityContainer = MainComponent.GetObject("txtIntegrity");
            IntegrityTitleContainer = MainComponent.GetObject("txtIntegrityTitle");
            if( TextContainer != None )
            {
                if( OriginalChargeX == default.OriginalChargeX )
                    OriginalChargeX = TextContainer.GetFloat("x");
                if( OriginalIntegrityX == default.OriginalIntegrityX )
                    OriginalIntegrityX = IntegrityContainer.GetFloat("x");
                if( OriginalIntegrityTitleX == default.OriginalIntegrityTitleX )
                    OriginalIntegrityTitleX = IntegrityTitleContainer.GetFloat("x");
                    
                if( RHI.GetHand() == HAND_Left )
                {
                    TextContainer.SetFloat("rotationY", -180.f);
                    TextContainer.SetFloat("x", OriginalChargeX - TextContainer.GetFloat("width"));
                    IntegrityContainer.SetFloat("rotationY", -180.f);
                    IntegrityContainer.SetFloat("x", OriginalIntegrityX - IntegrityContainer.GetFloat("width"));
                    IntegrityTitleContainer.SetFloat("rotationY", -180.f);
                    IntegrityTitleContainer.SetFloat("x", OriginalIntegrityTitleX - IntegrityTitleContainer.GetFloat("width"));
                }
                else
                {
                    TextContainer.SetFloat("rotationY", 0.f);
                    TextContainer.SetFloat("x", OriginalChargeX);
                    IntegrityContainer.SetFloat("rotationY", 0.f);
                    IntegrityContainer.SetFloat("x", OriginalIntegrityX);
                    IntegrityTitleContainer.SetFloat("rotationY", 0.f);
                    IntegrityTitleContainer.SetFloat("x", OriginalIntegrityTitleX);
                }
            }
        }
        else
        {
            `Warn("Invalid World Scaleform detected! ["$Class$"]");
            `TimerHelper.ClearTimer('CheckForFlip', self);
        }
	}
}