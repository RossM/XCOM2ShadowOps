class X2Ability_EngineerAbilitySet extends XMBAbility
	config(GameData_SoldierSkills);

var config int AggressionCritModifier, AggressionMaxCritModifier, AggressionGrenadeCritDamage;
var config int BreachEnvironmentalDamage;
var config float BreachRange, BreachRadius, BreachShotgunRadius;
var config float DangerZoneBonusRadius, DangerZoneBreachBonusRadius;
var config int MovingTargetDefenseBonus, MovingTargetDodgeBonus;

var config int BreachCooldown, FastballCooldown, FractureCooldown, SlamFireCooldown;
var config int BreachAmmo, FractureAmmo;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(DeepPockets());
	Templates.AddItem(DenseSmoke());
	Templates.AddItem(SmokeAndMirrors());
	Templates.AddItem(Breach());
	Templates.AddItem(BreachBonusRadius());
	Templates.AddItem(Fastball());
	Templates.AddItem(FastballRemovalTrigger());
	Templates.AddItem(FractureAbility());
	Templates.AddItem(FractureDamage());
	Templates.AddItem(Packmaster());
	Templates.AddItem(PurePassive('ShadowOps_Entrench', "img:///UILibrary_PerkIcons.UIPerk_one_for_all", true));
	Templates.AddItem(Aggression());
	Templates.AddItem(PurePassive('ShadowOps_CombatDrugs', "img:///UILibrary_BlackOps.UIPerk_combatdrugs", true));
	Templates.AddItem(SlamFire());
	Templates.AddItem(DangerZone());
	Templates.AddItem(ChainReaction());
	Templates.AddItem(ChainReactionFuse());
	Templates.AddItem(HeatAmmo());
	Templates.AddItem(MovingTarget());

	return Templates;
}

static function X2AbilityTemplate SmokeAndMirrors()
{
	local XMBEffect_AddGrenade Effect;

	Effect = new class'XMBEffect_AddGrenade';
	Effect.DataName = 'SmokeGrenade';
	Effect.Quantity = 1;

	return Passive('ShadowOps_SmokeAndMirrors', "img:///UILibrary_BlackOps.UIPerk_smokeandmirrors", false, Effect);
}

static function X2AbilityTemplate DeepPockets()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('ShadowOps_DeepPockets', "img:///UILibrary_PerkIcons.UIPerk_deeppockets");

	Template.SoldierAbilityPurchasedFn = DeepPocketsPurchased;

	Template.bCrossClassEligible = true;

	return Template;
}

static function DeepPocketsPurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	UnitState.ValidateLoadout(NewGameState);
}

static function X2AbilityTemplate Breach()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_SoldierBonusRadius_XModBase       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Breach');
	Template.AdditionalAbilities.AddItem('ShadowOps_BreachBonusRadius');
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_breach";
	Template.Hostility = eHostility_Offensive;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	Template.TargetingMethod = class'X2TargetingMethod_Breach';

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = default.BreachAmmo;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 0; //Uses typical action points of weapon:
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.BreachCooldown;
	Template.AbilityCooldown = Cooldown;
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;
	
	WeaponDamageEffect = new class'X2Effect_Breach';
	WeaponDamageEffect.EnvironmentalDamageAmount = default.BreachEnvironmentalDamage;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = default.BreachRange;
	Template.AbilityTargetStyle = CursorTarget;

	// Use SoldierBonusRadius because it grants the Danger Zone modifier,
	// but zero out BonusRadius so it isn't affected by Volatile Mix.
	RadiusMultiTarget = new class'X2AbilityMultiTarget_SoldierBonusRadius_XModBase';
	RadiusMultiTarget.fTargetRadius = default.BreachRadius;
	RadiusMultiTarget.BonusRadius = 0;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;

	return Template;	
}

