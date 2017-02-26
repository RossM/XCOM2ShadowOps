class TemplateEditors_Hunter extends Object config(GameCore);

static function EditTemplates()
{
	`Log("TemplateEditors_Hunter.EditTemplates");

	AddAllDisabledConditions();
}

static function AddAllDisabledConditions()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<name>							TemplateNames;
	local name									AbilityName;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2Condition							Condition;
	local X2Condition_UnitEffects				ExcludeEffectsCondition;
	local bool									bDoEdit, bShouldDisable;
	local X2AbilityTrigger						Trigger;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	AbilityManager.GetTemplateNames(TemplateNames);
	foreach TemplateNames(AbilityName)
	{
		AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
		foreach TemplateAllDifficulties(Template)
		{
			bDoEdit = true;
			bShouldDisable = false;

			// Only disable player input triggered abilities
			foreach Template.AbilityTriggers(Trigger)
			{
				if (Trigger.IsA('X2AbilityTrigger_PlayerInput'))
				{
					bShouldDisable = true;
					break;
				}
			}

			// Only disable non-melee abilities
			if (Template.AbilityToHitCalc != none && Template.AbilityToHitCalc.Isa('X2AbilityToHitCalc_StandardMelee'))
				bShouldDisable = false;

			// Don't disable certain basic abilities
			switch (AbilityName)
			{
			case 'StandardMove':
			case 'Reload':
			case 'HunkerDown':
				bShouldDisable = false;
				break;
			}

			if (!bShouldDisable)
				continue;

			foreach Template.AbilityShooterConditions(Condition)
			{
				ExcludeEffectsCondition = X2Condition_UnitEffects(Condition);

				if (ExcludeEffectsCondition != none)
				{
					if (ExcludeEffectsCondition.ExcludeEffects.Find('EffectName', class'X2Ability_HunterAbilitySet'.default.DisabledName) != INDEX_NONE)
					{
						bDoEdit = false;
						break;
					}
				}
			}

			if (!bDoEdit)
				continue;

			ExcludeEffectsCondition = new class'X2Condition_UnitEffects';
			ExcludeEffectsCondition.AddExcludeEffect(class'X2Ability_HunterAbilitySet'.default.DisabledName, 'AA_UnitIsImpaired');
			Template.AbilityShooterConditions.AddItem(ExcludeEffectsCondition);
		}
	}
}

