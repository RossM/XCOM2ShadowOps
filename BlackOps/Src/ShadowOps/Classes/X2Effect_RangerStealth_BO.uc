class X2Effect_RangerStealth_BO extends X2Effect_RangerStealth;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState, GremlinState;
	local XComGameState_Item ItemState;
	local StateObjectReference ItemReference;
	local X2EventManager EventManager;
	local XComGameStateHistory History;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none)
	{
		EventManager = `XEVENTMGR;
		History = `XCOMHISTORY;

		// Stealthing the unit itself is done by the superclass

		foreach UnitState.InventoryItems(ItemReference)
		{
			ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectId(ItemReference.ObjectID));
			if (ItemState == none)
				ItemState = XComGameState_Item(History.GetGameStateForObjectId(ItemReference.ObjectID));

			GremlinState = XComGameState_Unit(NewGameState.GetGameStateForObjectId(ItemState.CosmeticUnitRef.ObjectId));
			if (GremlinState == none)
				GremlinState = XComGameState_Unit(History.GetGameStateForObjectId(ItemState.CosmeticUnitRef.ObjectId));

			if (GremlinState != none)
			{
				EventManager.TriggerEvent('EffectEnterUnitConcealment', GremlinState, GremlinState, NewGameState);
			}
		}
	}
}

static private function RemoveConcealment(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed)
{
	local XComGameState_Unit UnitState, GremlinState;
	local XComGameState_Item ItemState;
	local StateObjectReference ItemReference;
	local X2EventManager EventManager;
	local XComGameStateHistory History;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if (UnitState != none)
	{
		EventManager = `XEVENTMGR;
		History = `XCOMHISTORY;

		EventManager.TriggerEvent('EffectBreakUnitConcealment', UnitState, UnitState, NewGameState);

		foreach UnitState.InventoryItems(ItemReference)
		{
			ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectId(ItemReference.ObjectID));
			if (ItemState == none)
				ItemState = XComGameState_Item(History.GetGameStateForObjectId(ItemReference.ObjectID));

			GremlinState = XComGameState_Unit(NewGameState.GetGameStateForObjectId(ItemState.CosmeticUnitRef.ObjectId));
			if (GremlinState == none)
				GremlinState = XComGameState_Unit(History.GetGameStateForObjectId(ItemState.CosmeticUnitRef.ObjectId));

			if (GremlinState != none)
				`XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', GremlinState, GremlinState, NewGameState);
		}
	}
}

defaultproperties
{
	EffectRemovedFn = RemoveConcealment
}