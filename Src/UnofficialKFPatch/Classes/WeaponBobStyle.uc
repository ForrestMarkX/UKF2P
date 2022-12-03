class WeaponBobStyle extends Object
    abstract;

var string BobName;
var WorldInfo WorldInfo;
var bool bForceDisableAdditiveBobAnimation, bAllowOriginalBobCode;

function Init();
function CalcViewBob(KFPawn_Human P, KFWeapon Wep, float BobDamping, out vector Pos, out rotator Ang);
function CalcViewRotation(KFPawn_Human P, out rotator Ang);

defaultproperties
{
    BobName="Invalid Bob"
}