class X2Item_CaselessAmmo extends X2Item config(ShadowOps);

var config int ClipSize;
var config array<name> ExcludeWeapon;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreateCaselessAmmo());
	
	return Items;
}

static function X2AmmoTemplate CreateCaselessAmmo()
{
	local X2AmmoTemplate BaseTemplate;
	local X2AmmoTemplate_ShadowOps Template;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', BaseTemplate, 'CaselessAmmo');
	Template = new class'X2AmmoTemplate_ShadowOps'(BaseTemplate);
	Template.strImage = "img:///UILibrary_SOItems.Inv_Caseless_Ammo";
	Template.bInfiniteItem = true;
	Template.StartingItem = true;
	Template.Tier = 0;
	Template.EquipSound = "StrategyUI_Ammo_Equip";

	Template.ModClipSize = default.ClipSize;
	Template.AllowedWeaponCat.AddItem('rifle');
	Template.ExcludeWeapon = default.ExcludeWeapon;

	//FX Reference
	Template.GameArchetype = "Ammo_AP.PJ_AP";
	
	return Template;
}
