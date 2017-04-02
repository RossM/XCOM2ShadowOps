class X2Effect_FlechetteRounds extends XMBEffect_ToHitModifierByRange;

var int ArmorAccuracyBonus;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	super.GetToHitModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotModifiers);

	if (ShotModifiers.Length > 0)
	{
		ShotModifiers[0].Value += ArmorAccuracyBonus * Target.GetMaxStat(eStat_ArmorMitigation);
	}
}