class X2Item_Armor_BO extends X2Item config(GameCore);

var config int ReinforcedVestMitigationChance, ReinforcedVestMitigationAmount;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateReinforcedVest());

	return Templates;
}

static function X2DataTemplate CreateReinforcedVest()
{
	local X2EquipmentTemplate Template;
	
	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'ReinforcedVest');
	Template.ItemCat = 'defense';
	Template.InventorySlot = eInvSlot_Utility;
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Carapace_Armor";
	Template.EquipSound = "StrategyUI_Vest_Equip";

	Template.Abilities.AddItem('ReinforcedVestBonus');

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 25;
	Template.PointsToComplete = 0;
	Template.Tier = 2;
	
	Template.RewardDecks.AddItem('ExperimentalArmorRewards');

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, default.ReinforcedVestMitigationAmount);
	
	return Template;
}
