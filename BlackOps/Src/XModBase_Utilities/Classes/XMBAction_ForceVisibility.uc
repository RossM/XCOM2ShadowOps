//---------------------------------------------------------------------------------------
//  FILE:    XMBAction_ForceVisibility.uc
//  AUTHOR:  xylthixlm
//
//  This visualization action simply sets a unit to be visible until its visibility
//  is next updated.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBAction_ForceVisibility extends X2Action;

var bool bEnableOutline;

simulated state Executing
{
Begin:
	Unit.SetForceVisibility(bEnableOutline ? eForceVisible : eForceNone);
	UnitPawn.UpdatePawnVisibility();

	CompleteAction();
}