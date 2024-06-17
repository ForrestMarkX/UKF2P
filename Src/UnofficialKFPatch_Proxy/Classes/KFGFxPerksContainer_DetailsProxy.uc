class KFGFxPerksContainer_DetailsProxy extends Object;

stripped function context(KFGFxPerksContainer_Details.UpdateAndGetCurrentWeaponIndexes) UpdateAndGetCurrentWeaponIndexes(class<KFPerk> PerkClass, KFPlayerController KFPC, out byte WeaponIdx, out byte SecondaryWeaponIdx, out byte GrenadeIdx, byte SelectedSkills[`MAX_PERK_SKILLS], bool IsChoosingPrev, bool IsChoosingNext)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	SecondaryWeaponIdx = PerkClass.static.GetSecondaryWeaponSelectedIndex(KFPC.SurvivalPerkSecondaryWeapIndex);

	if( KFPC.CurrentPerk.IsA(PerkClass.Name) )
		KFPC.CurrentPerk.StartingSecondaryWeaponClassIndex = SecondaryWeaponIdx;

	if( ClassIsChildOf(PerkClass, class'KFPerk_Survivalist') )
	{
		WeaponIdx = PerkClass.static.GetWeaponSelectedIndex(KFPC.SurvivalPerkWeapIndex);
		GrenadeIdx = PerkClass.static.GetGrenadeSelectedIndexUsingSkills(KFPC.SurvivalPerkGrenIndex, SelectedSkills, IsChoosingPrev, IsChoosingNext);

        KFPerk_Survivalist(KFPC.CurrentPerk).StartingWeaponClassIndex = WeaponIdx;
        KFPerk_Survivalist(KFPC.CurrentPerk).StartingGrenadeClassIndex = GrenadeIdx;

        if( !KFGRI.bWaveIsActive )
            KFPerk_Survivalist(KFPC.CurrentPerk).UpdateCurrentGrenade();
	}
}