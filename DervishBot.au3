#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ScrollBarsConstants.au3>
#include <GuiEdit.au3>
#include "../GWA2.au3"
#include "../_SimpleInventory.au3"
#include "TimeManagement.au3"
#NoTrayIcon

#cs
	Func HowToUseThisProgram()
		Start Guild Wars
		Log onto your dervish
		Equip a scythe
		Run the bot
		If one instance of Guild Wars is open Then
		   Click Start
		ElseIf multiple instances of Guild Wars are open Then
		   Select the character you want from the dropdown menu
			Click Start
		EndIf
	EndFunc

	Preparations:
		Dervish Equipment: Windwalker or Blessed Insignia; +4 Windprayers, +1 Scythe Mastery, +1 Mystisicm, +50 HP Rune, +2 Energy Rune
		Dervish Weapon: Equip a Zealous Scythe of Enchanting with a random inscription
		Skillbar Template: OgCjkqqLrSihdftXYijhOXhX0kA
		If You have no IAU: It is no problem, Bot will still work, the failrate will just increase slightly

		Remember to get the Quest Temple of the Damned
#ce

#Region Constants
; === Maps ===
Global Const $DOOMLORE_SHRINE = 648
Global Const $CATHEDRAL_OF_FLAMES = 560

; === Dialogs ===
Global Const $FIRST_DIALOG = 0x832105
Global Const $SECOND_DIALOG = 0x88
Global Const $THIRD_DIALOG = 0x7F

; === Build ===
Global Const $SkillBarTemplate = "OgCjkqqLrSihdftXYijhOXhX0kA"

; === Skills ===
Global Const $pious = 1
Global Const $grenths = 2
Global Const $vos = 3
Global Const $mystic = 4
Global Const $crippling = 5
Global Const $reap = 6
Global Const $vop = 7
Global Const $iau = 8

; === Skill Cost ===
Global Const $skillCost[9] = [0, 5, 10, 5, 0, 0, 0, 15, 5]
#EndRegion Constants

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $Fails = 0
Global $Bones = 0
Global $Dusts = 0
Global $TOTAL_RUNS = 0
Global $TOTAL_GOLDS = 0
Global $BOT_RUNNING = False
Global $BOT_INITIALIZED = False
Global $USABLE_BAGS = 3
Global $MerchOpened = False
Global $HWND
#EndRegion Declarations

#Region GUI
$GUI = GUICreate("CoF Farmer", 300, 260, -1, -1)
$CharInput = GUICtrlCreateCombo("", 5, 5, 120, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, GetLoggedCharNames())

GUICtrlCreateGroup("Drops", 5, 30, 120, 95)
$PICKUP_BONES = GUICtrlCreateCheckbox("Bones:", 10, 45, 75, 15)
$COUNT_BONES = GUICtrlCreateLabel("0", 90, 45, 25, 15, $SS_RIGHT)
$PICKUP_DUST = GUICtrlCreateCheckbox("Dusts:", 10, 65, 75, 15)
$COUNT_DUSTS = GUICtrlCreateLabel("0", 90, 65, 25, 15, $SS_RIGHT)
$PICKUP_GOLDS = GUICtrlCreateCheckbox("Golds:", 10, 85, 75, 15)
	GUICtrlSetState($PICKUP_GOLDS, $GUI_CHECKED)
$COUNT_GOLDS = GUICtrlCreateLabel("0", 90, 85, 25, 15, $SS_RIGHT)
$PICKUP_IRONS = GUICtrlCreateCheckbox("Irons:", 10, 105, 75, 15)
	GUICtrlSetState($PICKUP_IRONS, $GUI_CHECKED)
$COUNT_IRONS = GUICtrlCreateLabel("0", 90, 105, 25, 15, $SS_RIGHT)


