class KFCharacterInfo_HumanOriginal extends Object;

private function SetBodyMeshAndSkin( byte CurrentBodyMeshIndex, byte CurrentBodySkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI );
protected simulated function SetBodySkinMaterial(OutfitVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP);
protected simulated function SetHeadSkinMaterial(OutfitVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP);
private function SetHeadMeshAndSkin( byte CurrentHeadMeshIndex, byte CurrentHeadSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI );
protected simulated function SetAttachmentMesh(int CurrentAttachmentMeshIndex, int AttachmentSlotIndex, string CharAttachmentMeshName, name CharAttachmentSocketName, SkeletalMeshComponent PawnMesh, KFPawn KFP, bool bIsFirstPerson = false);
protected simulated function SetAttachmentSkinMaterial(int PawnAttachmentIndex, const out AttachmentVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP, optional bool bIsFirstPerson);
protected simulated function SetWeeklyCowboyAttachmentSkinMaterial(int PawnAttachmentIndex, const out AttachmentVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP, optional bool bIsFirstPerson);
private function SetAttachmentMeshAndSkin(int CurrentAttachmentMeshIndex, int CurrentAttachmentSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI);
simulated function SetArmsMeshAndSkin(byte ArmsMeshIndex, byte ArmsSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI);
function DetachConflictingAttachments(int NewAttachmentMeshIndex, KFPawn KFP, optional KFPlayerReplicationInfo KFPRI, optional out array<int> out_RemovedAttachments );