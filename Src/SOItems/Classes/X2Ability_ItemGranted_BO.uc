class X2Ability_ItemGranted_BO extends XMBAbility config(GameData_WeaponData);

var config array<int> FlechetteRangeAccuracy;
var config int FlechetteArmorAccuracyBonus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(FlechetteRounds());
	Templates.AddItem(HollowPointRounds());
	Templates.AddItem(ReinforcedVestBonusAbility());

	return Templates;
}

static function X2AbilityTemplate FlechetteRounds()
{
	local X2AbilityTemplate             Template;
	local X2Effect_FlechetteRounds      Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FlechetteRounds');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_ammo_fletchette";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_FlechetteRounds';
	Effect.RangeAccuracy = default.FlechetteRangeAccuracy;
	Effect.ArmorAccuracyBonus = default.FlechetteArmorAccuracyBonus;
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false);
	Template.AddShooterEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate HollowPointRounds()
{
	local X2AbilityTemplate             Template;
	local X2Effect_TalonRounds          Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HollowPointRounds');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_ammo_needle";
	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_TalonRounds';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false);
	Effect.AimMod = 0;
	Effect.CritChance = 0;
	Effect.CritDamage = class'X2Item_Ammo_BO'.default.HollowPointCritDamageModifier;
	Template.AddShooterEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate ReinforcedVestBonusAbility()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ReinforcedVestBonus');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorChance, class 'X2Item_Armor_BO'.default.ReinforcedVestMitigationChance);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, class 'X2Item_Armor_BO'.default.ReinforcedVestMitigationAmount);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}
