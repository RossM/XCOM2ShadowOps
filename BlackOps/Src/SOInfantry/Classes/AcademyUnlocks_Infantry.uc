class AcademyUnlocks_Infantry extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_Infantry') != INDEX_NONE)
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('AdrenalineSurgeUnlock', 'ShadowOps_Infantry', 'ShadowOps_AdrenalineSurge'));
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_Infantry_LW') != INDEX_NONE)
	{
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('AdrenalineSurgeUnlock_LW', 'ShadowOps_Infantry_LW', 'ShadowOps_AdrenalineSurge'));
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddBrigadierUnlock('AgainstTheOddsUnlock_LW', 'ShadowOps_Infantry_LW', 'ShadowOps_AgainstTheOdds'));
	}

	return Templates;
}
