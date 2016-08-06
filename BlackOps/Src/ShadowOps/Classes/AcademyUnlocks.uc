class AcademyUnlocks extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	Templates.AddItem(AddClassUnlock('PackmasterUnlock', 'ShadowOps_CombatEngineer', 'ShadowOps_Packmaster'));
	Templates.AddItem(AddClassUnlock('DamnGoodGroundUnlock', 'ShadowOps_Hunter', 'ShadowOps_DamnGoodGround'));
	Templates.AddItem(AddClassUnlock('AdrenalineSurgeUnlock', 'ShadowOps_Infantry', 'ShadowOps_AdrenalineSurge'));
	Templates.AddItem(AddClassUnlock('TacticalSenseUnlock', 'ShadowOps_Dragoon', 'ShadowOps_TacticalSense'));

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
