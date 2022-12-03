class KFGFxMenu_GearProxy extends Object;

stripped private function context(KFGFxMenu_Gear.Callback_AttachmentNumbered) Callback_AttachmentNumbered(int MeshIndex, int SkinIndex, int SlotIndex)
{
	local Pawn P;
	local KFPawn KFP;
	local array<int> RemovedAttachments;

	P = GetPC().Pawn;
	if( P != None )
	{
		KFP = KFPawn(P);
		if ( KFP != none && MyKFPRI != None )
			SelectCustomizationOption(KFP, CO_Attachment, MeshIndex, SkinIndex, SlotIndex);
	}
	SetAttachmentButtons(AttachmentKey, AttachmentFunctionKey);
    ResetCustomizationView();
}

stripped final function context(KFGFxMenu_Gear) ResetCustomizationView()
{
	if( KFPlayerCamera(GetPC().PlayerCamera) != None )
		KFPlayerCamera(GetPC().PlayerCamera).CustomizationCam.SetBodyView( 0 );
}

stripped function context(KFGFxMenu_Gear.CheckForCustomizationPawn) CheckForCustomizationPawn( PlayerController PC )
{
    CheckForCustomizationPawnEx(PC);
}

stripped final function context(KFGFxMenu_Gear) CheckForCustomizationPawnEx( PlayerController PC )
{
	local KFPlayerController KFPC;
    local ReplicationHelper CRI;

    KFPC = KFPlayerController( PC );
    if( KFPC != None && PC.Pawn != None && KFPC.MyGFxManager.bAfterLobby )
    {
        KFPC.SavedViewTargetInfo.SavedCameraMode = KFPC.PlayerCamera.CameraStyle;
        KFPC.ServerCamera('Customization');

        CRI = `GetChatRep();
        if( CRI != None )
            CRI.SetCustomizationView(true);
    }
}

stripped event context(KFGFxMenu_Gear.OnClose) OnClose()
{
	local PlayerController PC;
	local KFPlayerController KFPC;

	Super.OnClose();

	Manager.CachedProfile.Save( GetLP().ControllerId );

	GetGameViewportClient().HandleInputAxis = None;

	if( class'WorldInfo'.static.IsMenuLevel() )
		Manager.ManagerObject.SetBool("backgroundVisible", true);
        
	PC = GetPC();
	if( PC != None )
	{
		KFPC = KFPlayerController( PC );
		if( KFPC != None )
            RestorePlayerView(KFPC);
	}
}

stripped final function context(KFGFxMenu_Gear) RestorePlayerView( KFPlayerController PC )
{
    local ReplicationHelper CRI;

    if( PC.MyGFxManager.bAfterLobby )
    {
        PC.ServerCamera(PC.SavedViewTargetInfo.SavedCameraMode);

        CRI = `GetChatRep();
        if( CRI != None )
            CRI.SetCustomizationView(false);
    }
    else PC.ReturnToViewTarget();
}

stripped private function context(KFGFxMenu_Gear.Callback_Emote) Callback_Emote(int Index)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());
	if( KFPC != None )
	{
		class'KFEmoteList'.static.SaveEquippedEmote(EmoteList[Index].ID);

		if( KFPawn_Customization(KFPC.Pawn) != None )
			KFPawn_Customization(KFPC.Pawn).PlayEmoteAnimation();
        else if( `GetURI() != None )
            `GetURI().PlayEmoteAnimation(KFPawn_Human(KFPC.Pawn));
	}

	SetEmoteButton();
}