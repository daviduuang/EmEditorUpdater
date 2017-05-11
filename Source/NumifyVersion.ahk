
; Conversion of a version given as string to a numerical version (to allow version comparison)
;
; see: http://www.autohotkey.com/board/topic/62037-conversion-of-version-string-to-number/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example: Does current AHK-Version meet my requirements?
; Which version of Autohotkey is required?
;~ versionAHKReq := "1.0.90.0"
 
;~ vAHKCurr := NumifyVersion(A_AhkVersion)
;~ vAHKReq := NumifyVersion(versionAHKReq)
 
;~ If (vAHKCurr < vAHKReq) {
  ;~ Msgbox AHK-Version mismatch: Current Version < %A_AhkVersion% > <=> Required Version < %versionAHKReq% >
;~ }
;~ else {
	;~ Msgbox AHK-Version OK: Current Version < %A_AhkVersion% > <=> Required Version < %versionAHKReq% >
;~ }
 
/* ===============================================================================
   Function:   NumifyVersion
	  Conversion of a version given as string to a numerical version (to allow version comparison)
 
   Requirements for input version string:
      Description - 4 part Version Number: Major, Minor, Fixlevel, Bugfixlevel
      Separator - Parts have to be separated by "." (dot)
      Data Type - Major, Minor and Fixlevel are not allowed to be anything but number! Bugfixelevel might be either a single number only or a string "alpha", "beta", "RC" followed by a number
      Data Range - The numbers have to be less equal than 999
 
   Restrictions:
      This only works for Versionranges from 0 to 999
 
   Examples:
     "1.2.3.0" or "1.2.3.alpha9" or "1.2.3.beta8" "or "1.2.3.RC7"
 
     This functions numifies the string and therefore allows version comparison: 1.2.3.alpha9 (1002002.7009) < 1.2.3.beta8 (1002002.8008) < 1.2.3.RC7 (1002002.9007) < 1.2.3.5 (1002003.0005)
 
   Parameters:
      version - version number as string
 
   Return Values:
      version - numified version
 
   Author(s):
      hoppfrosch
===============================================================================  
*/
NumifyVersion(version) {
	StringSplit, MyVersion, version, `.`
 
	Major := MyVersion1
	Minor := MyVersion2
	Fixlevel := MyVersion3
	BugfixlevelFull := MyVersion4
 
	Correction := 0
	Bugfixlevel := BugfixlevelFull
 
	if (RegExMatch(BugfixlevelFull, "i)RC")) {
		Bugfixlevel := RegExReplace(BugfixlevelFull, "i)RC","")
		Correction := -1
	}
	else if (RegExMatch(BugfixlevelFull, "i)BETA")) {
		Bugfixlevel := RegExReplace(BugfixlevelFull, "i)BETA","")
		Correction := -2
	}
	else if (RegExMatch(BugfixlevelFull, "i)ALPHA")) {
		Bugfixlevel := RegExReplace(BugfixlevelFull, "i)ALPHA","")
		Correction := -3
	}
 
	NumVersion := Major*1000000 + Minor*1000 + Fixlevel +Correction/10 + Bugfixlevel/10000
	return NumVersion
 
}