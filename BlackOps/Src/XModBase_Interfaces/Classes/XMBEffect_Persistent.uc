class XMBEffect_Persistent extends X2Effect_Persistent;

// This class adds some extra methods to X2Effect_Persistent which can be overridden in a
// subclass to create new effects.

// If true, the unit with this effect is immune to critical hits.
function bool CannotBeCrit(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) { return false; }

// If true, the unit with this effect doesn't take penalties to hit and crit chance for using 
// squadsight.
function bool IgnoreSquadsightPenalty(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) { return false; }

// This function can add new hit modifiers after all other hit calculations are done. Importantly,
// it gets access to the complete shot breakdown so far, so it can inspect the chance of a hit, 
// chance of a graze, etc. For example, it could apply a penalty to graze chance based on the total
// hit chance.
//
// Since this applies after all other modifiers, including the modifier that zeroes out critical
// hit chance on shots that can't crit, it can do things like add critical hit chance to reaction 
// shots, or graze chance to shots with a 100% hit chance.
//
// If there are multiple effects with GetFinalToHitModifiers on a unit, they all get the same 
// breakdown, so they won't see the effects of other GetFinalToHitModifiers overrides.
function GetFinalToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers);

// Luck gives a final chance to affect the to-hit chance of a unit in a way that doesn't show up in
// the shot breakdown the player sees, exactly like the aim assist bonuses that players get on
// lower difficulty levels. After the results of a shot are determined, luck is added to the
// overall hit chance, and the roll is compared against hit chance + luck. If the comparison gives
// the same result as the unmodified hit chance, the original result is kept. If the comparison
// gives a different result, the shot becomes either a miss or a standard hit. (Yes, luck can turn
// a shot with a 100% crit chance into a normal hit.)
//
// Please use this sparingly.
function int GetLuckModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, EAbilityHitResult Result) { return 0; }
