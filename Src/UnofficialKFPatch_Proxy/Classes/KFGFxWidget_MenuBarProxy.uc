class KFGFxWidget_MenuBarProxy extends KFGFxWidget_MenuBar;

stripped static function context(KFGFxWidget_MenuBar.CanUseGearButton) bool CanUseGearButton( PlayerController PC, KFGfxMoviePlayer_Manager GfxManager )
{
    if( !PC.PlayerReplicationInfo.bOnlySpectator && GfxManager.bAfterLobby && ((KFGameReplicationInfo(PC.WorldInfo.GRI) != None && !KFGameReplicationInfo(PC.WorldInfo.GRI).bTraderIsOpen) || class'WorldInfo'.static.GetWorldInfo().NetMode == NM_StandAlone) )
        return false;
	return !(class'WorldInfo'.static.IsConsoleBuild() && !class'GameEngine'.static.IsGameFullyInstalled()) && (!PC.PlayerReplicationInfo.bOnlySpectator || class'WorldInfo'.static.IsMenuLevel());
}