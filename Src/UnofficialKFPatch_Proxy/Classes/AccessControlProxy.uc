class AccessControlProxy extends Object;

stripped function context(AccessControl.NotifyServerTravel) NotifyServerTravel(bool bSeamless)
{
    `GetURI().NotifyServerTravel(bSeamless);
	if( !bSeamless )
		Cleanup();
}