class KFGameDifficultyInfoProxy extends KFGameDifficultyInfo;

function float GetAIHiddenSpeedModifier( int NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_AIHiddenSpeed, `GetURI().GetEffectivePlayerCount(NumLivingPlayers) );
}

function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_WaveSize, `GetURI().GetEffectivePlayerCount(NumLivingPlayers) );
}

function float GetAmmoPickupInterval( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_AmmoPickupRespawnTime, `GetURI().GetEffectivePlayerCount(NumLivingPlayers) );
}

function float GetWeaponPickupInterval( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_WeaponPickupRespawnTime, `GetURI().GetEffectivePlayerCount(NumLivingPlayers) );
}

function float GetDamageResistanceModifier( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_ZedDamageResistance, `GetURI().GetEffectivePlayerCount(NumLivingPlayers) );
}