class AcademyUnlocks_CombatEngineer extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_CombatEngineer') != INDEX_NONE)
		Templates.AddItem(AddClassUnlock('PackmasterUnlock', 'ShadowOps_CombatEngineer', 'ShadowOps_Packmaster'));
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_CombatEngineer_LW') != INDEX_NONE)
	{
		Templates.AddItem(AddClassUnlock('PackmasterUnlock_LW', 'ShadowOps_CombatEngineer_LW', 'ShadowOps_Packmaster'));
		Templates.AddItem(AddBrigadierUnlock('ExtraMunitionsUnlock_LW', 'ShadowOps_CombatEngineer_LW', 'ShadowOps_ExtraMunitions'));
	}

	return Templates;
}

static function X2SoldierAbilityUnlockTemplate AddClassUnlock(name DataName, name ClassName, name AbilityName, string Image = "img:///UILibrary_StrategyImages.GTS.GTS_FNG")
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, DataName);

	Template.AllowedClasses.AddItem(ClassName);
	Template.AbilityName = AbilityName;
	Template.strImage = Image;

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = ClassName;
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2SoldierAbilityUnlockTemplate AddBrigadierUnlock(name DataName, name ClassName, name AbilityName, string Image = "img:///UILibrary_StrategyImages.GTS.GTS_FNG")
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, DataName);

	Template.AbilityName = AbilityName;
	Template.strImage = Image;

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 8;
	Template.Requirements.RequiredSoldierClass = ClassName;
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 150;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}
