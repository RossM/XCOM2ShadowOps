class X2AbilityTemplate_BO extends X2AbilityTemplate;

var EInventorySlot ApplyToWeaponSlot;
var name ApplyToWeaponCat;

function InitAbilityForUnit(XComGameState_Ability AbilityState, XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2WeaponTemplate WeaponTemplate;

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

	if (ApplyToWeaponCat != '')
	{
		CurrentInventory = UnitState.GetAllInventoryItems(NewGameState);

		foreach CurrentInventory(InventoryItem)
		{
			if (InventoryItem.bMergedOut)
				continue;

			WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
			if (WeaponTemplate == none)
				continue;

			if (WeaponTemplate.WeaponCat == ApplyToWeaponCat)
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