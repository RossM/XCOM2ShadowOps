//---------------------------------------------------------------------------------------
//  FILE:    X2Effect_SlugShot.uc
//  AUTHOR:  xylthixlm
//---------------------------------------------------------------------------------------
class X2Effect_SlugShot extends X2Effect_Persistent config(GameData_WeaponData);


//////////////////////
// Bonus properties //
//////////////////////

var config array<int> HitBonus, CritBonus;	


//////////////////////////
// Condition properties //
//////////////////////////

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being modified.
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being modified.


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

	if (HitBonus.Length > 0)
	{
		if (Tiles < HitBonus.Length)
			Modifier = HitBonus[Tiles];
		else  //  if this tile is not configured, use the last configured tile					
			Modifier = HitBonus[HitBonus.Length-1];

		ModInfo.ModType = eHit_Success;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = Modifier;
		ShotModifiers.AddItem(ModInfo);
	}

	if (CritBonus.Length > 0)
	{
		if (Tiles < CritBonus.Length)
			Modifier = CritBonus[Tiles];
		else  //  if this tile is not configured, use the last configured tile					
			Modifier = CritBonus[CritBonus.Length-1];

		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = Modifier;
		ShotModifiers.AddItem(ModInfo);
	}
}

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	// Change attacks on objects from auto-hit to auto-crit
	if (TargetUnit == none && CurrentResult == eHit_Success)
	{
		NewHitResult = eHit_Crit;
		return true;
	}

	return false;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local name AvailableCode;

	AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	return 'AA_Success';
}