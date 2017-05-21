; Determines whether a file is an executable (.exe) file, and if so, which subsystem runs the executable file.
; from: https://autohotkey.com/boards/viewtopic.php?t=28681
;
; To check if a .dll is 32 or 64-Bit you can try to load the .dll with LoadLibrary
; Ref: LoadLibrary function (msdn)
;
; Or read the file header:
; 32-Bit: PE L
; 64-Bit: PE d†


; MsgBox % GetBinaryType("C:\Windows\System32\notepad.exe")    ; -> 64BIT
; MsgBox % GetBinaryType("C:\Windows\SysWOW64\notepad.exe")    ; -> 32BIT
; MsgBox % GetBinaryType("D:\Tools\EmEditor\EmEditor.exe")   ; -> 0
; MsgBox % GetBinaryType("D:\Dwnld\emed64_16.7.901_portable\EmEditor.exe")   ; -> 0
 
GetBinaryType(Application)
{
    static GetBinaryType := "GetBinaryType" (A_IsUnicode ? "W" : "A")
    static Type := {0 : "32BIT", 1: "DOS", 2: "WOW", 3: "PIF", 4: "POSIX", 5: "OS216", 6: "64BIT"}
    if !(DllCall(GetBinaryType, "str", Application, "uint*", BinaryType))
        return 0
    return Type[BinaryType]
}