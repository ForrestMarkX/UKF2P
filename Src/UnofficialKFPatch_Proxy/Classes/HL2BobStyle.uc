class HL2BobStyle extends WeaponBobStyle;

const HL2_BOB_CYCLE_MIN = 1.0f;
const HL2_BOB_CYCLE_MAX = 0.45f;
const HL2_BOB_UP = 0.5f;

var float HL2BobTime;

function CalcViewBob(KFPawn_Human P, KFWeapon Wep, float BobDamping, out vector Pos, out rotator Ang)
{
	local vector Forward, Right, Up;
    local float LateralBob, VerticalBob;
    
    GetAxes(Ang, Forward, Right, Up);
    
	CalcViewmodelBob(P, VerticalBob, LateralBob);
    
	Pos = `VectorMA(Pos, VerticalBob * 0.1f, Up);
	
	Pos.Z += VerticalBob * 0.1f;
	
	Ang.Roll += VerticalBob * 0.5f;
	Ang.Pitch -= VerticalBob * 0.4f;
	Ang.Yaw -= LateralBob * 0.3f;

	Pos = `VectorMA(Pos, LateralBob * 0.8f, Right);
}

final function CalcViewmodelBob(KFPawn_Human P, out float VerticalBob, out float LateralBob)
{
	local float Cycle, Speed, Bob_Offset;
	
	Speed = VSize2D(P.Velocity);
	Speed = FClamp(Speed, -P.default.SprintSpeed, P.default.SprintSpeed);

	Bob_Offset = `RemapVal(Speed, 0, P.default.SprintSpeed, 0.0f, 1.0f);
	
	HL2BobTime += WorldInfo.DeltaSeconds * Bob_Offset;

	Cycle = HL2BobTime - int(HL2BobTime/HL2_BOB_CYCLE_MAX)*HL2_BOB_CYCLE_MAX;
	Cycle /= HL2_BOB_CYCLE_MAX;

	if ( Cycle < HL2_BOB_UP )
		Cycle = Pi * Cycle / HL2_BOB_UP;
	else Cycle = Pi + Pi * (Cycle-HL2_BOB_UP) / (1.f - HL2_BOB_UP);
	
	VerticalBob = Speed*0.005f;
	VerticalBob = VerticalBob*0.3f + VerticalBob*0.7f*Sin(Cycle);
	VerticalBob = FClamp(VerticalBob, -7.0f, 4.0f);

	Cycle = HL2BobTime - int(HL2BobTime/HL2_BOB_CYCLE_MAX*2)*HL2_BOB_CYCLE_MAX*2;
	Cycle /= HL2_BOB_CYCLE_MAX*2;

	if( Cycle < HL2_BOB_UP )
		Cycle = Pi * Cycle / HL2_BOB_UP;
	else Cycle = Pi + Pi*(Cycle-HL2_BOB_UP)/(1.f - HL2_BOB_UP);

	LateralBob = Speed*0.005f;
	LateralBob = LateralBob*0.3 + LateralBob*0.7*Sin(Cycle);
	LateralBob = FClamp( LateralBob, -7.0f, 4.0f );
}

defaultproperties
{
    BobName="Half-Life 2"
    bForceDisableAdditiveBobAnimation=true
}