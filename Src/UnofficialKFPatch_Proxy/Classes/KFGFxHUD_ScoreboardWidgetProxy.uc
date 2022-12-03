class KFGFxHUD_ScoreboardWidgetProxy extends Object;

stripped function context(KFGFxHUD_ScoreboardWidget.InitializeHUD) InitializeHUD()
{
    ScoreboardUpdateInterval = 0.1f;
    
    LocalizeText();
    UpdatePlayerList();
    UpdateMatchInfo();
    SendServerInfoToGFX();
}