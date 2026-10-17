; --------------------------
; CapsLock 레이어 (파일 생성 로직 통합)
; --------------------------

; CapsLock 동작 분리 (탭: 대문자 고정 / 홀드: 단축키 레이어)
$CapsLock::
{
    if KeyWait("CapsLock", "T0.2") {
        SetCapsLockState !GetKeyState("CapsLock", "T")
    }
    KeyWait("CapsLock")
}

; 핫키 설정
#HotIf GetKeyState("CapsLock", "P")
1::CreateFile(".txt")
2::CreateFile(".py")
3::CreateFile(".cpp")
#HotIf

; 파일 생성 공통 함수
CreateFile(ext) {
    if !WinActive("ahk_exe explorer.exe")
        return

    ; 탐색기 경로 가져오기 로직
    try {
        for window in ComObject("Shell.Application").Windows {
            if (window.HWND = WinExist("A")) {
                path := window.Document.Folder.Self.Path
                break
            }
        }
    } catch {
        path := A_Desktop
    }
    
    if !IsSet(path) || path == ""
        path := A_Desktop

    ; 파일명 생성 (NewFile.txt / NewFile.py / NewFile.cpp)
    baseName := path "\NewFile"
    targetFile := baseName ext
    
    counter := 1
    while FileExist(targetFile) {
        targetFile := baseName "_" counter ext
        counter++
    }
    
    FileAppend("", targetFile)
    
    ; 생성 후 시각적 피드백 및 파일 선택
    Sleep(100)
    Send("{F5}") ; 새로고침
    Sleep(100)
    ; 만약 생성된 파일을 바로 수정하고 싶다면 아래 주석을 해제하세요
    ; Send("{F2}")
}