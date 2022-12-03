class QuakeBobStyle extends WeaponBobStyle;

const QUAKE_ROLLSPEED = 200;
const QUAKE_ROLLANGLE = 364;

function CalcViewBob(KFPawn_Human P, KFWeapon Wep, float BobDamping, out vector Pos, out rotator Ang)
{
    local vector X, Y, Z;
    local float CurrentBob;
    
    GetAxes(Ang,X,Y,Z);
    
    CurrentBob = CalcQuakeWeaponBob(P);
    Pos = Pos + (X * CurrentBob);
}

// Original code ported by upset from Garrys Mod who saved me from digging for the Quake source code
function CalcViewRotation(KFPawn_Human P, out rotator Ang)
{
    local int Sign;
    local float Side;
    local vector Forward, Right, Up;
    
    GetAxes(Ang, Forward, Right, Up);

	Side = P.Velocity Dot Right;
	if( Side < 0 )
		Sign = -1;
	else Sign = 1;
    
	Side = Abs(Side);
	if( Side < QUAKE_ROLLSPEED )
		Side = Side * QUAKE_ROLLANGLE / QUAKE_ROLLSPEED;
	else Side = QUAKE_ROLLANGLE;
	
    Ang.Roll = Ang.Roll + Side * Sign;
}

final function float CalcQuakeWeaponBob( KFPawn_Human P )
{
    local float BobSpeed, BobCycle, BobUp, Time, Cycle, CurrentBob;
    
	BobSpeed = 0.02f;
	BobCycle = 0.6f;
	BobUp = 0.5f;
	
	Time = WorldInfo.TimeSeconds;
	Cycle = Time - FFloor(Time/BobCycle)*BobCycle;
	Cycle = Cycle / BobCycle;
	if( Cycle < BobUp )
		Cycle = Pi * Cycle / BobUp;
	else Cycle = Pi + Pi*(Cycle-BobUp)/(1.0 - BobUp);

	CurrentBob = VSize2D(P.Velocity) * BobSpeed;
	CurrentBob = CurrentBob*0.3f + CurrentBob*0.7f*Sin(Cycle);
	if( CurrentBob > 4 )
		CurrentBob = 4;
	else if( CurrentBob < -7 )
		CurrentBob = -7;
	
	return CurrentBob;
}

defaultproperties
{
    BobName="Quake"
}