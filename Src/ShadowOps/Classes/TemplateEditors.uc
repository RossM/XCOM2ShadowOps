// This is an Unreal Script
class TemplateEditors extends Object config(GameCore);

var config array<name> SuppressionBlockedAbilities;
var config array<name> WeaponCostAbilities;
var config array<name> SquadsightAbilities;
var config array<name> LWClasses;

static function EditTemplates()
{
	AddAllSuppressionConditions();
	ChangeAllToWeaponActionPoints();
	ChangeAllToSquadsight();

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

static function ChangeToWeaponActionPoints(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local int i;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		for (i = 0; i < Template.AbilityCosts.Length; i++)
		{
			if (Template.AbilityCosts[i].IsA('X2AbilityCost_ActionPoints'))
			{
				ActionPointCost = new class'XMBAbilityCost_ActionPoints'(Template.AbilityCosts[i]);
				ActionPointCost.iNumPoints = 0;
				ActionPointCost.bAddWeaponTypicalCost = true;
				Template.AbilityCosts[i] = ActionPointCost;
			}
		}
	}
}

static function ChangeAllToWeaponActionPoints()
{
	local name DataName;

	foreach default.WeaponCostAbilities(DataName)
	{
		`Log("ShadowOps: ChangeToWeaponActionPoints" @ DataName);
		ChangeToWeaponActionPoints(DataName);
	}
}

static function ChangeToSquadsight(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2Condition_Visibility				VisibilityCondition;
	local int i;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		for (i = 0; i < Template.AbilityTargetConditions.Length; i++)
		{
			if (Template.AbilityTargetConditions[i].IsA('X2Condition_Visibility'))
			{
				VisibilityCondition = new class'X2Condition_Visibility'(Template.AbilityTargetConditions[i]);
				VisibilityCondition.bAllowSquadsight = true;
				Template.AbilityTargetConditions[i] = VisibilityCondition;
			}
		}
	}
}

static function ChangeAllToSquadsight()
{
	local name DataName;

	foreach default.SquadsightAbilities(DataName)
	{
		`Log("ShadowOps: ChangeToSquadsight" @ DataName);
		ChangeToSquadsight(DataName);
	}
}
