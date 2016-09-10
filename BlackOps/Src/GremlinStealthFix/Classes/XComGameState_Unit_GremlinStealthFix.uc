class XComGameState_Unit_GremlinStealthFix extends XComGameState_Unit;

function SetCosmeticUnitConcealment(XComGameState NewGameState, bool bConcealment)
{
	local XComGameState_Unit CosmeticUnitState;
	local XComGameState_Item ItemState;
	local StateObjectReference ItemReference;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach InventoryItems(ItemReference)
	{
		ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectId(ItemReference.ObjectID));
		if (ItemState == none)
			ItemState = XComGameState_Item(History.GetGameStateForObjectId(ItemReference.ObjectID));

		CosmeticUnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectId(ItemState.CosmeticUnitRef.ObjectId));
		if (CosmeticUnitState == none)
			CosmeticUnitState = XComGameState_Unit(History.GetGameStateForObjectId(ItemState.CosmeticUnitRef.ObjectId));

		if (CosmeticUnitState != none)
		{
			CosmeticUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', CosmeticUnitState.ObjectID));
			CosmeticUnitState.SetIndividualConcealment(bConcealment, NewGameState);
			NewGameState.AddStateObject(CosmeticUnitState);
		}
	}
}

function EnterConcealmentNewGameState(XComGameState NewGameState)
{
	super.EnterConcealmentNewGameState(NewGameState);

	SetCosmeticUnitConcealment(NewGameState, true);
}

function BreakConcealmentNewGameState(XComGameState NewGameState, optional XComGameState_Unit ConcealmentBreaker, optional bool UnitWasFlanked)
{
	super.BreakConcealmentNewGameState(NewGameState, ConcealmentBreaker, UnitWasFlanked);

	SetCosmeticUnitConcealment(NewGameState, false);
}
