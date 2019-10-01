#include-once

Global Enum $RARITY_White = 0x3D, $RARITY_Blue = 0x3F, $RARITY_Purple = 0x42, $RARITY_Gold = 0x40, $RARITY_Green = 0x43

Func SellItemToMerchant()
	Out("Storing Gold Unid")
	StoreGolds()
	Sleep(Random(450, 550))
	Out("Going to merchant")
	$merchant = GetNearestNPCToCoords(-19166, 17980)
	Sleep(Random(450, 550))
	GoToNPC($merchant)
	Dialog($THIRD_DIALOG)
	Sleep(Random(450, 550))
	Out("Ident inventory")
	Ident(1)
	Ident(2)
	Out("Sell inventory")
	Sell(1)
	Sell(2)
EndFunc  ;==>SellItemToMerchant

;Buys IDKit if necessary and identify items
Func Ident($bagIndex)
	$bag = GetBag($bagIndex)
	For $i = 1 To DllStructGetData($bag, 'slots')
		If FindIdentificationKit() = 0 Then
			If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
				WithdrawGold(500)
				Sleep(Random(200, 300))
			EndIf
			local $J = 0
			Do
				BuySuperiorIdentificationKit()
				Sleep(Random(450, 550))
				$J = $J+1
			Until FindIdentificationKit() <> 0 OR $J = 3
			If $J = 3 Then ExitLoop
			RndSleep(500)
		EndIf
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') = 0 Then ContinueLoop
		IdentifyItem($aitem)
		Sleep(Random(400, 750))
	Next
 EndFunc   ;==>IDENT

;Sells items
Func Sell($bagIndex)
	$bag = GetBag($bagIndex)
	$numOfSlots = DllStructGetData($bag, 'slots')
	For $i = 1 To $numOfSlots
		Out("Selling item: " & $bagIndex & ", " & $i)
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') = 0 Then ContinueLoop
		If CanSell($aitem) Then
			SellItem($aitem)
		EndIf
		RndSleep(250)
	Next
 EndFunc   ;==>Sell

;Returns wether an item can be sold
Func CanSell($aitem)
	local $ModelID = DllStructGetData($aitem, 'ModelID')
	local $ExtraID = DllStructGetData($aitem, 'extraId')

	If $ModelID = 0 Then Return False
	If $ModelID > 21785 And $ModelID < 21806 Then Return False ;Elite/Normal Tomes
	If $ModelID = $ITEM_DYES Then Return False ;And $ExtraID = $ITEM_EXTRAID_BLACKDYE OR $ExtraID = $ITEM_EXTRAID_WHITEDYE Then Return False
	If $ModelID =  $ITEM_ID_BONES Then Return False
	If $ModelID =  $ITEM_ID_DUST Then Return False
	If $ModelID =  $ITEM_ID_DIESSA Then Return False
	If $ModelID =  $ITEM_ID_RIN Then Return False
	If $ModelID =  $ITEM_ID_LOCKPICKS Then Return False

	Return True
EndFunc   ;==>CanSell

Func StoreGolds()
	GoldIs(1, 20)
	GoldIs(2, 5)
	GoldIs(3, 10)
 EndFunc

Func GoldIs($bagIndex, $numOfSlots)
	For $i = 1 To $numOfSlots
		$aItem = GetItemBySlot($bagIndex, $i)
		ConsoleWrite("Checking items: " & $bagIndex & ", " & $i & @CRLF & DllStructGetData(GetExtraItemInfo($aItem), 'rarity') & @crlf)
		If DllStructGetData($aItem, 'ID') <> 0 And DllStructGetData(GetExtraItemInfo($aItem), 'rarity') = $RARITY_Gold Then
				Do
					For $bag = 8 To 12; Storage panels are form 8 till 16 (I have only standard amount plus aniversary one)
						$slot = FindEmptySlot($bag)
						$slot = @extended
						If $slot <> 0 Then
							$FULL = False
							$nSlot = $slot
							ExitLoop 2; finding first empty $slot in $bag and jump out
						Else
							$FULL = True; no empty slots :(
						EndIf
						Sleep(400)
					Next
				Until $FULL = True
				If $FULL = False Then
					MoveItem($aItem, $bag, $nSlot)
					ConsoleWrite("Gold item moved ...."& @CRLF)
					Sleep(Random(450, 550))
				EndIf
		EndIf
	Next
 EndFunc   ;==>GoldIs

Func CheckIfInventoryIsFull()
   return CountSlots() = 0
 EndFunc   ;==>CheckIfInventoryIsFull

Func CountSlots()
	Local $bag
	Local $count = 0
	For $i = 1 To 2
	   $bag = GetBag($i)
	   $count += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	Next

	Return $count
 EndFunc   ;==>CountSlots


Global $lItemExtraStruct = DllStructCreate( _ ; haha obsolete and wrong^^
		"byte rarity;" & _  ;Display Color $RARITY_White = 0x3D, $RARITY_Blue = 0x3F, $RARITY_Purple = 0x42, $RARITY_Gold = 0x40, $RARITY_Green = 0x43
		"byte unknown1[3];" & _
		"byte modifier;" & _ ;Display Mods (hex values): 30 = Display first mod only (Insignia, 31 = Insignia + "of" Rune, 32 = Insignia + [Rune], 33 = ...
		"byte unknown2[13];" & _ ;[13]
		"byte lastModifier")
Global $lItemExtraStructPtr = DllStructGetPtr($lItemExtraStruct)
Global $lItemExtraStructSize = DllStructGetSize($lItemExtraStruct)
Func GetExtraItemInfo($aitem)
    If IsDllStruct($aitem) = 0 Then $aAgent = GetItemByItemID($aitem)
    $lItemExtraPtr = DllStructGetData($aitem, "namestring")

    DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
    Return $lItemExtraStruct
EndFunc   ;==>GetExtraItemInfo

Func FindEmptySlot($bagIndex) ;Parameter = bag index to start searching from. Returns integer with item slot. This function also searches the storage. If any of the returns = 0, then no empty slots were found
	Local $lItemInfo, $aSlot

	For $aSlot = 1 To DllStructGetData(GetBag($bagIndex), 'Slots')
		Sleep(40)
		ConsoleWrite("Checking: " & $bagIndex & ", " & $aSlot & @CRLF)
		$lItemInfo = GetItemBySlot($bagIndex, $aSlot)
		If DllStructGetData($lItemInfo, 'ID') = 0 Then
			ConsoleWrite($bagIndex & ", " & $aSlot & "  <-Empty! " & @CRLF)
			SetExtended($aSlot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc   ;==>FindEmptySlot