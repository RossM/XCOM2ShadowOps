class X2Effect_BonusItemCharges extends X2Effect_Persistent;

var array<EInventorySlot> ApplyToSlots;
var int PerItemBonus;

// This effect adds additional charges to inventory items, similar to how Heavy Ordnance gives an
// extra use of the grenade in the grenade-only slot. You can either set the ApplyToSlots and 
// PerItemBonus for simple uses, or override GetItemChargeModifier() to do more complex things like
// only give extra uses to certain items.
//
// To use this effect, create an ability with AbilityTargetStyle set to X2AbilityTarget_Self and 
// add this effect to the AbilityTargetEffects. Note that this doesn't go through the normal effect
// code because determining item charges happens before init-play effects are applied, so any
// AbilityShooterConditions or AbilityTargetConditions set on the effect will be ignored.
function int GetItemChargeModifier(XComGameState NewGameState, XComGameState_Unit NewUnit, XComGameState_Item ItemIter)
{
	if (ApplyToSlots.Find(ItemIter.InventorySlot) != INDEX_NONE)
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