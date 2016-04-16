class X2Effect_PersistentBonus extends X2Effect_Persistent;

var array<ShotModifierInfo> ToHitModifiers;
var array<ShotModifierInfo> ToHitAsTargetModifiers;
var int BonusDamage;
var bool bRequireAbilityWeapon;

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
	ModInfo.Value = Value;
	ToHitAsTargetModifiers.AddItem(ModInfo);
}	

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	if (bRequireAbilityWeapon && AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
		return 0;

	return BonusDamage;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;

	if (bRequireAbilityWeapon && AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
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

	foreach ToHitAsTargetModifiers(ModInfo)
	{
		ModInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ModInfo);
	}	
}

