class KFGameInfoOriginal extends Object;

function ReplicateWelcomeScreen();
function ModifyAIDoshValueForPlayerCount( out float ModifiedValue );
function string GetFriendlyNameForCurrentGameMode();
static function int GetGameModeNumFromClass( string GameModeClassString );
static function string GetGameModeFriendlyNameFromClass( string GameModeClassString );
function CreateOutbreakEvent();
function UpdateGameSettings();
protected function ScoreMonsterKill( Controller Killer, Controller Monster, KFPawn_Monster MonsterPawn );
protected function DistributeMoneyAndXP(class<KFPawn_Monster> MonsterClass, const out array<DamageInfo> DamageHistory, Controller Killer);