static function X2AbilityTemplate BreachBonusRadius()
{
	local X2AbilityTemplate						Template;
	local XMBEffect_BonusRadius                  Effect;
	local X2Condition_UnitInventory				Condition;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_BreachBonusRadius');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Condition = new class'X2Condition_UnitInventory';
	Condition.RelevantSlot = eInvSlot_PrimaryWeapon;
	Condition.RequireWeaponCategory = 'shotgun';
	Template.AbilityTargetConditions.AddItem(Condition);

	Effect = new class'XMBEffect_BonusRadius';
	Effect.fBonusRadius = default.BreachShotgunRadius - default.BreachRadius;
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate Fastball()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_Persistent				FastballEffect;
	local X2Effect_GrantActionPoints		ActionPointEffect;
	local X2AbilityTargetStyle              TargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Fastball');
	
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fastball";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.Hostility = eHostility_Neutral;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.FastballCooldown;
	Template.AbilityCooldown = Cooldown;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_HasGrenade');

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	FastballEffect = new class'X2Effect_Persistent';
	FastballEffect.EffectName = 'Fastball';
	FastballEffect.BuildPersistentEffect(1,,,,eGameRule_PlayerTurnEnd);
	FastballEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, "img:///UILibrary_PerkIcons.UIPerk_bombard", true);
	Template.AddTargetEffect(FastballEffect);

	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = 'grenade';
	Template.AddTargetEffect(ActionPointEffect);

	Template.AddShooterEffectExclusions();

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.AdditionalAbilities.AddItem('ShadowOps_FastballRemovalTrigger');
	
	Template.bCrossClassEligible = true;

	return Template;	
}

static function X2AbilityTemplate FastballRemovalTrigger()
{
	local X2AbilityTemplate						Template;	
	local X2Effect_RemoveEffects				RemoveFastballEffect;
	local X2AbilityTrigger_EventListener		Trigger;
	local X2AbilityTargetStyle					TargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_FastballRemovalTrigger');
	
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fastball";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'GrenadeUsed';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	RemoveFastballEffect = new class'X2Effect_RemoveEffects';
	RemoveFastballEffect.EffectNamesToRemove.AddItem('Fastball');
	Template.AddTargetEffect(RemoveFastballEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// No visualization on purpose
	
	return Template;	
}

static function X2AbilityTemplate FractureAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Fracture');

	Template.AdditionalAbilities.AddItem('ShadowOps_FractureDamage');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fracture";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.FractureCooldown;
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.FractureAmmo;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 0; //Uses typical action points of weapon:
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate FractureDamage()
{
	local X2AbilityTemplate						Template;
	local X2Effect_FractureDamage                DamageEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_FractureDamage');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'X2Effect_FractureDamage';
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate Aggression()
{
	local X2Effect_Aggression Effect;

	Effect = new class'X2Effect_Aggression';
	Effect.EffectName = 'Aggression';
	Effect.CritModifier = default.AggressionCritModifier;
	Effect.MaxCritModifier = default.AggressionMaxCritModifier;
	Effect.GrenadeCritDamage = default.AggressionGrenadeCritDamage;

	return Passive('ShadowOps_Aggression', "img:///UILibrary_BlackOps.UIPerk_aggression", true, Effect);
}

static function X2AbilityTemplate SlamFire()
{
	local X2AbilityTemplate				Template;
	local X2AbilityCooldown				Cooldown;
	local X2Effect_SlamFire             SlamFireEffect;
	local X2AbilityCost_ActionPoints    ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_SlamFire');

	// Icon Properties
	Template.DisplayTargetHitChance = false;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                       // color of the icon
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_slamfire";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SlamFireCooldown;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	class'X2Ability_RangerAbilitySet'.static.SuperKillRestrictions(Template, 'Serial_SuperKillCheck');
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	SlamFireEffect = new class'X2Effect_SlamFire';
	SlamFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	SlamFireEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddTargetEffect(SlamFireEffect);

	Template.AbilityTargetStyle = default.SelfTarget;	
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate ChainReaction()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ChainReaction                Effect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ChainReaction');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fuse";
	Template.AdditionalAbilities.AddItem('ShadowOps_ChainReactionFuse');
	//Template.AdditionalAbilities.AddItem('FusePostActivationConcealmentBreaker');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_ChainReaction';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate ChainReactionFuse()
{
	local X2AbilityTemplate					Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ChainReactionFuse');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fuse";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_FuseTarget');	
	Template.AddShooterEffectExclusions();

	Template.PostActivationEvents.AddItem(class'X2ABility_PsiOperativeAbilitySet'.default.FuseEventName);
	//Template.PostActivationEvents.AddItem(class'X2ABility_PsiOperativeAbilitySet'.default.FusePostEventName);

	//Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildVisualizationFn = ChainReactionFuseVisualization;

	return Template;
}

simulated function ChainReactionFuseVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference          InteractingUnitRef;

	local VisualizationTrack        EmptyTrack;
	local VisualizationTrack        BuildTrack;

	local XComGameState_Ability         Ability;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_SendInterTrackMessage SendMessageAction;
	local X2Action_Delay			DelayAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.TrackActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_SyncVisualizer'.static.AddToVisualizationTrack(BuildTrack, Context);

	DelayAction = X2Action_Delay(class 'X2Action_Delay'.static.AddToVisualizationTrack(BuildTrack, Context));
	DelayAction.Duration = 6.0;

	// Send an intertrack message to trigger the fuse explosion
	SendMessageAction = X2Action_SendInterTrackMessage(class'X2Action_SendInterTrackMessage'.static.AddToVisualizationTrack(BuildTrack, Context));
	SendMessageAction.SendTrackMessageToRef = Context.InputContext.PrimaryTarget;

	OutVisualizationTracks.AddItem(BuildTrack);

	//Configure the visualization track for the target
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.PrimaryTarget;
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.TrackActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_SyncVisualizer'.static.AddToVisualizationTrack(BuildTrack, Context);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, Context));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Ability.GetMyTemplate().LocFlyOverText, '', eColor_Bad);
	
	OutVisualizationTracks.AddItem(BuildTrack);
}

static function X2AbilityTemplate Packmaster()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local XMBEffect_BonusItemCharges            ItemChargesEffect;
	local X2Effect_Persistent					PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Packmaster');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_packmaster";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	ItemChargesEffect = new class'XMBEffect_BonusItemCharges';
	ItemChargesEffect.ApplyToSlots.AddItem(eInvSlot_Utility);
	Template.AddTargetEffect(ItemChargesEffect);

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.EffectName = 'Packmaster';
	PersistentEffect.BuildPersistentEffect(1, true, true, true);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;
	
	return Template;
}

