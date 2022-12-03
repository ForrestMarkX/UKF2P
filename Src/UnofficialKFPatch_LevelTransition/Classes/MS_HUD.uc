Class MS_HUD extends HUD;

enum ECornerPosition
{
	ECP_TopLeft,
	ECP_TopRight,
	ECP_BottomLeft,
	ECP_BottomRight
};

enum ECornerShape
{
	ECS_Corner,
	ECS_BeveledCorner,
	ECS_VerticalCorner,
	ECS_HorisontalCorner
};

var transient Texture2D MapIcon, BackgroundImage;

var transient array<string> ProgressLines;
var transient bool bShowProgress,bProgressDC;

var transient float ScaledBorderSize;
var transient string MapName;

var Font MainFont;
var Texture2D ItemTex, MapImage;
var LoadingIcon LoadingIcon;

simulated function PostBeginPlay()
{
    LoadingIcon = New(self) class'LoadingIcon';
    LoadingIcon.Init();
    
    Super.PostBeginPlay();
    
    ItemTex = Texture2D'UI_LevelChevrons_TEX.UI_LevelChevron_Icon_02';
    if( ItemTex == None )
        ItemTex = Texture2D'EngineMaterials.DefaultWhiteGrid';
        
    MapName = MS_Game(WorldInfo.Game).MapName;
    MapImage = GetMapImage(MapName);
}

final static function string GetGameInfoName()
{
    local array<string> GamemModeStringArray;

    ParseStringIntoArray(KFGameEngine(Class'Engine'.static.GetEngine()).TransitionGameType, GamemModeStringArray, ".", true);

    if( GamemModeStringArray.Length > 0 )
    {
        if(Caps(GamemModeStringArray[0]) == Caps("KFGameContent"))
        {
            return Localize(GamemModeStringArray[1], "GameName", "KFGameContent" );
        }
        else if( GamemModeStringArray.Length > 1 )
        {
            return GamemModeStringArray[1];
        }
    }
    
    return "Unknown Game";
}

function PostRender()
{
    Super.PostRender();

    ScaledBorderSize = FMax(3 * ( Canvas.ClipX / 1920.f ), 1.f);
    if( bShowProgress )
        RenderProgress();
}

final function ShowProgressMsg( string S, optional bool bDis )
{
    if( S=="" )
    {
        bShowProgress = false;
        return;
    }
    bShowProgress = true;
    ParseStringIntoArray(S,ProgressLines,"|",false);
    bProgressDC = bDis;
    if( !bDis )
        ProgressLines.AddItem("Press [Esc] to cancel connection");
}

