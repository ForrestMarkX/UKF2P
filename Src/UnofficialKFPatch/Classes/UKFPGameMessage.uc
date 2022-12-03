class UKFPGameMessage extends GameMessage;

var string PlayerNameColor, UserAdd, UserDelete, UserGo, UserEdit;

static function string GetString(optional int Switch, optional bool bPRI1HUD, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    local string SteamID;

    if( RelatedPRI_1 != None )
        SteamID = ConvertUIDToSteamID(RelatedPRI_1.UniqueId);
    
	switch (Switch)
	{
		case 0:
			return class'GameMessage'.default.OverTimeMessage;
			break;
		case 1:
			if (RelatedPRI_1 == None)
                return class'GameMessage'.default.NewPlayerMessage;
			return default.UserAdd$default.PlayerNameColor$RelatedPRI_1.PlayerName$"</font>"$class'GameMessage'.default.EnteredMessage;
			break;
		case 2:
			if (RelatedPRI_1 == None)
				return "";
			return default.UserEdit$default.PlayerNameColor$RelatedPRI_1.OldName$"</font>"$class'GameMessage'.default.GlobalNameChange@default.PlayerNameColor$RelatedPRI_1.PlayerName$"</font>";
			break;
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			return default.UserDelete$default.PlayerNameColor$"("$SteamID$")"@RelatedPRI_1.PlayerName$"</font>"$class'GameMessage'.default.LeftMessage;
			break;
		case 5:
			return "<font color=\"#FFFFFF\" face=\"MIcon\">"$`GetMIconChar("earth-arrow-right")$"</font>"$class'GameMessage'.default.SwitchLevelMessage$"</font>";
			break;
		case 6:
			return class'GameMessage'.default.FailedTeamMessage;
			break;
		case 7:
			return class'GameMessage'.default.MaxedOutMessage;
			break;
		case 8:
			return class'GameMessage'.default.NoNameChange;
			break;
        case 9:
            return RelatedPRI_1.PlayerName@class'GameMessage'.default.VoteStarted;
            break;
        case 10:
            return class'GameMessage'.default.VotePassed;
            break;
        case 11:
			return class'GameMessage'.default.MustHaveStats;
			break;
        case 12:
            return class'GameMessage'.default.CantBeSpectator;
            break;
        case 13:
            return class'GameMessage'.default.CantBePlayer;
            break;
        case 14:
            return default.UserGo$default.PlayerNameColor$RelatedPRI_1.PlayerName$"</font>"$class'GameMessage'.default.BecameSpectator;
            break;
        case 15:
            return class'GameMessage'.default.KickWarning;
            break;
        case 16:
            if (RelatedPRI_1 == None)
                return class'GameMessage'.default.NewSpecMessage;
            return default.UserAdd$default.PlayerNameColor$RelatedPRI_1.PlayerName$"</font>"$class'GameMessage'.default.SpecEnteredMessage;
            break;
	}
	return "";
}

static final function string ConvertUIDToSteamID(UniqueNetId UniqueId)
{
    return "STEAM_" $ string((UniqueId.Uid.B >> 24) & 0xFF) $ ":" $ string(UniqueId.Uid.A & 1) $ ":" $ string((UniqueId.Uid.A >> 1) & 0x7FFFFFF);
}

static final function UniqueNetId ConvertSteamIDToUID(string SteamID)
{
    local string S;
    local byte Universe, AccountType;
    local int AccountNumber;
    local UniqueNetId UID;
    
    S = Repl(SteamID, "STEAM_", "");
    S = Repl(S, ":", "");
    
    Universe = byte(Mid(S, 0, 1));
    AccountType = byte(Mid(S, 1, 1));
    AccountNumber = int(Mid(S, 2));
    
    UID.Uid.A = AccountType | (AccountNumber << 1);
    UID.Uid.B = (Universe << 24) | 0x1100001;
    
    return UID;
}

static final function string ConvertSteamIDToSteamID64(string SteamID)
{
    local OnlineSubsystemSteamworks OnlineSub;
    local UniqueNetId UID;
    
    OnlineSub = OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem());
    UID = ConvertSteamIDToUID(SteamID);
    return OnlineSub.UniqueNetIdToInt64(UID);
}
 
defaultproperties
{
    PlayerNameColor="<font color=\"#C8FF00\">"
}
