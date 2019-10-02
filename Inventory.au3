#include-once
Func CleanInventory()
	Out("Storing Gold Unid")
	StoreGolds(1)
	StoreGolds(2)
	StoreGolds(3)

	Out("Going to merchant")
	GoToNPC(GetNearestNPCToCoords(-19166, 17980))
	RndSleep(550)
	Dialog($THIRD_DIALOG)
	RndSleep(550)

	Out("Ident inventory")
	Identify(1)
	Identify(2)
	Identify(3)

	Out("Sell inventory")
	Sell(1)
	Sell(2)
	Sell(3)
EndFunc ;CleanInventory

#Region Identification
Func Identify($bagIndex)
	Local $bag
	Local $i
	Local $item
	$bag = GetBag($bagIndex)
	For $i = 1 To DllStructGetData($bag, "slots")
		RetrieveIdentificationKit()
		$item = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($item, "Id") = 0 Then ContinueLoop
		IdentifyItem($item)
		RndSleep(500)
	Next
EndFunc ;Identify

Func RetrieveIdentificationKit()
	If FindIdentificationKit() = 0 Then
		If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
			WithdrawGold(500)
			RndSleep(500)
		EndIf
		Local $J = 0
		Do
			If InventoryIsFull() Then SellItem(GetItemBySlot(1, 1))
			BuySuperiorIdentificationKit()
			RndSleep(500)
			$J = $J + 1
		Until FindIdentificationKit() <> 0 Or $J = 3
		If $J = 3 Then MsgBox(0, "Error", "Could not buy an ID Kit") And Exit
		RndSleep(500)
	EndIf
EndFunc ;RetrieveIdentificationKit
#EndRegion Identification

#Region Sell
Func Sell($bagIndex)
	$bag = GetBag($bagIndex)

	For $i = 1 To DllStructGetData($bag, 'slots')
		$item = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($item, 'ID') = 0 Then ContinueLoop
		If CanSell($item) Then SellItem($item)
		RndSleep(250)
	Next
EndFunc ;Sell

Func CanSell($item)
	local $ModelID = DllStructGetData($item, 'ModelID')
	local $extraID = DllStructGetData($item, 'extraId')
	Local $rarity = GetRarity($item)

	If $ModelID = 0 Then Return False
	If $ModelID > 21785 And $ModelID < 21806 Then Return False ;Elite/Normal Tomes
	If $ModelID == $ITEM_DYES Then Return False ;And $ExtraID = $ITEM_EXTRAID_BLACKDYE OR $ExtraID = $ITEM_EXTRAID_WHITEDYE Then Return False
	If $ModelID == $ITEM_ID_BONES Then Return False
	If $ModelID == $ITEM_ID_DUST Then Return False
	If $ModelID == $ITEM_ID_DIESSA Then Return False
	If $ModelID == $ITEM_ID_RIN Then Return False
	If $ModelID == $ITEM_ID_LOCKPICKS Then Return False
	If $rarity == $RARITY_GOLD Then Return False

	Return True
EndFunc ;CanSell
#EndRegion Sell

#Region Storage
Func StoreGolds($bagIndex)
	Local $rarity, $item
	Local $bag = GetBag($bagIndex)
	Local $slots = DllStructGetData($bag, 'slots')

	For $i = 1 To $slots
		$item = GetItemBySlot($bagIndex, $i)
		$rarity = GetRarity($item)

		If StorageIsFull() Then ExitLoop
		If $rarity <> $RARITY_GOLD Then ContinueLoop

		For $bag = 8 To 13 ;Storage panels are form 8 till 16 (I have only standard amount plus aniversary one)
			$slot = FindEmptySlot($bag)
			$slot = @extended
			If $slot <> 0 Then ExitLoop
		Next

		MoveItem($item, $bag, $slot)
		RndSleep(250)
	Next
EndFunc
Func StorageIsFull()
	Local $count = 0
	For $i = 8 To 16
		$bag = GetBag($i)
		$count += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	Next

	Return $count
EndFunc ;StorageIsFull
Func InventoryIsFull()
	Local $count = 0
	For $i = 1 To 3
	   $bag = GetBag($i)
	   $count += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	Next

	Return $count == 0
EndFunc ;InventoryIsFull
Func FindEmptySlot($bag)
	For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
		If DllStructGetData(GetItemBySlot($bag, $slot), 'ID') == 0 Then Return $slot
	Next

	Return 0
EndFunc ;FindEmptySlot
#EndRegion Storage