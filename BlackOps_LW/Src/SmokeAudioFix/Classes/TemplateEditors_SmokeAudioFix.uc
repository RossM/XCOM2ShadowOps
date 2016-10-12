class TemplateEditors_SmokeAudioFix extends object;

static function EditTemplates()
{
	UpgradeAbilityVisualization('LaunchGrenade');
}

static function UpgradeAbilityVisualization(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.BuildVisualizationFn = class'X2Ability_BO'.static.TypicalAbility_BuildVisualization;
	}
}
