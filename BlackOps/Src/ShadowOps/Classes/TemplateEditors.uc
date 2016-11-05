// This is an Unreal Script
class TemplateEditors extends Object config(GameCore);

var config array<name> SuppressionBlockedAbilities;
var config array<name> LWClasses;

static function EditTemplates()
{
	AddAllSuppressionConditions();

	KillLongWarDead();
}

static function KillLongWarDead()
{
	local name TemplateName;
	local array<X2DataTemplate> AllTemplates;
	local X2DataTemplate Template;
	local X2SoldierClassTemplate SoldierClassTemplate;
	local X2SoldierClassTemplateManager SoldierClassManager;

	SoldierClassManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();

	foreach default.LWClasses(TemplateName)
	{
		SoldierClassManager.FindDataTemplateAllDifficulties(TemplateName, AllTemplates);
		foreach AllTemplates(Template)
		{
			SoldierClassTemplate = X2SoldierClassTemplate(Template);

			SoldierClassTemplate.NumInForcedDeck = 0;
			SoldierClassTemplate.NumInDeck = 0;
		}
	}
}

// --- Tactical ---

static function AddSuppressionCondition(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2Condition							Condition;
	local X2Condition_UnitEffects				ExcludeEffectsCondition;
	local bool									bDoEdit;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		bDoEdit = true;
		foreach Template.AbilityShooterConditions(Condition)
		{
			ExcludeEffectsCondition = X2Condition_UnitEffects(Condition);
			if (ExcludeEffectsCondition != none && ExcludeEffectsCondition.ExcludeEffects.Find('EffectName', class'X2Effect_Suppression'.default.EffectName) != INDEX_NONE)
			{
				bDoEdit = false;
				break;
			}
		}

		if (!bDoEdit)
			continue;

		ExcludeEffectsCondition = new class'X2Condition_UnitEffects';
		ExcludeEffectsCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
		Template.AbilityShooterConditions.AddItem(ExcludeEffectsCondition);
	}
}

static function AddAllSuppressionConditions()
{
	local name DataName;

	foreach default.SuppressionBlockedAbilities(DataName)
	{
		`Log("ShadowOps: AddSuppressionCondition" @ DataName);
		AddSuppressionCondition(DataName);
	}
}

