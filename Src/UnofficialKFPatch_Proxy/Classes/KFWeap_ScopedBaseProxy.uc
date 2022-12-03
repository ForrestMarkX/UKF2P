class KFWeap_ScopedBaseProxy extends Object;

stripped simulated event context(KFWeap_ScopedBase.OnZoomInFinished) OnZoomInFinished()
{
	NotifyScopeWeaponZoom(true);
    if( ScopeLenseMIC != None )
        ScopeLenseMIC.SetScalarParameterValue(InterpParamName, 1.0);
	Super.OnZoomInFinished();
}

stripped simulated function context(KFWeap_ScopedBase.ZoomOut) ZoomOut(bool bAnimateTransition, float ZoomTimeToGo)
{
    Super.ZoomOut(bAnimateTransition, ZoomTimeToGo);

    if( !bAnimateTransition )
        SetTimer(ZoomTimeToGo + 0.01,false,nameof(ZoomOutFastFinished));
    else
    {
		NotifyScopeWeaponZoom(false);
        if( SceneCapture != None && Instigator != None && !Instigator.PlayerReplicationInfo.bBot )
        {
            SceneCapture.bEnabled = false;
            SceneCapture.SetFrameRate(0.0);
        }
    }
}

stripped final simulated function context(KFWeap_ScopedBase) NotifyScopeWeaponZoom(bool B)
{
    local ReplicationHelper RHI;
    
    RHI = `GetURI().GetPlayerChat(Instigator.PlayerReplicationInfo);
    if( RHI != None )
		RHI.bUndoWeaponFlip = B;
}