final function RenderProgress()
{
    local float X,Y,XL,YL,Sc,TY,TX,BoxX,BoxW,TextX,LoadingSize;
    local int i;
    local Color OutlineColor;
    
    Canvas.Font = PickFont(Sc);
    Sc += 0.25f;
    
    if( bProgressDC )
        Canvas.SetDrawColor(255,80,80,255);
    else Canvas.SetDrawColor(255,255,255,255);
    Y = Canvas.ClipY*0.05;

    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize("<"@ProgressLines[i]@">",XL,YL,Sc,Sc);
        TX = FMax(TX,XL);
    }
    TY = YL*ProgressLines.Length;
    
    X = (Canvas.ClipX/2) - (TX/2);
    
    BoxX = X+(ScaledBorderSize*2);
    BoxW = TX-(ScaledBorderSize*4);
    
    Canvas.SetDrawColor(5, 5, 5, 163);
    DrawRectBoxEx(BoxX, Y, BoxW, TY, 8, 0);
    
    Canvas.SetDrawColor(237, 8, 0, 255);
    DrawRectBoxEx(X, Y, ScaledBorderSize*2, TY, 8, 151);
    DrawRectBoxEx(X+TX-(ScaledBorderSize*2), Y, ScaledBorderSize*2, TY, 8, 153);

    Canvas.DrawColor = WhiteColor;
    for( i=0; i<ProgressLines.Length; ++i )
    {
        Canvas.TextSize(ProgressLines[i],XL,YL,Sc,Sc);
        
        TextX = BoxX + (BoxW/2) - (XL/2);
        
        DrawTextShadow(ProgressLines[i], TextX, Y, 1, Sc);
        Y+=YL;
    }
    
    if( MapImage != None )
    {
        OutlineColor = MakeColor(40, 40, 40, 255);
        Canvas.TextSize(MapName,XL,YL,Sc,Sc);
        
        BoxW = Canvas.ClipX*0.25;
        TY = BoxW;
        
        GetRatioSize(MapImage, BoxW, TY, ScaledBorderSize*2);
        
        Y += (YL*2.f) + (ScaledBorderSize*2);
        X = (Canvas.ClipX-BoxW) * 0.5f;
        
        Canvas.DrawColor = WhiteColor;
        Canvas.SetPos(X, Y);
        Canvas.DrawTile(MapImage, BoxW, TY, 0, 0, MapImage.GetSurfaceWidth(), MapImage.GetSurfaceHeight());
        
        DrawRoundedBoxEx(8, X, Y, ScaledBorderSize*2, TY, OutlineColor, false, false, true, false);
        DrawRoundedBoxEx(8, X+BoxW-(ScaledBorderSize*2), Y, ScaledBorderSize*2, TY, OutlineColor, false, false, false, true);
        DrawRoundedBoxEx(8, X, Y-YL, BoxW, YL, OutlineColor, true, true, false, false);
        
        X += (BoxW-XL) * 0.5f;
        Y -= (YL+ScaledBorderSize);
        
        Canvas.DrawColor = WhiteColor;
        DrawTextShadow(MapName, X, Y, 1, Sc);
    }
    
    if( LoadingIcon != None )
    {
        YL = Canvas.ClipY * 0.1f;
        
        Y = Canvas.ClipY - YL - (ScaledBorderSize*4);
        X = Canvas.ClipX - YL - (ScaledBorderSize*4);
        
        BoxX = X+(ScaledBorderSize*2);
        BoxW = YL-(ScaledBorderSize*4);
        
        Canvas.SetDrawColor(5, 5, 5, 163);
        DrawRectBoxEx(BoxX, Y, BoxW, YL, 8, 0);
        
        Canvas.SetDrawColor(237, 8, 0, 255);
        DrawRectBoxEx(X, Y, ScaledBorderSize*2, YL, 8, 151);
        DrawRectBoxEx(X + YL - (ScaledBorderSize*2), Y, ScaledBorderSize*2, YL, 8, 153);
        
        LoadingSize = BoxW - (ScaledBorderSize*2.f);
        
        Canvas.DrawColor = WhiteColor;
        Canvas.SetPos(BoxX + ((BoxW-LoadingSize) * 0.5f), Y + ((YL-LoadingSize) * 0.5f));
        LoadingIcon.Render(Canvas, LoadingSize, LoadingSize);
    }
}

static final function Texture2D GetMapImage(string M)
{
    local KFMapSummary MapData;

    MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName(M);
    if ( MapData != None )
        return Texture2D(DynamicLoadObject(MapData.ScreenshotPathName, class'Texture2D'));
    else
    {
        MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName("KF-Default");
        if ( MapData != None )
            return Texture2D(DynamicLoadObject(MapData.ScreenshotPathName, class'Texture2D'));    
    }
    
    return None;
}

final function Font PickFont( out float Scaler )
{
    Scaler = GetFontScaler();
    return MainFont;
}

final function float GetFontScaler(optional float Scaler=0.750f, optional float Min=0.175f, optional float Max=1.0f)
{
	return FClamp((SizeY / 1080.f) * Scaler, Min, Max);
}

final function DrawRoundedBoxEx( float BorderSize, float X, float Y, float W, float H, Color BoxColor, optional bool TopLeft, optional bool TopRight, optional bool BottomLeft, optional bool BottomRight )
{
    Canvas.DrawColor = BoxColor;

    if( BorderSize <= 0 || (!TopLeft && !TopRight && !BottomLeft && !BottomRight) )
    {
        Canvas.SetPos(X, Y);
        DrawWhiteBox(W, H);
        return;
    }
    
    Canvas.PreOptimizeDrawTiles(7, ItemTex);

    BorderSize = Min(FMin(BorderSize,(W)*0.5),(H)*0.5);

    Canvas.SetPos(X + BorderSize, Y);
    DrawWhiteBox(W - BorderSize * 2, H);
    
    Canvas.SetPos(X, Y + BorderSize);
    DrawWhiteBox(BorderSize, H - BorderSize * 2);
    
    Canvas.SetPos(X + W - BorderSize, Y + BorderSize);
    DrawWhiteBox(BorderSize, H - BorderSize * 2);

    DrawBoxCorners(BorderSize, X, Y, W, H, TopLeft, TopRight, BottomLeft, BottomRight);
}

