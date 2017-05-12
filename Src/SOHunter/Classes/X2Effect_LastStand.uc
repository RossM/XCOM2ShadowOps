class X2Effect_LastStand extends XMBEffect_Extended;

function bool PreDeathCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	UnitState.SetCurrentStat(eStat_HP, 1);
	return true;
}

function bool PreBleedoutCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	return PreDeathCheck(NewGameState, UnitState, EffectState);
}

function OnPostTemplatesCreated()
{
	local array<name> AbilityNames;
	local name Ability;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;
	local X2Effect Effect;

	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityMgr.GetTemplateNames(AbilityNames);

	foreach AbilityNames(Ability)
	{
		AbilityTemplate = AbilityMgr.FindAbilityTemplate(Ability);

		foreach AbilityTemplate.AbilityShooterEffects(Effect)
		{
			ModifyEffect(Effect);
		}

		foreach AbilityTemplate.AbilityTargetEffects(Effect)
		{
			ModifyEffect(Effect);
		}

		foreach AbilityTemplate.AbilityMultiTargetEffects(Effect)
		{
			ModifyEffect(Effect);
		}

	}
}

function ModifyEffect(X2Effect Effect)
{
	local X2Condition Condition;
	local X2Condition_UnitEffects EffectsCondition;

	if (!Effect.bIsImpairing && !Effect.bIsImpairingMomentarily)
		return;

	foreach Effect.TargetConditions(Condition)
	{
		EffectsCondition = X2Condition_UnitEffects(Condition);
		if (EffectsCondition != none)
			return;
	}

	if (EffectsCondition == none)
	{
		EffectsCondition = new class'X2Condition_UnitEffects';
		Effect.TargetConditions.AddItem(EffectsCondition);
	}

	if (EffectsCondition.ExcludeEffects.Find('EffectName', EffectName) == INDEX_NONE)
	{
		EffectsCondition.AddExcludeEffect(EffectName, 'AA_UnitIsImmune');
	}
}

defaultproperties
{
	EffectName = "LastStand"
}