;
; EmEditor Updater
;   V2.0
;   by David Wang
;   2017-05-06 15:03
;

;parse EmEditor(portable) download links from: http://updates.emeditor.com/emed32_updates2.txt
;download portable files
;decompress portable files
;extract portable files
;backup old files as zip
;move new files to overwrite the old dirs
;try to patch

#include WinHttpRequest.ahk
; #include json.ahk
#include NumifyVersion.ahk
#include SmartZip.ahk


#SingleInstance On
#NoEnv
DetectHiddenWindows, on
SetWorkingDir, %A_ScriptDir%
menu, tray, deleteall

/*
* 获取EmEditor主程序所在的目录
*/
_GetEmDir:
	If 0 > 0
	{
		dir = %1%
		ifexist , %dir%\EmEditor.exe ;file exist
		{
			em_dir := dir
			goto, _CheckLocalVersion
		}
	}
	IfExist, %A_ScriptDir%\EmEditor.exe
		em_dir := A_ScriptDir
	else
	{
		SplitPath, A_ScriptDir,, dir		;back to the up folder
		IfExist, %dir%\EmEditor.exe
		{
			em_dir := dir
		}
		else
		{
			SplitPath, dir,, dir		;back to the up folder again
			IfExist, %dir%\EmEditor.exe
			{
				em_dir := dir
			}
		}
	}
	if em_dir=
	{
		msgbox, 16, EmEditor Updater,
		(LTrim
		EmEditor AppDir not found!
		
		Usage:`t 
		`t 1.you can pass AppDir of EmEditor as parameter;
		`t 2.you can also put this program inside the dir/subdir of EmEditor;
		
		)
		ExitApp
	}

/*
* get local file version
*/
_CheckLocalVersion:
	FileGetVersion, local_ver,  %em_dir%\EmEditor.exe
	;e.g 14.5.2.0
	if ErrorLevel
	{
		MsgBox, Check local EmEditor version error!
		ExitApp
	}

/*
* request latest version information from: http://updates.emeditor.com/emed32_updates2.txt
*/
_CheckOnlineVersion:
	IfExist, %A_Temp%\emed32_updates2.txt
		FileDelete, %A_Temp%\emed32_updates2.txt
	check_url := "http://updates.emeditor.com/emed32_updates2.txt"
	try
	{
		ToolTip Retrieving latest version information...
		URLDownloadToFile, %check_url%, %A_Temp%\emed32_updates2.txt
		Tooltip
	}catch e
	{
		MsgBox, 16, EmEditor Updater , % "There was an error during the update!`n"  e.message "`nwhat: " e.what "`nextra: " e.extra
		Tooltip
		return
	}
	IniRead, online_ver, %A_Temp%\emed32_updates2.txt, update32_14, Version
	;e.g 14.5.2.0
	if online_ver=
	{
		MsgBox, 16, EmEditor Updater, There is no information about EmEditor updates recently!
		ExitApp
	}


/*
* compare version to decide whether to update or not
*/
_CompareVersion:
	local_ver :=NumifyVersion(local_ver)
	online_ver :=NumifyVersion(online_ver)
	;~ goto , _BackupOld
	if (local_ver = online_ver)
	{
	MsgBox, 64, EmEditor Updater, EmEditor is up to date.
	ExitApp
	}
	if (local_ver < online_ver)
	{
		MsgBox, 36, EmEditor Updater,
		(LTrim
		There is a new EmEditor version.
		
		Current version:`t%local_ver%
		Latest version:`t%online_ver%
		
		Do you wish to download and install it?
		)
		IfMsgBox, No
		ExitApp
	}


/*-------------------------------------
* download latest portable files
*/
_Download:
	; e.g http://files.emeditor.com/emed32_16.7.2.exe   --->   http://files.emeditor.com/emed32_16.7.2_portable.zip
	IniRead, url_install, %A_Temp%\emed32_updates2.txt, update32_14, URL
	down_url :=RegExReplace(url_install,"\.exe","_portable.zip")
	; down_url   ->   local_url
	StringSplit, URLArray, down_url, "/"
	; URLArray := StrSplit(down_url, "/")
	local_url:=URLArray[URLArray.MaxIndex()]
	IF FileExist(A_Temp "\" local_url)
	{
		FileGetSize, local_file_size, %A_Temp%\%local_url%
		; --- check online file size
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("HEAD", local_url)
		WebRequest.Send()
		online_file_size := WebRequest.GetResponseHeader("Content-Length")
		if (online_file_size = local_file_size)
		{
			goto, _Unzip
		}
		else
		{
			FileDelete, %A_Temp%\%local_url%
		}
	}
	try
	{
		ToolTip Downloading new version in progress..
		URLDownloadToFile, %down_url%, %A_Temp%\%local_url%
		Tooltip
	}catch e
	{
		MsgBox, 16, EmEditor Updater , % "There was an error during the update!`n" e.message "`nwhat: " e.what "`nextra: " e.extra
		Tooltip
		return
	}	
/*
*   unzip portable.zip files
*/
_UnZip:
	sZip = %A_Temp%\%local_url%
	sUnz := A_Temp . "\em-ext"
	FileRemoveDir, sUnz, 1
	SmartZip(sZip, sUnz)	
/*
*   remove useless files from decompress files
*/
_RemoveUseless:
	;%A_Temp%\ext\template.*
	FileDelete, %A_Temp%\em-ext\template.*
	;%A_Temp%\ext\mui\*.* (not 1033 & 2052)
	Loop, %A_Temp%\em-ext\mui\*.*, 2, 0
	{
	if ( A_LoopFileName <> "1033" ) && ( A_LoopFileName <> "2052" ) 
	FileRemoveDir, %A_Temp%\em-ext\mui\%A_LoopFileName%, 1
	}
	;%A_Temp%\ext\PlugIns\mui\*.* (not 1033 & 2052)
	Loop, %A_Temp%\em-ext\PlugIns\mui\*.*, 2, 0
	{
	if ( A_LoopFileName <> "1033" ) && ( A_LoopFileName <> "2052" ) 
	FileRemoveDir, %A_Temp%\em-ext\PlugIns\mui\%A_LoopFileName%, 1
	}

/*-------------------------------------
* "check / download / extract" latest help files
*/
; e.g http://files.emeditor.com/help/emed_help_zh-cn_16.7.1.msi
_CheckHelp:
	IniRead, help_url, %A_Temp%\emed32_updates2.txt, help_zh-cn, URL
	StringSplit, URLArray, down_url, "/"
	; URLArray := StrSplit(help_url, "/")
	help_name:=URLArray[URLArray.MaxIndex()]
	IF FileExist(A_Temp "\" help_name)
	{
		IniRead, online_help_size, %A_Temp%\emed32_updates2.txt, help_zh-cn, Size
		FileGetSize, local_help_size, %A_Temp%\%help_name%
		if (online_help_size != local_help_size)
		{
			goto, _DownloadHelp
		}
		else
		{
			goto, _ExtractHelp
		}
	}
	else
	{
		goto, _DownloadHelp
	}
_DownloadHelp:
	try
	{
		ToolTip Downloading help files in progress..
		URLDownloadToFile, %help_url%, %A_Temp%\%help_name%
		Tooltip
		goto, _ExtractHelp
	}catch e
	{
		MsgBox, 16, EmEditor Updater , % "There was an error during the update!`n" e.message "`nwhat: " e.what "`nextra: " e.extra
		Tooltip
		return
	}
_ExtractHelp:
	FileRemoveDir, "%A_Temp%\emhelp-ext", 1
	RunWait msiexec /a "%A_Temp%\%help_name%" /qb TARGETDIR="%A_Temp%\emhelp-ext"


/*
*   backup the old version of emeditor before overwrite it!!!
*/
_BackupOld:
	;delete old backup files
	FileSetAttrib, -R, %em_dir%\EmEditor_BAK.zip
	FileRecycle, %em_dir%\EmEditor_BAK.zip
	;build a new backup
	bZip :=em_dir . "\EmEditor_BAK.zip"
	SmartZip(em_dir, bZip)

/*
* Overwrite EmEditor with new files
*/
_Overwrite:
	; check whether EmEditor window is opened or not
	if WinExist("ahk_class EmEditorMainFrame3")
	{
		LastOpened :=1
		msgbox , 36, EmEditor Updater,	
		(LTrim
		You need to Quit EmEditor to complete the update!
		Do you wish to do so?
		)
		IfMsgBox, No
			ExitApp
		PostMessage, 0x112, 0xF060,,, ahk_class EmEditorMainFrame3  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
		WinWaitClose, ahk_class EmEditorMainFrame3
	}
	;move & overwrite the old files
	; --- portable files
	FileMove, %A_Temp%\em-ext\*.*, %em_dir%, 1
	; --- help files
	FileMove, %A_Temp%\emhelp-ext\CommonAppDataFolder\Emurasoft\EmEditor\Help\*.*, %em_dir%\Help, 1

/*
* Try to patch EmEditor if possible
*/
_PatchIt:
	IF FileExist(A_ScriptDir "\EmEditorPatch.exe")
	{
		Run, "%A_ScriptDir%\EmEditorPatch.exe", %em_dir%
		WinWait, EmEditor 15.x [x86|x64] patch, , 5
		if ErrorLevel
		{
			MsgBox, 16, EmEditor Updater, % "There was an error during Patching!"
			return
		}
		else
		{
			WinActivate  ; WinActivate the window found by WinWait.
			ControlClick, Button1, EmEditor 15.x [x86|x64] patch  ; Clicks the Patch button
			WinWait, Fail :-(, , 1
			if ErrorLevel
			{
				WinWait, Congratulation!, , 1
				if ErrorLevel
				{
					; nop
				}
				else
				{
					TrayTip, EmEditor Patch, Patch Successfully!, 3, 1
				}
			}
			else
			{
				TrayTip, EmEditor Patch, Patch Failed!, 3, 3
			}
			WinActivate
			ControlClick, Button1  ;Click the OK button
			WinWaitClose
			
			WinClose, EmEditor 15.x [x86|x64] patch
			WinWaitClose, EmEditor 15.x [x86|x64] patch
		}
	}


; ------------------------------
if (LastOpened)
{
    msgbox , 36, EmEditor Updater,	
	(LTrim
   EmEditor was successfully updated!
	Do you want to re-open the EmEditor?
	)
	IfMsgBox, Yes
		Run, "%em_dir%\EmEditor.exe"
}
else
{
 MsgBox, 64, EmEditor Updater, EmEditor was successfully updated!
}
; remove backup files
FileRecycle, %em_dir%\EmEditor_BAK.zip
ExitApp

