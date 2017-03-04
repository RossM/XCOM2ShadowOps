class X2Effect_GrantReserveActionPoint extends X2Effect;

var name ImmediateActionPoint;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (TargetUnit != none && ImmediateActionPoint != '')
	{
		TargetUnit.ReserveActionPoints.AddItem(ImmediateActionPoint);
	}
}