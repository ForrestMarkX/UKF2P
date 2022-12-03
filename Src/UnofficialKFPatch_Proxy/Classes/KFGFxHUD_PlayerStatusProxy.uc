class KFGFxHUD_PlayerStatusProxy extends Object;

stripped function context(KFGFxHUD_PlayerStatus.TickHud) TickHud(float DeltaTime)
{
    MoveXPBark();
    
	UpdatePerk();
	UpdateHealth();
	UpdateArmor();
	UpdateHealer();
	UpdateGlobalDamage();

    LastUpdateTime = MyPC.WorldInfo.TimeSeconds;
}

stripped final function context(KFGFxHUD_PlayerStatus) MoveXPBark()
{
    local GFxObject XPBarkMC;
    local ASDisplayInfo XPBarkDI;

    XPBarkMC = GetObject("XPBarkMC");
    if( XPBarkMC == None )
        return;
        
    XPBarkDI = XPBarkMC.GetDisplayInfo();
    if( XPBarkDI.Y != -15 )
    {
        XPBarkDI.Y = -15;
        XPBarkMC.SetDisplayInfo(XPBarkDI);
    }
}