class X2Effect_Aggression extends X2Effect_Persistent;

function bool AllowCritOverride() { return true; }

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	local X2AbilityToHitCalc_StandardAim StandardHit;

	if (AppliedData.AbilityResultContext.HitResult == eHit_Crit)
	{
		StandardHit = X2AbilityToHitCalc_StandardAim(AbilityState.GetMyTemplate().AbilityToHitCalc);
		if (StandardHit != none && StandardHit.bIndirectFire)
		{
			return 2;
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
	ModInfo.Value = 10 * min(VisibleEnemies, 3);
	ShotModifiers.AddItem(ModInfo);
}

