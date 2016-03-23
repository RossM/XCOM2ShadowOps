class X2Effect_FractureDamage extends X2Effect_Persistent config(GameData_SoldierSkills);

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	local X2WeaponTemplate WeaponTemplate;
	local float ExtraDamage;

	if (AbilityState.GetMyTemplateName() == 'Fracture')
	{
		//  only add bonus damage on a crit
		if (AppliedData.AbilityResultContext.HitResult == eHit_Crit)
		{
			WeaponTemplate = X2WeaponTemplate(AbilityState.GetSourceWeapon().GetMyTemplate());
			if (WeaponTemplate != none)
			{
				ExtraDamage = 2;

				if (WeaponTemplate.WeaponTech == 'magnetic')
					ExtraDamage = 4;
				else if (WeaponTemplate.WeaponTech == 'beam')
					ExtraDamage = 6;
			}
		}
	}
	return int(ExtraDamage);
}

function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{

	local X2WeaponTemplate WeaponTemplate;
	local float ExtraShred;

	if (AbilityState.GetMyTemplateName() == 'Fracture')
	{
		WeaponTemplate = X2WeaponTemplate(AbilityState.GetSourceWeapon().GetMyTemplate());
		if (WeaponTemplate != none)
		{
			ExtraShred = 2;

			if (WeaponTemplate.WeaponTech == 'magnetic')
				ExtraShred = 3;
			else if (WeaponTemplate.WeaponTech == 'beam')
				ExtraShred = 4;
		}
	}
	return int(ExtraShred);
}