#Requires AutoHotkey v2.0
#SingleInstance Force

global voice := ComObject("SAPI.SpVoice")

voice.Rate := 2   ; 속도 (0=기본, 1=약 1.5배)

; CapsLock + 9 : 읽기
CapsLock & 9::
{
    A_Clipboard := ""
    Send "^c"

    if !ClipWait(1)
        return

    text := A_Clipboard

    if (text = "")
        return

    ; 현재 읽기 중지
    voice.Speak("", 2)

    ; 비동기 읽기 (중요!)
    voice.Speak(text, 1)
}

; CapsLock + 0 : 중지
CapsLock & 8::
{
    voice.Speak("", 2)
}

; Esc 두 번 : 긴급 중지
~Esc::
{
    static lastTime := 0

    if (A_TickCount - lastTime < 500)
        voice.Speak("", 2)

    lastTime := A_TickCount
}