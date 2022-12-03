class PawnProxy extends Object;

stripped simulated event context(Pawn.InFreeCam) bool InFreeCam()
{
	local PlayerController	PC;
    
    if( `GetChatRep() != None && `GetChatRep().bCustomizationView )
        return true;

	PC = PlayerController(Controller);
	return (PC != None && PC.PlayerCamera != None && (PC.PlayerCamera.CameraStyle == 'FreeCam' || PC.PlayerCamera.CameraStyle == 'FreeCam_Default') );
}

stripped final simulated function context(Pawn) bool CheckForExploit()
{
    local int i;
    local UKFPReplicationInfo UKFRI;
    
    if( Weapon == None )
        return false;
    
    UKFRI = `GetURI();
    if( UKFRI == None )
        return false;
        
    for( i=0; i<UKFRI.WeaponExploitFix.Length; i++ )
    {
        if( Weapon.IsA(UKFRI.WeaponExploitFix[i].Name) )
            return true;
    }
    
    return false;
}

stripped simulated function context(Pawn.StartFire) StartFire(byte FireModeNum)
{
	if( bNoWeaponFiring || (KFWeapon(Weapon) != None && FireModeNum == KFWeapon(Weapon).CUSTOM_FIREMODE && CheckForExploit()) )
		return;
	if( Weapon != None )
		Weapon.StartFire(FireModeNum);
}

stripped simulated event context(Pawn.GetActorEyesViewPoint) GetActorEyesViewPoint( out vector out_Location, out Rotator out_Rotation )
{
	out_Location = GetPawnViewLocation();
	out_Rotation = GetViewRotation();
    if( IsA('KFPawn_Human') )
        CalcViewRotation(out_Rotation);
}

stripped final simulated function context(KFPawn_Human) CalcViewRotation(out rotator Rot)
{
    local ReplicationHelper CRI;
    
    CRI = `GetChatRep();
    if( CRI != None )
        CRI.CalcViewRotation(self, Rot);
}