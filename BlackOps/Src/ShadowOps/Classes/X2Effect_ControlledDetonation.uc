class X2Effect_ControlledDetonation extends X2Effect_Persistent implements(XMBEffectInterface);

var float ReductionAmount;

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being modified.
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being modified.

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local X2Effect_ApplyWeaponDamage ApplyDamageEffect;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	ApplyDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
	if (ApplyDamageEffect == none || !ApplyDamageEffect.bExplosiveDamage)
		return 0;

	return -int(CurrentDamage * ReductionAmount);
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local name AvailableCode;

	AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	return 'AA_Success';
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	if (tag != 'DamageReductionPercent')
		return false;

	TagValue = int(ReductionAmount * 100) $ "%";
	return true;
}

function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }
function bool GetExtValue(LWTuple Data) { return false; }
 