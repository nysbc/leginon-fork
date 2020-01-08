#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:       Anchi Cheng

 Script Function:
	Get and Set Aperture Selection
	To run from command line needs parameters

	Requires setting the position selections in fei.cfg

    $sFeiConfigPath: the path to fei.cfg
	$tem:(talos or titan)
	$mechanism: (condenser_2, objective, selected_area)
	$action: (get or set)

	If setting, also the sizes in um or 'open' as defined in fei.cfg.

	$sSelection

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <MsgBoxConstants.au3>
#include <Array.au3>
Global $error_log = "autoit_error.log"
Global $result_log = "autoit_result.log"
_ResetError()
_ResetResult()

Local $before
Local $after
$before = WinActive("TEM User Interface")
; activate the window with title
Global $my_title, $my_text
$my_title = "Apertures"
$my_text = ""
WinActivate($my_title)
WinWaitActive($my_title, "", 5)
$after = WinActive($my_title)
Global $sFeiConfigPath = "c:\Program Files (x86)\myami\fei.cfg"
; Set Default
Local $sTem = 'titan'
Local $sMechanism = 'objective'
Local $action = 'set'
Local $sSelection = '100'
; Set from command line
If $CmdLine[0] > 0 Then
   $sFeiConfigPath = $CmdLine[1]
   $sTem = $CmdLine[2]
   $sMechanism = $CmdLine[3]
   $action = $CmdLine[4]
   If $action == 'set' Then
	  $sSelection = $CmdLine[5]
   EndIf
EndIf

;Deciding instance indices for button and combobox
Local $hasAutoC3 = GetFeiConfigHasAutoC3($sFeiConfigPath)
Local $aInstanceIndices = GetInstanceIndices($sTem, $hasAutoC3, $sMechanism)
;Running get or set
If $action = 'get' Then
   Local $result = GetApertureSelection($aInstanceIndices)
   If $CmdLine[0] = 0 Then
	  MsgBox(0,'selected aperture',$sMechanism & ", " & $result)
   EndIf
   _WriteResult($result)
ElseIf $action = 'set' Then
   SetApertureSelection($aInstanceIndices, $sSelection)
   Local $tText = GetApertureSelection($aInstanceIndices)
   If $sSelection <> $tText Then
	  _WriteError("Selecting position " & $sSelection & " failed.  It is still " & $tText)
   EndIf

EndIf

Func GetInstanceIndices($sTem, $hasAutoC3, $mechanism)
   ;ComboBox and Button instance indices depends on the gui. Can get this information using AutoIt Window Info program
   ;Two common tem gui choices.
   If $sTem = 'titan' Then
	  ;MsgBox(0,'this',$hasAutoC3)
 	  Global $aMechanisms[] = ['condenser_2','objective','selected_area']
	  Global $aSelections = GetFeiConfigSelections($sFeiConfigPath,"aperture",$mechanism)
	  If $hasAutoC3 Then
		 ; 3 auto condenser aperture system with condenser_2 not retractable
		 Local $aComboBoxInstances[] = [2,4,5]
		 Local $aButtonInstances[] = [-1,4,6]
	  Else
		 Local $aComboBoxInstances[] = [2,3,4]
		 Local $aButtonInstances[] = [-1,3,5]
	  EndIf
   Else
 	  Global $aMechanisms[] = ['condenser_2','objective','selected_area']
	  Global $aSelections = GetFeiConfigSelections($sFeiConfigPath,"aperture",$mechanism)
	  ; C3 not exist or is manual so that it does not have button to activate nor combobox
	  Local $aComboBoxInstances[] = [1,2,3]
	  Local $aButtonInstances[] = [-1,2,4]
   EndIf

    ;Decide which one
   Local $iMechIndex = _ArraySearch($aMechanisms, $mechanism)
   Local $iButtonInst = $aButtonInstances[$iMechIndex]
   Local $iComboInst = $aComboBoxInstances[$iMechIndex]
   Local $aResult[2] = [$iButtonInst, $iComboInst]
   Return $aResult
EndFunc

Func GetApertureSelection($aIndices)
   ; set aperture selection
   Local $iButtonInst = $aIndices[0]
   Local $iComboInst = $aIndices[1]
   Local $tText = ControlGetText($my_title,"","[CLASS:ComboBox;INSTANCE:" & $iComboInst & "]")

   If $tText = "[none]" Then
	  return 'open'
   Else
	  return $tText
   EndIf
EndFunc

