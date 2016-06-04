class X2Effect_TacticalSense extends X2Effect_Persistent implements(XMBEffectInterface);

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

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	switch (tag)
	{
	case 'Dodge':
		TagValue = string(DodgeModifier);
		return true;
	case 'MaxDodge':
		TagValue = string(MaxDodgeModifier);
		return true;
	}

	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }
