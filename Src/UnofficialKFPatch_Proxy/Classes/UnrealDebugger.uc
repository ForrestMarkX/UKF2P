class UnrealDebugger extends Info;

var FileWriter FileWriter;
var UnrealDebugger StaticReference;

function PostBeginPlay()
{
    default.StaticReference = self;
    
    `if(`isdefined(DEBUGLOGS))
    FileWriter = Spawn(class'FileWriter', self);
    FileWriter.OpenFile("KFDebugLog", FWFT_Debug, ".log", true, false);
    `endif
}

final function LogFile(coerce string S, optional string LogName="ScriptLog")
{
    if( FileWriter != None )
        FileWriter.Logf(LogName$":"@S);
}