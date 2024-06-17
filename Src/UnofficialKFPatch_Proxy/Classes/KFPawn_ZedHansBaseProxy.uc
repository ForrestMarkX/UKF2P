class KFPawn_ZedHansBaseProxy extends Object;

stripped function context(KFPawn_ZedHansBase.PossessedBy) PossessedBy( Controller C, bool bVehicleTransition )
{
    Super.PossessedBy( C, bVehicleTransition );

    MyHansController = KFAIController_Hans( C );

    SetPhaseCooldowns( 0 );

	ExplosiveGrenadeClass = SeasonalExplosiveGrenadeClasses[`GetURI().GetZEDSeasonalIndex()];
	NerveGasGrenadeClass = SeasonalNerveGasGrenadeClasses[`GetURI().GetZEDSeasonalIndex()];
	SmokeGrenadeClass = SeasonalSmokeGrenadeClasses[`GetURI().GetZEDSeasonalIndex()];
}