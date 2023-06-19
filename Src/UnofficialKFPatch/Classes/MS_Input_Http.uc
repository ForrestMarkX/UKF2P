Class MS_Input_Http extends PlayerInput;

event bool FilterButtonInput(int ControllerId, Name Key, EInputEvent Event, float AmountDepressed, bool bGamepad)
{
    if ( Event==IE_Pressed && (Key == 'Escape' || Key == 'XboxTypeS_Start') )
    {
        MS_PC_Http(Outer).AbortConnection();
        return true;
    }
    return false;
}

defaultproperties
{
    OnReceivedNativeInputKey=FilterButtonInput
}