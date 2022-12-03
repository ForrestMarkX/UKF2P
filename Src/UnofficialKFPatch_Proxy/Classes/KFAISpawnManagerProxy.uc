class KFAISpawnManagerProxy extends Object;

stripped function context(KFAISpawnManager.GetMaxMonsters) int GetMaxMonsters()
{
	local int LivingPlayerCount;
	local int Difficulty;
    
	LivingPlayerCount = Clamp(GetLivingPlayerCount() - 1, 0, 5);
	Difficulty = Clamp(GameDifficulty, 0, 3);
    
    if( `GetURI() != None && `GetURI().CurrentMaxMonsters > 0 )
        return Max(`GetURI().CurrentMaxMonsters, PerDifficultyMaxMonsters[Difficulty].MaxMonsters[LivingPlayerCount]);
	return PerDifficultyMaxMonsters[Difficulty].MaxMonsters[LivingPlayerCount];
}