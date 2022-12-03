class KFPawn_HumanProxy extends Object;

stripped simulated function context(KFPawn_Human.UpdateHealingSpeedBoost) UpdateHealingSpeedBoost()
{
    if( HealingSpeedBoost <= 0 )
        `GetURI().GetPlayerChat(Controller.PlayerReplicationInfo).HealingSpeedBoost = 0;
    ApplySpeedBoostStatus();
	HealingSpeedBoost = Min( HealingSpeedBoost + class'KFPerk_FieldMedic'.static.GetHealingSpeedBoost(), class'KFPerk_FieldMedic'.static.GetMaxHealingSpeedBoost() );
	SetTimer( class'KFPerk_FieldMedic'.static.GetHealingSpeedBoostDuration(),, 'ResetHealingSpeedBoost' );
}

stripped final function context(KFPawn_Human) ApplySpeedBoostStatus()
{
    local ReplicationHelper CRI;
    local UKFPReplicationInfo UKFPRI;
    
    UKFPRI = `GetURI();
    if( UKFPRI == None )
        return;
    CRI = UKFPRI.GetPlayerChat(Controller.PlayerReplicationInfo);
    if( CRI == None )
        return;
    if( HealingSpeedBoost < class'KFPerk_FieldMedic'.static.GetMaxHealingSpeedBoost() )
        CRI.HealingSpeedBoost++;
    CRI.ApplySpeedBoostStatus(CRI.HealingSpeedBoost, class'KFPerk_FieldMedic'.static.GetHealingSpeedBoostDuration());
}

stripped simulated function context(KFPawn_Human.UpdateHealingDamageBoost) UpdateHealingDamageBoost()
{
    if( HealingDamageBoost <= 0 )
        `GetURI().GetPlayerChat(Controller.PlayerReplicationInfo).HealingDamageBoost = 0;
    ApplyDamageBoostStatus();
	HealingDamageBoost = Min( HealingDamageBoost + class'KFPerk_FieldMedic'.static.GetHealingDamageBoost(), class'KFPerk_FieldMedic'.static.GetMaxHealingDamageBoost() );
	SetTimer( class'KFPerk_FieldMedic'.static.GetHealingDamageBoostDuration(),, 'ResetHealingDamageBoost' );
}

stripped final function context(KFPawn_Human) ApplyDamageBoostStatus()
{
    local ReplicationHelper CRI;
    local UKFPReplicationInfo UKFPRI;
    
    UKFPRI = `GetURI();
    if( UKFPRI == None )
        return;
    CRI = UKFPRI.GetPlayerChat(Controller.PlayerReplicationInfo);
    if( CRI == None )
        return;
    if( HealingDamageBoost < class'KFPerk_FieldMedic'.static.GetMaxHealingDamageBoost() )
        CRI.HealingDamageBoost++;
    CRI.ApplyDamageBoostStatus(CRI.HealingDamageBoost, class'KFPerk_FieldMedic'.static.GetHealingDamageBoostDuration());
}

stripped simulated function context(KFPawn_Human.UpdateHealingShield) UpdateHealingShield()
{
    if( HealingShield <= 0 )
        `GetURI().GetPlayerChat(Controller.PlayerReplicationInfo).HealingShield = 0;
    ApplyShieldBoostStatus();
    
	HealingShield = Min( HealingShield + class'KFPerk_FieldMedic'.static.GetHealingShield(), class'KFPerk_FieldMedic'.static.GetMaxHealingShield() );
	SetTimer( class'KFPerk_FieldMedic'.static.GetHealingShieldDuration(),, 'ResetHealingShield' );
}

stripped final function context(KFPawn_Human) ApplyShieldBoostStatus()
{
    local ReplicationHelper CRI;
    local UKFPReplicationInfo UKFPRI;
    
    UKFPRI = `GetURI();
    if( UKFPRI == None )
        return;
    CRI = UKFPRI.GetPlayerChat(Controller.PlayerReplicationInfo);
    if( CRI == None )
        return;
    if( HealingShield < class'KFPerk_FieldMedic'.static.GetMaxHealingShield() )
        CRI.HealingShield++;
    CRI.ApplyShieldBoostStatus(CRI.HealingShield, class'KFPerk_FieldMedic'.static.GetHealingShieldDuration());
}

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