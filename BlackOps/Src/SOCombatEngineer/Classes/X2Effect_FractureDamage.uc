class X2Effect_FractureDamage extends X2Effect_Persistent implements(XMBEffectInterface) config(GameData_SoldierSkills);

var int CritModifier;

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

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;

	if (AbilityState.GetMyTemplateName() == 'ShadowOps_Fracture')
	{
		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = CritModifier;
		ShotModifiers.AddItem(ModInfo);
	}
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	switch (tag)
	{
	case 'Crit':
		TagValue = string(CritModifier);
		return true;
	}

	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }
