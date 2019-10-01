#Region About
;~ Func HowToUseThisProgram()
;~ 		Start Guild Wars
;~ 		Log onto your dervish
;~ 		Equip a scythe
;~ 		Run the bot
;~ 		If one instance of Guild Wars is open Then
;~    		Click Start
;~ 		ElseIf multiple instances of Guild Wars are open Then
;~      	Select the character you want from the dropdown menu
;~ 			Click Start
;~ 		EndIf
;~ EndFunc

;~ Preparations:
;~		Dervish Equipment: Windwalker or Blessed Insignia; +4 Windprayers, +1 Scythe Mastery, +1 Mystisicm, +50 HP Rune, +2 Energy Rune
;~		Dervish Weapon: Equip a Zealous Scythe of Enchanting with a random inscription
;~		Skillbar Template: OgCjkqqLrSihdftXYijhOXhX0kA
;~		If You have no IAU: It is no problem, Bot will still work, the failrate will just increase slightly
;~
;~		Remember to get the Quest Temple of the Damned
#EndRegion About

#include <ButtonConstants.au3>
#include <GWA2.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include <Inventory.au3>
#NoTrayIcon

#Region Constants
; === Maps ===
Global Const $MAP_ID_DOOMLORE = 648
Global Const $MAP_ID_COF = 560

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

; === Item Rarity ===
Global Const $RARITY_GOLD = 2624
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE = 2623
Global Const $RARITY_WHITE = 2621

; === Materials and usefull Items ===
Global Const $GOLD_COINS = 2511
Global Const $ITEM_ID_BONES = 921
Global Const $ITEM_ID_DUST = 929
Global Const $ITEM_ID_DIESSA = 24353
Global Const $ITEM_ID_RIN = 24354
Global Const $ITEM_ID_LOCKPICKS = 22751
Global Const $ITEM_DYES = 146
Global Const $ITEM_EXTRAID_BLACKDYE = 10
Global Const $ITEM_EXTRAID_WHITEDYE = 12

; === Pcons ===
Global Const $ITEM_ID_TOTS = 28434
Global Const $ITEM_ID_GOLDEN_EGGS = 22752
Global Const $ITEM_ID_BUNNIES = 22644
Global Const $ITEM_ID_GROG = 30855
Global Const $ITEM_ID_CLOVER = 22191
Global Const $ITEM_ID_PIE = 28436
Global Const $ITEM_ID_CIDER = 28435
Global Const $ITEM_ID_POPPERS = 21810
Global Const $ITEM_ID_ROCKETS = 21809
Global Const $ITEM_ID_CUPCAKES = 22269
Global Const $ITEM_ID_SPARKLER = 21813
Global Const $ITEM_ID_HONEYCOMB = 26784
Global Const $ITEM_ID_VICTORY_TOKEN = 18345
Global Const $ITEM_ID_LUNAR_TOKEN = 21833
Global Const $ITEM_ID_HUNTERS_ALE = 910
Global Const $ITEM_ID_LUNAR_TOKENS = 28433
Global Const $ITEM_ID_KRYTAN_BRANDY = 35124
Global Const $ITEM_ID_BLUE_DRINK = 21812
#EndRegion Constants

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global Const $WEAPON_SLOT_SCYTHE = 1
Global Const $WEAPON_SLOT_STAFF = 2
Global $Runs = 0
Global $Fails = 0
Global $Bones = 0
Global $Dusts = 0
Global $TOTAL_GOLDS = 0
Global $BOT_RUNNING = False
Global $BOT_INITIALIZED = False
Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $HWND
#EndRegion Declarations

