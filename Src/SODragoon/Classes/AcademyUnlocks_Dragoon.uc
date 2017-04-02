class AcademyUnlocks_Dragoon extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_Dragoon') != INDEX_NONE)
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('TacticalSenseUnlock', 'ShadowOps_Dragoon', 'ShadowOps_TacticalSense'));
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_Dragoon_LW') != INDEX_NONE)
	{
		Templates.AddItem(DigitalWarfare());
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddBrigadierUnlock('ChargeUnlock_LW', 'ShadowOps_Dragoon_LW', 'ShadowOps_Charge'));
	}

	return Templates;
}

static function X2SoldierStatUnlockTemplate DigitalWarfare()
{
	local X2SoldierStatUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierStatUnlockTemplate', Template, 'DigitalWarfareUnlock_LW');

	Template.AllowedClasses.AddItem('ShadowOps_Dragoon_LW');
	Template.BoostStat = eStat_CombatSims;
	Template.BoostMaxValue = 1;
	Template.strImage = "img:///UILibrary_StrategyImages.GTS.GTS_FNG";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = 'ShadowOps_Dragoon_LW';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

