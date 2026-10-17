#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode(2)
SetCapsLockState "AlwaysOff"

; --- 설정 및 전역 변수 ---
ControlExe := "X:\controlmymonitor\ControlMyMonitor.exe"
BrightnessFile := A_ScriptDir "\brightness.ini"
mode := ""
brightness := Map()
LoadBrightness() ; 초기 밝기 로드

; --------------------------
; 핫스트링 (날짜/시간)
; --------------------------
::;;l::
::;;d:: ; 중복 정리
{
    SendText FormatTime(, "yyMMdd_HHmmss")
}

::;;d2::
{
    SendText FormatTime(, "yyyy-MM-dd")
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
; CapsLock 레이어 (파일 생성)
; --------------------------
$CapsLock::
{
    if KeyWait("CapsLock", "T0.2") {
        SetCapsLockState !GetKeyState("CapsLock", "T")
    }
    KeyWait("CapsLock")
}

#HotIf GetKeyState("CapsLock", "P")
1::CreateFile(".txt")
2::CreateFile(".py")
3::CreateFile(".cpp")
#HotIf

CreateFile(ext) {
    if !WinActive("ahk_exe explorer.exe")
        return
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
    Sleep(100)
    Send("{F5}")
}

; --------------------------
; 모니터 및 기타 기능 (생략된 부분 동일하게 유지)
; ... 여기에 기존 작성하신 #F2, #F3, #F5, #F6, #F12, ^!F8 함수들을 순서대로 배치하세요 ...
; --------------------------

; --- 도구 모음 함수 ---
RemoveToolTip() {
    ToolTip()
}

LoadBrightness() {
    global brightness, BrightnessFile
    Loop 4 {
        val := IniRead(BrightnessFile, "Brightness", "DISPLAY" A_Index, 50)
        brightness[A_Index] := val
    }
}