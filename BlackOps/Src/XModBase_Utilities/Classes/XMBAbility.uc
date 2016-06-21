//---------------------------------------------------------------------------------------
//  FILE:    XMBAbility.uc
//  AUTHOR:  xylthixlm
//
//  This class provides additional helpers for defining ability templates. Simply
//  declare your ability sets to extend XMBAbility instead of X2Ability, and then use
//  whatever helpers you need.
//
//  USAGE
//
//  class X2Ability_MyClassAbilitySet extends XMBAbility;
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  XMBCondition_CoverType.uc
//  XMBCondition_HeightAdvantage.uc
//  XMBCondition_ReactionFire.uc
//  XMBCondition_Dead.uc
//---------------------------------------------------------------------------------------

class XMBAbility extends X2Ability;

// Used by ActionPointCost and related functions
enum EActionPointCost
{
	eCost_Free,					// No action point cost, but you must have an action point available.
	eCost_Single,				// Costs a single action point.
	eCost_SingleConsumeAll,		// Costs a single action point, ends the turn.
	eCost_Double,				// Costs two action points.
	eCost_DoubleConsumeAll,		// Costs two action points, ends the turn.
	eCost_Weapon,				// Costs as much as a weapon shot.
	eCost_WeaponConsumeAll,		// Costs as much as a weapon shot, ends the turn.
	eCost_Overwatch,			// No action point cost, but displays as ending the turn. Used for 
								// abilities that have an X2Effect_ReserveActionPoints or similar.
	eCost_None,					// No action point cost. For abilities which may be triggered during
								// the enemy turn. You should use eCost_Free for activated abilities.
};

// Predefined conditions for use with XMBEffect_ConditionalBonus and similar effects.

// Careful, these objects should NEVER be modified - only constructed by default.
// They can be freely used by any ability template, but NEVER modified by them.

// Cover conditions. Only work as target conditions, not shooter conditions.
var const XMBCondition_CoverType FullCoverCondition;				// The target is in full cover
var const XMBCondition_CoverType HalfCoverCondition;				// The target is in half cover
var const XMBCondition_CoverType NoCoverCondition;					// The target is not in cover
var const XMBCondition_CoverType FlankedCondition;					// The target is not in cover and can be flanked

// Height advantage conditions. Only work as target conditions, not shooter conditions.
var const XMBCondition_HeightAdvantage HeightAdvantageCondition;	// The target is higher than the shooter
var const XMBCondition_HeightAdvantage HeightDisadvantageCondition;	// The target is lower than the shooter

// Reaction fire conditions. Only work as target conditions, not shooter conditions. Nonsensical
// if used on an X2AbilityTemplate, since it will always be either reaction fire or not.
var const XMBCondition_ReactionFire ReactionFireCondition;			// The attack is reaction fire

// Liveness conditions. Work as target or shooter conditions.
var const XMBCondition_Dead DeadCondition;							// The target is dead

// Result conditions. Only work as target conditions, not shooter conditions. Doesn't work if used
// on an X2AbilityTemplate since the hit result isn't known when selecting targets.
var const XMBCondition_AbilityHitResult HitCondition;				// The ability hits (including crits and grazes)
var const XMBCondition_AbilityHitResult MissCondition;				// The ability misses
var const XMBCondition_AbilityHitResult CritCondition;				// The ability crits
var const XMBCondition_AbilityHitResult GrazeCondition;				// The ability grazes

// Matching weapon conditions. Only work as target conditions. Doesn't work if used on an
// X2AbilityTemplate.
var const XMBCondition_MatchingWeapon MatchingWeaponCondition;		// The ability matches the weapon of the 
																	// ability defining the condition

// Unit property conditions.
var const X2Condition_UnitProperty LivingFriendlyTargetProperty;

// Use this for ShotHUDPriority to have the priority calculated automatically
var const int AUTO_PRIORITY;


// Helper method for quickly defining a non-pure passive. Works like PurePassive, except it also 
// takes an X2Effect_Persistent.
static function X2AbilityTemplate Passive(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect_Persistent Effect = none)
{
	local X2AbilityTemplate						Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);
	Template.IconImage = IconImage;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	if (Effect == none)
		Effect = new class'X2Effect_Persistent';

	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

// Helper function for quickly defining an ability that triggers on an event and targets the unit 
// itself. Note that this does not add a passive ability icon, so you should pair it with a
// Passive or PurePassive that defines the icon, or use AddIconPassive. The IconImage argument is
// still used as the icon for effects created by this ability.
static function X2AbilityTemplate SelfTargetTrigger(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional name EventID = '', optional AbilityEventFilter Filter = eFilter_Unit)
{
	local X2AbilityTemplate						Template;
	local XMBAbilityTrigger_EventListener		EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = IconImage;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	if (EventID == '')
		EventID = DataName;

	EventListener = new class'XMBAbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = EventID;
	EventListener.ListenerData.Filter = Filter;
	EventListener.bSelfTarget = true;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	if (Effect != none)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);

		Template.AddTargetEffect(Effect);
	}

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

// Helper function for creating an activated ability that targets the user.
static function X2AbilityTemplate SelfTargetActivated(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EActionPointCost Cost = eCost_Single)
{
	local X2AbilityTemplate						Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.DisplayTargetHitChance = false;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = IconImage;
	Template.ShotHUDPriority = ShotHUDPriority;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	if (Cost != eCost_None)
	{
		Template.AbilityCosts.AddItem(ActionPointCost(Cost));
	}

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	if (Effect != none)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);

		Template.AddTargetEffect(Effect);
	}

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

// Helper function for creating a typical weapon attack.
static function X2AbilityTemplate Attack(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EActionPointCost Cost = eCost_SingleConsumeAll, optional int iAmmo = 1)
{
	local X2AbilityTemplate                 Template;	
	local X2Condition_Visibility            VisibilityCondition;

	// Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	// Icon Properties
	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = IconImage;
	Template.ShotHUDPriority = ShotHUDPriority;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk'; 

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AddShooterEffectExclusions();

	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;

	Template.AbilityTargetConditions.AddItem(VisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	if (Cost != eCost_None)
	{
		Template.AbilityCosts.AddItem(ActionPointCost(Cost));	
	}

	if (iAmmo > 0)
	{
		AddAmmoCost(Template, iAmmo);
	}

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.bAllowFreeFireWeaponUpgrade = true;

	if (Effect != none)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);

		Template.AddTargetEffect(Effect);
	}
	else
	{
		//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
		Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
		//  Various Soldier ability specific effects - effects check for the ability before applying	
		Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

		Template.AddTargetEffect(default.WeaponUpgradeMissDamage);
	}
	
	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;
		
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	

	Template.AssociatedPassives.AddItem('HoloTargeting');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;	
}

static function X2AbilityTemplate MeleeAttack(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EActionPointCost Cost = eCost_SingleConsumeAll)
{
	local X2AbilityTemplate                 Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = IconImage;
	Template.ShotHUDPriority = ShotHUDPriority;

	if (Cost != eCost_None)
	{
		Template.AbilityCosts.AddItem(ActionPointCost(Cost));	
	}

	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	if (Effect != none)
	{
		Template.AddTargetEffect(Effect);
	}
	else
	{
		Template.AddTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	}

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

// Helper function for creating an ability that targets a visible enemy and has 100% hit chance.
static function X2AbilityTemplate TargetedDebuff(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EActionPointCost Cost = eCost_Single)
{
	local X2AbilityTemplate                 Template;	

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.ShotHUDPriority = ShotHUDPriority;
	Template.IconImage = IconImage;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;

	if (Cost != eCost_None)
	{
		Template.AbilityCosts.AddItem(ActionPointCost(Cost));	
	}

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	// 100% chance to hit
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	if (Effect != none)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);

		Template.AddTargetEffect(Effect);
	}

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CustomFireAnim = 'HL_SignalPoint';
	
	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

// Helper function for creating an ability that targets an ally (or the user).
static function X2AbilityTemplate TargetedBuff(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EActionPointCost Cost = eCost_Single)
{
	local X2AbilityTemplate                 Template;	

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.ShotHUDPriority = ShotHUDPriority;
	Template.IconImage = IconImage;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;

	if (Cost != eCost_None)
	{
		Template.AbilityCosts.AddItem(ActionPointCost(Cost));	
	}

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AbilityTargetConditions.AddItem(default.LivingFriendlyTargetProperty);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	// 100% chance to hit
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	if (Effect != none)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);

		Template.AddTargetEffect(Effect);
	}

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CustomFireAnim = 'HL_SignalPoint';
	
	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

// Hides the icon of an ability. For use with secondary abilities added in AdditionaAbilities that
// shouldn't get their own icon.
static function HidePerkIcon(X2AbilityTemplate Template)
{
	local X2Effect Effect;

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	foreach Template.AbilityTargetEffects(Effect)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).bDisplayInUI = false;
	}
}

// Helper function for creating an X2AbilityCost_ActionPoints.
static function X2AbilityCost_ActionPoints ActionPointCost(EActionPointCost Cost)
{
	local X2AbilityCost_ActionPoints			AbilityCost;

	AbilityCost = new class'X2AbilityCost_ActionPoints';
	switch (Cost)
	{
	case eCost_Free:				AbilityCost.iNumPoints = 1; AbilityCost.bFreeCost = true; break;
	case eCost_Single:				AbilityCost.iNumPoints = 1; break;
	case eCost_SingleConsumeAll:	AbilityCost.iNumPoints = 1; AbilityCost.bConsumeAllPoints = true; break;
	case eCost_Double:				AbilityCost.iNumPoints = 2; break;
	case eCost_DoubleConsumeAll:	AbilityCost.iNumPoints = 2; AbilityCost.bConsumeAllPoints = true; break;
	case eCost_Weapon:				AbilityCost.iNumPoints = 0; AbilityCost.bAddWeaponTypicalCost = true; break;
	case eCost_WeaponConsumeAll:	AbilityCost.iNumPoints = 0; AbilityCost.bAddWeaponTypicalCost = true; AbilityCost.bConsumeAllPoints = true; break;
	case eCost_Overwatch:			AbilityCost.iNumPoints = 1; AbilityCost.bConsumeAllPoints = true; AbilityCost.bFreeCost = true; break;
	case eCost_None:				AbilityCost.iNumPoints = 0; break;
	}

	return AbilityCost;
}

// Helper function for creating an X2AbilityCooldown.
static function AddCooldown(X2AbilityTemplate Template, int iNumTurns)
{
	local X2AbilityCooldown AbilityCooldown;
	AbilityCooldown = new class'X2AbilityCooldown';
	AbilityCooldown.iNumTurns = iNumTurns;
	Template.AbilityCooldown = AbilityCooldown;
}

// Helper function for creating an X2AbilityCost_Ammo.
static function AddAmmoCost(X2AbilityTemplate Template, int iAmmo)
{
	local X2AbilityCost_Ammo AmmoCost;
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = iAmmo;
	Template.AbilityCosts.AddItem(AmmoCost);
}

static function AddCharges(X2AbilityTemplate Template, int InitialCharges)
{
	local X2AbilityCharges Charges;
	local X2AbilityCost_Charges ChargeCost;

	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = InitialCharges;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
}

static function AddMovementTrigger(X2AbilityTemplate Template)
{
	local X2AbilityTrigger_Event Trigger;
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
}

static function AddAttackTrigger(X2AbilityTemplate Template)
{
	local X2AbilityTrigger_Event Trigger;
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
}

static function AddPerTargetCooldown(X2AbilityTemplate Template, optional int iTurns = 1, optional name CooldownEffectName = '', optional GameRuleStateChange GameRule = eGameRule_PlayerTurnEnd)
{
	local X2Effect_Persistent PersistentEffect;
	local X2Condition_UnitEffectsWithAbilitySource EffectsCondition;

	if (CooldownEffectName == '')
	{
		CooldownEffectName = name(Template.DataName $ "_CooldownEffect");
	}

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.EffectName = CooldownEffectName;
	PersistentEffect.DuplicateResponse = eDupe_Refresh;
	PersistentEffect.BuildPersistentEffect(iTurns, false, true, false, GameRule);
	PersistentEffect.bApplyOnHit = true;
	PersistentEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(PersistentEffect);

	// Create a condition that checks for the presence of a certain effect. There are three
	// similar classes that do this: X2Condition_UnitEffects,
	// X2Condition_UnitEffectsWithAbilitySource, and X2Condition_UnitEffectsWithAbilityTarget.
	// The first one looks for any effect with the right name, the second only for effects
	// with that were applied by the unit using this ability, and the third only for effects
	// that apply to the unit using this ability. Since we want to match the persistent effect
	// we applied as a mark - but not the same effect applied by any other unit - we use
	// X2Condition_UnitEffectsWithAbilitySource.

	EffectsCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	EffectsCondition.AddExcludeEffect(CooldownEffectName, 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);
}

static function AddTriggerTargetCondition(X2AbilityTemplate Template, X2Condition Condition)
{
	local X2AbilityTrigger Trigger;

	foreach Template.AbilityTriggers(Trigger)
	{
		if (XMBAbilityTrigger_EventListener(Trigger) != none)
			XMBAbilityTrigger_EventListener(Trigger).AbilityTargetConditions.AddItem(Condition);
	}
}

static function AddTriggerShooterCondition(X2AbilityTemplate Template, X2Condition Condition)
{
	local X2AbilityTrigger Trigger;

	foreach Template.AbilityTriggers(Trigger)
	{
		if (XMBAbilityTrigger_EventListener(Trigger) != none)
			XMBAbilityTrigger_EventListener(Trigger).AbilityShooterConditions.AddItem(Condition);
	}
}

static function PreventStackingEffects(X2AbilityTemplate Template)
{
	local X2Condition_UnitEffectsWithAbilitySource EffectsCondition;
	local X2Effect Effect;

	EffectsCondition = new class'X2Condition_UnitEffectsWithAbilitySource';

	foreach Template.AbilityTargetEffects(Effect)
	{
		if (X2Effect_Persistent(Effect) != none)
			EffectsCondition.AddExcludeEffect(X2Effect_Persistent(Effect).EffectName, 'AA_UnitIsImmune');
	}

	Template.AbilityTargetConditions.AddItem(EffectsCondition);
}

