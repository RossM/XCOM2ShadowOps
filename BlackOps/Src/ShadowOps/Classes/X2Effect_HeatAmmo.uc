class X2Effect_HeatAmmo extends XMBEffect_Persistent config(GameData_SoldierSkills);

var config float DamageMultiplier;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float ExtraDamage;
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(TargetDamageable);

	if (TargetUnit != none && TargetUnit.IsRobotic())
	{
		ExtraDamage = CurrentDamage * DamageMultiplier;
	}
	return int(ExtraDamage);
}

defaultproperties
{
	EffectName = "HeatAmmo";
}