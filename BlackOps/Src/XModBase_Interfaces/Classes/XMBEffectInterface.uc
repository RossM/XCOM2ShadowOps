interface XMBEffectInterface;

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue);
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers);

function bool GetExtValue(LWTuple Data);
