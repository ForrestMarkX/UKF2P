class PlayerControllerOriginal extends Object;

exec function Say( string Msg );
exec function TeamSay( string Msg );
unreliable server function ServerSay( string Msg );
unreliable server function ServerTeamSay( string Msg );
reliable server function ServerCamera( name NewMode );