GUICtrlCreateGroup("Stats", 5, 130, 120, 95)
$LabelRuns = GUICtrlCreateLabel("Runs:", 10, 145, 30, 15)
$COUNT_RUNS = GUICtrlCreateLabel("0", 40, 145, 75, 15, $SS_RIGHT)
$FailsLabel = GUICtrlCreateLabel("Fails:", 10, 165, 30, 15)
$COUNT_FAILS = GUICtrlCreateLabel("0", 40, 165, 75, 15, $SS_RIGHT)
	GUICtrlSetColor(-1, 0x990000)
$LabelAvgTime = GUICtrlCreateLabel("Average time:", 10, 185, 65, 15)
$AVERAGE_TIME = GUICtrlCreateLabel("-", 75, 185, 40, 15, $SS_RIGHT)
$LabelTotTime = GUICtrlCreateLabel("Total time:", 10, 205, 50, 15)
$TOTAL_TIME = GUICtrlCreateLabel("-", 60, 205, 55, 15, $SS_RIGHT)

$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 10, 235, 105, 15)
	GUICtrlSetOnEvent(-1, "ToggleRendering")
	GUICtrlSetState($RenderingBox, $GUI_DISABLE)

$StatusLabel = GUICtrlCreateEdit("", 130, 5, 165, 220, 2097220)
$StartButton = GUICtrlCreateButton("Start", 130, 230, 165, 23)
	GUICtrlSetOnEvent(-1, "StartButtonHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Handlers
Func StartButtonHandler()
	If $BOT_RUNNING Then
		Out("Will pause after this run.")
		GUICtrlSetData($StartButton, "force pause NOW")
		GUICtrlSetOnEvent($StartButton, "Resign")
		$BOT_RUNNING = False
	ElseIf $BOT_INITIALIZED Then
		GUICtrlSetData($StartButton, "Pause")
		$BOT_RUNNING = True
	Else
		Out("Initializing...")
		Local $charname = GUICtrlRead($CharInput)
		If $charname == "" Then
			If Initialize(ProcessExists("gw.exe"), True, True) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($charname, True, True) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $charname & "'")
				Exit
			EndIf
		EndIf
		$HWND = GetWindowHandle()

		GUICtrlSetState($RenderingBox, $GUI_ENABLE)
		GUICtrlSetState($CharInput, $GUI_DISABLE)
		Local $charname = GetCharname()
		GUICtrlSetData($CharInput, $charname, $charname)
		GUICtrlSetData($StartButton, "Pause")
		WinSetTitle($Gui, "", "" & $charname & " - CoF Farmer")
		$BOT_RUNNING = True
		$BOT_INITIALIZED = True
		SetMaxMemory()
	EndIf
EndFunc
#EndRegion Handlers

#Region Loops
Out("Ready")
While Not $BOT_RUNNING
	Sleep(500)
WEnd

AdlibRegister("TimeUpdater", 1000)
AdlibRegister("VerifyConnection", 5000)
Setup()
While 1
	If Not $BOT_RUNNING Then
		AdlibUnRegister("TimeUpdater")
		AdlibUnRegister("VerifyConnection")
		If $BOT_INITIALIZED Then Inventory()
		Out("Bot is paused.")
		GUICtrlSetState($StartButton, $GUI_ENABLE)
		GUICtrlSetData($StartButton, "Start")
		While Not $BOT_RUNNING
			Sleep(500)
		WEnd
		AdlibRegister("TimeUpdater", 1000)
		AdlibRegister("VerifyConnection", 5000)
	EndIf
	MainLoop()
WEnd
#EndRegion Loops

