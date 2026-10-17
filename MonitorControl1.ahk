#Requires AutoHotkey v2.0
#SingleInstance Force

ControlExe := "X:\controlmymonitor\ControlMyMonitor.exe"
BrightnessFile := A_ScriptDir "\brightness.ini"

mode := ""
brightness := Map()

; 초기 밝기 로드
LoadBrightness()

; --------------------------
; 날짜 입력 단축키
; --------------------------

::;;d::
{
    SendText FormatTime(, "yyyy-MM-dd")
}

::;;d2::
{
    SendText FormatTime(, "yyMMdd_HHmmss")
}

::;;ㅇ2::
{
    SendText FormatTime(, "yyMMdd_HHmmss")
}

::;;d3::
{
    SendText FormatTime(, "yyyy.MM.dd")
}

::;;dw::
{
    SendText FormatTime(, "yyyy-MM-dd dddd")
}

; --------------------------
; ON 모드
; --------------------------

#F2::
{
    global mode
    mode := "ON"

    SoundBeep(1400,100)
    Sleep(80)
    SoundBeep(1800,100)

    ToolTip("ON mode (0=ALL,1~4)")
    SetTimer(RemoveToolTip, -1000)
}

; --------------------------
; OFF 모드
; --------------------------

#F3::
{
    global mode
    mode := "OFF"

    SoundBeep(600,150)

    ToolTip("OFF mode (0=ALL,1~4)")
    SetTimer(RemoveToolTip, -1000)
}

#HotIf (mode != "")

0::HandleMonitor(0)
1::HandleMonitor(1)
2::HandleMonitor(2)
3::HandleMonitor(3)
4::HandleMonitor(4)

#HotIf

; --------------------------
; 밝기 감소
; --------------------------

#F5::
{
    ChangeBrightness(-10)
}

; --------------------------
; 밝기 증가
; --------------------------

#F6::
{
    ChangeBrightness(+10)
}

; --------------------------
; 모니터 ON/OFF
; --------------------------

HandleMonitor(num)
{
    global mode, ControlExe, brightness

    value := (mode="ON") ? 1 : 4

    if (mode="ON")
        SoundBeep(1500,80)
    else
        SoundBeep(500,120)

    if (num=0)
    {
        Loop 4
        {
            Run('"' ControlExe '" /SetValue \\.\DISPLAY' A_Index '\Monitor0 D6 ' value,, "Hide")

            if (mode="ON")
                RestoreBrightness(A_Index)
        }
    }
    else
    {
        Run('"' ControlExe '" /SetValue \\.\DISPLAY' num '\Monitor0 D6 ' value,, "Hide")

        if (mode="ON")
            RestoreBrightness(num)
    }

    mode := ""
}

; --------------------------
; 밝기 변경
; --------------------------

ChangeBrightness(delta)
{
    Loop 4
    {
        n := A_Index

        old := brightness.Has(n) ? brightness[n] : 50

        new := old + delta

        if (new<0)
            new := 0
        if (new>100)
            new := 100

        brightness[n] := new

        Run('"' ControlExe '" /SetValue \\.\DISPLAY' n '\Monitor0 10 ' new,, "Hide")

        ShowBrightness(n,new)

        IniWrite(new, BrightnessFile, "Brightness", "DISPLAY" n)
    }

    SoundBeep(1000,50)
}

; --------------------------
; 밝기 표시
; --------------------------

ShowBrightness(n,value)
{
    ToolTip("DISPLAY" n " Brightness: " value "%")
    SetTimer(RemoveToolTip, -1000)
}

RemoveToolTip()
{
    ToolTip()
}

; --------------------------
; 밝기 복원
; --------------------------

RestoreBrightness(n)
{
    global brightness, ControlExe

    if brightness.Has(n)
    {
        value := brightness[n]

        Run('"' ControlExe '" /SetValue \\.\DISPLAY' n '\Monitor0 10 ' value,, "Hide")

        ShowBrightness(n,value)
    }
}

; --------------------------
; 밝기 로드
; --------------------------

LoadBrightness()
{
    global brightness, BrightnessFile

    Loop 4
    {
        val := IniRead(BrightnessFile, "Brightness", "DISPLAY" A_Index, 50)
        brightness[A_Index] := val
    }
}