static function X2AbilityTemplate DangerZone()
{
	local X2Effect_DangerZone Effect;

	Effect = new class'X2Effect_DangerZone';
	Effect.EffectName = 'DangerZone';
	Effect.fBonusRadius = default.DangerZoneBonusRadius;
	Effect.fBreachBonusRadius = default.DangerZoneBreachBonusRadius;

	return Passive('ShadowOps_DangerZone', "img:///UILibrary_BlackOps.UIPerk_dangerzone", true, Effect);
}

static function X2AbilityTemplate DenseSmoke()
{
	local XMBEffect_BonusRadius Effect;

	Effect = new class'XMBEffect_BonusRadius';
	Effect.EffectName = 'DenseSmokeRadius';
	Effect.fBonusRadius = class'X2Effect_SmokeGrenade_BO'.default.DenseSmokeBonusRadius;
	Effect.AllowedTemplateNames.AddItem('SmokeGrenade');
	Effect.AllowedTemplateNames.AddItem('SmokeGrenadeMk2');

	return Passive('ShadowOps_DenseSmoke', "img:///UILibrary_BlackOps.UIPerk_densesmoke", true, Effect);
}

static function X2AbilityTemplate HeatAmmo()
{
	local X2Effect_HeatAmmo Effect;

	Effect = new class'X2Effect_HeatAmmo';

	return Passive('ShadowOps_HeatAmmo', "img:///UILibrary_BlackOps.UIPerk_heatammo", true, Effect);
}

static function X2AbilityTemplate MovingTarget()
{
	local XMBEffect_ConditionalBonus             Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.SelfConditions.AddItem(new class'X2Condition_ReactionFire');
	Effect.AddToHitAsTargetModifier(-default.MovingTargetDefenseBonus);
	Effect.AddToHitAsTargetModifier(default.MovingTargetDodgeBonus, eHit_Graze);

	return Passive('ShadowOps_MovingTarget', "img:///UILibrary_BlackOps.UIPerk_movingtarget", false, Effect);
}

