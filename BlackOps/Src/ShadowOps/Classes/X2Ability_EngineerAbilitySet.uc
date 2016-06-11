class X2Ability_EngineerAbilitySet extends XMBAbility
	config(GameData_SoldierSkills);

var config int AggressionCritModifier, AggressionMaxCritModifier, AggressionGrenadeCritDamage;
var config int BreachEnvironmentalDamage;
var config float BreachRange, BreachRadius, BreachShotgunRange, BreachShotgunRadius;
var config float DangerZoneBonusRadius, DangerZoneBreachBonusRadius;
var config int MovingTargetDefenseBonus, MovingTargetDodgeBonus;
var config int EntrenchDefense, EntrenchDodge;
var config int FractureCritModifier;

var config int BreachCooldown, FastballCooldown, FractureCooldown, SlamFireCooldown;
var config int BreachAmmo, FractureAmmo;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(DeepPockets());
	Templates.AddItem(DenseSmoke());
	Templates.AddItem(SmokeAndMirrors());
	Templates.AddItem(Breach());
	Templates.AddItem(ShotgunBreach());
	Templates.AddItem(Fastball());
	Templates.AddItem(FastballRemovalTrigger());
	Templates.AddItem(FractureAbility());
	Templates.AddItem(FractureDamage());
	Templates.AddItem(Packmaster());
	Templates.AddItem(Entrench());
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
	local XMBEffect_AddUtilityItem Effect;

	Effect = new class'XMBEffect_AddUtilityItem';
	Effect.DataName = 'SmokeGrenade';
	Effect.BaseCharges = 1;

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
	local XMBAbilityMultiTarget_SoldierBonusRadius       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitInventory			InventoryCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Breach');
	Template.AdditionalAbilities.AddItem('ShadowOps_ShotgunBreach');
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
	Template.HideIfAvailable.AddItem('ShadowOps_ShotgunBreach');
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
	
	InventoryCondition = new class'X2Condition_UnitInventory';
	InventoryCondition.RelevantSlot = eInvSlot_PrimaryWeapon;
	InventoryCondition.ExcludeWeaponCategory = 'shotgun';
	Template.AbilityShooterConditions.AddItem(InventoryCondition);

	WeaponDamageEffect = new class'X2Effect_Breach';
	WeaponDamageEffect.EnvironmentalDamageAmount = default.BreachEnvironmentalDamage;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = default.BreachRange;
	Template.AbilityTargetStyle = CursorTarget;

	// Use SoldierBonusRadius because it grants the Danger Zone modifier,
	// but zero out BonusRadius so it isn't affected by Volatile Mix.
	RadiusMultiTarget = new class'XMBAbilityMultiTarget_SoldierBonusRadius';
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

static function X2AbilityTemplate ShotgunBreach()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local XMBAbilityMultiTarget_SoldierBonusRadius       RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitInventory			InventoryCondition;
	local AdditionalCooldownInfo			AdditionalCooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ShotgunBreach');
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
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
	AdditionalCooldown.AbilityName = 'ShadowOps_Breach';
	AdditionalCooldown.bUseAbilityCooldownNumTurns = true;
	Cooldown.AditionalAbilityCooldowns.AddItem(AdditionalCooldown);
	Template.AbilityCooldown = Cooldown;
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;
	
	InventoryCondition = new class'X2Condition_UnitInventory';
	InventoryCondition.RelevantSlot = eInvSlot_PrimaryWeapon;
	InventoryCondition.RequireWeaponCategory = 'shotgun';
	Template.AbilityShooterConditions.AddItem(InventoryCondition);

	WeaponDamageEffect = new class'X2Effect_Breach';
	WeaponDamageEffect.EnvironmentalDamageAmount = default.BreachEnvironmentalDamage;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = default.BreachShotgunRange;
	Template.AbilityTargetStyle = CursorTarget;

	// Use SoldierBonusRadius because it grants the Danger Zone modifier,
	// but zero out BonusRadius so it isn't affected by Volatile Mix.
	RadiusMultiTarget = new class'XMBAbilityMultiTarget_SoldierBonusRadius';
	RadiusMultiTarget.fTargetRadius = default.BreachShotgunRadius;
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
	DamageEffect.CritModifier = default.FractureCritModifier;
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
	local X2AbilityTemplate					Template;
	local XMBEffect_AbilityCostRefund       SlamFireEffect;

	SlamFireEffect = new class'XMBEffect_AbilityCostRefund';
	SlamFireEffect.EffectName = 'SlamFire';
	SlamFireEffect.TriggeredEvent = 'SlamFire';
	SlamFireEffect.bRequireAbilityWeapon = true;
	SlamFireEffect.AbilityTargetConditions.AddItem(default.CritCondition);
	SlamFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	Template = SelfTargetActivated('ShadowOps_SlamFire', "img:///UILibrary_BlackOps.UIPerk_slamfire", true, SlamFireEffect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, false, eCost_Free, default.SlamFireCooldown);

	class'X2Ability_RangerAbilitySet'.static.SuperKillRestrictions(Template, 'Serial_SuperKillCheck');
	Template.AddShooterEffectExclusions();

	return Template;
}

