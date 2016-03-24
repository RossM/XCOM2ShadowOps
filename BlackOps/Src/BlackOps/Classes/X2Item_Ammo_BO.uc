class X2Item_Ammo_BO extends X2Item config(GameData_WeaponData);

var config int FlechetteDamageModifier, FlechetteHitModifier;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateFlechetteRounds());

	return Templates;
}

static function X2AmmoTemplate CreateFlechetteRounds()
{
	local X2AmmoTemplate Template;
	local WeaponDamageValue DamageValue;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'FlechetteRounds');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Stiletto_Rounds";
	Template.Abilities.AddItem('FlechetteRounds');
	DamageValue.Damage = default.FlechetteDamageModifier;
	Template.AddAmmoDamageModifier(none, DamageValue);
	Template.TradingPostValue = 30;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.StartingItem = true;
	Template.CanBeBuilt = false;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.DamageBonusLabel, , default.FlechetteDamageModifier);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.AimLabel, eStat_Offense, default.FlechetteHitModifier);

	//FX Reference
	Template.GameArchetype = "Ammo_Stiletto.PJ_Stiletto";
	
	return Template;
}

