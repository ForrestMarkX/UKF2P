class GFxMoviePlayerProxy extends Object;

stripped function context(GFxMoviePlayer.Init) Init(optional LocalPlayer LocPlay)
{
	LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocPlay);
	if( LocalPlayerOwnerIndex == INDEX_NONE )
		LocalPlayerOwnerIndex = 0;

	if( MovieInfo != None )
	{
		if( bAutoPlay )
		{
			Start();
			Advance(0.f);
		}
	}
    
    if( IsA('KFGFxMoviePlayer_World') )
        CheckForWeaponFlip();
    else if( IsA('KFGFxWorld_MedicOptics') )
        CheckForMedicWeaponFlip();
    else if( IsA('KFGFxWorld_WeaponRadar') )
        CheckForRadarFlip();
}

stripped final function context(KFGFxMoviePlayer_World) CheckForWeaponFlip()
{
    `TimerHelper.SetTimer(0.1f, true, 'CheckForFlip', new(self) class'WeaponFlipHelper');
}

stripped final function context(KFGFxWorld_MedicOptics) CheckForMedicWeaponFlip()
{
    `TimerHelper.SetTimer(0.1f, true, 'CheckForFlip', new(self) class'MedicWeaponFlipHelper');
}

stripped final function context(KFGFxWorld_WeaponRadar) CheckForRadarFlip()
{
    `TimerHelper.SetTimer(0.1f, true, 'CheckForFlip', new(self) class'RadarFlipHelper');
}