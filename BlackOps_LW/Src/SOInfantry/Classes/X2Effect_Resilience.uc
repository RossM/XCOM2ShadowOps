class X2Effect_Resilience extends XMBEffect_Extended;

function bool CannotBeCrit(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) { return true; }

defaultproperties
{
	EffectName = "Resilience";
}