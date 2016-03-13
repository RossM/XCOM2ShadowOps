class X2Effect_VitalPoint extends X2Effect_Persistent;

var int BonusArmorPiercing;
var int BonusCritChance;
var int BonusDamage;
var int BonusDamagePerTier;
var int BonusShred;
var int BonusShredPerTier;

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

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	local int Result;

	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		Result += BonusDamage;

		SourceWeapon = AbilityState.GetSourceWeapon();

		if (SourceWeapon != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				Result += BonusDamagePerTier * WeaponTemplate.Tier / 2;
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
		Result += BonusShred;

		SourceWeapon = AbilityState.GetSourceWeapon();

		if (SourceWeapon != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				Result += BonusShredPerTier * WeaponTemplate.Tier / 2;
			}
		}
	}

	return Result;
}
