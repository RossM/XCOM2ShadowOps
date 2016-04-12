class X2ItemOverrides_BO extends X2Item config(GameData_WeaponData);

// This class replaces some items from the base game with modified versions.

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateKevlarArmor());
	Templates.AddItem(CreateFlashbangGrenade());
	Templates.AddItem(CreateSmokeGrenade());
	Templates.AddItem(SmokeGrenadeMk2());
	Templates.AddItem(CreateNanoScaleVest());
	Templates.AddItem(CreatePlatedVest());

	return Templates;
}

// This function causes templates defined in this file to replace the base game templates with the same name.
static event array<X2DataTemplate> CreateTemplatesEvent()
{
	local array<X2DataTemplate> NewTemplates;
	local int Index;
	local X2ItemTemplateManager ItemManager;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	NewTemplates = super.CreateTemplatesEvent();

	for( Index = 0; Index < NewTemplates.Length; ++Index )
	{
		ItemManager.AddItemTemplate(X2ItemTemplate(NewTemplates[Index]), true);
	}

	NewTemplates.Length = 0;
	return NewTemplates;
}

static function X2DataTemplate CreateKevlarArmor()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'KevlarArmor');
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Kevlar_Armor";
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.ArmorTechCat = 'conventional';
	Template.Tier = 0;
	Template.AkAudioSoldierArmorSwitch = 'Conventional';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, 0, true);

	return Template;
}

static function X2DataTemplate CreateFlashbangGrenade()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'FlashbangGrenade');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons..Inv_Flashbang_Grenade";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");
	Template.iRange = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_RANGE;
	Template.iRadius = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_RADIUS;
	
	Template.bFriendlyFire = false;
	Template.bFriendlyFireWarning = false;
	Template.Abilities.AddItem('ThrowGrenade');

	Template.ThrownGrenadeEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect());

	//We need to have an ApplyWeaponDamage for visualization, even if the grenade does 0 damage (makes the unit flinch, shows overwatch removal)
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.ThrownGrenadeEffects.AddItem(WeaponDamageEffect);

	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	
	Template.GameArchetype = "WP_Grenade_Flashbang.WP_Grenade_Flashbang";

	Template.StartingItem = true;
	Template.CanBeBuilt = false;

	Template.iSoundRange = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = 10;
	Template.PointsToComplete = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_IPOINTS;
	Template.iClipSize = class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_ICLIPSIZE;
	Template.Tier = 0;

	// Soldier Bark
	Template.OnThrowBarkSoundCue = 'ThrowFlashbang';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , class'X2Item_DefaultGrenades'.default.FLASHBANGGRENADE_RADIUS);

	return Template;
}

static function X2Effect SmokeGrenadeEffect()
{
	local X2Effect_SmokeGrenade Effect;

	Effect = new class'X2Effect_SmokeGrenade';
	//Must be at least as long as the duration of the smoke effect on the tiles. Will get "cut short" when the tile stops smoking or the unit moves. -btopp 2015-08-05
	Effect.BuildPersistentEffect(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Duration + 1, false, false, false, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, class'X2Item_DefaultGrenades'.default.SmokeGrenadeEffectDisplayName, class'X2Item_DefaultGrenades'.default.SmokeGrenadeEffectDisplayDesc, "img:///UILibrary_PerkIcons.UIPerk_grenade_smoke");
	Effect.HitMod = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_HITMOD;
	Effect.DuplicateResponse = eDupe_Refresh;
	return Effect;
}

