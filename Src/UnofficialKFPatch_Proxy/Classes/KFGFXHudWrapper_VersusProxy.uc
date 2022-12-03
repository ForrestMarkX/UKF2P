class KFGFXHudWrapper_VersusProxy extends Object;

stripped function context(KFGFXHudWrapper_Versus.CreateHUDMovie) CreateHUDMovie(optional bool bForce)
{
    if( !class'WorldInfo'.static.IsMenuLevel() )
    {       
        if(KFPlayerOwner != none && KFPlayerOwner.PlayerReplicationInfo.GetTeamNum() != LastTeamIndex || bForce)
        {
            LastTeamIndex = KFPlayerOwner.GetTeamNum();
            if( HudMovie != None )
                RemoveMovies();
            HudMovie = new GetHUDClass();
            if( HudMovie.Class == ZedHUDClass )
                HudMovie.SetMovieInfo(SwfMovie(`SafeLoadObject("UKFP_UI_HUD.InGameHUD_ZED_SWF", class'SwfMovie')));
            else HudMovie.SetMovieInfo(SwfMovie(`SafeLoadObject("UKFP_UI_HUD.InGameHUD_SWF", class'SwfMovie')));
            HudMovie.SetTimingMode(TM_Real);
            HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
        }
    }
}