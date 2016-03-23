class X2Effect_Resilience extends X2Effect_Persistent;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = -100;
	ShotModifiers.AddItem(ModInfo);
}