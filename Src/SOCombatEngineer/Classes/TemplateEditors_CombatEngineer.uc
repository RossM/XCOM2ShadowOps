// This is an Unreal Script
class TemplateEditors_CombatEngineer extends Object config(GameCore);

var config array<name> GrenadeAbilities;

static function EditTemplates()
{
	local name DataName;

	`Log("TemplateEditors_CombatEngineer.EditTemplates");

	// Smoke and Mirrors, Fastball
	foreach default.GrenadeAbilities(DataName)
	{
		`Log("SOCombatEngineer: Editing" @ DataName);
		AddPostActivationEvent(DataName, 'GrenadeUsed');
	}

	foreach class'X2AbilityCost_GrenadeActionPoints'.default.SmokeGrenadeTemplates(DataName)
	{
		`Log("SOCombatEngineer: Editing" @ DataName);
		AddCombatDrugsEffect(DataName);
	}		
}

static function AddPostActivationEvent(name AbilityName, name EventName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local array<X2AbilityTemplate>		TemplateAllDifficulties;
	local X2AbilityTemplate				Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		if (Template.PostActivationEvents.Find(EventName) == INDEX_NONE)
			Template.PostActivationEvents.AddItem(EventName);
	}
}

static function AddCombatDrugsEffect(name ItemName)
{
	local X2ItemTemplateManager		ItemManager;
	local array<X2DataTemplate>		TemplateAllDifficulties;
	local X2DataTemplate			Template;
	local X2GrenadeTemplate			GrenadeTemplate;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		GrenadeTemplate = X2GrenadeTemplate(Template);
		// Note: Not idempotent!
		GrenadeTemplate.ThrownGrenadeEffects.AddItem(class'X2Ability_EngineerAbilitySet'.static.CombatDrugsEffect());
		GrenadeTemplate.LaunchedGrenadeEffects.AddItem(class'X2Ability_EngineerAbilitySet'.static.CombatDrugsEffect());
	}
}