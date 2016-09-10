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

// Evil hack
static function SetAbilityTargetEffects(X2AbilityTemplate Template, out array<X2Effect> TargetEffects)
{
	Template.AbilityTargetEffects = TargetEffects;
}

defaultproperties
{
	ApplyToWeaponSlot = eInvSlot_Unknown;
}