class X2Effect_Evasive extends X2Effect_Persistent implements(XMBEffectInterface);

var bool HandledOnPostTemplatesCreated;

// From XMBEffectInterface
function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }

// From XMBEffectInterface
function bool GetExtValue(LWTuple Tuple)
{
	local array<name> AbilityNames;
	local name Ability;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;
	local X2Condition Condition;
	local X2Condition_UnitEffects EffectsCondition;

	if (Tuple.id != 'OnPostTemplatesCreated')
		return false;

	if (HandledOnPostTemplatesCreated)
		return false;

	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityMgr.GetTemplateNames(AbilityNames);

	foreach AbilityNames(Ability)
	{
		AbilityTemplate = AbilityMgr.FindAbilityTemplate(Ability);

		if (AbilityTemplate.Hostility != eHostility_Offensive)
			continue;

		if (AbilityTemplate.AbilityMultiTargetStyle == none)
			continue;

		EffectsCondition = none;

		// Modify multitarget conditions
		if (AbilityTemplate.AbilityMultiTargetConditions.Length > 0)
		{
			foreach AbilityTemplate.AbilityMultiTargetConditions(Condition)
			{
				EffectsCondition = X2Condition_UnitEffects(Condition);
				if (EffectsCondition != none)
					break;
			}

			if (EffectsCondition == none)
			{
				EffectsCondition = new class'X2Condition_UnitEffects';
				AbilityTemplate.AbilityMultiTargetConditions.AddItem(EffectsCondition);
			}

			if (EffectsCondition.ExcludeEffects.Find('EffectName', EffectName) == INDEX_NONE)
			{
				EffectsCondition.AddExcludeEffect(EffectName, 'AA_UnitIsImmune');
			}
		}
		else
		{
			// If there are no multitarget conditions, target conditions are used instead.
			foreach AbilityTemplate.AbilityTargetConditions(Condition)
			{
				EffectsCondition = X2Condition_UnitEffects(Condition);
				if (EffectsCondition != none)
					break;
			}

			if (EffectsCondition == none)
			{
				EffectsCondition = new class'X2Condition_UnitEffects';
				AbilityTemplate.AbilityTargetConditions.AddItem(EffectsCondition);
			}

			if (EffectsCondition.ExcludeEffects.Find('EffectName', EffectName) == INDEX_NONE)
			{
				EffectsCondition.AddExcludeEffect(EffectName, 'AA_UnitIsImmune');
			}
		}
	}

	HandledOnPostTemplatesCreated = true;
	return true;
}

defaultproperties
{
	EffectName = "Evasive"
}