Func SetApertureSelection($aIndices, $sSelection)
   ; set aperture selection
   Local $iButtonInst = $aIndices[0]
   Local $iComboInst = $aIndices[1]
   Local $tText = ControlGetText($my_title,"","[CLASS:ComboBox;INSTANCE:" & $iComboInst & "]")
   Local $iTry = 0

   ; Select aperture position
   If _ArraySearch($aSelections, $sSelection) = -1 Then
	  _WriteError("Selection not valid: " & $sSelection)
	  Return
   EndIf
   If $sSelection == 'open' Then
	  $sPosition = "[none]"
	  If $tText <> "[none]" Then
		 ControlClick($my_title,"","[CLASS:Button;INSTANCE:" & $iButtonInst & "]")
		 ;MsgBox(0,'button',$iButtonInst)
		 ;long sleep to wait for the combobox to change to [none]
		 Sleep(10000)
	  EndIf
   Else
	  ;Try multiple times since combobox selection does not always works when the selection is not adjacent
	  While $sSelection <> $tText Or $iTry >=10
		 ControlSend($my_title,"","[CLASS:ComboBox;INSTANCE:" & $iComboInst & "]",$sSelection)
		 Sleep(2000)
		 $tText = ControlGetText($my_title,"","[CLASS:ComboBox;INSTANCE:" & $iComboInst & "]")
		 ;MsgBox(0,'tries',$iTry & " " & $sSelection & " ? " & $tText)
		 $iTry += 1
	  WEnd
   EndIf
EndFunc

Func getFeiConfigModuleLines($configpath, $module)
   ; Read lines under a module in fei.cfg
   Local $h2 = FileOpen($configpath, 0)
   If $h2 == -1 Then
	  _WriteError("can not open " & $configpath)
	  Exit
   EndIf
   Local $bInModule = False
   ; declare array must have at least one item
   Local $Lines[1]=['dummy']
   While 1
	  Local $sLine = FileReadLine($h2)
	  If @error Then ExitLoop
	  If StringLeft($sLine,1)=="[" AND StringRight($sLine,1)=="]" Then
		 Local $modname = StringSplit(StringSplit($sLine,"]",2)[0],"[",2)[1]
		 If $modname == $module Then

			$bInModule = True
		 Else
			$bInModule = False
		 EndIf
	  ElseIf $bInModule == True Then
		 Local $aBits = StringSplit($sLine,"=",2)
		 If UBound($aBits) > 1 Then
			_ArrayAdd($Lines, $sLine)
		 EndIf
	  EndIf
   Wend
   FileClose($h2)
   ;remove dummy
   _ArrayDelete($Lines, 0)
   Return $Lines
EndFunc

Func GetFeiConfigHasAutoC3($configpath)
   ;Get boolean value of aperture:has_auto_c3 from fei.cfg
   Local $key = 'has_auto_c3'
   Local $aLines = getFeiConfigModuleLines($configpath, 'aperture')
   Local $hasAutoC3 = False
   For $i = 0 to UBound($aLines)-1
	  Local $sLine = $aLines[$i]
	  Local $aBits = StringSplit($sLine,"=",2)
	  $sKey = StringStripWS($aBits[0],3); strip leading and trailing white spaces
	  If StringLower($sKey) == StringLower($key) Then
		 If StringLower(StringStripWS($aBits[1],3)) = 'true' Then
			$hasAutoC3 = True
		 EndIf
	  EndIf
   Next
   return $hasAutoC3
EndFunc

Func GetFeiConfigSelections($configpath,$module,$key)
   Local $aListNames[10] ; In case there are 6 phase plates.
   Local $aLines = getFeiConfigModuleLines($configpath, $module)
   For $i = 0 to UBound($aLines)-1
	  Local $sLine = $aLines[$i]
	  Local $aBits = StringSplit($sLine,"=",2)
	  $sKey = StringStripWS($aBits[0],3); strip leading and trailing white spaces

	  If StringLower($sKey) == StringLower($key) Then
		 Local $aList = StringSplit($aBits[1],",",2)
		 For $i = 0 to UBound($aList)-1
			$aListNames[$i] = StringStripWS($aList[$i],3); strip leading and trailing white spaces
			;MsgBox(0,'config value',$sKey & ' ' & $i & ' ' & $aListNames[$i])
		 Next
	  EndIf
   Next
   If $aListNames[0]=='' Then
	  _WriteError("Can not find " & $key & " selection list in " & $module & " in fei.cfg")
	  Exit
   EndIf
   Return $aListNames
EndFunc

Func _ResetError()
   FileDelete($error_log)
EndFunc

Func _WriteError($msg)
   ;Error written to log is read by caller to retrieve error
   Local $h = FileOpen($error_log, 1)
   FileWriteLine($h,$msg)
   FileClose($h)
EndFunc

Func _ResetResult()
   FileDelete($result_log)
EndFunc

Func _WriteResult($msg)
   ;Result written to log is read by caller
   Local $h = FileOpen($result_log, 1)
   FileWriteLine($h,$msg)
   FileClose($h)
EndFunc



