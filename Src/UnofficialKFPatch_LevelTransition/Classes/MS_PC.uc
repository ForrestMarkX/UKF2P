Class MS_PC extends KFPlayerController;

var byte ConnectionCounter;
var bool bConnectionFailed;
var transient MS_Game Game;

simulated event ReceivedPlayer();
simulated function ReceivedGameClass(class<GameInfo> GameClass);

simulated function HandleNetworkError( bool bConnectionLost )
{
    ConsoleCommand("Disconnect");
}

function PlayerTick( float DeltaTime )
{
    if( ConnectionCounter<3 && ++ConnectionCounter==3 )
    {
        if( Game.PendingURL!="" )
        {
            if( Game.bServerHidden )
                MS_HUD(myHUD).ShowProgressMsg("Connecting to Private Match");
            else MS_HUD(myHUD).ShowProgressMsg("Connecting to "$Game.PendingURL);
            ConsoleCommand("Open "$Game.PendingURL$"?SpectatorOnly="$Game.SpectatorInfo);
        }
    }
    PlayerInput.PlayerInput(DeltaTime);
}

final function AbortConnection()
{
    if( bConnectionFailed )
        HandleNetworkError(false);
    else
    {
        ShowConnectionProgressPopup(PMT_ConnectionFailure,"Connection aborted","User aborted connection...",true);
        ConsoleCommand("Cancel");
    }
}

exec function Cancel()
{
    SetTimer(4,false,'HandleNetworkError');
}

reliable client function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  );

reliable client function bool ShowConnectionProgressPopup( EProgressMessageType ProgressType, string ProgressTitle, string ProgressDescription, bool SuppressPasswordRetry = false)
{
    if( bConnectionFailed )
        return false;
    switch(ProgressType)
    {
    case PMT_ConnectionFailure:
    case PMT_PeerConnectionFailure:
        bConnectionFailed = true;
        MS_HUD(myHUD).ShowProgressMsg("Connection Error: "$ProgressTitle$"|"$ProgressDescription$"|Disconnecting...",true);
        SetTimer(4,false,'HandleNetworkError');
        return true;
    case PMT_DownloadProgress:
    case PMT_AdminMessage:
        MS_HUD(myHUD).ShowProgressMsg(ProgressTitle$"|"$ProgressDescription);
        return true;
    }
    return false;
}

auto state PlayerWaiting
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

    reliable server function ServerChangeTeam( int N );

    reliable server function ServerRestartPlayer();

    function PlayerMove(float DeltaTime)
    {
    }
}

defaultproperties
{
    InputClass=class'MS_Input'
}