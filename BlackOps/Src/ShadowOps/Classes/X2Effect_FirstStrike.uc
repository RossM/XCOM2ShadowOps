class X2Effect_FirstStrike extends X2Effect_XModBase;

var int BonusDamage;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	if (Attacker.IsConcealed() && AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef &&
			class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		return BonusDamage;
	}

	return 0;
}

function bool IgnoreSquadsightPenalty(XComGameState_Ability AbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target) 
{ 
	return Attacker.IsConcealed(); 
}

defaultproperties
{
	EffectName = "FirstStrike";
}
