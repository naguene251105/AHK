#Requires AutoHotkey v2.0
#SingleInstance Force
SetCapsLockState "AlwaysOff"

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
0::CreateNewFolder()
#HotIf

CreateFile(ext) => CreateAndRename(ext, false)
CreateNewFolder() => CreateAndRename("", true)

CreateAndRename(ext, isFolder) {
    if !WinActive("ahk_exe explorer.exe")
        return

    path := GetExplorerPath()
    ; 파일/폴더 이름 생성
    baseName := path (isFolder ? "\NewFolder" : "\NewFile")
    targetPath := baseName ext
    
    counter := 1
    while (isFolder ? DirExist(targetPath) : FileExist(targetPath)) {
        targetPath := baseName "_" counter ext
        counter++
    }
    
    ; 1. 파일/폴더 생성
    if (isFolder)
        DirCreate(targetPath)
    else
        FileAppend("", targetPath)

    ; 2. 생성될 때까지 대기
    Loop 50 {
        if (isFolder ? DirExist(targetPath) : FileExist(targetPath))
            break
        Sleep(20)
    }

    ; 3. [최후의 수단] 탐색기에 강제 갱신 명령 전송
    try {
        shell := ComObject("Shell.Application")
        for window in shell.Windows {
            if (window.HWND = WinExist("A")) {
                ; 새로 만든 항목의 이름만 추출
                itemName := StrReplace(targetPath, path "\")
                
                ; 강제 새로고침
                window.Refresh()
                Sleep(200)
                
                ; 정확히 해당 이름을 가진 항목 선택 (17 = 선택+포커스)
                window.Document.SelectItem(window.Document.Folder.ParseName(itemName), 17)
                
                Sleep(150)
                Send("{F2}") ; 이름 변경
                return
            }
        }
    }
}

GetExplorerPath() {
    for window in ComObject("Shell.Application").Windows {
        if (window.HWND = WinExist("A"))
            return window.Document.Folder.Self.Path
    }
    return A_Desktop
}