#Region GUI
$Gui = GUICreate("CoF Farmer", 299, 212, -1, -1)
$CharInput = GUICtrlCreateCombo("", 6, 6, 103, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
   GUICtrlSetData(-1, GetLoggedCharNames())
$StartButton = GUICtrlCreateButton("Start", 5, 184, 105, 23)
   GUICtrlSetOnEvent(-1, "StartButtonHandler")
$RunsLabel = GUICtrlCreateLabel("Runs:", 6, 31, 31, 17)
$COUNT_RUNS = GUICtrlCreateLabel("0", 34, 31, 75, 17, $SS_RIGHT)
$FailsLabel = GUICtrlCreateLabel("Fails:", 6, 50, 31, 17)
$COUNT_FAILS = GUICtrlCreateLabel("0", 30, 50, 79, 17, $SS_RIGHT)

$BonesLabel = GUICtrlCreateLabel("Bones:", 6, 69, 76, 17)
$COUNT_BONES = GUICtrlCreateLabel("0", 82, 69, 27, 17, $SS_RIGHT)
$DustsLabel = GUICtrlCreateLabel("Dusts:", 6, 88, 76, 17)
$COUNT_DUSTS = GUICtrlCreateLabel("0", 82, 88, 27, 17, $SS_RIGHT)
$TOTAL_GOLDSLabel = GUICtrlCreateLabel("Golds:", 6, 107, 76, 17)
$COUNT_GOLDS = GUICtrlCreateLabel("0", 82, 107, 27, 17, $SS_RIGHT)

$AvgTimeLabel = GUICtrlCreateLabel("Average time:", 6, 126, 65, 17)
$AVERAGE_TIME = GUICtrlCreateLabel("-", 71, 126, 38, 17, $SS_RIGHT)
$TotTimeLabel = GUICtrlCreateLabel("Total time:", 6, 145, 49, 17)
$TotTimeCount = GUICtrlCreateLabel("-", 55, 145, 54, 17, $SS_RIGHT)

$StatusLabel = GUICtrlCreateEdit("", 115, 6, 178, 200, 2097220)
$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 6, 162, 103, 17)
   GUICtrlSetOnEvent(-1, "ToggleRendering")
   GUICtrlSetState($RenderingBox, $GUI_DISABLE)
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
		WinSetTitle($Gui, "", "CoF Farmer - " & $charname)
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
;Setup()
While 1
   If Not $BOT_RUNNING Then
	  AdlibUnRegister("TimeUpdater")
	  AdlibUnRegister("VerifyConnection")
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
	If GetMapID() == $MAP_ID_DOOMLORE Then EnterDungeon()

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
	EndIf

	$Runs += 1
	GUICtrlSetData($COUNT_RUNS, $Runs)

	If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()

	Out("Returning to Doomlore")
	Resign()
	RndSleep(5000)
	ReturnToOutpost()
	WaitMapLoading($MAP_ID_DOOMLORE)
	If InventoryIsFull() Then CleanInventory()
EndFunc


#Region Setup
Func Setup()
	Out("Travelling to Doomlore.")
	If GetMapID() <> $MAP_ID_DOOMLORE Then TravelTo($MAP_ID_DOOMLORE)

	Out("Loading skillbar.")
	LoadSkillTemplate("OgCjkqqLrSihdftXYijhOXhX0kA")

	RndSleep(500)
	SetupResign()
EndFunc

