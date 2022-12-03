class FunctionUtils extends Object
    abstract
    transient;
    
struct FUncompressedVector
{
    var float X, Y, Z;
};
struct FUncompressedRotator
{
    var int Yaw, Pitch, Roll;
};
    
static final function vector VectorMA( const vector Start, float Scale, const vector Direction )
{
    return Start + (Direction * Scale);
}

static final function float RemapVal( float Val, float A, float B, float C, float D)
{
	if( A == B )
		return Val >= B ? D : C;
	return C + (D - C) * (Val - A) / (B - A);
}

static final function string IntToBin(int Num, optional bool bPadWithZeroes=true, optional byte PadLength=32)
{
    local string S;
    
    while( Num > 0 )
    {
        S = ((Num % 2 ) == 0 ? "0" : "1") $ S;
        Num = Num / 2;
    }
    
    return bPadWithZeroes ? (GetFilledString((PadLength - Len(S)), "0") $ S) : S;
}

static final function int BinToInt(string Binary)
{
    local int Result, i, BinaryL;
    
    BinaryL = Len(Binary);
    for( i=BinaryL-1; i >= 0; i-- )
    {
        if( Mid(Binary, i, 1) == "1" )
            Result += 2 ** ((BinaryL-i) - 1);
    }
    
    return Result;
}

static final function float TimeFraction( float Start, float End, float Current )
{
    return FClamp((Current - Start) / (End - Start), 0.f, 1.f);
}

static final function string LTrim(coerce string S, optional string Find=" ")
{
    while (Left(S, 1) == Find)
        S = Right(S, Len(S) - 1);
    return S;
}

static final function string RTrim(coerce string S, optional string Find=" ")
{
    while (Right(S, 1) == Find)
        S = Left(S, Len(S) - 1);
    return S;
}

static final function string Trim(coerce string S)
{
    return LTrim(RTrim(S));
}

static final function string FormatFloat( float F, optional int Points=2 )
{
	local int Index;
	local string S;	

	S = string(F);
	Index = InStr(S, ".") + 1;
    
	return Mid(S, 0, Index+Points);
}

static final function string TrimFloat( float F )
{
	local int Index;
	local string S, Dec;	

	S = string(F);
	Index = InStr(S, ".")+1;
    Dec = RTrim(Mid(S, Index), "0");
    if( Dec == "" )
        Dec = "0";
    
	return Left(S, Index)$Dec;
}

static final function float Approach( float Cur, float Target, float Inc )
{
	Inc = Abs(Inc);

	if( Cur < Target )
		return FMin(Cur + Inc, Target);
	else if( Cur > Target )
		return FMax(Cur - Inc, Target);

	return Target;
}

static final function string FormatInteger(coerce int Val)
{
	local string S,O;

	S = string(Val);
	Val = Len(S);
	if( Val<=3 )
		return S;
	while( Val>3 )
	{
		if( O=="" )
			O = Right(S,3);
		else O = Right(S,3)$","$O;
		S = Left(S,Val-3);
		Val-=3;
	}
	if( Val>0 )
		O = S$","$O;
	return O;
}

static final function string FormatTimeSMH( coerce float Sec )
{
	local int Seconds,Minutes,Hours,Days;
	local string S;

	Sec = Abs(Sec);
	Seconds = int(Sec);

	Minutes = Seconds/60;
	Seconds-=(Minutes*60);

	Hours = Minutes/60;
	Minutes-=(Hours*60);
	
	Days = Hours/24;
	Hours-=(Days*24);

	S = Hours$":"$(Minutes<10 ? "0"$Minutes : string(Minutes))$":"$(Seconds<10 ? "0"$Seconds : string(Seconds));
	if( Days>0 )
		S = Days$"d "$S;
	return S;
}

static final function string GetMonthName(int Month)
{
    switch( Month )
    {
        case 1:
            return "Jan";
        case 2:
            return "Feb";
        case 3:
            return "Mar";
        case 4:
            return "Apr";
        case 5:
            return "May";
        case 6:
            return "Jun";
        case 7:
            return "Jul";
        case 8:
            return "Aug";
        case 9:
            return "Sep";
        case 10:
            return "Oct";
        case 11:
            return "Nov";
        case 12:
            return "Dec";
    }
    
    return "Unk";
}

static final function string GetNiceTime(coerce int Hour, coerce int Min)
{
    return (Hour == 0 ? 12 : (Hour > 12 ? Hour - 12 : Hour))$":"$(Min < 10 ? ("0"$Min) : string(Min))$(Hour >= 12 ? "pm" : "am");
}

static final function string GetTimeStamp()
{
    local int Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec;
    
    class'WorldInfo'.static.GetWorldInfo().GetSystemTime(Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec);
    return GetMonthName(Month) @ Day @ "@" @ GetNiceTime(Hour, Min);
}

static final function bool IsWhitespace( string C )
{
	return C == " " || C == "\t";
}

static final function string GetFilledString(int N, string C)
{
    local string S;
    local int i;
    
    for( i=0; i<n; i++ )
        S $= C;
        
    return S;
}

static final function float RoundFloatPrecision(float Val, optional byte N=2)
{
    return float(FCeil((Val * (10 ** N)) - 0.49f)) / (10 ** N);
}