Func MainLoop()
	If GetMapID() == $DOOMLORE_SHRINE Then EnterDungeon()

	MoveTo(-16850, -8930)
	UseSkillEx($vop)
	UseSkillEx($grenths)
	UseSkillEx($vos)
	UseSkillEx($mystic)
	MoveTo(-15220, -8950)
	UseSkill($iau, -2)

	Kill()
	If GetIsDead(-2) Then
		$Fails += 1
		Out("I'm dead.")
		GUICtrlSetData($COUNT_FAILS, $Fails)
	Else
		Out("Completed in " & GetTime() & ".")
		GUICtrlSetData($AVERAGE_TIME, AvgTime())
		PickUpLoot()
	EndIf

	$TOTAL_RUNS += 1
	GUICtrlSetData($COUNT_RUNS, $TOTAL_RUNS)

	If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()

	Out("Returning to Doomlore")
	Resign()
	RndSleep(4000)
	ReturnToOutpost()
	WaitMapLoading($DOOMLORE_SHRINE)
	If InventoryIsFull() Then Inventory()
EndFunc ;MainLoop

#Region Setup
Func Setup()
	Out("Travel to Doomlore.")
	If GetMapID() <> $DOOMLORE_SHRINE Then TravelTo($DOOMLORE_SHRINE)

	Out("Loading skillbar.")
	LoadSkillTemplate("OgCjkqqLrSihdftXYijhOXhX0kA")
	SwitchMode(False)

	RndSleep(500)
	SetupResign()
EndFunc ;Setup

Func SetupResign()
	Out("Setting up resign.")
	GoToNPC(GetNearestNPCToCoords(-19090, 17980))
	Dialog($FIRST_DIALOG)
	RndSleep(250)
	Dialog($SECOND_DIALOG)
	RndSleep(250)
	WaitMapLoading($CATHEDRAL_OF_FLAMES)
	Move(-19300, -8250)
	RndSleep(2500)
	WaitMapLoading($DOOMLORE_SHRINE)
	RndSleep(500)
	Return True
EndFunc ;SetupResign

