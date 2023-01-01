class KFGameDifficultyInfoProxy extends Object;

stripped function context(KFGameDifficultyInfo.GetNumPlayersModifier) float GetNumPlayersModifier( const out NumPlayerMods PlayerSetting, byte NumLivingPlayers )
{
	local float StartingLerp, LerpRate;
	
	NumLivingPlayers = Max(`GetURI().CurrentFakePlayers, NumLivingPlayers);

	if( `KF_MAX_PLAYERS > NumLivingPlayers )
	 	return PlayerSetting.PlayersMod[Max(NumLivingPlayers - 1, 0)];

    StartingLerp = PlayerSetting.PlayersMod[ `KF_MAX_PLAYERS - 1 ];
	LerpRate = (NumLivingPlayers - `KF_MAX_PLAYERS) / (32.f - `KF_MAX_PLAYERS);
	return Lerp( StartingLerp, PlayerSetting.ModCap, LerpRate );
}