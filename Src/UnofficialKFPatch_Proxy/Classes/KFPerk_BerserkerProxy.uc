class KFPerk_BerserkerProxy extends Object;

stripped simulated function context(KFPerk_Berserker.SetSuccessfullParry) SetSuccessfullParry()
{
	if( IsParryActive() )
	{
		bParryActive = true;
		SetTickIsDisabled(false);
		SetTimer(ParryDuration, false, 'ParryTimer');

		if( OwnerPC != None )
			OwnerPC.SetPerkEffect( true );

		OwnerPC.PlaySoundBase( ParrySkillSoundModeStart, true );
        
        if( CheckOwnerPawn() )
            ApplyParryBuffStatus(ParryDuration);
	}
}

stripped simulated function context(KFPerk_Berserker.ParryTimer) ParryTimer()
{
	bParryActive = false;
	SetTickIsDisabled( !IsNinjaActive() );

	if( OwnerPC != None )
		OwnerPC.SetPerkEffect( false );

	OwnerPC.PlaySoundBase( ParrySkillSoundModeStop, true );
    
    if( CheckOwnerPawn() )
        ApplyParryBuffStatus(0.f);
}

stripped final function context(KFPerk_Berserker) ApplyParryBuffStatus(float ParryTime)
{
    local ReplicationHelper CRI;
    
    CRI = `GetURI().GetPlayerChat(OwnerPawn.PlayerReplicationInfo);
    if( CRI == None )
        return;
    CRI.ApplyParryBuffStatus(ParryTime);
}