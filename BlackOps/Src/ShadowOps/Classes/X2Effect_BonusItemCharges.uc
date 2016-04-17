class X2Effect_BonusItemCharges extends X2Effect_Persistent;

var array<EInventorySlot> ApplyToSlots;
var int PerItemBonus;

// This effect adds additional charges to inventory items, similar to how Heavy Ordnance gives an extra use
// of the grenade in the grenade-only slot. You can either set the ApplyToSlots and PerItemBonus for simple
// uses, or override GetItemChargeModifier() to do more complex things like only give extra uses to certain items.
//
// To use this effect, create an ability with AbilityTargetStyle set to X2AbilityTarget_Self and add this
// effect to the AbilityTargetEffects.

function int GetItemChargeModifier(XComGameState NewGameState, XComGameState_Unit NewUnit, XComGameState_Item ItemIter)
{
	if (ApplyToSlots.Find(ItemIter.InventorySlot) >= 0)
	{
		return PerItemBonus * ItemIter.MergedItemCount;
	}

	return 0;
}

defaultproperties
{
	EffectName = "BonusItemCharges";
	PerItemBonus = 1;
}