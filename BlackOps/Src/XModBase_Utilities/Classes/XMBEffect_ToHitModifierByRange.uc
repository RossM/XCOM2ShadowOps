//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_AddItemChargesBySlot.uc
//  AUTHOR:  xylthixlm
//
//  Adds a to-hit modifier to attacks based on the range between the attacker and the
//  target. This can also check conditions on the attacker and/or target, like
//  XMBEffect_ConditionalBonus does. Usually this is used to add a special range-based
//  bonus to a weapon or ammo, in which case you should set bRequireAbilityWeapon to
//  true.
//
//  USAGE
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBEffect_ToHitModifierByRange extends X2Effect_Persistent;


//////////////////////
// Bonus properties //
//////////////////////

var array<int> RangeAccuracy;
var EAbilityHitResult ModType;


//////////////////////////
// Condition properties //
//////////////////////////

var bool bRequireAbilityWeapon;

var array<X2Condition> AbilityTargetConditions;
var array<X2Condition> AbilityShooterConditions;


////////////////////
// Implementation //
////////////////////

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local int Tiles, Modifier;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) != 'AA_Success')
		return;

	Tiles = Attacker.TileDistanceBetween(Target);

	if (RangeAccuracy.Length > 0)
	{
		if (Tiles < RangeAccuracy.Length)
			Modifier = RangeAccuracy[Tiles];
		else  //  if this tile is not configured, use the last configured tile					
			Modifier = RangeAccuracy[RangeAccuracy.Length-1];
	}

	ModInfo.ModType = ModType;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = Modifier;
	ShotModifiers.AddItem(ModInfo);
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	if (bRequireAbilityWeapon)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon == none)
			return 'AA_UnknownError';

		ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
		if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
			return 'AA_UnknownError';
	}

	foreach AbilityTargetConditions(kCondition)
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

	foreach AbilityShooterConditions(kCondition)
	{
		AvailableCode = kCondition.MeetsCondition(Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	return 'AA_Success';
}

DefaultProperties
{
	ModType = eHit_Success
}