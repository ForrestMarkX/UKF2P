class KFMonsterDifficultyInfoProxy extends Object;

stripped static function context(KFMonsterDifficultyInfo.GetSpecialSpawnChance) float GetSpecialSpawnChance(KFGameReplicationInfo KFGRI)
{
    return GetSpecialSpawnChanceEx(KFGRI);
}

stripped final static function context(KFMonsterDifficultyInfo) float GetSpecialSpawnChanceEx(KFGameReplicationInfo KFGRI)
{
    local UKFPReplicationInfo URI;
    
	if( default.ChanceToSpawnAsSpecial.Length == 0 || (!default.bVersusCanSpawnAsSpecial && KFGRI.bVersusGame) )
		return 0.f;
 
    URI = `GetURI();
    if( URI != None && (ClassIsChildOf(default.Class, class'KFDifficulty_Husk') || ClassIsChildOf(default.Class, class'KFDifficulty_Stalker')) && URI.bForceDisableEDARs )
        return 0.f;

	return default.ChanceToSpawnAsSpecial[Clamp(KFGRI.GetModifiedGameDifficulty(), 0, default.ChanceToSpawnAsSpecial.Length-1)];
}