final function DrawBoxCorners(float BorderSize, float X, float Y, float W, float H, optional bool TopLeft, optional bool TopRight, optional bool BottomLeft, optional bool BottomRight)
{
    // Top left
    Canvas.SetPos(X,Y);
    if( TopLeft )
        DrawCornerTex(BorderSize,0);
    else DrawWhiteBox(BorderSize, BorderSize);
    
    // Top right
    Canvas.SetPos(X+W-BorderSize,Y);
    if( TopRight )
        DrawCornerTex(BorderSize,1);
    else DrawWhiteBox(BorderSize, BorderSize);
    
    // Bottom left
    Canvas.SetPos(X,Y+H-BorderSize);
    if( BottomLeft )
        DrawCornerTex(BorderSize,2);
    else DrawWhiteBox(BorderSize, BorderSize);
    
    // Bottom right
    Canvas.SetPos(X+W-BorderSize,Y+H-BorderSize);
    if( BottomRight )
        DrawCornerTex(BorderSize,3);
    else DrawWhiteBox(BorderSize, BorderSize);
}

final function DrawWhiteBox( float XS, float YS, optional bool bClip )
{
    Canvas.DrawTile(ItemTex,XS,YS,19,45,1,1,,bClip);
}

final function GetRatioSize(Texture Tex, out float XL, out float YL, optional float BorderSize, optional float ForceTexW, optional float ForceTexH)
{
    local float RatioW, RatioH, RatioDiff;
    
    if( ForceTexH <= 0.f )
        ForceTexH = Tex.GetSurfaceHeight();
    if( ForceTexW <= 0.f )
        ForceTexW = Tex.GetSurfaceWidth();
    
    RatioH = ForceTexH / YL;
    RatioW = ForceTexW / RatioH;
    
    if( RatioW > XL )
    {
        RatioDiff = XL/RatioW;
        
        RatioW *= RatioDiff;
        YL *= RatioDiff;
    }
    
    YL -= BorderSize * 2;
    XL = RatioW - (BorderSize * 2);
}

final function DrawCornerTex( int Size, byte Dir )
{
    switch( Dir )
    {
    case 0: // Up-left
        Canvas.DrawTile(ItemTex,Size,Size,77,15,-66,58);
        break;
    case 1: // Up-right
        Canvas.DrawTile(ItemTex,Size,Size,11,15,66,58);
        break;
    case 2: // Down-left
        Canvas.DrawTile(ItemTex,Size,Size,77,73,-66,-58);
        break;
    default: // Down-right
        Canvas.DrawTile(ItemTex,Size,Size,11,73,66,-58);
    }
}

final function DrawTextShadow( coerce string S, float X, float Y, float ShadowSize, optional float Scale=1.f, optional FontRenderInfo FRI  )
{
    local Color OldDrawColor;
    
    OldDrawColor = Canvas.DrawColor;
    
    Canvas.SetPos(X + ShadowSize, Y + ShadowSize);
    Canvas.SetDrawColor(0, 0, 0, OldDrawColor.A);
    Canvas.DrawText(S,, Scale, Scale, FRI);
    
    Canvas.SetPos(X, Y);
    Canvas.DrawColor = OldDrawColor;
    Canvas.DrawText(S,, Scale, Scale, FRI);
}

final function DrawCornerSmart(float X, float Y, int Edge, int CornerPosition, int CornerShape)
{
	switch (CornerPosition)
	{
	case ECP_TopLeft:
		switch (CornerShape)
		{
		case ECS_Corner:
		return;
		case ECS_BeveledCorner:
		Canvas.SetPos(X, Y);
		DrawCornerTex(Edge, 0);
		return;
		case ECS_VerticalCorner:
		Canvas.SetPos(X, Y - Edge);
		DrawCornerTex(Edge, 1);
		return;
		case ECS_HorisontalCorner:
		Canvas.SetPos(X - Edge, Y);
		DrawCornerTex(Edge, 2);
		return;
		}
	case ECP_TopRight:
		switch (CornerShape)
		{
		case ECS_Corner:
		return;
		case ECS_BeveledCorner:
		Canvas.SetPos(X - Edge, Y);
		DrawCornerTex(Edge, 1);
		return;
		case ECS_VerticalCorner:
		Canvas.SetPos(X - Edge, Y - Edge);
		DrawCornerTex(Edge, 0);
		return;
		case ECS_HorisontalCorner:
		Canvas.SetPos(X, Y);
		DrawCornerTex(Edge, 3);
		return;
		}
	case ECP_BottomLeft:
		switch (CornerShape)
		{
		case ECS_Corner:
		return;
		case ECS_BeveledCorner:
		Canvas.SetPos(X, Y - Edge);
		DrawCornerTex(Edge, 2);
		return;
		case ECS_VerticalCorner:
		Canvas.SetPos(X, Y);
		DrawCornerTex(Edge, 3);
		return;
		case ECS_HorisontalCorner:
		Canvas.SetPos(X - Edge, Y - Edge);
		DrawCornerTex(Edge, 0);
		return;
		}
	case ECP_BottomRight:
		switch (CornerShape)
		{
		case ECS_Corner:
		return;
		case ECS_BeveledCorner:
		Canvas.SetPos(X - Edge, Y - Edge);
		DrawCornerTex(Edge, 3);
		return;
		case ECS_VerticalCorner:
		Canvas.SetPos(X - Edge, Y);
		DrawCornerTex(Edge, 2);
		return;
		case ECS_HorisontalCorner:
		Canvas.SetPos(X, Y - Edge);
		DrawCornerTex(Edge, 1);
		return;
		}
	}
}