static function X2AbilityTemplate ChainReaction()
{
	local X2AbilityTemplate						Template;

	Template = PurePassive('ShadowOps_ChainReaction', "img:///UILibrary_PerkIcons.UIPerk_fuse", false);
	Template.AdditionalAbilities.AddItem('ShadowOps_ChainReactionFuse');

	return Template;
}

static function X2AbilityTemplate ChainReactionFuse()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ChainReactionFuse');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fuse";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'KillMail';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_KilledByExplosion');	
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_FuseTarget');	

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
	DelayAction.bIgnoreZipMode = true;
	DelayAction.Duration = 1.2;

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
	local XMBEffect_AddItemChargesBySlot            ItemChargesEffect;
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

	ItemChargesEffect = new class'XMBEffect_AddItemChargesBySlot';
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
	Effect.IncludeItemNames.AddItem('SmokeGrenade');
	Effect.IncludeItemNames.AddItem('SmokeGrenadeMk2');

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
	Effect.SelfConditions.AddItem(default.ReactionFireCondition);
	Effect.AddToHitAsTargetModifier(-default.MovingTargetDefenseBonus);
	Effect.AddToHitAsTargetModifier(default.MovingTargetDodgeBonus, eHit_Graze);

	return Passive('ShadowOps_MovingTarget', "img:///UILibrary_BlackOps.UIPerk_movingtarget", false, Effect);
}

static function X2AbilityTemplate Entrench()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Condition_UnitProperty          PropertyCondition;
	local X2Effect_Entrench				    PersistentStatChangeEffect;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local X2Condition_UnitEffects UnitEffectsCondition;
	local array<name>                       SkipExclusions;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Entrench');
	Template.OverrideAbilities.AddItem('HunkerDown');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_one_for_all";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.HUNKER_DOWN_PRIORITY;
	Template.bDisplayInUITooltip = false;

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.HunkerDownAbility_BuildVisualization;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.DeepCoverActionPoint);
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	PropertyCondition = new class'X2Condition_UnitProperty';	
	PropertyCondition.ExcludeDead = true;                           // Can't hunkerdown while dead
	PropertyCondition.ExcludeFriendlyToSource = false;              // Self targeted
	PropertyCondition.ExcludeNoCover = true;                        // Unit must be in cover.
	Template.AbilityShooterConditions.AddItem(PropertyCondition);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect('HunkerDown', 'AA_UnitIsImmune');
	UnitEffectsCondition.AddExcludeEffect('Entrench', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(UnitEffectsCondition);

	Template.AbilityToHitCalc = default.DeadEye;
		Template.AbilityTargetStyle = default.SelfTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	PersistentStatChangeEffect = new class'X2Effect_Entrench';
	PersistentStatChangeEffect.EffectName = 'Entrench';
	PersistentStatChangeEffect.BuildPersistentEffect(1 /* Turns */, true,,,eGameRule_PlayerTurnBegin);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.EntrenchDodge);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, default.EntrenchDefense);
	PersistentStatChangeEffect.DuplicateResponse = eDupe_Refresh;
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.AddTargetEffect(class'X2Ability_SharpshooterAbilitySet'.static.SharpshooterAimEffect());

	Template.Hostility = eHostility_Defensive;

	Template.bCrossClassEligible = true;
	
	return Template;
}
