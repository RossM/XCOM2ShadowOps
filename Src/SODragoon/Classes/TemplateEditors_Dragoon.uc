class TemplateEditors_Dragoon extends Object config(GameCore);

static function EditTemplates()
{
	local name DataName;

	`Log("TemplateEditors_Dragoon.EditTemplates");

	// Puppeteer
	foreach class'X2Ability_DragoonAbilitySet'.default.PuppeteerAbilityNames(DataName)
	{
		`Log("SODragoon: Editing" @ DataName);
		EditHaywire(DataName);
	}
}

static function EditHaywire(name AbilityName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local array<X2AbilityTemplate>		TemplateAllDifficulties;
	local X2AbilityTemplate				Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.AbilityCooldown = new class'X2AbilityCooldown_HaywireProtocol'(Template.AbilityCooldown);
	}
}
