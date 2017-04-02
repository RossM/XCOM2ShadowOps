class AcademyUnlocks_Hunter extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_Hunter') != INDEX_NONE)
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('DamnGoodGroundUnlock', 'ShadowOps_Hunter', 'ShadowOps_DamnGoodGround'));
	if (class'X2SoldierClass_DefaultClasses'.default.SoldierClasses.Find('ShadowOps_Hunter_LW') != INDEX_NONE)
	{
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddClassUnlock('StalkerUnlock_LW', 'ShadowOps_Hunter_LW', 'ShadowOps_Stalker'));
		Templates.AddItem(class'XMBTemplateUtilities'.static.AddBrigadierUnlock('SurvivalInstinctUnlock_LW', 'ShadowOps_Hunter_LW', 'ShadowOps_SurvivalInstinct'));
	}

	return Templates;
}
