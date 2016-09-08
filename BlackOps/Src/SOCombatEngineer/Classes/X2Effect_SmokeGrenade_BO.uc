class X2Effect_SmokeGrenade_BO extends X2Effect_SmokeGrenade config(GameData_SoldierSkills);

var config int DenseSmokeBonusDefense;
var config float DenseSmokeBonusRadius;
var config int CombatDrugsBonusOffense;
var config int CombatDrugsBonusCrit;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotMod;
	local XComGameState_Unit SourceUnit;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;

	super.GetToHitAsTargetModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotModifiers);

	if (Target.IsInWorldEffectTile(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Class.Name))
	{
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

		if (SourceUnit.HasSoldierAbility('ShadowOps_DenseSmoke'))
		{
			AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('DenseSmoke');

			ShotMod.ModType = eHit_Success;
			ShotMod.Value = -default.DenseSmokeBonusDefense;
			ShotMod.Reason = AbilityTemplate.LocFriendlyName;
			ShotModifiers.AddItem(ShotMod);
		}
	}
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local XComGameState_Unit SourceUnit;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;

	if (Attacker.IsInWorldEffectTile(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Class.Name))
	{
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

		if (SourceUnit.HasSoldierAbility('ShadowOps_CombatDrugs'))
		{
			AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('CombatDrugs');

			ModInfo.ModType = eHit_Crit;
			ModInfo.Value = default.CombatDrugsBonusCrit;
			ModInfo.Reason = AbilityTemplate.LocFriendlyName;
			ShotModifiers.AddItem(ModInfo);

			ModInfo.ModType = eHit_Success;
			ModInfo.Value = default.CombatDrugsBonusOffense;
			ModInfo.Reason = AbilityTemplate.LocFriendlyName;
			ShotModifiers.AddItem(ModInfo);
		}
	}
}