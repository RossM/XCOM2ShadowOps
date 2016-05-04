class X2Action_UpdateTracked extends X2Action;

var bool bEnableOutline;

simulated state Executing
{
Begin:
	Unit.SetForceVisibility(bEnableOutline ? eForceVisible : eForceNone);
	UnitPawn.UpdatePawnVisibility();

	CompleteAction();
}