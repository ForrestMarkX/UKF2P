class KFProj_Explosive_HRG_KaboomstickProxy extends Object;

stripped simulated function context(KFProj_Explosive_HRG_Kaboomstick.AllowNuke) bool AllowNuke()
{
    if( AllowNukeEx() )
        return false;
	return Super.AllowNuke();
}

stripped final simulated function context(KFProj_Explosive_HRG_Kaboomstick) bool AllowNukeEx()
{
	local KFPawn KFP;
    local UKFPReplicationInfo UKFPRep;
    local ReplicationHelper CRI;
    
	KFP = KFPawn(Instigator);
    if( KFP == None )
        return true;

    UKFPRep = `GetURI();
    if( UKFPRep == None )
        return true;
        
    CRI = UKFPRep.GetPlayerChat(KFP.PlayerReplicationInfo);
    if( CRI == None )
        return true;
        
	return `TimeSince(CRI.GetLastHX25NukeTime()) < 0.25f;
}

stripped simulated protected function context(KFProj_Explosive_HRG_Kaboomstick.PrepareExplosionTemplate) PrepareExplosionTemplate()
{
	ExplosionTemplate.bIgnoreInstigator = true;

    Super.PrepareExplosionTemplate();

    if( ExplosionActorClass == class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass() )
		PrepareExplosionTemplateEx();
}

stripped final simulated function context(KFProj_Explosive_HRG_Kaboomstick) PrepareExplosionTemplateEx()
{
	local KFPawn KFP;
    local UKFPReplicationInfo UKFPRep;
    local ReplicationHelper CRI;
    
	KFP = KFPawn(Instigator);
    if( KFP == None )
        return;

    UKFPRep = `GetURI();
    if( UKFPRep == None )
        return;
        
    CRI = UKFPRep.GetPlayerChat(KFP.PlayerReplicationInfo);
    if( CRI == None )
        return;
        
    CRI.SetLastHX25NukeTime(WorldInfo.TimeSeconds);
}