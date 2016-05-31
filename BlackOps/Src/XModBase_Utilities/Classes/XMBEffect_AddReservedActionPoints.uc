class XMBEffect_AddReservedActionPoints extends X2Effect;

var name ReserveType;       //  type of action point to reserve
var int NumPoints;          //  number of points to reserve

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;
	local int i;
	
	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if (TargetUnitState == none)
		return;

	for (i = 0; i < NumPoints; ++i)
	{
		TargetUnitState.ReserveActionPoints.AddItem(ReserveType);
	}
}

DefaultProperties
{
	NumPoints = 1
}