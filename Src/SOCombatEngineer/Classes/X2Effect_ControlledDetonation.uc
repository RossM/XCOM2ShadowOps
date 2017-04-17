class X2Effect_ControlledDetonation extends X2Effect_Persistent implements(XMBEffectInterface);

var bool HandledOnPostTemplatesCreated;

// From XMBEffectInterface
function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }

// From XMBEffectInterface
function bool GetExtValue(LWTuple Tuple)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;

	if (Tuple.id != 'OnPostTemplatesCreated')
		return false;

	if (HandledOnPostTemplatesCreated)
		return false;

	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityMgr.FindAbilityTemplate('ThrowGrenade');
	AbilityTemplate.AbilityMultiTargetConditions.AddItem(new class'X2Condition_ControlledDetonation');
	AbilityTemplate = AbilityMgr.FindAbilityTemplate('LaunchGrenade');
	AbilityTemplate.AbilityMultiTargetConditions.AddItem(new class'X2Condition_ControlledDetonation');

	HandledOnPostTemplatesCreated = true;
	return true;
}