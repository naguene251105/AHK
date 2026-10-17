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