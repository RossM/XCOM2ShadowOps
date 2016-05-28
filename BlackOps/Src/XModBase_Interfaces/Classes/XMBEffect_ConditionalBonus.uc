class XMBEffect_ConditionalBonus extends XMBEffect_Persistent;


/////////////
// Bonuses //
/////////////

var protectedwrite array<ShotModifierInfo> ToHitModifiers;
var protectedwrite array<ShotModifierInfo> ToHitAsTargetModifiers;
var protectedwrite array<ShotModifierInfo> DamageModifiers;

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

function AddToHitModifier(int Value, optional EAbilityHitResult ModType = eHit_Success)
{
	local ShotModifierInfo ModInfo;

	ModInfo.ModType = ModType;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = Value;
	ToHitModifiers.AddItem(ModInfo);
}	

function AddToHitAsTargetModifier(int Value, optional EAbilityHitResult ModType = eHit_Success)
{
	local ShotModifierInfo ModInfo;

	ModInfo.ModType = ModType;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = Value;
	ToHitAsTargetModifiers.AddItem(ModInfo);
}	

function AddDamageModifier(int Value, optional EAbilityHitResult ModType = eHit_Success)
{
	local ShotModifierInfo ModInfo;

	ModInfo.ModType = ModType;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = Value;
	DamageModifiers.AddItem(ModInfo);
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

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local ShotModifierInfo ModInfo;
	local int BonusDamage;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach DamageModifiers(ModInfo)
	{
		if ((ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusDamage += ModInfo.Value;
		}
	}

	return BonusDamage;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) != 'AA_Success')
		return;
	
	foreach ToHitModifiers(ModInfo)
	{
		ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ModInfo);
	}	
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState, true) != 'AA_Success')
		return;
	
	foreach ToHitAsTargetModifiers(ModInfo)
	{
		ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ModInfo);
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