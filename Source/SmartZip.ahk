;; ---------    THE FUNCTION    ------------------------------------
/*
SmartZip()
   Smart ZIP/UnZIP files
Parameters:
   s, o   When compressing, s is the dir/files of the source and o is ZIP filename of object. When unpressing, they are the reverse.
   t      The options used by CopyHere method. For availble values, please refer to: http://msdn.microsoft.com/en-us/library/windows/desktop/bb787866
Link:
http://www.autohotkey.com/forum/viewtopic.php?p=523649#523649
*/


; Support flexible form of parameters
; SmartZip("dir1", "test.zip")   ; Pack the whole folder to ZIP file
;~ SmartZip("*.ahk", "scripts.zip")   ; Pack ahk scripts of the working dir
;~ SmartZip("*.zip", "package.zip")   ; Pack a number of ZIP files to one
;~ SmartZip("*.zip", "dir2")   ; Unpack a number of ZIP files to dir2
;~ SmartZip("*.zip", "")   ; Unpack to the working dir


/*
SmartZip()
        智能压缩/解压或添加文件到 ZIP 文档, 需要 WinXP 或更高版本系统. 其中的压缩和解压可以很容易拆分成两个单独的压缩和解压函数.
参数说明:
        s, o        当压缩时, s 为源目录或文件, o 为目标 ZIP 文档; 解压时, s 为源 ZIP 文档, o 为目标目录. 可使用相对路径或绝对路径.
        t                        CopyHere 方法使用的选项. 可用数值请参阅: http://msdn.microsoft.com/en-us/library/windows/desktop/bb787866
*/

SmartZip(s, o, t = 4)
{
        IfNotExist, %s%
                return, -1        ; 源不存在, 可能是书写错误
        
        oShell := ComObjCreate("Shell.Application")
        
        if (SubStr(o, -3) = ".zip")        ; 目标名称的后面部分含有 .zip, 需要压缩
        {
                IfNotExist, %o%        ; 若目标压缩文件不存在, 则创建
                        CreateZip(o)
                
                Loop, %o%, 1
                        sObjectLongName := A_LoopFileLongPath

                oObject := oShell.NameSpace(sObjectLongName)
                
                Loop, %s%, 1
                {
                        if (sObjectLongName = A_LoopFileLongPath)        ; 在压缩含有 ZIP 文档到另一个相同路径的 ZIP 文档时，忽略目标 ZIP 文档
                        {
                                continue
                        }
                        ToolTip, 正在压缩 %A_LoopFileName% ..
                        oObject.CopyHere(A_LoopFileLongPath, t)        ; 这里支持文件夹
                        SplitPath, A_LoopFileLongPath, OutFileName
                        Loop
                        {
                                oObject := "", oObject := oShell.NameSpace(sObjectLongName)        ; 清空对象后, 判断才会准确, 这样操作不影响正在进行的 copyhere 方法. 此外在添加文件到已有的压缩文件时这种方法比使用文件数更安全.
                                if oObject.ParseName(OutFileName)
                                        break
                        }
                }
                ToolTip
        }
        else if InStr(FileExist(o), "D") or (!FileExist(o) and (SubStr(s, -3) = ".zip"))        ; 解压缩
        {
                if !o
                        o := A_ScriptDir        ; 若目标为空, 则使用脚本所在目录.
                else IfNotExist, %o%
                        FileCreateDir, %o%
                
                Loop, %o%, 1
                        sObjectLongName := A_LoopFileLongPath
                
                oObject := oShell.NameSpace(sObjectLongName)
                
                Loop, %s%, 1
                {
                        oSource := oShell.NameSpace(A_LoopFileLongPath)
                        oObject.CopyHere(oSource.Items, t)
                }
        }
}

CreateZip(n)
{
        ZIPHeader1 := "PK" . Chr(5) . Chr(6)
        VarSetCapacity(ZIPHeader2, 18, 0)
        ZIPFile := FileOpen(n, "w")
        ZIPFile.Write(ZIPHeader1)
        ZIPFile.RawWrite(ZIPHeader2, 18)
        ZIPFile.close()
}