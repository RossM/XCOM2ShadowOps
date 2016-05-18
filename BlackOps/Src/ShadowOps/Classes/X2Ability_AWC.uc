class X2Ability_AWC extends X2Ability
	config(GameData_SoldierSkills);

var config int HipFireHitModifier;
var config int HipFireCooldown;
var config float AnatomistCritModifier, AnatomistMaxCritModifier;
var config int WeaponmasterBonusDamage;
var config int AbsolutelyCriticalCritBonus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(HipFire());
	Templates.AddItem(Anatomist());
	Templates.AddItem(Scrounger());
	Templates.AddItem(ScroungerTrigger());
	Templates.AddItem(Weaponmaster());
	Templates.AddItem(AbsolutelyCritical());
	Templates.AddItem(HitAndRun());

	return Templates;
}

static function X2AbilityTemplate HipFire()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local array<name>                       SkipExclusions;
	local X2AbilityCooldown					Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_HipFire');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_lightninghands";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HipFireCooldown;
	Template.AbilityCooldown = Cooldown;

	// *** VALIDITY CHECKS *** //
	//  Normal effect restrictions (except disoriented)
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Targeting Details
	// Can only shoot visible enemies
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Hit Calculation (Different weapons now have different calculations for range)
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.HipFireHitModifier;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Anatomist()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Anatomist                    Effect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Anatomist');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_xenobiology_overlays";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_Anatomist';
	Effect.CritModifier = default.AnatomistCritModifier;
	Effect.MaxCritModifier = default.AnatomistMaxCritModifier;
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Scrounger()
{
	local X2AbilityTemplate						Template;
	
	Template = PurePassive('ShadowOps_Scrounger', "img:///UILibrary_PerkIcons.UIPerk_deeppockets", true);
	Template.AdditionalAbilities.AddItem('ShadowOps_ScroungerTrigger');

	return Template;
}

static function X2AbilityTemplate ScroungerTrigger()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ScroungerTrigger');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deeppockets"; // TODO

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	MultiTargetStyle = new class'X2AbilityMultiTarget_AllUnits';
	MultiTargetStyle.bAcceptEnemyUnits = true;
	MultiTargetStyle.bRandomlySelectOne = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	Template.AddMultiTargetEffect(new class'X2Effect_DropLoot');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Weaponmaster()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentBonus              Effect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Weaponmaster');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_xenobiology_overlays"; //TODO

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_PersistentBonus';
	Effect.BonusDamage = default.WeaponmasterBonusDamage;
	Effect.bRequireAbilityWeapon = true;
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate AbsolutelyCritical()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentBonus              Effect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_AbsolutelyCritical');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_xenobiology_overlays"; // TODO

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_PersistentBonus';
	Effect.AllowedCoverTypes.AddItem(CT_NONE);
	Effect.AddToHitModifier(default.AbsolutelyCriticalCritBonus, eHit_Crit);
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate HitAndRun()
{
	local X2AbilityTemplate						Template;
	local X2Effect_HitAndRun                    Effect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_HitAndRun');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_runandgun"; // TODO

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_HitAndRun';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

