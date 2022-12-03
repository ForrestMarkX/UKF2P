class KFProj_Grenade_GravityImploderAltProxy extends Object;

simulated state ImplodingState
{
	stripped simulated function context(KFProj_Grenade_GravityImploderAlt.ImplodingState.AbsorbEnemies) AbsorbEnemies()
	{
		local Actor          Victim;
		local TraceHitInfo   HitInfo;
		local KFPawn         KFP;
		local KFPawn_Monster KFPM;
		local float		     ColRadius, ColHeight;
		local float		     Dist;
		local vector	     Dir;
		local vector         Momentum;
		local float          MomentumModifier;

		foreach CollidingActors(class'Actor', Victim, VortexRadius, VortexLocation, true,, HitInfo)
		{
			KFP  = KFPawn(Victim);
			KFPM = KFPawn_Monster(Victim);

			if (Victim != Self
				&& (!Victim.bWorldGeometry || Victim.bCanBeDamaged)
				&& (NavigationPoint(Victim) == None)
				&& Victim != Instigator
				&& KFP != None 
				&& KFPawn_Human(Victim) == none // No player's character
				&& (KFPM == none || VortexTime < VortexDuration*KFPM.GetVortexAttractionModifier())
                && DroppedPickup(Victim) == None)
			{
				KFP.GetBoundingCylinder(ColRadius, ColHeight);

				if (bFirstAbsorption)
				{
					Dir      = vect(0,0,1);
					Momentum = Dir * VortexElevationStrength;
				}
				else
				{
					Dir              = Normal(VortexLocation - KFP.Location);
					Dist             = FMax(vSize(Dir) - ColRadius, 0.f);
					MomentumModifier = bVortexReduceImpulseOnDist ? (1.0f - Dist / VortexRadius) : 1.0f;
					Momentum         = Dir * VortexAbsorptionStrength * MomentumModifier + vect(0,0,1) * (Dist/VortexRadius) * VortexAbsorptionStrength;
				}

				if(KFPM != none)
				{
					Momentum *= KFPM.GetVortexAttractionModifier();
				}

				KFP.AddVelocity( Momentum, KFP.Location - 0.5 * (ColHeight + ColRadius) * Dir, class 'KFDT_Explosive_GravityImploder');
			}
		}
	}
}