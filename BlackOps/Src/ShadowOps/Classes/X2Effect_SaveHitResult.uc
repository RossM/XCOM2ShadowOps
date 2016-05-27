class X2Effect_SaveHitResult extends X2Effect;

var name HitResultValueName, CalculatedHitChanceValueName;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit NewUnit;
	
	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	NewUnit.SetUnitFloatValue(default.HitResultValueName, ApplyEffectParameters.AbilityResultContext.HitResult);
	NewUnit.SetUnitFloatValue(default.CalculatedHitChanceValueName, ApplyEffectParameters.AbilityResultContext.CalculatedHitChance);
}

defaultproperties
{
	HitResultValueName = "LastHitResult"
	CalculatedHitChanceValueName = "LastCalculatedHitChance"
}