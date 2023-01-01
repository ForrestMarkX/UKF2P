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
    
    if( IsA('KFGFxMoviePlayer_World') || IsA('KFGFxWorld_MedicOptics') || IsA('KFGFxWorld_WeaponRadar') )
		`TimerHelper.SetTimer(0.1f, false, 'Init', new(self) class'WeaponFlipHelper');
}