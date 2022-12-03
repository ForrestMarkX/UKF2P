class DoomInverseBobStyle extends DoomBobStyle;

function CalcViewBob(KFPawn_Human P, KFWeapon Wep, float BobDamping, out vector Pos, out rotator Ang)
{
    local vector X, Y, Z;
    local float BobSpeed;
    
    GetAxes(Ang,X,Y,Z);
    
    BobSpeed = CalcBobSpeed(P, Wep, BobDamping);
    Pos = Pos + (Y * BobSpeed * Cos(4.f * BobTimeEx)) + (Z * BobSpeed * Abs(Sin(4.f * BobTimeEx)));
}

defaultproperties
{
    BobName="Doom (Inverse)"
}