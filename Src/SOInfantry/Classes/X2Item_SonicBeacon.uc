class X2Item_SonicBeacon extends X2Item config(GameData_SoldierSkills);

var config float SONICBEACON_RANGE, SONICBEACON_ISOUNDRANGE, SONICBEACON_IENVIRONMENTDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Items;

    Items.AddItem(CreateSonicBeacon());

	return Items;
}

static function X2GrenadeTemplate CreateSonicBeacon()
{
	local X2GrenadeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'SonicBeacon');

	Template.WeaponCat = 'Utility';
    Template.ItemCat = 'Utility';

	Template.iRange = default.SONICBEACON_RANGE;
    Template.iRadius = default.SONICBEACON_ISOUNDRANGE;
    Template.iSoundRange = default.SONICBEACON_ISOUNDRANGE;
    Template.iEnvironmentDamage = default.SONICBEACON_IENVIRONMENTDAMAGE;
	Template.iClipSize = 0;
	Template.Tier = 1;

	Template.Abilities.AddItem('ShadowOps_ThrowSonicBeacon');

	Template.GameArchetype = "WP_Grenade_BattleScanner.WP_Grenade_BattleScanner";
	// Template.OnThrowBarkSoundCue = 'SmokeGrenade';

	Template.CanBeBuilt = false;

	return Template;
}
