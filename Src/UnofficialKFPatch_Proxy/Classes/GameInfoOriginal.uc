class GameInfoOriginal extends Object;

function GenericPlayerInitialization(Controller C);
function Logout(Controller Exiting);
function bool CheckRelevance(Actor Other);
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType );
function bool PickupQuery(Pawn Other, class<Inventory> ItemClass, Actor Pickup);
function ProcessServerTravel(string URL, optional bool bAbsolute);
event PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string ErrorMessage);
function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType );
function ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo);