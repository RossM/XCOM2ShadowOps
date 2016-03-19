class X2Ability_HunterAbilitySet extends X2Ability
	config(GameData_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(SnapShot());
	Templates.AddItem(SnapShotOverwatch());
	Templates.AddItem(HunterMark());
	Templates.AddItem(VitalPoint());
	Templates.AddItem(HipFire());
	Templates.AddItem(Precision());
	Templates.AddItem(LowProfile());
	Templates.AddItem(Sprinter());

	return Templates;
}

static function X2AbilityTemplate SnapShot()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_UnitActionPoints		UnitActionPointCondition;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;

	//Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'SnapShot');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snapshot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.DisplayTargetHitChance = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailableOrNoTargets;
	Template.AbilitySourceName = 'eAbilitySource_Standard';                                       // color of the icon
	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	
	// *** VALIDITY CHECKS *** //
	// Status condtions that do *not* prohibit this action.
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// *** TARGETING PARAMETERS *** //
	// Can only shoot visible enemies
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	UnitActionPointCondition = new class'X2Condition_UnitActionPoints';
	UnitActionPointCondition.AddActionPointCheck(1);
	Template.AbilityShooterConditions.AddItem(UnitActionPointCondition);

	// Action Point
	ActionPointCost = new class 'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;                                               // Consume all points
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true;

	// Weapon Upgrade Compatibility
	Template.bAllowFreeFireWeaponUpgrade = true;                                            // Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Hit Calculation (Different weapons now have different calculations for range)
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = -10;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddTargetEffect(KnockbackEffect);

	Template.AdditionalAbilities.AddItem('SnapShotOverwatch');

	return Template;
}

static function X2AbilityTemplate SnapShotOverwatch()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ReserveActionPoints      ReserveActionPointsEffect;
	local array<name>                       SkipExclusions;
	local X2Effect_CoveringFire             CoveringFireEffect;
	local X2Condition_AbilityProperty       CoveringFireCondition;
	local X2Condition_UnitProperty          ConcealedCondition;
	local X2Effect_SetUnitValue             UnitValueEffect;
	local X2Condition_UnitEffects           SuppressedCondition;
	local X2Condition_UnitActionPoints		UnitActionPointCondition;
	local X2Effect_PersistentStatChange		LowerAimEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SnapShotOverwatch');
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;                  //  ammo is consumed by the shot, not by this, but this should verify ammo is available
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);
	
	UnitActionPointCondition = new class'X2Condition_UnitActionPoints';
	UnitActionPointCondition.AddActionPointCheck(1);
	Template.AbilityShooterConditions.AddItem(UnitActionPointCondition);

	ReserveActionPointsEffect = new class'X2Effect_ReserveOverwatchPoints';
	Template.AddTargetEffect(ReserveActionPointsEffect);

	LowerAimEffect = new class'X2Effect_PersistentStatChange';
	LowerAimEffect.BuildPersistentEffect(1,,,,eGameRule_PlayerTurnBegin);
	LowerAimEffect.AddPersistentStatChange(eStat_Offense, -10);
	LowerAimEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_snapshot", true);
	Template.AddShooterEffect(LowerAimEffect);

	CoveringFireEffect = new class'X2Effect_CoveringFire';
	CoveringFireEffect.AbilityToActivate = 'OverwatchShot';
	CoveringFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	CoveringFireCondition = new class'X2Condition_AbilityProperty';
	CoveringFireCondition.OwnerHasSoldierAbilities.AddItem('CoveringFire');
	CoveringFireEffect.TargetConditions.AddItem(CoveringFireCondition);
	Template.AddTargetEffect(CoveringFireEffect);

	ConcealedCondition = new class'X2Condition_UnitProperty';
	ConcealedCondition.ExcludeFriendlyToSource = false;
	ConcealedCondition.IsConcealed = true;
	UnitValueEffect = new class'X2Effect_SetUnitValue';
	UnitValueEffect.UnitName = class'X2Ability_DefaultAbilitySet'.default.ConcealedOverwatchTurn;
	UnitValueEffect.CleanupType = eCleanup_BeginTurn;
	UnitValueEffect.NewValueToSet = 1;
	UnitValueEffect.TargetConditions.AddItem(ConcealedCondition);
	Template.AddTargetEffect(UnitValueEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_ActionPoints');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.AbilityConfirmSound = "Unreal2DSounds_OverWatch";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.OverwatchAbility_BuildVisualization;
	Template.CinescriptCameraType = "Overwatch";

	Template.Hostility = eHostility_Defensive;

	Template.DefaultKeyBinding = class'UIUtilities_Input'.const.FXS_KEY_Y;
	Template.bNoConfirmationWithHotKey = true;

	return Template;	
}

