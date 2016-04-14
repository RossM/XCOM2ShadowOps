class X2Effect_Resilience extends X2Effect_XModBase;

function bool CannotBeCrit(XComGameState_Ability AbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target) { return true; }

defaultproperties
{
	EffectName = "Resilience";
}