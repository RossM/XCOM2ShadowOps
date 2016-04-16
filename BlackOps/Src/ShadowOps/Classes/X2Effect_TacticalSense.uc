class X2Effect_TacticalSense extends X2Effect_Persistent;

var int DodgeModifier, MaxDodgeModifier;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local float VisibleEnemies;

	VisibleEnemies = class'X2TacticalVisibilityHelpers'.static.GetNumVisibleEnemyTargetsToSource(Target.ObjectId,,class'X2TacticalVisibilityHelpers'.default.LivingGameplayVisibleFilter);

	ModInfo.ModType = eHit_Graze;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = min(DodgeModifier * VisibleEnemies, MaxDodgeModifier);
	ShotModifiers.AddItem(ModInfo);
}

