class X2Effect_FractureDamage extends X2Effect_Persistent config(GameData_SoldierSkills);

var config int ConventionalBonusShred, MagneticBonusShred, BeamBonusShred;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local X2WeaponTemplate WeaponTemplate;
	local float ExtraDamage;

	if (AbilityState.GetMyTemplateName() == 'ShadowOps_Fracture')
	{
		//  only add bonus damage on a crit
		if (AppliedData.AbilityResultContext.HitResult == eHit_Crit)
		{
			WeaponTemplate = X2WeaponTemplate(AbilityState.GetSourceWeapon().GetMyTemplate());
			if (WeaponTemplate != none)
			{
				ExtraDamage = WeaponTemplate.BaseDamage.Crit;
			}
		}
	}
	return int(ExtraDamage);
}

function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{

	local X2WeaponTemplate WeaponTemplate;
	local float ExtraShred;

	if (AbilityState.GetMyTemplateName() == 'ShadowOps_Fracture')
	{
		WeaponTemplate = X2WeaponTemplate(AbilityState.GetSourceWeapon().GetMyTemplate());
		if (WeaponTemplate != none)
		{
			ExtraShred = default.ConventionalBonusShred;

			if (WeaponTemplate.WeaponTech == 'magnetic')
				ExtraShred = default.MagneticBonusShred;
			else if (WeaponTemplate.WeaponTech == 'beam')
				ExtraShred = default.BeamBonusShred;
		}
	}
	return int(ExtraShred);
}