static final function string GetTimeString(coerce int Seconds, optional bool bForceHours)
{
    local int Minutes, Hours;
    local string Time;

    if( bForceHours || Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

        if( Hours >= 10 )
            Time = Hours $ ":";
        else Time = "0" $ Hours $ ":";
    }
    Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    if( Minutes >= 10 )
        Time = Time $ Minutes $ ":";
    else Time = Time $ "0" $ Minutes $ ":";

    if( Seconds >= 10 )
        Time = Time $ Seconds;
    else Time = Time $ "0" $ Seconds;

    return Time;
}

static final function string GetTimeStringMS(coerce int Milliseconds, optional bool bForceHours)
{
    local int Seconds, Minutes, Hours;
    local string Time;

    if( bForceHours || Milliseconds > 3600000 )
    {
        Hours = Milliseconds / 3600000;
        Milliseconds -= Hours * 3600000;

        if( Hours >= 10 )
            Time = Hours $ ":";
        else Time = "0" $ Hours $ ":";
    }
    Minutes = Milliseconds / 60000;
    Milliseconds -= Minutes * 60000;

    if( Minutes >= 10 )
        Time = Time $ Minutes $ ":";
    else Time = Time $ "0" $ Minutes $ ":";
    
    Seconds = Milliseconds / 1000;
    Milliseconds -= Seconds * 1000;
    if( Seconds >= 10 )
        Time = Time $ Seconds $ ".";
    else Time = Time $ "0" $ Seconds $ ".";
    
    if( Milliseconds >= 100 )
        Time = Time $ Milliseconds;
    else if( Milliseconds >= 10 )
        Time = Time $ "0" $ Milliseconds;
    else Time = Time $ "00" $ Milliseconds;

    return Time;
}

static final function string SQLStr(string S)
{
    S = Repl(S, "'", "''", false);
    S = Repl(S, "\"", "\"\"", false);
    
    return S;
}

static final function string EscapeStr(string S)
{
    S = Repl(S, "'", "\\\\'", false);
    S = Repl(S, "\"", "\\\\\"", false);
    
    return S;
}

static final function string RemoveQuotes(string S)
{
    S = Repl(S, "'", "", false);
    S = Repl(S, "\"", "", false);
    
    return S;
}

static final function string RemoveEscapeStr(string S)
{
    S = Repl(S, "\\'", "'", false);
    S = Repl(S, "\\\"", "\"", false);
    
    return S;
}

static final function vector MakeVector(float X, float Y, float Z)
{
	local vector V;

	V.X = X;
	V.Y = Y;
	V.Z = Z;
	return V;
}

static final function FUncompressedRotator MakeUncompressedRotator(int Pitch, int Yaw, int Roll)
{
	local FUncompressedRotator R;

	R.Pitch = Pitch;
	R.Yaw = Yaw;
	R.Roll = Roll;
	return R;
}

static final function FUncompressedVector MakeUncompressedVector(float X, float Y, float Z)
{
	local FUncompressedVector V;

	V.X = X;
	V.Y = Y;
	V.Z = Z;
	return V;
}

static final function FUncompressedRotator ConvertRotatorToUnCompressed(rotator R)
{
	local FUncompressedRotator UR;

	UR.Pitch = R.Pitch;
	UR.Yaw = R.Yaw;
	UR.Roll = R.Roll;
	return UR;
}

static final function FUncompressedVector ConvertVectorToUnCompressed(vector V)
{
	local FUncompressedVector UV;

	UV.X = V.X;
	UV.Y = V.Y;
	UV.Z = V.Z;
	return UV;
}

static final function rotator ConvertUnCompressedRotator(FUncompressedRotator UR)
{
	local rotator R;

	R.Pitch = UR.Pitch;
	R.Yaw = UR.Yaw;
	R.Roll = UR.Roll;
	return R;
}

static final function vector ConvertUnCompressedVector(FUncompressedVector UV)
{
	local vector V;

	V.X = UV.X;
	V.Y = UV.Y;
	V.Z = UV.Z;
	return V;
}

static final function vector AlignedOffset(rotator R, vector Offset)
{
	local vector X,Y,Z;
	GetAxes(R,X,Y,Z);
	return (X*Offset.X + Y*Offset.Y + Z*Offset.Z);
}

static final function int Loop(int It, int By, optional int Max, optional int Min)
{
	if (It + By > Max)
		return -1 + Min + It + By - Max;
	if (It + By < Min)
		return 1 + Max + It + By - Min;
	return It + By;
}

static final function float LoopFloat(float It, float By, optional float Max, optional float Min)
{
	if (It + By > Max)
		return Min + It + By - Max;
	if (It + By < Min)
		return Max + It + By - Min;
	return It + By;
}

static final function vector GetUpAxis(rotator Angle)
{
	return GetRotatorAxis(Angle, AXIS_Z);
}

static final function vector GetRightAxis(rotator Angle)
{
	return GetRotatorAxis(Angle, AXIS_X);
}

static final function vector GetForwardAxis(rotator Angle)
{
	return GetRotatorAxis(Angle, AXIS_Y);
}

static final function rotator RotateAboutAxis(rotator Axis, rotator Offset)
{
	local vector X,Y,Z;
	GetAxes(Offset, X, Y, Z);
	return OrthoRotation(X>>Axis, Y>>Axis, Z>>Axis);
}