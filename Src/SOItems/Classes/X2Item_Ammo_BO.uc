class X2Item_Ammo_BO extends X2Item config(GameData_WeaponData);

var config int FlechetteDamageModifier, FlechetteHitModifier;
var config int HollowPointCritDamageModifier;
var config int TigerShred;
var config int DepletedEleriumDamageModifier, DepletedEleriumShred;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateFlechetteRounds());
	Templates.AddItem(CreateHollowPointRounds());
	Templates.AddItem(CreateTigerRounds());
	Templates.AddItem(CreateDepletedEleriumRounds());

	return Templates;
}

static function X2AmmoTemplate CreateFlechetteRounds()
{
	local X2AmmoTemplate Template;
	local WeaponDamageValue DamageValue;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'FlechetteRounds');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Flechette_Rounds";
	Template.Abilities.AddItem('FlechetteRounds');
	DamageValue.Damage = default.FlechetteDamageModifier;
	Template.AddAmmoDamageModifier(none, DamageValue);
	Template.TradingPostValue = 10;
	Template.PointsToComplete = 0;
	Template.Tier = 0;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.StartingItem = false;
	Template.CanBeBuilt = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.DamageBonusLabel, , default.FlechetteDamageModifier);

	//FX Reference
	Template.GameArchetype = "Ammo_Flechette.PJ_Flechette";
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('ModularWeapons');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 25;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2DataTemplate CreateHollowPointRounds()
{
	local X2AmmoTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'HollowPointRounds');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Needle_Rounds";
	Template.Abilities.AddItem('HollowPointRounds');
	Template.PointsToComplete = 0;
	Template.Tier = 0;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.CriticalDamageLabel, , default.HollowPointCritDamageModifier);

	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
		
	//FX Reference
	Template.GameArchetype = "Ammo_Talon.PJ_Talon";
	
	return Template;
}

static function X2DataTemplate CreateTigerRounds()
{
	local X2AmmoTemplate Template;
	local WeaponDamageValue DamageValue;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'ShadowOps_TigerRounds');
	Template.strImage = "img:///UILibrary_SOItems.X2InventoryIcons.Inv_Tiger_Rounds";
	DamageValue.Shred = default.TigerShred;
	Template.AddAmmoDamageModifier(none, DamageValue);
	Template.TradingPostValue = 15;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.StartingItem = false;
	Template.CanBeBuilt = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ShredLabel, , default.TigerShred);

	//FX Reference
	Template.GameArchetype = "Ammo_Incendiary.PJ_Incendiary";

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 40;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2DataTemplate CreateDepletedEleriumRounds()
{
	local X2AmmoTemplate Template;
	local WeaponDamageValue DamageValue;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'ShadowOps_DepletedEleriumRounds');
	Template.strImage = "img:///UILibrary_SOItems.X2InventoryIcons.Inv_Depleted_Elerium_Rounds";
	DamageValue.Damage = default.DepletedEleriumDamageModifier;
	DamageValue.Shred = default.DepletedEleriumShred;
	Template.AddAmmoDamageModifier(none, DamageValue);
	Template.TradingPostValue = 30;
	Template.PointsToComplete = 0;
	Template.Tier = 2;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.StartingItem = false;
	Template.CanBeBuilt = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.DamageBonusLabel, , default.DepletedEleriumDamageModifier);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ShredLabel, , default.DepletedEleriumShred);

	//FX Reference
	Template.GameArchetype = "Ammo_Talon.PJ_Talon";

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('Tech_Elerium');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = 10;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}