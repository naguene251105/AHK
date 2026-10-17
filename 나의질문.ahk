#Requires AutoHotkey v2.0
#SingleInstance Force

global currentNum := 1

:?:;;k::
{
    global currentNum
    
    ; 작은 입력창을 띄워 시작 번호를 물어봅니다. (기본값은 현재 번호)
    myGui := InputBox("시작할 번호를 입력하세요 (그냥 엔터 누르면 이어서 진행):", "번호 지정", "w300 h130", currentNum)
    
    ; 취소를 누르지 않고 값이 입력되었다면
    if (myGui.Result = "OK" && myGui.Value != "") {
        currentNum := Integer(myGui.Value)
    } else if (myGui.Result = "Cancel") {
        return ; 취소 누르면 아무것도 안 함
    }
    
    ; 텍스트 출력
    SendInput("나의질문" . currentNum . ".")
    
    ; 번호 증가
    currentNum++
}