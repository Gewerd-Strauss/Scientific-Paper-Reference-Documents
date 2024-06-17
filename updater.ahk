#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent
#Requires Autohotkey v1.1+
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
path:=A_ScriptDir
cmd =
    (LTrim Join&
        cd /d ""%path%""
    )
cmd := "git add . & git commit -m ""Update " A_Now """ & git push"
full_cmd:=A_Comspec " /C " Quote(cmd)
if IsConnected("https://google.com/") {
    if GetStdStreams_WithInput(full_cmd,path,InOut) {
        ttip("Updated Zotero Repository")
    } else {
        ttip("Word Reference Files Repository up to date")
        RunWait %  A_ComSpec " /C " Quote(cmd), % path,hide
    }
}
ExitApp


; #region:GetStdStreams_WithInput (685341990)

; #region:Metadata:
; Snippet: GetStdStreams_WithInput;  (v.1.1.3)
;  27 April 2023
; --------------------------------------------------------------
; Author: anonymous1184
; License: none
; --------------------------------------------------------------
; Library: Personal Library
; Section: 25 - Command CommandLine
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Executes a command line input in Directory 'WorkDir', returns the command line output via the byRef variable 'InOut'
; #endregion:Description

; #region:Example
; if GetStdStreams_WithInput(A_ComSpec " /C ping 127.0.0.1 -n 9",, io) {
; msgbox, % io "`n" e
; } else {
; msgbox, % "command failed"
; }
; 
; #endregion:Example


; #region:Code
GetStdStreams_WithInput(CommandLine, WorkDir := "", ByRef InOut := "") {
    static HANDLE_FLAG_INHERIT := 0x00000001, PIPE_NOWAIT := 0x00000001, STARTF_USESTDHANDLES := 0x0100, CREATE_NO_WINDOW := 0x08000000, HIGH_PRIORITY_CLASS := 0x00000080
    DllCall("CreatePipe", "Ptr*", hInputR := 0, "Ptr*", hInputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("CreatePipe", "Ptr*", hOutputR := 0, "Ptr*", hOutputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hInputR, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetHandleInformation", "Ptr", hOutputW, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetNamedPipeHandleState", "Ptr", hOutputR, "Ptr", &PIPE_NOWAIT, "Ptr", 0, "Ptr", 0)
    VarSetCapacity(processInformation, A_PtrSize = 4 ? 16 : 24, 0) ; PROCESS_INFORMATION
    cb := VarSetCapacity(startupInfo, A_PtrSize = 4 ? 68 : 104, 0) ; STARTUPINFO
    NumPut(cb, startupInfo, 0, "UInt")
    NumPut(STARTF_USESTDHANDLES, startupInfo, A_PtrSize = 4 ? 44 : 60, "UInt")
    NumPut(hInputR, startupInfo, A_PtrSize = 4 ? 56 : 80, "Ptr")
    NumPut(hOutputW, startupInfo, A_PtrSize = 4 ? 60 : 88, "Ptr")
    NumPut(hOutputW, startupInfo, A_PtrSize = 4 ? 64 : 96, "Ptr")
    pWorkDir := IsSet(WorkDir) && WorkDir ? &WorkDir : 0
    created := DllCall("CreateProcess", "Ptr", 0, "Ptr", &CommandLine, "Ptr", 0, "Ptr", 0, "Int", true, "UInt", CREATE_NO_WINDOW | HIGH_PRIORITY_CLASS, "Ptr", 0, "Ptr", pWorkDir, "Ptr", &startupInfo, "Ptr", &processInformation)
    lastError := A_LastError
    DllCall("CloseHandle", "Ptr", hInputR)
    DllCall("CloseHandle", "Ptr", hOutputW)
    if (!created) {
        DllCall("CloseHandle", "Ptr", hInputW)
        DllCall("CloseHandle", "Ptr", hOutputR)
        throw Exception("Couldn't create process.", -1, Format("{:04x}", lastError))
    }
    if (IsSet(InOut) && InOut != "") {
        if (SubStr(InOut, 0) != "`n") {
            InOut .= "`n"
        }
        FileOpen(hInputW, "h", "UTF-8").Write(InOut)

    }
    DllCall("CloseHandle", "Ptr", hInputW)
    cbAvail := 0, InOut := ""
    pipe := FileOpen(hOutputR, "h`n", "UTF-8")
    while (DllCall("PeekNamedPipe", "Ptr", hOutputR, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", cbAvail, "Ptr", 0)) {
        if (cbAvail) {
            InOut .= pipe.Read()
        }
        else {
            Sleep 10
        }
    }
    DllCall("CloseHandle", "Ptr", hOutputR)
    hProcess := NumGet(processInformation, 0)
    DllCall("GetExitCodeProcess", "Ptr", hProcess, "UInt*", exitCode := 0)
    DllCall("CloseHandle", "Ptr", hProcess)
    hThread := NumGet(processInformation, A_PtrSize)
    DllCall("CloseHandle", "Ptr", hThread)
    return exitCode
}

; #endregion:Code



; #endregion:GetStdStreams_WithInput (685341990)

; #region:IsConnected() (1993173571)

; #region:Metadata:
; Snippet: IsConnected()
; 09 Oktober 2022
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 09 - Internet/Network
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Returns true if there is an available internet connection
; 
; 
; #endregion:Description

; #region:Code
IsConnected(URL="https://autohotkey.com/boards/") {                            	;-- Returns true if there is an available internet connection
    return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
}
; #endregion:Code



; #endregion:IsConnected() (1993173571)

; #region:ttip (2588811139)

; #region:Metadata:
; Snippet: ttip;  (v.0.2.2)
;  13.04.2023
; --------------------------------------------------------------
; Author: Gewerd Strauss
; License: MIT
; --------------------------------------------------------------
; Library: Personal Library
; Section: 20 - ToolTips
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: TOOLTIP
; #endregion:Metadata


; #region:Description:
; small tooltip handler
; 
; /*
; 		
; 		Modes:  
; 	                 -1: do not show ttip - useful when you want to temporarily disable it, without having to remove the call every time, but without having to change text every time.
; 		1: remove tt after "to" milliseconds 
; 		2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat 
; 		3: not sure anymore what the plan was lol - remove 
; 		4: shows tooltip slightly offset from current mouse, does not repeat
; 		5: keep that tt until the function is called again  
; 
; 		CoordMode:
; 		-1: Default: currently set behaviour
; 		1: Screen
; 		2: Window
; 
; 		to: 
; 		Timeout in milliseconds
; 		
; 		xp/yp: 
; 		xPosition and yPosition of tooltip. 
; 		"NaN": offset by +50/+50 relative to mouse
; 		IF mode=4, 
; 		----  Function uses tooltip 20 by default, use parameter
; 		"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
; 		separately from each other, hence a removal of ttip20 will not remove tt14 
; 
; 		---
; 		v.0.2.1
; 		- added Obj2Str-Conversion via "ttip_Obj2Str()"
; 		v.0.1.1 
; 		- Initial build, 	no changelog yet
; 	
; 	*/
; #endregion:Description

; #region:Code
ttip(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2:=1750,Times:=20,currTip:=20)
{

    cCoordModeTT:=A_CoordModeToolTip
    if (mode=-1)
        return
    if (text="") || (text=-1)
        gosub, RemoveTTIP
    if IsObject(text)
        text:=ScriptObj_Obj2Str(text)
    static ttip_text
    static lastcall_tip
    static currTip2
    global ttOnOff
    currTip2:=currTip
    cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
    CoordMode % cMode
    tooltip


    ttip_text:=text
    lUnevenTimers:=false 
    MouseGetPos xp1,yp1
    if (mode=4) ; set text offset from cursor
    {
        yp:=yp1+15
        xp:=xp1
    }	
    else
    {
        if (xp="NaN")
            xp:=xp1 + 50
        if (yp="NaN")
            yp:=yp1 + 50
    }
    tooltip % ttip_text,xp,yp,% currTip
    if (mode=1) ; remove after given time
    {
        SetTimer RemoveTTIP, % "-" to
    }
    else if (mode=2) ; remove, but repeatedly show every "to"
    {
        ; gosub,  A
        global to_1:=to
        global to2_1:=to2
        global tTimes:=Times
        Settimer lTTIP_SwitchOnOff,-100
    }
    else if (mode=3)
    {
        lUnevenTimers:=true
        SetTimer RepeatedShow, %  to
    }
    else if (mode=5) ; keep until function called again
    {

    }
    CoordMode % cCoordModeTT
    return text
    lTTIP_SwitchOnOff:
    ttOnOff++
    if mod(ttOnOff,2)	
    {
        gosub, RemoveTTIP
        sleep % to_1
    }
    else
    {
        tooltip % ttip_text,xp,yp,% currTip
        sleep % to2_1
    }
    if (ttOnOff>=ttimes)
    {
        Settimer lTTIP_SwitchOnOff, off
        gosub, RemoveTTIP
        return
    }
    Settimer lTTIP_SwitchOnOff, -100
    return

    RepeatedShow:
    ToolTip % ttip_text,,, % currTip2
    if lUnevenTimers
        sleep % to2
    Else
        sleep % to
    return
    RemoveTTIP:
    ToolTip,,,,currTip2
    return
}

ScriptObj_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
    static String,Blank
    if(FullPath=1)
    String:=FullPath:=Blank:=""
    if(IsObject(Obj)){
        for a,b in Obj{
            if(IsObject(b))
            ScriptObj_Obj2Str(b,FullPath "." a,BottomBlank)
            else{
                if(BottomBlank=0)
                String.=FullPath "." a " = " b "`n"
                else if(b!="")
                    String.=FullPath "." a " = " b "`n"
                else
                    Blank.=FullPath "." a " =`n"
            }
        }}
    return String Blank
}
; #endregion:Code



; #endregion:ttip (2588811139)

; #region:Quote (3251425676)

; #region:Metadata:
; Snippet: Quote;  (v.1)
; --------------------------------------------------------------
; Author: u/anonymous1184
; Source: https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
; (11 November 2022)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: apostrophe
; #endregion:Metadata


; #region:Description:
; Quotes a string
; #endregion:Description

; #region:Example
; Var:="Hello World"
; msgbox, % Quote(Var . " Test")
; 
; #endregion:Example


; #region:Code
Quote(String) {
    return """" String """"
}
; #endregion:Code



; #endregion:Quote (3251425676)
