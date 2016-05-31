//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_ConditionalBonus.uc
//  AUTHOR:  xylthixlm
//---------------------------------------------------------------------------------------

class XMBEffect_ConditionalBonus extends XMBEffect_Persistent;

struct ExtShotModifierInfo
{
	var ShotModifierInfo ModInfo;
	var name WeaponTech;
	var name Type;
};


/////////////
// Bonuses //
/////////////

var array<ExtShotModifierInfo> Modifiers;	// Modifiers to attacks made by (or at) the unit with the effect

var bool bIgnoreSquadsightPenalty;			// Negates squadsight penalties. Requires XMBEffect_Persistent.


////////////////
// Conditions //
////////////////

var bool bRequireAbilityWeapon;				// Require that the weapon used matches the weapon associated with the ability

var array<X2Condition> SelfConditions;		// Conditions applied to the unit with the effect (usually the shooter)
var array<X2Condition> OtherConditions;		// Conditions applied to the other unit involved (usually the target)


/////////////
// Setters //
/////////////

function AddToHitModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'ToHit';
	Modifiers.AddItem(ExtModInfo);
}	

function AddToHitAsTargetModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'ToHitAsTarget';
	Modifiers.AddItem(ExtModInfo);
}	

function AddDamageModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'Damage';
	Modifiers.AddItem(ExtModInfo);
}	

function AddShredModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'Shred';
	Modifiers.AddItem(ExtModInfo);
}	

function AddArmorPiercingModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'ArmorPiercing';
	Modifiers.AddItem(ExtModInfo);
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

static function name ValidateWeapon(ExtShotModifierInfo ExtModInfo, XComGameState_Item SourceWeapon)
{
	local X2WeaponTemplate WeaponTemplate;

	if (ExtModInfo.WeaponTech != '')
	{
		if (SourceWeapon == none)
			return 'AA_WeaponIncompatible';

		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate == none || WeaponTemplate.WeaponTech != ExtModInfo.WeaponTech)
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

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'Damage')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
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

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'Shred')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
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

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'ArmorPiercing')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
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
	
	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'ToHit')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
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
	
	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'ToHitAsTarget')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
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


/////////////
// Utility //
/////////////

static function float GetWeaponValue(name Type, XComGameState_Item ItemState, out array<ExtShotModifierInfo> TestModifiers)
{
	local float Result;

	local ExtShotModifierInfo ExtModInfo;

	foreach TestModifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != Type)
			continue;

		if (ValidateWeapon(ExtModInfo, ItemState) != 'AA_Success')
			continue;

		Result += ExtModInfo.ModInfo.Value;
	}

	return Result;
}

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local float Result;
	local XComGameState_Item ItemState;
	local ExtShotModifierInfo ExtModInfo;

	if (Modifiers.Find('Type', Tag) == INDEX_NONE)
		return false;

	ItemState = AbilityState.GetSourceWeapon();

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != Tag)
			continue;

		if (ValidateWeapon(ExtModInfo, ItemState) != 'AA_Success')
			continue;

		Result += ExtModInfo.ModInfo.Value;
	}

	TagValue = string(int(Result));
	return true;
}