; 1. 붙여쓰기 형식 (260214) - 폴더 정리할 때 유용
::;;l::
{
    SendText FormatTime(, "yyMMdd_HHmmss")
}

; 1. 붙여쓰기 형식 (260214) - 폴더 정리할 때 유용
::;;d::
{
    SendText FormatTime(, "yyMMdd_HHmmss")
}

; 2. 기본 형식 (2026-02-14)
::;;d2::
{
    SendText FormatTime(, "yyyy-MM-dd")
}

; 3. 점 찍는 형식 (2026.02.14)
::;;d3::
{
    SendText FormatTime(, "yyyy.MM.dd")
}

; 4. 요일까지 포함 (2026-02-14 토요일)
::;;dw::
{
    SendText FormatTime(, "yyyy-MM-dd dddd")
}

#F12::
{
    ; 1. 실행할 명령들을 포함한 임시 배치 파일 내용 구성
    ; wake_armed 목록의 모든 장치를 끄고 절전 모드로 진입합니다.
    batContent := 
    (
    "@echo off
    for /f `"tokens=*`" %%i in ('powercfg -devicequery wake_armed') do powercfg -devicedisablewake `"%%i`"
    rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    exit"
    )

    try {
        ; 2. 임시 배치 파일 생성 (스크립트와 같은 폴더)
        tempBat := A_ScriptDir "\temp_sleep.bat"
        if FileExist(tempBat)
            FileDelete(tempBat)
        FileAppend(batContent, tempBat, "CP949")

        ; 3. 관리자 권한으로 배치 파일 실행
        RunWait("*RunAs `"" tempBat "`"", , "Hide")
        
        ; 4. 실행 후 임시 파일 삭제
        FileDelete(tempBat)
    } catch as e {
        MsgBox("오류 발생: " e.Message "`n관리자 권한을 승인했는지 확인하세요.")
    }
}



#Requires AutoHotkey v2.0
SetTitleMatchMode(2)

; Ctrl + Alt + F8 키를 누를 때 동작하도록 설정
^!F8:: {
    if WinExist("ahk_exe Zulddo.exe") {
        activeId := WinGetID("A")
        
        WinActivate("ahk_exe Zulddo.exe")
        if WinWaitActive("ahk_exe Zulddo.exe", , 1) {
            
            Send("^{End}")  
            Sleep(50)       
            
            Send("^v")      
            Sleep(100)      
            
            ; 현재 시간을 가져와서 구분선과 함께 붙여넣기
            currentTime := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            Send("{Enter}--- [ " currentTime " ] -------------------------{Enter}{Enter}") 
            
            ; 원래 작업하던 창으로 복귀
            WinActivate("ahk_id " activeId)
        }
    } else {
        MsgBox("Zulddo.exe를 찾을 수 없습니다.")
    }
}


#Requires AutoHotkey v2.0
SetCapsLockState "AlwaysOff"

; 1. CapsLock 동작 분리 (탭: 대문자 고정 / 홀드: 단축키 레이어)
$CapsLock::
{
    if KeyWait("CapsLock", "T0.2") { ; 0.2초 이내 짧게 누르면
        SetCapsLockState !GetKeyState("CapsLock", "T")
    }
    KeyWait("CapsLock") ; 홀드 중일 때는 대기
}

; 2. 파일 생성 함수 (중복 시 숫자 붙이기)
CreateFile(ext) {
    if !WinActive("ahk_exe explorer.exe")
        return

    ; 현재 탐색기 경로 가져오기
    path := ""
    for window in ComObject("Shell.Application").Windows {
        if (window.HWND = WinExist("A")) {
            path := window.Document.Folder.Self.Path
            break
        }
    }
    if (path = "") path := A_Desktop

    baseName := "NewFile"
    targetFile := path "\" baseName ext
    
    counter := 1
    while FileExist(targetFile) {
        targetFile := path "\" baseName "_" counter ext
        counter++
    }
    
    FileAppend("", targetFile)
    
    ; 생성 후 F5(새로고침) 및 파일 선택(F2)
    Sleep(100)
    Send("{F5}")
    Sleep(100)
    ; 파일이 화면에 보일 시간을 위해 약간 대기 후 선택 로직
}

; 3. CapsLock 조합 단축키 설정
#HotIf GetKeyState("CapsLock", "P")
1::CreateFile(".txt")
2::CreateFile(".py")
3::CreateFile(".cpp")
#HotIf