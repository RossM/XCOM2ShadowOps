class XMBEffect_ConditionalBonus extends XMBEffect_Persistent;


struct ExtShotModifierInfo
{
	var ShotModifierInfo ModInfo;
	var name Tech;
};


/////////////
// Bonuses //
/////////////

var protectedwrite array<ExtShotModifierInfo> ToHitModifiers;
var protectedwrite array<ExtShotModifierInfo> ToHitAsTargetModifiers;
var protectedwrite array<ExtShotModifierInfo> DamageModifiers;
var protectedwrite array<ExtShotModifierInfo> ShredModifiers;
var protectedwrite array<ExtShotModifierInfo> ArmorPiercingModifiers;

var bool bIgnoreSquadsightPenalty;


////////////////
// Conditions //
////////////////

var bool bRequireAbilityWeapon;

var array<X2Condition> SelfConditions;
var array<X2Condition> OtherConditions;


/////////////
// Setters //
/////////////

function AddToHitModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.Tech = WeaponTech;
	ToHitModifiers.AddItem(ExtModInfo);
}	

function AddToHitAsTargetModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.Tech = WeaponTech;
	ToHitAsTargetModifiers.AddItem(ExtModInfo);
}	

function AddDamageModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.Tech = WeaponTech;
	DamageModifiers.AddItem(ExtModInfo);
}	

function AddShredModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.Tech = WeaponTech;
	ShredModifiers.AddItem(ExtModInfo);
}	

function AddArmorPiercingModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.Tech = WeaponTech;
	ArmorPiercingModifiers.AddItem(ExtModInfo);
}	


////////////////////
// Implementation //
////////////////////

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, bool bAsTarget = false)
{
	local X2Condition kCondition;
	local name AvailableCode;

	if (!bAsTarget && bRequireAbilityWeapon && AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
		return 'AA_UnknownError';

	if (!bAsTarget)
	{
		foreach OtherConditions(kCondition)
		{
			AvailableCode = kCondition.AbilityMeetsCondition(AbilityState, Target);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;

			AvailableCode = kCondition.MeetsCondition(Target);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		
			AvailableCode = kCondition.MeetsConditionWithSource(Target, Attacker);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		}

		foreach SelfConditions(kCondition)
		{
			AvailableCode = kCondition.MeetsCondition(Attacker);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		}
	}
	else
	{
		foreach SelfConditions(kCondition)
		{
			AvailableCode = kCondition.AbilityMeetsCondition(AbilityState, Target);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;

			AvailableCode = kCondition.MeetsCondition(Target);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		
			AvailableCode = kCondition.MeetsConditionWithSource(Target, Attacker);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		}

		foreach TargetConditions(kCondition)
		{
			AvailableCode = kCondition.MeetsCondition(Attacker);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		}
	}

	return 'AA_Success';
}

function name ValidateWeapon(ExtShotModifierInfo ExtModInfo, XComGameState_Ability AbilityState)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;

	if (ExtModInfo.Tech != '')
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon == none)
			return 'AA_WeaponIncompatible';

		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate == none || WeaponTemplate.WeaponTech != ExtModInfo.Tech)
			return 'AA_WeaponIncompatible';
	}

	return 'AA_Success';
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local ExtShotModifierInfo ExtModInfo;
	local int BonusDamage;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach DamageModifiers(ExtModInfo)
	{
		if (ValidateWeapon(ExtModInfo, AbilityState) != 'AA_Success')
			continue;

		if ((ExtModInfo.ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ExtModInfo.ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusDamage += ExtModInfo.ModInfo.Value;
		}
	}

	return BonusDamage;
}

function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	local ExtShotModifierInfo ExtModInfo;
	local int BonusShred;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach ShredModifiers(ExtModInfo)
	{
		if (ValidateWeapon(ExtModInfo, AbilityState) != 'AA_Success')
			continue;

		if ((ExtModInfo.ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ExtModInfo.ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusShred += ExtModInfo.ModInfo.Value;
		}
	}

	return BonusShred;
}

function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	local ExtShotModifierInfo ExtModInfo;
	local int BonusArmorPiercing;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach ArmorPiercingModifiers(ExtModInfo)
	{
		if (ValidateWeapon(ExtModInfo, AbilityState) != 'AA_Success')
			continue;

		if ((ExtModInfo.ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ExtModInfo.ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusArmorPiercing += ExtModInfo.ModInfo.Value;
		}
	}

	return BonusArmorPiercing;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ExtShotModifierInfo ExtModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) != 'AA_Success')
		return;
	
	foreach ToHitModifiers(ExtModInfo)
	{
		if (ValidateWeapon(ExtModInfo, AbilityState) != 'AA_Success')
			continue;

		ExtModInfo.ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ExtModInfo.ModInfo);
	}	
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ExtShotModifierInfo ExtModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState, true) != 'AA_Success')
		return;
	
	foreach ToHitAsTargetModifiers(ExtModInfo)
	{
		if (ValidateWeapon(ExtModInfo, AbilityState) != 'AA_Success')
			continue;

		ExtModInfo.ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ExtModInfo.ModInfo);
	}	
}

function bool IgnoreSquadsightPenalty(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) 
{
	if (!bIgnoreSquadsightPenalty)
		return false;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) != 'AA_Success')
		return false;

	return true;
}