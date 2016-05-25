class XMBEffect_PersistentBonus extends X2Effect_Persistent;

var protectedwrite array<ShotModifierInfo> ToHitModifiers;
var protectedwrite array<ShotModifierInfo> ToHitAsTargetModifiers;
var protectedwrite array<ShotModifierInfo> DamageModifiers;

var bool bRequireAbilityWeapon, bReactionFireOnly;
var array<ECoverType> AllowedCoverTypes;

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

function private bool ValidAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, bool bAsTarget = false)
{
	local GameRulesCache_VisibilityInfo VisInfo;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim StandardAim;

	if (!bAsTarget && bRequireAbilityWeapon && AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
		return false;

	if (AllowedCoverTypes.Length > 0)
	{
		if (Target == none)
			return false;
		if (!`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo))
			return false;
		if (AllowedCoverTypes.Find(VisInfo.TargetCover) == INDEX_NONE)
			return false;
	}

	if (bReactionFireOnly)
	{
		AbilityTemplate = AbilityState.GetMyTemplate();
		StandardAim = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);
		if (StandardAim == none || !StandardAim.bReactionFire)
			return false;
	}

	return true;
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local ShotModifierInfo ModInfo;
	local int BonusDamage;

	if (!ValidAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState))
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

	if (!ValidAttack(EffectState, Attacker, Target, AbilityState))
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

	if (!ValidAttack(EffectState, Attacker, Target, AbilityState, true))
		return;
	
	foreach ToHitAsTargetModifiers(ModInfo)
	{
		ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ModInfo);
	}	
}

