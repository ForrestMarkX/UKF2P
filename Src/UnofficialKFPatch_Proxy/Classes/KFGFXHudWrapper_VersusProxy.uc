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
                HudMovie.SetMovieInfo(SwfMovie'UKFP_UI_HUD.UKFP_InGameHUD_ZED_SWF');
            else HudMovie.SetMovieInfo(SwfMovie'UKFP_UI_HUD.UKFP_InGameHUD_SWF');
            HudMovie.SetTimingMode(TM_Real);
            HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
            
            HudMovie.SpecialWaveIconPath[AT_FleshpoundMini] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_FP";
            HudMovie.SpecialWaveIconPath[AT_EliteClot] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_Clot";
            HudMovie.SpecialWaveIconPath[AT_EliteCrawler] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_Crawler";
            HudMovie.SpecialWaveIconPath[AT_EliteGoreFast] = "UI_Endless_TEX.ZEDs.UI_ZED_Endless_Gorefast";
            HudMovie.SpecialWaveIconPath[AT_EDAR_EMP] = "Spring_UI.UI_Objectives_Spring_DAR01";
            HudMovie.SpecialWaveIconPath[AT_EDAR_Laser] = "Spring_UI.UI_Objectives_Spring_DAR03";
            HudMovie.SpecialWaveIconPath[AT_EDAR_Rocket] = "Spring_UI.UI_Objectives_Spring_DAR05";

            HudMovie.SpecialWaveLocKey[AT_FleshpoundMini] = "KFPawn_ZedFleshPoundMini";
            HudMovie.SpecialWaveLocKey[AT_EliteClot] = "KFPawn_ZedClot_AlphaKing";
            HudMovie.SpecialWaveLocKey[AT_EliteCrawler] = "KFPawn_ZedCrawlerKing";
            HudMovie.SpecialWaveLocKey[AT_EliteGoreFast] = "KFPawn_ZedGorefastDualBlade";
            HudMovie.SpecialWaveLocKey[AT_EDAR_EMP] = "KFPawn_ZedDAR_EMP";
            HudMovie.SpecialWaveLocKey[AT_EDAR_Laser] = "KFPawn_ZedDAR_Laser";
            HudMovie.SpecialWaveLocKey[AT_EDAR_Rocket] = "KFPawn_ZedDAR_Rocket";
        }
    }
}