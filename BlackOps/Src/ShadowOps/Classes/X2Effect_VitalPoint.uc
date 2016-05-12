class X2Effect_VitalPoint extends X2Effect_Persistent config(GameData_SoldierSkills);

var config int BonusArmorPiercing;
var config int BonusCritChance;
var config int ConventionalBonusDamage, MagneticBonusDamage, BeamBonusDamage;
var config int ConventionalBonusShred, MagneticBonusShred, BeamBonusShred;

function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
		return BonusArmorPiercing;
	return 0;	
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;

	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = BonusCritChance;
		ShotModifiers.AddItem(ModInfo);
	}
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	local int Result;

	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef &&
			class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		SourceWeapon = AbilityState.GetSourceWeapon();

		if (SourceWeapon != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				Result = default.ConventionalBonusDamage;
					
				if (WeaponTemplate.WeaponTech == 'magnetic')
					Result = default.MagneticBonusDamage;
				else if (WeaponTemplate.WeaponTech == 'beam')
					Result = default.BeamBonusDamage;
			}
		}
	}

	return Result;
}

function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	local int Result;

	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();

		if (SourceWeapon != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				Result = default.ConventionalBonusShred;
					
				if (WeaponTemplate.WeaponTech == 'magnetic')
					Result = default.MagneticBonusShred;
				else if (WeaponTemplate.WeaponTech == 'beam')
					Result = default.BeamBonusShred;
			}
		}
	}

	return Result;
}