static function X2DataTemplate HunterMark()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_Visibility TargetVisibilityCondition;
	local X2Condition_UnitEffects UnitEffectsCondition;
	local X2AbilityTarget_Single SingleTarget;
	local X2AbilityTrigger_PlayerInput InputTrigger;
	local X2Effect_Persistent MarkedEffect;
	local X2Effect_RemoveEffects RemovePreviousMarkEffect;
	local X2AbilityCooldown Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HunterMark');

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_mark";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 2;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Stay concealed while using
	Template.ConcealmentRule = eConceal_Always;

	// The shooter cannot be mind controlled
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsMindControlled');
	Template.AbilityShooterConditions.AddItem(UnitEffectsCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Target must be an enemy
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.RequireWithinRange = false;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
	
	// Target must be visible and may use squad sight
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// Target cannot already be marked
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect(class'X2StatusEffects'.default.MarkedName, 'AA_UnitIsMarked');
	Template.AbilityTargetConditions.AddItem(UnitEffectsCondition);

	// 100% chance to hit
	Template.AbilityToHitCalc = default.DeadEye;

	SingleTarget = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = SingleTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	// Remove previous mark, if any
	RemovePreviousMarkEffect = new class'X2Effect_RemoveEffects';
	RemovePreviousMarkEffect.bCheckSource = true;
	RemovePreviousMarkEffect.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.MarkedName);
	Template.AddShooterEffect(RemovePreviousMarkEffect);

	// Create the Marked effect
	MarkedEffect = CreateMarkedEffect(1, true);

	Template.AddTargetEffect(MarkedEffect); //BMU - changing to an immediate execution for evaluation

	Template.CustomFireAnim = 'HL_SignalPoint';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = class'X2Ability_AdventCaptain'.static.TargetGettingMarked_BuildVisualization;
	Template.CinescriptCameraType = "Mark_Target";
	
	return Template;
}

static function X2Effect_Marked_BO CreateMarkedEffect(int NumTurns, bool bIsInfinite)
{
	local X2Effect_Marked_BO MarkedEffect;

	MarkedEffect = new class 'X2Effect_Marked_BO';
	MarkedEffect.EffectName = class'X2StatusEffects'.default.MarkedName;
	MarkedEffect.DuplicateResponse = eDupe_Ignore;
	MarkedEffect.BuildPersistentEffect(NumTurns, bIsInfinite, true,,eGameRule_PlayerTurnEnd);
	MarkedEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.MarkedFriendlyName, class'X2StatusEffects'.default.MarkedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_mark");
	MarkedEffect.VisualizationFn = class'X2StatusEffects'.static.MarkedVisualization;
	MarkedEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.MarkedVisualizationTicked;
	MarkedEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.MarkedVisualizationRemoved;
	MarkedEffect.bRemoveWhenTargetDies = true;
	MarkedEffect.AccuracyBonus = 15;

	return MarkedEffect;
}

static function X2AbilityTemplate VitalPoint()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_VitalPoint                   VitalPointEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'VitalPoint');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_xenobiology_overlays";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	VitalPointEffect = new class'X2Effect_VitalPoint';
	VitalPointEffect.BuildPersistentEffect(1, true, true, true);
	VitalPointEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	//VitalPointEffect.BonusArmorPiercing = 10;
	VitalPointEffect.BonusDamage = 1;
	VitalPointEffect.BonusDamagePerTier = 1;
	VitalPointEffect.BonusShred = 2;
	VitalPointEffect.BonusShredPerTier = 1;
	Template.AddTargetEffect(VitalPointEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate HipFire()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local array<name>                       SkipExclusions;
	local X2AbilityCooldown					Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HipFire');

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

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 4;
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
	ToHitCalc.BuiltInHitMod = -20;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	return Template;
}

static function X2AbilityTemplate Precision()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_Precision                   PrecisionEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Precision');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_urban_aim";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	PrecisionEffect = new class'X2Effect_Precision';
	PrecisionEffect.BuildPersistentEffect(1, true, true, true);
	PrecisionEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	PrecisionEffect.Aim = 20;
	Template.AddTargetEffect(PrecisionEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate LowProfile()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_HunterLowProfile             LowProfileEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LowProfile');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_lowprofile";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	LowProfileEffect = new class'X2Effect_HunterLowProfile';
	LowProfileEffect.BuildPersistentEffect(1, true, true, true);
	LowProfileEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	LowProfileEffect.Defense = 20;
	Template.AddTargetEffect(LowProfileEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate Sprinter()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_PersistentStatChange         PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Sprinter');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sprinter";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	PersistentEffect = new class'X2Effect_PersistentStatChange';
	PersistentEffect.EffectName = 'Sprinter';
	PersistentEffect.BuildPersistentEffect(1, true, true, true);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	PersistentEffect.AddPersistentStatChange(eStat_Mobility, 4);
	Template.AddTargetEffect(PersistentEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_Mobility, 4);

	return Template;
}

