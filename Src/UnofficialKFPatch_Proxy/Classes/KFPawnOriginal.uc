class KFPawnOriginal extends Object;

event PostBeginPlay();
simulated function SetWeaponAttachmentFromWeaponClass(class<KFWeapon> WeaponClass);
simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime);
function JumpOffPawn();
simulated function vector WeaponBob( float BobDamping, float JumpDamping );
simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon);
function SetSprinting(bool bNewSprintStatus);
function bool DoJump( bool bUpdating );