class KFGFxPerksContainer_DetailsProxy extends Object;

stripped function context(KFGFxPerksContainer_Details.UpdateAndGetCurrentWeaponIndexes) UpdateAndGetCurrentWeaponIndexes(class<KFPerk> PerkClass, KFPlayerController KFPC, out byte WeaponIdx, out byte GrenadeIdx, byte SelectedSkills[`MAX_PERK_SKILLS], bool IsChoosingPrev, bool IsChoosingNext)
{
	if( ClassIsChildOf(PerkClass, class'KFPerk_Survivalist') )
	{
		WeaponIdx = KFPC.CurrentPerk.SetWeaponSelectedIndex(KFPC.SurvivalPerkWeapIndex);
		GrenadeIdx = KFPC.CurrentPerk.SetGrenadeSelectedIndexUsingSkills(KFPC.SurvivalPerkGrenIndex, SelectedSkills, IsChoosingPrev, IsChoosingNext);
	}
}