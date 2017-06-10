class X2Effect_HeavyHitter extends XMBEffect_Extended;

var int BonusDamage, BonusDamageOverTime;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;

	if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
		return 0;

	// Damage preview doesn't fill out the EffectRef, so skip this check if there's no EffectRef
	if (AppliedData.EffectRef.SourceTemplateName != '')
	{
		WeaponDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
		if (WeaponDamageEffect == none || WeaponDamageEffect.bIgnoreBaseDamage)
			return BonusDamageOverTime;
	}

	return BonusDamage;
}

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) 
{
	if (Tag == 'Damage')
	{
		TagValue = string(BonusDamage);
		return true;
	}
	else if (Tag == 'DamageOverTime')
	{
		TagValue = string(BonusDamageOverTime);
		return true;
	}
 
	return false; 
}
