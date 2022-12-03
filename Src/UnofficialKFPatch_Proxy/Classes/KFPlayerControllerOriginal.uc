class KFPlayerControllerOriginal extends Object;

reliable client function ClientTriggerWeaponContentLoad(class<KFWeapon> WeaponClass);
event PreClientTravel( string PendingURL, ETravelType TravelType, bool bIsSeamlessTravel );
function RecieveChatMessage(PlayerReplicationInfo PRI, string ChatMessage, name Type, optional float MsgLifeTime);
reliable client event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime);
reliable client event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject );
function EnterZedTime();
function CompleteZedTime();
event name GetSeasonalStateName();
reliable server function ServerPause();
reliable client function ClientWonGame( string MapName, byte Difficulty, byte GameLength, byte bCoop );
reliable client function ClientGameOver(string MapName, byte Difficulty, byte GameLength, byte bCoop, byte FinalWaveNum);
stripped reliable client event OnAllMapCollectiblesFound(string MapName);
simulated function bool SeasonalEventIsValid();
function GetSeasonalEventStatInfo(int StatIdx, out int CurrentValue, out int MaxValue);