Func SetupResign()
	Out("Setting up resign.")
	GoToNPC(GetNearestNPCToCoords(-19090, 17980))
	Dialog($FIRST_DIALOG)
	RndSleep(GetPing() + 250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($MAP_ID_COF)
	Move(-19300, -8250)
	RndSleep(2500)
	WaitMapLoading($MAP_ID_DOOMLORE)
	RndSleep(500)
	Return True
EndFunc

Func EnterDungeon()
	Out("Entering dungeon.")
	GoToNPC(GetNearestNPCToCoords(-19090, 17980))
	Dialog($FIRST_DIALOG)
	RndSleep(GetPing() + 250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($MAP_ID_COF)
EndFunc
#EndRegion Setup

#Region Fight
Func Kill()
	Out("Killing Cryptos.")
	If GetIsDead(-2) Then Return
	CheckVos()
	While GetNumberOfFoesInRangeOfAgent(-2, 800) > 0
		If GetIsDead(-2) Then Return
		If GetSkillbarSkillAdrenaline($crippling) >= 150 Then
			CheckVoS()
			TargetNearestEnemy()
			UseSkill($crippling, -1)
			RndSleep(800)
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
	PickUpLoot()
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
		;If StringLeft(GetAgentName($agent), 7) <> "Sensali" Then ContinueLoop
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
		$me = GetAgentByID(-2)
		If DllStructGetData($me, 'HP') <= 0.0 Then Return
		$agent = GetAgentByID($i)
		If Not GetIsMovable($agent) Then ContinueLoop
		If Not GetCanPickUp($agent) Then ContinueLoop
		$item = GetItemByAgentID($i)
		If CanPickUp($item) Then
			Do
				;If $lBlockedCount > 2 Then UseSkillEx(6,-2)
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
EndFunc

Func CanPickUp($item)
	Local $ModelID = DllStructGetData($item, 'ModelID')
	Local $ExtraID = DllStructGetData($item, 'ExtraID')
	Local $rarity = GetRarity($item)

	If $ModelID == $ITEM_DYES Then Return True	; Black and White Dye ;And ($ExtraID == 10 Or $ExtraID == 12) for only B/W
	If $rarity == $RARITY_GOLD Then
		$TOTAL_GOLDS += 1
		GUICtrlSetData($COUNT_GOLDS, $TOTAL_GOLDS)
		Return True
	EndIf
	If $ModelID == $ITEM_ID_BONES Then
		$bones += DllStructGetData($item, 'Quantity')
		GUICtrlSetData($COUNT_BONES, $bones)
		Return True ;changed to false because too many bones
	EndIf
	If $ModelID == $ITEM_ID_DUST Then
		$dusts += DllStructGetData($item, 'Quantity')
		GUICtrlSetData($COUNT_DUSTS, $dusts)
		Return True
	EndIf
	If $ModelID == $ITEM_ID_DIESSA Then Return True
	If $ModelID == $ITEM_ID_RIN Then Return True
	If $ModelID == $ITEM_ID_LOCKPICKS Then Return True
	If $ModelID == 22191 Then Return True ; Clover
	If $ModelID == $GOLD_COINS And GetGoldCharacter() < 99000 Then Return True

	Return True ;Added to gather everything
	Return False
EndFunc
#EndRegion Loot

#Region Salvage
Func SalvageStuff()
   $MerchOpened = False
   Local $Item
   Local $Quantity
   For $Bag = 1 To 4
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag, $Slot)
		 If CanSalvage($Item) Then
			$Quantity = DllStructGetData($Item, 'Quantity')
			For $i = 1 To $Quantity
			   If FindCheapSalvageKit() = 0 Then BuySalvageKit()
			   StartSalvage1($Item, True)
			   Do
				  Sleep(10)
			   Until DllStructGetData(GetItemBySlot($Bag, $Slot), 'Quantity') = $Quantity - $i
			   $Item = GetItemBySlot($Bag, $Slot)
			Next
		 EndIf
	  Next
   Next
EndFunc

Func StartSalvage1($aItem, $aCheap = false)
   Local $lOffset[4] = [0, 0x18, 0x2C, 0x62C]
   Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
   If IsDllStruct($aItem) = 0 Then
	  Local $itemID = $aItem
   Else
	  Local $itemID = DllStructGetData($aItem, 'ID')
   EndIf
   If $aCheap Then
	  Local $lSalvageKit = FindCheapSalvageKit()
   Else
	  Local $lSalvageKit = FindSalvageKit()
   EndIf
   If $lSalvageKit = 0 Then Return
   DllStructSetData($mSalvage, 2, $itemID)
   DllStructSetData($mSalvage, 3, $lSalvageKit)
   DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
   Enqueue($mSalvagePtr, 16)
EndFunc

Func CanSalvage($Item)
   If DllStructGetData($Item, 'ModelID') == 835 Then Return True
   Return False
EndFunc

Func FindCheapSalvageKit()
   Local $Item
   Local $Kit = 0
   Local $Uses = 101
   For $Bag = 1 To 16
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag, $Slot)
		 Switch DllStructGetData($Item, 'ModelID')
			Case 2992
			   If DllStructGetData($Item, 'Value')/2 < $Uses Then
				  $Kit = DllStructGetData($Item, 'ID')
				  $Uses = DllStructGetData($Item, 'Value')/8
			   EndIf
			Case Else
			   ContinueLoop
		 EndSwitch
	  Next
   Next
   Return $Kit
EndFunc

Func BuySalvageKit()
   WithdrawGold(100)
   GoToNPC(GetNearestNPCToCoords(-19166, 17980))
   RndSleep(500)
   BuyItem(2, 1, 100)
   Sleep(1500)
   If FindCheapSalvageKit() = 0 Then BuySalvageKit()
EndFunc
#EndRegion Salvage

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
	Local $AvgSeconds = Floor($TotalSeconds/$Runs)
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
	GUICtrlSetData($TotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc
#EndRegion Time

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
#EndRegion Helpers