static function X2DataTemplate CreateSmokeGrenade()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplySmokeGrenadeToWorld WeaponEffect;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'SmokeGrenade');

	Template.WeaponCat = 'utility';
	Template.ItemCat = 'utility';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Smoke_Grenade";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_smoke");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_smoke");
	Template.iRange = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_RANGE;
	Template.iRadius = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_RADIUS;

	Template.iSoundRange = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = 7;
	Template.PointsToComplete = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_IPOINTS;
	Template.iClipSize = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_ICLIPSIZE;
	Template.Tier = 0;

	Template.Abilities.AddItem('ThrowGrenade');
	Template.bFriendlyFireWarning = false;

	WeaponEffect = new class'X2Effect_ApplySmokeGrenadeToWorld';	
	Template.ThrownGrenadeEffects.AddItem(WeaponEffect);
	Template.ThrownGrenadeEffects.AddItem(SmokeGrenadeEffect());
	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;

	Template.GameArchetype = "WP_Grenade_Smoke.WP_Grenade_Smoke";

	Template.StartingItem = true;
	Template.CanBeBuilt = false;

	// Template.HideIfResearched = 'AdvancedGrenades';

	// Soldier Bark
	Template.OnThrowBarkSoundCue = 'SmokeGrenade';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_RADIUS);

	return Template;
}

static function X2DataTemplate SmokeGrenadeMk2()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplySmokeGrenadeToWorld WeaponEffect;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'SmokeGrenadeMk2');
	
	Template.WeaponCat = 'utility';
	Template.ItemCat = 'utility';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Smoke_GrenadeMK2";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_smoke");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_smoke");
	Template.iRange = class'X2Item_DefaultGrenades'.default.SMOKEGRENADEMK2_RANGE;
	Template.iRadius = class'X2Item_DefaultGrenades'.default.SMOKEGRENADEMK2_RADIUS;

	Template.iSoundRange = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = 10;
	Template.PointsToComplete = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_IPOINTS;
	Template.iClipSize = class'X2Item_DefaultGrenades'.default.SMOKEGRENADE_ICLIPSIZE;
	Template.Tier = 1;

	Template.Abilities.AddItem('ThrowGrenade');
	Template.bFriendlyFireWarning = false;

	WeaponEffect = new class'X2Effect_ApplySmokeGrenadeToWorld';	
	Template.ThrownGrenadeEffects.AddItem(WeaponEffect);
	Template.ThrownGrenadeEffects.AddItem(SmokeGrenadeEffect());
	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;

	Template.GameArchetype = "WP_Grenade_Smoke.WP_Grenade_Smoke_Lv2";

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	// Disabling smoke bomb.

	// Template.CreatorTemplateName = 'AdvancedGrenades'; // The schematic which creates this item
	// Template.BaseItem = 'SmokeGrenade'; // Which item this will be upgraded from
	
	// Soldier Bark
	Template.OnThrowBarkSoundCue = 'SmokeGrenade';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , class'X2Item_DefaultGrenades'.default.SMOKEGRENADEMK2_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , class'X2Item_DefaultGrenades'.default.SMOKEGRENADEMK2_RADIUS);

	return Template;
}

static function X2DataTemplate CreateNanoScaleVest()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'NanofiberVest');
	Template.ItemCat = 'defense';
	Template.InventorySlot = eInvSlot_Utility;
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Nano_Fiber_Vest";
	Template.EquipSound = "StrategyUI_Vest_Equip";

	Template.Abilities.AddItem('NanofiberVestBonus');

	Template.TradingPostValue = 15;
	Template.PointsToComplete = 0;
	Template.Tier = 0;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_ItemGrantedAbilitySet'.default.NANOFIBER_VEST_HP_BONUS);

	Template.StartingItem = true;
	Template.CanBeBuilt = false;

	return Template;
}

static function X2DataTemplate CreatePlatedVest()
{
	local X2EquipmentTemplate Template;
	local ArtifactCost Resources;
	local ArtifactCost Artifacts;
	
	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'PlatedVest');
	Template.ItemCat = 'defense';
	Template.InventorySlot = eInvSlot_Utility;
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Armor_Harness";
	Template.EquipSound = "StrategyUI_Vest_Equip";

	Template.Abilities.AddItem('PlatedVestBonus');

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 15;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_ItemGrantedAbilitySet'.default.PLATED_VEST_MITIGATION_AMOUNT);
	
	// Requirements
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 30;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Artifacts.ItemTemplateName = 'CorpseAdventTrooper';
	Artifacts.Quantity = 2;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}
