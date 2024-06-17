class KFPawn_HumanProxy extends Object;

stripped function context(KFPawn_Human.UpdateActiveSkillsPath) UpdateActiveSkillsPath(string IconPath, int Multiplier, bool Active, float MaxDuration)
{
	ApplyStatusHUDInfo(IconPath, Multiplier, Active, MaxDuration);
}

stripped final function context(KFPawn_Human) ApplyStatusHUDInfo(string IconPath, int Multiplier, bool Active, float MaxDuration)
{
    local ReplicationHelper CRI;
    local UKFPReplicationInfo UKFPRI;
    
    if( !Active )
        return;
    
    UKFPRI = `GetURI();
    if( UKFPRI == None )
        return;
        
    CRI = UKFPRI.GetPlayerChat(Controller.PlayerReplicationInfo);
    if( CRI == None )
        return;
    
    switch( IconPath )
    {
        case class'KFPerk_FieldMedic'.default.PerkSkills[EMedicHealingSpeedBoost].IconPath:
            CRI.ApplySpeedBoostStatus(Multiplier, MaxDuration);
            break;
        case class'KFPerk_FieldMedic'.default.PerkSkills[EMedicHealingDamageBoost].IconPath:
            CRI.ApplyDamageBoostStatus(Multiplier, MaxDuration);
            break;
        case class'KFPerk_FieldMedic'.default.PerkSkills[EMedicHealingShield].IconPath:
            CRI.ApplyShieldBoostStatus(Multiplier, MaxDuration);
            break;
    }
}

stripped function context(KFPawn_Human.PossessedBy) PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);

	ResetHealingSpeedBoost();
	ResetHealingDamageBoost();
	ResetHealingShield();

	ResetIdleStartTime();

	if( IsAliveAndWell() && WorldInfo.Game != none && WorldInfo.Game.NumPlayers == 1 && KFGameInfo(WorldInfo.Game).bOnePlayerAtStart )
		SetTimer( 1.f, true, 'Timer_CheckSurrounded' );

	KFGameInfo(WorldInfo.Game).OverrideHumanDefaults( self );
	SetTimer(0.5f, false, 'ClientOverrideHumanDefaults', self);
    
    if( !IsA('KFPawn_Customization') )
        ForceFixCamera();
}

stripped final function context(KFPawn_Human) ForceFixCamera()
{
    local ReplicationHelper CRI;
    local UKFPReplicationInfo UKFPRI;
    
    UKFPRI = `GetURI();
    if( UKFPRI == None )
        return;
        
    CRI = UKFPRI.GetPlayerChat(Controller.PlayerReplicationInfo);
    if( CRI == None )
        return;
        
    CRI.SetTimer(0.25f, false, 'ForceFixCamera');
}

stripped simulated event context(KFPawn_Human.Tick) Tick( float DeltaTime )
{
	local float NewSpeedPenalty;

	Super.Tick( DeltaTime );

	if( Role == ROLE_Authority )
	{
		if( Health < HealthMax )
			NewSpeedPenalty = Lerp(0.15f, 0.f, FMin(float(Health) / 100, 1.f));
		else NewSpeedPenalty = 0.f;

		if( NewSpeedPenalty != LowHealthSpeedPenalty )
		{
			LowHealthSpeedPenalty = NewSpeedPenalty;
			UpdateGroundSpeed();
		}
	}

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( DeathMaterialEffectTimeRemaining > 0 )
			UpdateDeathMaterialEffect( DeltaTime );
	}
	
	if( !IsA('KFPawn_Customization') )
		ForceSpawnedIn();
}

stripped final simulated function context(KFPawn_Human) ForceSpawnedIn()
{
	local KFPlayerReplicationInfo KFPRI;
	
    KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
    if( KFPRI != None && !KFPRI.bHasSpawnedIn )
		KFPRI.bHasSpawnedIn = true;
}