class X2Ability_AWC extends X2Ability
	config(GameData_SoldierSkills);

var config int HipFireHitModifier;
var config int HipFireCooldown;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(HipFire());

	return Templates;
}
