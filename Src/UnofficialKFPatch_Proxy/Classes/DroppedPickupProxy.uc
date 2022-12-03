class DroppedPickupProxy extends Object;

stripped event context(DroppedPickup.Landed) Landed(Vector HitNormal, Actor FloorActor)
{
	bForceNetUpdate = TRUE;
	bNetDirty = true;
	NetUpdateFrequency = 8.f;

	AddToNavigation();
}