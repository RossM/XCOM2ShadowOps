class X2Effect_XModBase extends X2Effect_Persistent;

function bool CannotBeCrit(XComGameState_Ability AbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target) { return false; }
function bool IgnoreSquadsightPenalty(XComGameState_Ability AbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target) { return false; }
