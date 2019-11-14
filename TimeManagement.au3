#include-once

Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0

#Region Time
Func GetTime()
	Local $Time = GetInstanceUpTime()
	Local $Seconds = Floor($Time/1000)
	Local $Minutes = Floor($Seconds/60)
	Local $Hours = Floor($Minutes/60)
	Local $Second = $Seconds - $Minutes*60
	Local $Minute = $Minutes - $Hours*60
	If $Hours = 0 Then
		If $Second < 10 Then $InstTime = $Minute&':0'&$Second
		If $Second >= 10 Then $InstTime = $Minute&':'&$Second
	ElseIf $Hours <> 0 Then
		If $Minutes < 10 Then
			If $Second < 10 Then $InstTime = $Hours&':0'&$Minute&':0'&$Second
			If $Second >= 10 Then $InstTime = $Hours&':0'&$Minute&':'&$Second
		ElseIf $Minutes >= 10 Then
			If $Second < 10 Then $InstTime = $Hours&':'&$Minute&':0'&$Second
			If $Second >= 10 Then $InstTime = $Hours&':'&$Minute&':'&$Second
		EndIf
	EndIf
	Return $InstTime
EndFunc

Func AvgTime()
	Local $Time = GetInstanceUpTime()
	Local $Seconds = Floor($Time/1000)
	$TotalSeconds += $Seconds
	Local $AvgSeconds = Floor($TotalSeconds/$TOTAL_RUNS)
	Local $Minutes = Floor($AvgSeconds/60)
	Local $Hours = Floor($Minutes/60)
	Local $Second = $AvgSeconds - $Minutes*60
	Local $Minute = $Minutes - $Hours*60
	If $Hours = 0 Then
		If $Second < 10 Then $AvgTime = $Minute&':0'&$Second
		If $Second >= 10 Then $AvgTime = $Minute&':'&$Second
	ElseIf $Hours <> 0 Then
		If $Minutes < 10 Then
			If $Second < 10 Then $AvgTime = $Hours&':0'&$Minute&':0'&$Second
			If $Second >= 10 Then $AvgTime = $Hours&':0'&$Minute&':'&$Second
		ElseIf $Minutes >= 10 Then
			If $Second < 10 Then $AvgTime = $Hours&':'&$Minute&':0'&$Second
			If $Second >= 10 Then $AvgTime = $Hours&':'&$Minute&':'&$Second
		EndIf
	EndIf
	Return $AvgTime
EndFunc

Func TimeUpdater()
	$Seconds += 1
	If $Seconds = 60 Then
		$Minutes += 1
		$Seconds = $Seconds - 60
	EndIf
	If $Minutes = 60 Then
		$Hours += 1
		$Minutes = $Minutes - 60
	EndIf
	If $Seconds < 10 Then
		$L_Sec = "0" & $Seconds
	Else
		$L_Sec = $Seconds
	EndIf
	If $Minutes < 10 Then
		$L_Min = "0" & $Minutes
	Else
		$L_Min = $Minutes
	EndIf
	If $Hours < 10 Then
		$L_Hour = "0" & $Hours
	Else
		$L_Hour = $Hours
	EndIf
	GUICtrlSetData($TOTAL_TIME, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc
#EndRegion Time