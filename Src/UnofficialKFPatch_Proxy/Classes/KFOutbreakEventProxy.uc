class KFOutbreakEventProxy extends Object;

stripped function context(KFOutbreakEvent.UpdateGRI) UpdateGRI()
{
	local int i;
	local KFGameReplicationInfo KFGRI;
    
    if( !Outer.IsA('KFGameInfo_WeeklySurvival') )
        return;

	CacheGRI();

	if( GameReplicationInfo != None && KFGameReplicationInfo(GameReplicationInfo) != None )
	{
		KFGRI = KFGameReplicationInfo(GameReplicationInfo);

		if( ActiveEvent.TraderWeaponList != None )
			KFGRI.TraderItems = ActiveEvent.TraderWeaponList;

		if( ActiveEvent.PerksAvailableList.Length > 0 )
		{
			KFGRI.PerksAvailableData.bPerksAvailableLimited = true;
			KFGRI.PerksAvailableData.bBerserkerAvailable = false;
			KFGRI.PerksAvailableData.bCommandoAvailable = false;
			KFGRI.PerksAvailableData.bSupportAvailable = false;
			KFGRI.PerksAvailableData.bFieldMedicAvailable = false;
			KFGRI.PerksAvailableData.bDemolitionistAvailable = false;
			KFGRI.PerksAvailableData.bFirebugAvailable = false;
			KFGRI.PerksAvailableData.bGunslingerAvailable = false;
			KFGRI.PerksAvailableData.bSharpshooterAvailable = false;
			KFGRI.PerksAvailableData.bSwatAvailable = false;
			KFGRI.PerksAvailableData.bSurvivalistAvailable = false;

			for( i=0; i<ActiveEvent.PerksAvailableList.Length ; i++ )
			{
				if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Berserker')			KFGRI.PerksAvailableData.bBerserkerAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Commando')		KFGRI.PerksAvailableData.bCommandoAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Support')			KFGRI.PerksAvailableData.bSupportAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_FieldMedic')		KFGRI.PerksAvailableData.bFieldMedicAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Demolitionist')	KFGRI.PerksAvailableData.bDemolitionistAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Firebug')			KFGRI.PerksAvailableData.bFirebugAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Gunslinger')		KFGRI.PerksAvailableData.bGunslingerAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Sharpshooter')	KFGRI.PerksAvailableData.bSharpshooterAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Swat')			KFGRI.PerksAvailableData.bSwatAvailable = true;
				else if(ActiveEvent.PerksAvailableList[i] == class'KFPerk_Survivalist')		KFGRI.PerksAvailableData.bSurvivalistAvailable = true;
			}
		}

		KFGRI.GameAmmoCostScale = ActiveEvent.GlobalAmmoCostScale;
		KFGRI.bAllowGrenadePurchase = !ActiveEvent.bDisableGrenades;
		KFGRI.bTradersEnabled = !ActiveEvent.bDisableTraders;
		KFGRI.MaxPerkLevel = ActiveEvent.MaxPerkLevel;
		KFGRI.bForceShowSkipTrader = ActiveEvent.bForceShowSkipTrader;
	}
}