static function AddIconPassive(X2AbilityTemplate Template)
{
	local X2AbilityTemplate IconTemplate;

	IconTemplate = PurePassive(name(Template.DataName $ "_Icon"), Template.IconImage);
	IconTemplate.LocFriendlyName = Template.LocFriendlyName;
	IconTemplate.LocHelpText = Template.LocHelpText;
	IconTemplate.LocLongDescription = Template.LocLongDescription;
	IconTemplate.LocFlyOverText = Template.LocFlyOverText;

	Template.AdditionalAbilities.AddItem(IconTemplate.DataName);

	class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().AddAbilityTemplate(IconTemplate);
}

// Helper function for creating an X2Condition that requires a maximum distance between shooter and target.
simulated static function X2Condition_UnitProperty TargetWithinTiles(int Tiles)
{
	local X2Condition_UnitProperty UnitPropertyCondition;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.RequireWithinRange = true;
	// WithinRange is measured in Unreal units, so we need to convert tiles to units.
	UnitPropertyCondition.WithinRange = `TILESTOUNITS(Tiles);

	// Remove default checks
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeCosmetic = false;
	UnitPropertyCondition.ExcludeInStasis = false;

	return UnitPropertyCondition;
}

// Set this as the VisualizationFn on an X2Effect_Persistent to have it display a flyover over the target when applied.
simulated static function EffectFlyOver_Visualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local EWidgetColor					MessageColor;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	
	MessageColor = AbilityTemplate.Hostility == eHostility_Offensive ? eColor_Bad : eColor_Good;

	if (EffectApplyResult == 'AA_Success' && XGUnit(BuildTrack.TrackActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', MessageColor, AbilityTemplate.IconImage);
	}
}


defaultproperties
{
	Begin Object Class=XMBCondition_CoverType Name=DefaultFullCoverCondition
		AllowedCoverTypes[0] = CT_Standing
	End Object
	FullCoverCondition = DefaultFullCoverCondition

	Begin Object Class=XMBCondition_CoverType Name=DefaultHalfCoverCondition
		AllowedCoverTypes[0] = CT_MidLevel
	End Object
	HalfCoverCondition = DefaultHalfCoverCondition

	Begin Object Class=XMBCondition_CoverType Name=DefaultNoCoverCondition
		AllowedCoverTypes[0] = CT_None
	End Object
	NoCoverCondition = DefaultNoCoverCondition

	Begin Object Class=XMBCondition_CoverType Name=DefaultFlankedCondition
		AllowedCoverTypes[0] = CT_None
		bRequireCanTakeCover = true
	End Object
	FlankedCondition = DefaultFlankedCondition

	Begin Object Class=XMBCondition_HeightAdvantage Name=DefaultHeightAdvantageCondition
		bRequireHeightAdvantage = true
	End Object
	HeightAdvantageCondition = DefaultHeightAdvantageCondition

	Begin Object Class=XMBCondition_HeightAdvantage Name=DefaultHeightDisadvantageCondition
		bRequireHeightDisadvantage = true
	End Object
	HeightDisadvantageCondition = DefaultHeightDisadvantageCondition

	Begin Object Class=XMBCondition_ReactionFire Name=DefaultReactionFireCondition
	End Object
	ReactionFireCondition = DefaultReactionFireCondition

	Begin Object Class=XMBCondition_Dead Name=DefaultDeadCondition
	End Object
	DeadCondition = DefaultDeadCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultHitCondition
		bRequireHit = true
	End Object
	HitCondition = DefaultHitCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultMissCondition
		bRequireMiss = true
	End Object
	MissCondition = DefaultMissCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultCritCondition
		IncludeHitResults[0] = eHit_Crit
	End Object
	CritCondition = DefaultCritCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultGrazeCondition
		IncludeHitResults[0] = eHit_Graze
	End Object
	GrazeCondition = DefaultGrazeCondition

	Begin Object Class=XMBCondition_MatchingWeapon Name=DefaultMatchingWeaponCondition
	End Object
	MatchingWeaponCondition = DefaultMatchingWeaponCondition

	Begin Object Class=X2Condition_UnitProperty Name=DefaultLivingFriendlyTargetProperty
		ExcludeAlive=false
		ExcludeDead=true
		ExcludeFriendlyToSource=false
		ExcludeHostileToSource=true
		FailOnNonUnits=true
	End Object
	LivingFriendlyTargetProperty = DefaultLivingFriendlyTargetProperty

	AUTO_PRIORITY = -1
}