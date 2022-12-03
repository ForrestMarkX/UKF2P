class EntranceSoundPlayer extends Object;

var KFPawn PawnOwner;

final function DelayPlayEntranceSound()
{
    PawnOwner.SoundGroupArch.PlayEntranceSound( PawnOwner );
}