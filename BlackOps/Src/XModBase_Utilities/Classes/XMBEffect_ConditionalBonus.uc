//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_ConditionalBonus.uc
//  AUTHOR:  xylthixlm
//
//  This class provides an easy way of creating passive effects that give bonuses based
//  on some condition. Build up the modifiers you want to add using AddToHitModifier
//  and related functions, and set the conditions for them by adding an X2Condition to
//  SelfConditions or OtherConditions. This class takes care of validating the
//  conditions and applying the modifiers. You can also define different modifiers
//  based on the tech tier of the weapon or other item used. Ability tags are
//  automatically defined for each modifier.
//
//  EXAMPLES
//
//  +4 damage against flanked targets:
//    CoverTypeCondition = new class'XMBCondition_CoverType';
//    CoverTypeCondition.AllowedCoverTypes.AddItem(CT_NONE);
//    ConditionalBonusEffect = new class'XMBEffect_ConditionalBonus';
//    ConditionalBonusEffect.OtherConditions.AddItem(CoverTypeCondition);
//    ConditionalBonusEffect.AddDamageModifier(4);
//
//  +100 dodge against reaction fire:
//    ReactionFireCondition = new class'XMBCondition_ReactionFire';
//    ConditionalBonusEffect = new class'XMBEffect_ConditionalBonus';
//    ConditionalBonusEffect.SelfConditions.AddItem(ReactionFireCondition);
//    ConditionalBonusEffect.AddToHitAsTargetModifier(100, eHit_Graze);
//
//  +10/15/20 crit chance based on weapon tech:
//    ConditionalBonusEffect = new class'XMBEffect_ConditionalBonus';
//    ConditionalBonusEffect.AddToHitModifier(10, eHit_Crit, 'conventional');
//    ConditionalBonusEffect.AddToHitModifier(15, eHit_Crit, 'magnetic');
//    ConditionalBonusEffect.AddToHitModifier(20, eHit_Crit, 'beam');
//---------------------------------------------------------------------------------------

class XMBEffect_ConditionalBonus extends XMBEffect_Extended;

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

var bool bIgnoreSquadsightPenalty;			// Negates squadsight penalties. Requires XMBEffect_Extended.


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
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	if (!bAsTarget && bRequireAbilityWeapon)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon == none)
			return 'AA_UnknownError';

		ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
		if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
			return 'AA_UnknownError';
	}

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

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) == 'AA_Success')
	{	
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
	
	super.GetToHitModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotModifiers);	
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ExtShotModifierInfo ExtModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState, true) == 'AA_Success')
	{
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
	
	super.GetToHitAsTargetModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotModifiers);	
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

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local float Result;
	local array<float> TechResults;
	local XComGameState_Item ItemState;
	local ExtShotModifierInfo ExtModInfo;
	local int ValidModifiers, ValidTechModifiers;
	local EAbilityHitResult HitResult;
	local float ResultMultiplier;
	local int idx;

	ResultMultiplier = 1;
	TechResults.Length = class'X2ItemTemplateManager'.default.WeaponTechCategories.Length;

	switch (Tag)
	{
	case 'ToHit':				Tag = 'ToHit';			HitResult = eHit_Success;							break;
	case 'ToHitAsTarget':		Tag = 'ToHitAsTarget';	HitResult = eHit_Success;							break;
	case 'Defense':				Tag = 'ToHitAsTarget';	HitResult = eHit_Success;	ResultMultiplier = -1;	break;
	case 'Damage':				Tag = 'Damage';			HitResult = eHit_Success;							break;
	case 'Shred':				Tag = 'Shred';			HitResult = eHit_Success;							break;
	case 'ArmorPiercing':		Tag = 'ArmorPiercing';	HitResult = eHit_Success;							break;
	case 'Crit':				Tag = 'ToHit';			HitResult = eHit_Crit;								break;
	case 'CritDefense':			Tag = 'ToHitAsTarget';	HitResult = eHit_Crit;		ResultMultiplier = -1;	break;
	case 'CritDamage':			Tag = 'Damage';			HitResult = eHit_Crit;								break;
	case 'CritShred':			Tag = 'Shred';			HitResult = eHit_Crit;								break;
	case 'CritArmorPiercing':	Tag = 'ArmorPiercing';	HitResult = eHit_Crit;								break;
	case 'Graze':				Tag = 'ToHit';			HitResult = eHit_Graze;								break;
	case 'Dodge':				Tag = 'ToHitAsTarget';	HitResult = eHit_Graze;								break;
	case 'GrazeDamage':			Tag = 'Damage';			HitResult = eHit_Graze;								break;
	case 'GrazeShred':			Tag = 'Shred';			HitResult = eHit_Graze;								break;
	case 'GrezeArmorPiercing':	Tag = 'ArmorPiercing';	HitResult = eHit_Graze;								break;
	case 'MissDamage':			Tag = 'Damage';			HitResult = eHit_Miss;								break;
	case 'MissShred':			Tag = 'Shred';			HitResult = eHit_Miss;								break;
	case 'MissArmorPiercing':	Tag = 'ArmorPiercing';	HitResult = eHit_Miss;								break;

	default:
		return false;
	}

	if (Modifiers.Find('Type', Tag) == INDEX_NONE)
		return false;

	if (AbilityState != none)
	{
		ItemState = AbilityState.GetSourceWeapon();
	}

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != Tag)
			continue;

		if (ExtModInfo.ModInfo.ModType != HitResult)
			continue;

		idx = class'X2ItemTemplateManager'.default.WeaponTechCategories.Find(ExtModInfo.WeaponTech);
		if (idx != INDEX_NONE)
		{
			TechResults[idx] += ExtModInfo.ModInfo.Value;
			ValidTechModifiers++;
		}

		if (ValidateWeapon(ExtModInfo, ItemState) != 'AA_Success')
			continue;

		ValidModifiers++;

		Result += ExtModInfo.ModInfo.Value;
	}

	if (ValidModifiers == 0 && ValidTechModifiers > 0)
	{
		TagValue = "";
		for (idx = 0; idx < TechResults.Length && idx < 3; idx++)  // HACK
		{
			if (idx > 0) TagValue $= "/";
			TagValue $= string(int(TechResults[idx] * ResultMultiplier));
		}
		return true;
	}

	if (ValidModifiers == 0)
		return false;

	TagValue = string(int(Result * ResultMultiplier));
	return true;
}