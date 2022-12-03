class KFDroppedPickupOriginal extends Object;

simulated function SetPickupMesh(PrimitiveComponent NewPickupMesh);
auto state Pickup { simulated function BeginState(Name PreviousStateName); }
event Destroyed();
function GiveTo(Pawn P);