final function DrawRectBoxSmart(float X, float Y, float W, float H, int Edge, int TopLeftShape, int TopRightShape, int BottomLeftShape, int BottomRightShape)
{
	local float BoxX, BoxW;
	
	// Top Line
	DrawCornerSmart(X, Y, Edge, ECP_TopLeft, TopLeftShape);
	
	BoxX = X; BoxW = W;
	if (TopLeftShape == ECS_BeveledCorner)
	{
		BoxX += Edge;
		BoxW -= Edge;
	}
	if (TopRightShape == ECS_BeveledCorner)
	{
		BoxW -= Edge;
	}
	Canvas.SetPos(BoxX, Y);
	DrawWhiteBox(BoxW, Edge);
	
	DrawCornerSmart(X + W, Y, Edge, ECP_TopRight, TopRightShape);
	
	// Mid Line
	Canvas.SetPos(X, Y + Edge);
	DrawWhiteBox(W, H - Edge * 2);
	
	// Bottom Line
	DrawCornerSmart(X, Y + H, Edge, ECP_BottomLeft, BottomLeftShape);
	
	BoxX = X; BoxW = W;
	if (BottomLeftShape == ECS_BeveledCorner)
	{
		BoxX += Edge;
		BoxW -= Edge;
	}
	if (BottomRightShape == ECS_BeveledCorner)
	{
		BoxW -= Edge;
	}
	Canvas.SetPos(BoxX, Y + H - Edge);
	DrawWhiteBox(BoxW, Edge);
	
	DrawCornerSmart(X + W, Y + H, Edge, ECP_BottomRight, BottomRightShape);
}

// Enhanced version by GenZmeY
final function DrawRectBoxEx(float X, float Y, float Width, float Height, int Edge, optional byte Extrav)
{
	if (Extrav == 2)
		Edge=Min(FMin(Edge, (Width)*0.5), Height);// Verify size.
	else Edge=Min(FMin(Edge, (Width)*0.5), (Height)*0.5);// Verify size.

	Canvas.PreOptimizeDrawTiles(Extrav == 0 ? 7 : 6, ItemTex);
	
	switch (Extrav)
	{
		case 100:
		//   ______
		//  |      |
		//  |      |
		//  |______|
		
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 110:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 111:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 120:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 121:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 130:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 131:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 132:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 133:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 140:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 141:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 142: 
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 143:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 150:
		//   ______
		//  /      \
		//  | ____ |
		//  |/    \|
		
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 151:
		//   _______
		//  /      /
		//  |     |
		//  \______\
		
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 152:
		// 
		//  |\____/|
		//  |      |
		//  \______/
		
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 153:
		//   _______
		//   \      \
		//   |      |
		//   /______/
		
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 160:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 161:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 162:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 163:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 170:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 171:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 172:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 173:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 180:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 181:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 182:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 183:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 190:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 191:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 192:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 193:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 200:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 201:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 202:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 203:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 210:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 211:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 212:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 213:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 220:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 221:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 222:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_Corner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 223:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 230:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 231:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 232:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 233:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
		
		case 240:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_HorisontalCorner, // TopRight
			ECS_HorisontalCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		case 241:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_VerticalCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_VerticalCorner // BottomRight
		);
		break;
		
		case 242:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_HorisontalCorner, // TopLeft
			ECS_Corner, // TopRight
			ECS_Corner, // BottomLeft
			ECS_HorisontalCorner // BottomRight
		);
		break;
		
		case 243:
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_Corner, // TopLeft
			ECS_VerticalCorner, // TopRight
			ECS_VerticalCorner, // BottomLeft
			ECS_Corner // BottomRight
		);
		break;
		
		default: // 0
		//   ______
		//  /      \
		//  |      |
		//  \______/
		
		DrawRectBoxSmart(X, Y, Width, Height, Edge, 
			ECS_BeveledCorner, // TopLeft
			ECS_BeveledCorner, // TopRight
			ECS_BeveledCorner, // BottomLeft
			ECS_BeveledCorner // BottomRight
		);
		break;
	}
}

defaultproperties
{
    MainFont=Font'UI_Canvas_Fonts.Font_Main'
    MapImage=Texture2D'ui_mappreview_tex.UI_MapPreview_Placeholder'
}