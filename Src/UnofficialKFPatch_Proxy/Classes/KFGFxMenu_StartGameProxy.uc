class KFGFxMenu_StartGameProxy extends Object;

stripped static function context(KFGFxMenu_StartGame.GetSpecialEventClass) class<KFGFxSpecialeventObjectivesContainer> GetSpecialEventClass(int SpecialEventID)
{
    switch( `GetURI().CurrentForcedSeasonalEventDate )
    {
        case SET_Spring2019:
            return class'KFGFxSpring2019ObjectivesContainer';
        case SET_Spring2020:
            return class'KFGFxSpecialEventObjectivesContainer_Spring2020';
        case SET_Spring2021:
            return class'KFGFxSpecialEventObjectivesContainer_Spring2021';
        case SET_Summer2019:
            return class'KFGFxSummer2019ObjectivesContainer';
        case SET_Summer2020:
            return class'KFGFxSpecialEventObjectivesContainer_Summer2020';
        case SET_Summer2021:
            return class'KFGFxSpecialEventObjectivesContainer_Summer2021';
        case SET_Summer2022:
            return class'KFGFxSpecialEventObjectivesContainer_Summer2022';
        case SET_Fall2018:
            return class'KFGFxFallObjectivesContainer';
        case SET_Fall2019:
            return class'KFGFxFall2019ObjectivesContainer';
        case SET_Fall2020:
            return class'KFGFXSpecialEventObjectivesContainer_Fall2020';
        case SET_Fall2021:
            return class'KFGFxSpecialEventObjectivesContainer_Fall2021';
        case SET_Fall2022:
            return class'KFGFxSpecialEventObjectivesContainer_Fall2022';
        case SET_Xmas2018:
            return class'KFGFxChristmasObjectivesContainer';
        case SET_Xmas2019:
            return class'KFGFxSpecialEventObjectivesContainer_Xmas2019';
        case SET_Xmas2020:
            return class'KFGFxSpecialEventObjectivesContainer_Xmas2020';
        case SET_Xmas2021:
            return class'KFGFxSpecialEventObjectivesContainer_Xmas2021';
        case SET_Xmas2022:
            return class'KFGFxSpecialEventObjectivesContainer_Xmas2022';
    }
    
	switch( SpecialEventID )
	{
		case SEI_Spring:
			return class'KFGFxSpecialEventObjectivesContainer_Spring2021';
		case SEI_Summer:
			return class'KFGFxSpecialEventObjectivesContainer_Summer2022';
		case SEI_Fall:
			return class'KFGFxSpecialEventObjectivesContainer_Fall2022';
		case SEI_Winter:
            return class'KFGFxSpecialEventObjectivesContainer_Xmas2022';
	}

	return class'KFGFxSpecialEventObjectivesContainer';
}