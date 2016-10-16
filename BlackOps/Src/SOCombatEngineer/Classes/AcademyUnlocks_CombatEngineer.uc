class AcademyUnlocks_CombatEngineer extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_CombatEngineer') != INDEX_NONE)
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('PackmasterUnlock', 'ShadowOps_CombatEngineer', 'ShadowOps_Packmaster'));
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_CombatEngineer_LW') != INDEX_NONE)
	{
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('PackmasterUnlock_LW', 'ShadowOps_CombatEngineer_LW', 'ShadowOps_Packmaster'));
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddBrigadierUnlock('ExtraMunitionsUnlock_LW', 'ShadowOps_CombatEngineer_LW', 'ShadowOps_ExtraMunitions'));
	}

	return Templates;
}
