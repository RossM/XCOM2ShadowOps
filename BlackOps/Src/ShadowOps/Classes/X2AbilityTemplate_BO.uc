class X2AbilityTemplate_BO extends X2AbilityTemplate;

var EInventorySlot ApplyToWeaponSlot;

function InitAbilityForUnit(XComGameState_Ability AbilityState, XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	super.InitAbilityForUnit(AbilityState, UnitState, NewGameState);

	if (ApplyToWeaponSlot != eInvSlot_Unknown)
	{
		CurrentInventory = UnitState.GetAllInventoryItems(NewGameState);

		foreach CurrentInventory(InventoryItem)
		{
			if (InventoryItem.bMergedOut)
				continue;
			if (InventoryItem.InventorySlot == ApplyToWeaponSlot)
			{
				AbilityState.SourceWeapon = InventoryItem.GetReference();
				break;
			}
		}
	}
}

defaultproperties
{
	ApplyToWeaponSlot = eInvSlot_Unknown;
}