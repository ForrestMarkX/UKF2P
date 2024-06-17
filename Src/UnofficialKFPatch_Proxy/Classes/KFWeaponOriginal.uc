class KFWeaponOriginal extends Object;

simulated event PreBeginPlay();
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate );
reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate);
simulated function KFWeaponAttachment GetWeaponAttachmentTemplate();
simulated event SetPosition(KFPawn Holder);
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName );
simulated event HandleRecoil();
simulated static event class<KFPerk> GetWeaponPerkClass( class<KFPerk> InstigatorPerkClass );
simulated event vector GetMuzzleLoc();
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp);
reliable server function SyncCurrentAmmoCount(byte FireMode, int CurrentAmmoCount);