class KFGFxPerksContainer_SelectionProxy extends Object;

stripped function context(KFGFxPerksContainer_Selection.UpdatePerkSelection) UpdatePerkSelection(byte SelectedPerkIndex)
{
 	local int i;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local KFPlayerController KFPC;
	local class<KFPerk> PerkClass;	
	local byte bTierUnlocked;
	local int UnlockedPerkLevel;

	KFPC = KFPlayerController( GetPC() );
	if( KFPC != None )
	{
	   	DataProvider = CreateArray();

		for( i=0; i<KFPC.PerkList.Length; i++ )
		{
			PerkClass = KFPC.PerkList[i].PerkClass;
			class'KFPerk'.static.LoadTierUnlockFromConfig(PerkClass, bTierUnlocked, UnlockedPerkLevel);
		    TempObj = CreateObject( "Object" );
		    TempObj.SetInt("PerkLevel", KFPC.PerkList[i].PerkLevel);
		    TempObj.SetString("Title", PerkClass.default.PerkName);	
			TempObj.SetString("iconSource",  "img://"$PerkClass.static.GetPerkIconPath());
			TempObj.SetBool("bTierUnlocked", bool(bTierUnlocked) && KFPC.PerkList[i].PerkLevel >= UnlockedPerkLevel);
            TempObj.SetBool("bPerkAllowed", KFGRI.IsPerkAllowed(PerkClass));

		    DataProvider.SetElementObject( i, TempObj );
		}
		SetObject( "perkData", DataProvider );
		SetInt("SelectedIndex", SelectedPerkIndex);
		SetInt("ActiveIndex", SelectedPerkIndex); //Separated active index from the selected index call. This way the 'selected' index can be different from the active perk...mainly for navigation. (Shows the dark red button for the choosen perk) - HSL

		UpdatePendingPerkInfo(SelectedPerkIndex);
        
        `GetChatRep().ForcePerkUpdate();
        `TimerHelper.SetTimer(0.1f, true, 'ForcePerkUpdate', `GetChatRep());
    }
}