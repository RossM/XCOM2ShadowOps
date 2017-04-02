class X2Effect_Aggression extends X2Effect_Persistent implements(XMBEffectInterface) config(GameData_SoldierSkills);

var int CritModifier, MaxCritModifier;
var int GrenadeCritDamage;

function bool AllowCritOverride() { return true; }

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local X2AbilityToHitCalc_StandardAim StandardHit;

	if (AppliedData.AbilityResultContext.HitResult == eHit_Crit)
	{
		StandardHit = X2AbilityToHitCalc_StandardAim(AbilityState.GetMyTemplate().AbilityToHitCalc);
		if (StandardHit != none && StandardHit.bIndirectFire)
		{
			return GrenadeCritDamage;
		}
	}
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local float VisibleEnemies;

	VisibleEnemies = class'X2TacticalVisibilityHelpers'.static.GetNumVisibleEnemyTargetsToSource(Attacker.ObjectId,,class'X2TacticalVisibilityHelpers'.default.LivingGameplayVisibleFilter);

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = min(CritModifier * VisibleEnemies, MaxCritModifier);
	ShotModifiers.AddItem(ModInfo);
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	switch (tag)
	{
	case 'Crit':
		TagValue = string(CritModifier);
		return true;
	case 'MaxCrit':
		TagValue = string(MaxCritModifier);
		return true;
	}

	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }
