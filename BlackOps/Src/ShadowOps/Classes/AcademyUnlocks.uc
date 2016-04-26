class AcademyUnlocks extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	Templates.AddItem(PackmasterUnlock());
	Templates.AddItem(DamnGoodGroundUnlock());
	Templates.AddItem(AdrenalineSurgeUnlock());
	Templates.AddItem(TacticalSenseUnlock());

	return Templates;
}

static function X2SoldierAbilityUnlockTemplate PackmasterUnlock()
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'PackmasterUnlock');

	Template.AllowedClasses.AddItem('ShadowOps_CombatEngineer');
	Template.AbilityName = 'Packmaster';
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_FNG";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = 'ShadowOps_CombatEngineer';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2SoldierAbilityUnlockTemplate DamnGoodGroundUnlock()
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'DamnGoodGroundUnlock');

	Template.AllowedClasses.AddItem('ShadowOps_Hunter');
	Template.AbilityName = 'DamnGoodGround';
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_FNG";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = 'ShadowOps_Hunter';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2SoldierAbilityUnlockTemplate AdrenalineSurgeUnlock()
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'AdrenalineSurgeUnlock');

	Template.AllowedClasses.AddItem('ShadowOps_Infantry');
	Template.AbilityName = 'AdrenalineSurge';
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_FNG";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = 'ShadowOps_Infantry';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2SoldierAbilityUnlockTemplate TacticalSenseUnlock()
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, 'TacticalSenseUnlock');

	Template.AllowedClasses.AddItem('ShadowOps_Dragoon');
	Template.AbilityName = 'TacticalSense';
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_FNG";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = 'ShadowOps_Dragoon';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}
