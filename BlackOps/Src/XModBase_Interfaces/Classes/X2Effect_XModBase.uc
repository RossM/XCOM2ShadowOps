class X2Effect_XModBase extends X2Effect_Persistent;

function bool CannotBeCrit(XComGameState_Ability AbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target) { return false; }
function bool IgnoreSquadsightPenalty(XComGameState_Ability AbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target) { return false; }
function GetFinalToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers);
