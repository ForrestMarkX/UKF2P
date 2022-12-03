class KFWeap_DualBaseProxy extends Object;

stripped final simulated function context(KFWeap_DualBase) vector GetWeaponHandFireOffset()
{
	local vector FinalFireOffset;
	
	FinalFireOffset = LeftFireOffset;
	switch( class'KFWeaponProxy'.static.GetHand(self) )
	{
		case HAND_Left:
			FinalFireOffset.Y *= -1.f;
			break;
		case HAND_Centered:
			FinalFireOffset.Y = 0.f;
			break;
	}
	
	return FinalFireOffset;
}

stripped simulated event context(KFWeap_DualBase.GetLeftMuzzleLoc) vector GetLeftMuzzleLoc()
{
    local Rotator ViewRotation;

	if( Instigator != None )
	{
		ViewRotation = Instigator.GetViewRotation();

		if( KFPlayerController(Instigator.Controller) != None )
			ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;

		if( bUsingSights )
			return Instigator.GetWeaponStartTraceLocation() + (GetWeaponHandFireOffset() >> ViewRotation);
		else return Instigator.GetPawnViewLocation() + (GetWeaponHandFireOffset() >> ViewRotation);
	}

	return Location;
}