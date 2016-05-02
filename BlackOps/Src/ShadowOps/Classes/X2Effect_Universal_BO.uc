class X2Effect_Universal_BO extends X2Effect_XModBase config(GameCore);

var localized string LowHitChanceCritModifier;

var config float MinimumHitChanceForNoCritPenalty;
var config float HitChanceCritPenaltyScale;

function GetFinalToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local float FinalAdjust;

	FinalAdjust = (default.MinimumHitChanceForNoCritPenalty - ShotBreakdown.ResultTable[eHit_Success]) * default.HitChanceCritPenaltyScale;
	FinalAdjust = min(FinalAdjust, ShotBreakdown.ResultTable[eHit_Crit]);

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = LowHitChanceCritModifier;
	ModInfo.Value = -int(FinalAdjust);
	ShotModifiers.AddItem(ModInfo);
}


defaultproperties
{
	EffectName = "ShadowOps_UniversalEffect";
}