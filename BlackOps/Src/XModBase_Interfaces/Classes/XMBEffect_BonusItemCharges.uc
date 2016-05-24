class XMBEffect_BonusItemCharges extends X2Effect;

var array<EInventorySlot> ApplyToSlots;
var int PerItemBonus;

// This effect adds additional charges to inventory items, similar to how Heavy Ordnance gives an
// extra use of the grenade in the grenade-only slot. You can either set the ApplyToSlots and 
// PerItemBonus for simple uses, or override GetItemChargeModifier() to do more complex things like
// only give extra uses to certain items.
function int GetItemChargeModifier(XComGameState NewGameState, XComGameState_Unit NewUnit, XComGameState_Item ItemIter)
{
	if (ApplyToSlots.Find(ItemIter.InventorySlot) != INDEX_NONE)
	{
		return PerItemBonus * ItemIter.MergedItemCount;
	}

	return 0;
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit NewUnit;
	local XComGameState_Item ItemState;
	local XComGameStateHistory History;
	local int i, modifier;

	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	History = `XCOMHISTORY;

	for (i = 0; i < NewUnit.InventoryItems.Length; ++i)
	{
		ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(NewUnit.InventoryItems[i].ObjectID));
		if (ItemState == none)
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(NewUnit.InventoryItems[i].ObjectID));
		if (ItemState != none && !ItemState.bMergedOut)
		{
			modifier = GetItemChargeModifier(NewGameState, NewUnit, ItemState);
			if (modifier != 0)
			{
				ItemState = XComGameState_Item(NewGameState.CreateStateObject(ItemState.Class, ItemState.ObjectID));
				ItemState.Ammo += modifier;
				NewGameState.AddStateObject(ItemState);
			}
		}
	}
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

defaultproperties
{
	PerItemBonus = 1;
}