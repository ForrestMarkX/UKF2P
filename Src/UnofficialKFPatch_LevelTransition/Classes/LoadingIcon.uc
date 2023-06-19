class LoadingIcon extends Object;

var float FrameTime, FrameFadeTime;
var array<Texture2D> Frames;
var bool bFadeBetweenFrames;
var transient float CurrentFrameTime;
var transient byte CurrentFrame, NextFrame;
var WorldInfo WorldInfo;

final function Init()
{
    WorldInfo = class'WorldInfo'.static.GetWorldInfo();
}

final function Render(Canvas C, float SizeX, float SizeY)
{
    local Color OrgColor;

    if( Frames.Length <= 0 || FrameTime == 0.f )
        return;
        
    CurrentFrameTime += WorldInfo.DeltaSeconds;
    if( CurrentFrameTime >= FrameTime )
    {
        CurrentFrameTime = 0.f;
        if( ++CurrentFrame >= Frames.Length )
            CurrentFrame = 0;
            
        NextFrame = CurrentFrame + 1;
        if( NextFrame >= Frames.Length )
            NextFrame = 0;
    }
    
    if( bFadeBetweenFrames && FrameFadeTime != 0.f && FrameFadeTime < FrameTime && CurrentFrameTime > (FrameTime - FrameFadeTime) )
    {
        OrgColor = C.DrawColor;
        C.DrawRect(SizeX, SizeY, Frames[NextFrame]);
        C.DrawColor.A = int((1.f - ((CurrentFrameTime - (FrameTime - FrameFadeTime)) / FrameFadeTime)) * OrgColor.A);
        C.DrawRect(SizeX, SizeY, Frames[CurrentFrame]);
        C.DrawColor = OrgColor;
        return;
    }
    C.DrawRect(SizeX, SizeY, Frames[CurrentFrame]);
}

defaultproperties
{
    FrameTime=0.0395
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I3A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I3C')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I3E')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I40')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I42')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I44')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I46')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I48')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I4A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I4C')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I4E')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I50')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I52')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I54')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I56')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I58')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I5A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I5C')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I5E')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I60')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I62')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I64')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I66')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I66')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I66')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I66')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I66')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLib_I66')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I64')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I62')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I60')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I5E')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I5C')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I5A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I58')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I56')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I54')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I52')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I50')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I4E')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I4C')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I4A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I48')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I46')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I44')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I42')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I40')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3E')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3C')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3A')
    Frames.Add(Texture2D'UKFP_LevelTrans_HUD.Animated.AssetLibRRev_I3A')
}