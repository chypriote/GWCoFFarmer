#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <GWA2.au3>
#NoTrayIcon

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $BOT_RUNNING = False
Global $BOT_LOADED = False
Global $HWND
Global $GUI
Global $CharSelect
Global $charname
Global $BAGS_TO_USE = 4

GUI()
While 1
    Sleep(500)
WEnd

#Region GUI
Func GUI()
    $GUI = GUICreate("Identifier bot", 115, 90, -1, -1)
    Global $CharLabel = GUICtrlCreateLabel("Select character :", 5, 5, 105, 15)
    Global $CharSelect = GUICtrlCreateCombo("", 5, 25, 105, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
       GUICtrlSetData(-1, GetLoggedCharNames())
    Global $LoadButton = GUICtrlCreateButton("Load", 5, 55, 105, 25)
        GUICtrlSetOnEvent($LoadButton, "_load")

    Global $IdentifyButton = GUICtrlCreateButton("Identify", 5, 25, 50, 25)
        GUICtrlSetState($IdentifyButton, $GUI_HIDE)
        GUICtrlSetOnEvent($IdentifyButton, "_identify")
    Global $SalvageButton = GUICtrlCreateButton("Salvage", 60, 25, 50, 25)
        GUICtrlSetState($SalvageButton, $GUI_HIDE)
        GUICtrlSetOnEvent($SalvageButton, "_salvage")

    Global $SellButton = GUICtrlCreateButton("Sell", 5, 55, 50, 25)
        GUICtrlSetState($SellButton, $GUI_HIDE)
        GUICtrlSetOnEvent($SellButton, "_sell")
    Global $TestButton2 = GUICtrlCreateButton("Test", 60, 55, 50, 25)
        GUICtrlSetState($TestButton2, $GUI_HIDE)
    
    GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
    GUISetState(@SW_SHOW)
EndFunc
#EndRegion GUI

#Region Handlers
Func _load()
    GUICtrlSetState($CharSelect, $GUI_DISABLE)
    $charname = GUICtrlRead($CharSelect)
    If $charname == "" And Initialize(ProcessExists("gw.exe"), True, True) = False Then
        MsgBox(0, "Error", "Guild Wars is not running.")
        Exit
    EndIf
    If Initialize($charname, True, True) = False Then
        MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $charname & "'")
        Exit
    EndIf
    $HWND = GetWindowHandle()

    $charname = GetCharname()
    WinSetTitle($Gui, "", GUICtrlRead($CharSelect))
    $BOT_LOADED = True
    GUICtrlSetData($CharLabel, GUICtrlRead($CharSelect))
    GUICtrlSetState($CharSelect, $GUI_HIDE)
    GUICtrlSetState($LoadButton, $GUI_HIDE)

    GUICtrlSetState($IdentifyButton, $GUI_SHOW)
    GUICtrlSetState($SalvageButton, $GUI_SHOW)
    GUICtrlSetState($SellButton, $GUI_SHOW)
    GUICtrlSetState($TestButton2, $GUI_SHOW)
    SetMaxMemory()
EndFunc
Func ToggleButtons()
    ConsoleWrite("ToggleButtons")
    GUICtrlSetState($IdentifyButton, GUICtrlGetState($IdentifyButton) == $GUI_ENABLE ? $GUI_DISABLE : $GUI_ENABLE)
    GUICtrlSetState($SalvageButton, GUICtrlGetState($SalvageButton) == $GUI_ENABLE ? $GUI_DISABLE : $GUI_ENABLE)
    GUICtrlSetState($SellButton, GUICtrlGetState($SellButton) == $GUI_ENABLE ? $GUI_DISABLE : $GUI_ENABLE)
    GUICtrlSetState($TestButton2, GUICtrlGetState($TestButton2) == $GUI_ENABLE ? $GUI_DISABLE : $GUI_ENABLE)
EndFunc ;ToggleButtons
Func _exit()
    Exit
EndFunc
#EndRegion Handlers

#Region Identification
Func _Identify()
    Local $item, $bag
    
    ConsoleWrite("Identify start")
    ToggleButtons()
    RetrieveIdentificationKit()
    
    For $i = 0 To $BAGS_TO_USE
        $i += 1
        $bag = GetBag($i)
        
		For $j = 1 To DllStructGetData($bag, "slots")
			$item = GetItemBySlot($i, $j)
			If DllStructGetData($item, "Id") == 0 Then ContinueLoop
            IdentifyItem($item) ;hasSleep
            RndSleep(250)
		Next
    Next

    ConsoleWrite("Identify end")
    ToggleButtons()
EndFunc ;Identify
Func RetrieveIdentificationKit()
    If FindIdentificationKit() = 0 Then
        If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
            WithdrawGold(500)
            RndSleep(500)
        EndIf
        Local $j = 0
        Do
            BuySuperiorIdentificationKit()
            RndSleep(500)
            $j = $j + 1
        Until FindIdentificationKit() <> 0 Or $j = 3
        If $j = 3 Then Exit
        RndSleep(500)
    EndIf
EndFunc ;RetrieveIdentificationKit
#EndRegion Identification

#Region Salvage
Func _Salvage()
    Local $item, $bag

    ToggleButtons()
	RetrieveSalvageKit()
	For $i = 1 To $BAGS_TO_USE
		$bag = Getbag($i)

		For $j = 1 To DllStructGetData($bag, 'Slots')
			$item = GetItemBySlot($i, $j)
            StartSalvage($item) ;noSleep
            RndSleep(250)
            SalvageMaterials()
            RndSleep(250)
		Next
    Next
    ToggleButtons()
EndFunc ;Salvage
Func RetrieveSalvageKit()
	If SI_FindSalvageKit() = 0 Then
		If GetGoldCharacter() < 400 And GetGoldStorage() > 399 Then
			WithdrawGold(400)
			RndSleep(500)
		EndIf
		Local $J = 0
		Do
			BuyExpertSalvageKit()
			RndSleep(500)
			$J = $J + 1
		Until SI_FindSalvageKit() <> 0 Or $J = 3
		If $J = 3 Then Exit
		RndSleep(500)
	EndIf
EndFunc ;RetrieveSalvageKit
;Override of GWA2 function because the real one is broken
Func SI_FindSalvageKit()
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 16
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case 2992:
					If DllStructGetData($lItem, 'Value') / 2 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2
						ExitLoop
					EndIf
				Case 2991:
					If DllStructGetData($lItem, 'Value') / 2 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2
						ExitLoop
					EndIf
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc ;SI_FindSalvageKit
#EndRegion Salvage

#Region Sell
Func _Sell()
	Local $item, $bag
    ToggleButtons()
	For $i = 1 To $BAGS_TO_USE
		$bag = Getbag($i)

		For $j = 1 To DllStructGetData($bag, 'Slots')
			$item = GetItemBySlot($i, $j)
			If DllStructGetData($item, "Id") == 0 Then ContinueLoop
            SellItem($item) ;noSleep
            RndSleep(250)
		Next
    Next
    ToggleButtons()
EndFunc ;Sell
#EndRegion Sell