Func EnterDungeon()
	Out("Entering dungeon.")
	GoToNPC(GetNearestNPCToCoords(-19090, 17980))
	Dialog($FIRST_DIALOG)
	RndSleep(250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($CATHEDRAL_OF_FLAMES)
EndFunc ;EnterDungeon
#EndRegion Setup

Func GoMerchant()
	GoToNPC(GetNearestNPCToCoords(-19166, 17980))
	RndSleep(550)
	Dialog($THIRD_DIALOG)
	RndSleep(550)
EndFunc

#Region Fight
Func Kill()
	Out("Killing Cryptos.")
	CheckVos()
	While GetNumberOfFoesInRangeOfAgent(-2, 800) > 0
		If GetIsDead(-2) Then Return
		If GetSkillbarSkillAdrenaline($crippling) >= 150 Then
			CheckVoS()
			TargetNearestEnemy()
			UseSkill($crippling, -1)
		EndIf
		If GetSkillbarSkillAdrenaline($reap) >= 120 Then
			CheckVoS()
			TargetNearestEnemy()
			UseSkill($reap, -1)
		EndIf
		RndSleep(200)
		CheckVos()
		TargetNearestEnemy()
		Attack(-1)
	WEnd
	RndSleep(200)
EndFunc

Func CheckVoS()
	If IsRecharged($vos) Then
		UseSkillEx($pious)
		UseSkillEx($grenths)
		UseSkillEx($vos)
	EndIf
EndFunc
Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	Local $agent, $lDistance
	Local $lCount = 0, $agentArray = GetAgentArray(0xDB)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To $agentArray[0]
		$agent = $agentArray[$i]
		If BitAND(DllStructGetData($agent, 'typemap'), 262144) Then
			If StringLeft(GetAgentName($agent), 7) <> "Servant" Then ContinueLoop
		EndIf
		If DllStructGetData($agent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($agent, 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($agent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = GetDistance($agent)
		If $lDistance > $aRange Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc
#EndRegion Fight

#Region Loot
Func PickUpLoot()
	Local $me, $agent, $item
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $itemExists = True
	For $i = 1 To GetMaxAgents()
		If InventoryIsFull() Then ExitLoop
		$me = GetAgentByID(-2)
		If DllStructGetData($me, 'HP') <= 0.0 Then Return
		$agent = GetAgentByID($i)
		If Not GetIsMovable($agent) Or Not GetCanPickUp($agent) Then ContinueLoop
		$item = GetItemByAgentID($i)
		If CanPickUp($item) Then
			Do
				PickUpItem($item)
				Sleep(GetPing())
				Do
					Sleep(100)
					$me = GetAgentByID(-2)
				Until DllStructGetData($me, 'MoveX') == 0 And DllStructGetData($me, 'MoveY') == 0
				$lBlockedTimer = TimerInit()
				Do
					Sleep(3)
					$itemExists = IsDllStruct(GetAgentByID($i))
				Until Not $itemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
				If $itemExists Then $lBlockedCount += 1
			Until Not $itemExists Or $lBlockedCount > 5
		EndIf
	Next
EndFunc ;PickUpLoot

Func CanPickUp($item)
	Local $ModelID = DllStructGetData($item, 'ModelID')
	Local $ExtraID = DllStructGetData($item, 'ExtraID')
	Local $rarity = GetRarity($item)

	If $ModelID == $ITEM_DYES And ($ExtraID == $ITEM_BLACK_DYE Or $ExtraID == $ITEM_WHITE_DYE) Then Return True	;Black and White Dye ; for only B/W
	If $rarity == $RARITY_GOLD Then
		If Not GetChecked($PICKUP_GOLDS) Then Return False
		$TOTAL_GOLDS += 1
		GUICtrlSetData($COUNT_GOLDS, $TOTAL_GOLDS)
		Return True
	EndIf
	If $ModelID == $MAT_BONES Then
		If Not GetChecked($PICKUP_BONES) Then Return False
		$bones += DllStructGetData($item, 'Quantity')
		GUICtrlSetData($COUNT_BONES, $bones)
		Return True ;changed to false because too many bones
	EndIf
	If $ModelID == $MAT_DUST Then
		If Not GetChecked($PICKUP_DUST) Then Return False
		$dusts += DllStructGetData($item, 'Quantity')
		GUICtrlSetData($COUNT_DUSTS, $dusts)
		Return True
	EndIf
	If $ModelID == $TROPHY_DIESSA_CHALICE Then Return True
	If $ModelID == $TROPHY_RIN_RELIC Then Return True
	If $ModelID == $ITEM_LOCKPICK Then Return True
	If $ModelID == $DPREMOVAL_CLOVER Then Return True
	If $ModelID == $GOLD_COINS And GetGoldCharacter() < 99000 Then Return True

	Return GetChecked($PICKUP_IRONS) ;Added to gather everything
EndFunc
#EndRegion Loot

#Region Helpers
Func Out($msg)
	GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
	_GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
	_GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

Func VerifyConnection()
	If GetMapLoading() == 2 Then Disconnected()
EndFunc ;VerifyConneciton

Func _exit()
	If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
		EnableRendering()
		WinSetState($HWND, "", @SW_SHOW)
		Sleep(500)
	EndIf
	Exit
EndFunc
Func GetChecked($GUICtrl)
   Return GUICtrlRead($GUICtrl) == $GUI_Checked
EndFunc
#EndRegion Helpers

;~ Description: Use a skill and wait for it to be used.
Func UseSkillEx($lSkill, $lTgt = -2, $aTimeout = 3000)
	If GetIsDead(-2) Then Return
	If Not IsRecharged($lSkill) Then Return
	Local $Skill = GetSkillByID(GetSkillBarSkillID($lSkill, 0))
	Local $Energy = StringReplace(StringReplace(StringReplace(StringMid(DllStructGetData($Skill, 'Unknown4'), 6, 1), 'C', '25'), 'B', '15'), 'A', '10')
	If GetEnergy(-2) < $Energy Then Return
	Local $lAftercast = DllStructGetData($Skill, 'Aftercast')
	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)
	Do
		Sleep(50)
		If GetIsDead(-2) = 1 Then Return
		Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
	Sleep($lAftercast * 1000)
EndFunc   ;==>UseSkillEx
