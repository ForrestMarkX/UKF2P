class DoomBobStyle extends WeaponBobStyle;

var float BobTimeEx;

final function float CalcBobSpeed(KFPawn_Human P, KFWeapon Wep, float BobDamping)
{
    local float BobSpeed, CurrentSpeed;
    
    CurrentSpeed = FMin(VSize2D(P.Velocity), P.default.SprintSpeed);
    BobSpeed = CurrentSpeed * P.Bob * (Wep.bUsingSights ? (1.f - BobDamping) : 1.f);
    if ( CurrentSpeed < 10.f )
        BobTimeEx += 0.2f * WorldInfo.DeltaSeconds;
    else BobTimeEx += WorldInfo.DeltaSeconds * (1.f * CurrentSpeed/FMin(P.GroundSpeed, P.default.SprintSpeed));
    
    return BobSpeed;
}

function CalcViewBob(KFPawn_Human P, KFWeapon Wep, float BobDamping, out vector Pos, out rotator Ang)
{
    local vector X, Y, Z;
    local float BobSpeed;
    
    GetAxes(Ang,X,Y,Z);
    
    BobSpeed = CalcBobSpeed(P, Wep, BobDamping);
    Pos = Pos + (Y * BobSpeed * Cos(4.f * BobTimeEx)) + (Z * BobSpeed * (Abs(Sin(4.f * BobTimeEx)) * -1.f));
}

defaultproperties
{
    BobName="Doom"
}