class X2Ability_EngineerAbilitySet extends XMBAbility
	config(GameData_SoldierSkills);

var config int AggressionCritModifier, AggressionMaxCritModifier, AggressionGrenadeCritDamage;
var config int BreachEnvironmentalDamage;
var config float BreachRange, BreachRadius;
var config float DangerZoneBonusRadius, DangerZoneBreachBonusRadius;
var config int MovingTargetDefenseBonus, MovingTargetDodgeBonus;
var config int EntrenchDefense, EntrenchDodge;
var config int FocusedDefenseDefense, FocusedDefenseDodge;
var config int FractureCritModifier;
var config int LineEmUpOffense, LineEmUpCrit;
var config float ControlledDetonationDamageReduction;
var config int MayhemDamageBonus;
var config array<name> MayhemExcludeAbilities;
var config int SaboteurDamageBonus;
var config int AnatomistDamageBonus, AnatomistMaxKills;
var config float HeatAmmoDamageMultiplier;

var config int BreachCooldown, FastballCooldown, FractureCooldown, SlamFireCooldown;
var config int BreachAmmo, FractureAmmo;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(DeepPockets());
	Templates.AddItem(DenseSmoke());			// Non-LW only
	Templates.AddItem(SmokeAndMirrors());
	Templates.AddItem(Breach());
	Templates.AddItem(Fastball());
	Templates.AddItem(FastballRemovalTrigger());
	Templates.AddItem(FractureAbility());
	Templates.AddItem(FractureDamage());
	Templates.AddItem(Packmaster());
	Templates.AddItem(Entrench());
	Templates.AddItem(Aggression());			// Non-LW only
	Templates.AddItem(PurePassive('ShadowOps_CombatDrugs', "img:///UILibrary_BlackOps.UIPerk_combatdrugs", true));
	Templates.AddItem(SlamFire());
	Templates.AddItem(DangerZone());
	Templates.AddItem(ChainReaction());			// Unused
	Templates.AddItem(ChainReactionFuse());		// Unused
	Templates.AddItem(HeatAmmo());
	Templates.AddItem(MovingTarget());
	Templates.AddItem(SlugShot());				// Unused
	Templates.AddItem(Pyromaniac());
	Templates.AddItem(HitAndRun());
	Templates.AddItem(FocusedDefense());
	Templates.AddItem(LineEmUp());				// Unused
	Templates.AddItem(ControlledDetonation());	// Unused
	Templates.AddItem(DevilsLuck());
	Templates.AddItem(Mayhem());
	Templates.AddItem(Saboteur());
	Templates.AddItem(Anatomist());
	Templates.AddItem(ExtraMunitions());

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
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityTarget_Cursor            CursorTarget;
	local XMBAbilityMultiTarget_Radius      RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitInventory			InventoryCondition;
	local AdditionalCooldownInfo			AdditionalCooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Breach');
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_breach";
	Template.Hostility = eHostility_Offensive;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	Template.TargetingMethod = class'X2TargetingMethod_Breach';

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = default.BreachAmmo;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	Template.AbilityCosts.AddItem(ActionPointCost(eCost_WeaponConsumeAll));
	
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
	CursorTarget.FixedAbilityRange = default.BreachRange;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'XMBAbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.BreachRadius;
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
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_Persistent				FastballEffect;
	local X2AbilityTargetStyle              TargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Fastball');
	
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fastball";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.Hostility = eHostility_Neutral;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Free));
	
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
	FastballEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, "img:///UILibrary_PerkIcons.UIPerk_bombard", true);
	Template.AddTargetEffect(FastballEffect);

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

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_WeaponConsumeAll));

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
	SlamFireEffect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);
	SlamFireEffect.AbilityTargetConditions.AddItem(default.CritCondition);
	SlamFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	Template = SelfTargetActivated('ShadowOps_SlamFire', "img:///UILibrary_BlackOps.UIPerk_slamfire", true, SlamFireEffect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Free);
	AddCooldown(Template, default.SlamFireCooldown);

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
	Effect.DamageMultiplier = default.HeatAmmoDamageMultiplier;

	return Passive('ShadowOps_HeatAmmo', "img:///UILibrary_BlackOps.UIPerk_heatammo", true, Effect);
}

static function X2AbilityTemplate MovingTarget()
{
	local XMBEffect_ConditionalBonus             Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AbilityTargetConditionsAsTarget.AddItem(default.ReactionFireCondition);
	Effect.AddToHitAsTargetModifier(-default.MovingTargetDefenseBonus);
	Effect.AddToHitAsTargetModifier(default.MovingTargetDodgeBonus, eHit_Graze);

	return Passive('ShadowOps_MovingTarget', "img:///UILibrary_BlackOps.UIPerk_movingtarget", false, Effect);
}

static function X2AbilityTemplate Entrench()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        AbilityActionPointCost;
	local X2Condition_UnitProperty          PropertyCondition;
	local X2Effect_PersistentStatChange	    PersistentStatChangeEffect;
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

	AbilityActionPointCost = ActionPointCost(eCost_SingleConsumeAll);
	AbilityActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.DeepCoverActionPoint);
	Template.AbilityCosts.AddItem(AbilityActionPointCost);
	
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

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.EffectName = 'HunkerDown';
	PersistentStatChangeEffect.BuildPersistentEffect(1 /* Turns */, true,,,eGameRule_PlayerTurnBegin);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.EntrenchDodge);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, default.EntrenchDefense);
	PersistentStatChangeEffect.DuplicateResponse = eDupe_Refresh;
	PersistentStatChangeEffect.EffectAddedFn = Entrench_EffectAdded;
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.AddTargetEffect(class'X2Ability_SharpshooterAbilitySet'.static.SharpshooterAimEffect());

	Template.Hostility = eHostility_Defensive;

	Template.bCrossClassEligible = true;
	
	return Template;
}

static function Entrench_EffectAdded(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectGameState;

	UnitState = XComGameState_Unit( NewGameState.CreateStateObject( class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID ) );
	EffectGameState = UnitState.GetUnitAffectedByEffectState(PersistentEffect.EffectName);

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'ObjectMoved', EffectGameState.GenerateCover_ObjectMoved, ELD_OnStateSubmitted, , UnitState);
}



static function X2AbilityTemplate SlugShot()
{
	local X2AbilityTemplate Template;

	// Create the template using a helper function
	// TODO: icon
	Template = Attack('ShadowOps_SlugShot', "img:///UILibrary_BlackOps.UIPerk_AWC", true, none, , eCost_WeaponConsumeAll, 1);

	// Add a cooldown. The internal cooldown numbers include the turn the cooldown is applied, so
	// this is actually a 2 turn cooldown.
	AddCooldown(Template, 3);

	// Add a secondary ability to provide bonuses on the shot
	AddSecondaryAbility(Template, SlugShotBonuses());

	return Template;
}

static function X2AbilityTemplate SlugShotBonuses()
{
	local X2AbilityTemplate Template;
	local X2Effect_SlugShot Effect;
	local XMBCondition_AbilityName Condition;

	// Create a conditional bonus effect
	Effect = new class'X2Effect_SlugShot';
	Effect.EffectName = 'SlugShotBonuses';

	// The bonus only applies to the Slug Shot ability
	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('ShadowOps_SlugShot');
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Create the template using a helper function
	// TODO: icon
	Template = Passive('ShadowOps_SlugShotBonuses', "img:///UILibrary_BlackOps.UIPerk_AWC", false, Effect);

	// The Slug Shot ability will show up as an active ability, so hide the icon for the passive damage effect
	HidePerkIcon(Template);

	return Template;
}

static function X2AbilityTemplate Pyromaniac()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	// TODO: icon
	Template = Passive('ShadowOps_Pyromaniac', "img:///UILibrary_BlackOps.UIPerk_pyromaniac", true);

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'Firebomb';
	Template.AddTargetEffect(ItemEffect);

	return Template;
}

// Perk name:		Hit and Run
// Perk effect:		Move after taking a single action that would normally end your turn.
// Localized text:	"Move after taking a single action that would normally end your turn."
// Config:			(AbilityName="XMBExample_HitAndRun")
static function X2AbilityTemplate HitAndRun()
{
	local X2Effect_GrantActionPoints Effect;
	local X2AbilityTemplate Template;
	local XMBCondition_AbilityCost CostCondition;
	local XMBCondition_AbilityName NameCondition;

	// Add a single movement-only action point to the unit
	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;

	// Create a triggered ability that will activate whenever the unit uses an ability that meets the condition
	// TODO: icon
	Template = SelfTargetTrigger('ShadowOps_HitAndRun', "img:///UILibrary_BlackOps.UIPerk_skirmisher", false, Effect, 'AbilityActivated');

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	AddIconPassive(Template);

	// Require that the activated ability costs 1 action point, but actually spent at least 2
	CostCondition = new class'XMBCondition_AbilityCost';
	CostCondition.bRequireMaximumCost = true;
	CostCondition.MaximumCost = 1;
	CostCondition.bRequireMinimumPointsSpent = true;
	CostCondition.MinimumPointsSpent = 2;
	AddTriggerTargetCondition(Template, CostCondition);

	// Exclude Hunker Down
	NameCondition = new class'XMBCondition_AbilityName';
	NameCondition.ExcludeAbilityNames.AddItem('HunkerDown');
	NameCondition.ExcludeAbilityNames.AddItem('ShadowOps_Entrench');
	AddTriggerTargetCondition(Template, NameCondition);

	// Show a flyover when Hit and Run is activated
	Template.bShowActivation = true;

	return Template;
}

static function X2AbilityTemplate FocusedDefense()
{
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_CoverType NotFlankedCondition;

	NotFlankedCondition = new class'XMBCondition_CoverType';
	NotFlankedCondition.ExcludedCoverTypes.AddItem(CT_None);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitAsTargetModifier(-default.FocusedDefenseDefense, eHit_Success);
	Effect.AddToHitAsTargetModifier(default.FocusedDefenseDodge, eHit_Graze);

	Effect.AbilityTargetConditionsAsTarget.AddItem(NotFlankedCondition);
	Effect.AbilityTargetConditionsAsTarget.AddItem(new class'X2Condition_ClosestVisibleEnemy');

	// TODO: icon
	return Passive('ShadowOps_FocusedDefense', "img:///UILibrary_BlackOps.UIPerk_focuseddefense", true, Effect);
}

static function X2AbilityTemplate LineEmUp()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.LineEmUpOffense, eHit_Success);
	Effect.AddToHitModifier(default.LineEmUpCrit, eHit_Crit);

	Effect.AbilityTargetConditions.AddItem(new class'X2Condition_ClosestVisibleEnemy');

	// TODO: icon
	return Passive('ShadowOps_LineEmUp', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate ControlledDetonation()
{
	local X2Effect_ControlledDetonation Effect;

	Effect = new class'X2Effect_ControlledDetonation';
	Effect.ReductionAmount = default.ControlledDetonationDamageReduction;

	Effect.AbilityTargetConditions.AddItem(default.LivingFriendlyTargetProperty);

	// TODO: icon
	return Passive('ShadowOps_ControlledDetonation', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate DevilsLuck()
{
	local X2AbilityTemplate Template;

	// TODO: icon
	Template = Passive('ShadowOps_DevilsLuck', "img:///UILibrary_BlackOps.UIPerk_devilsluck", true, new class'X2Effect_DevilsLuck');

	// Add a secondary ability to provide bonuses on the shot
	AddSecondaryAbility(Template, DevilsLuckTrigger());

	return Template;
}

static function X2AbilityTemplate DevilsLuckTrigger()
{
	local X2AbilityTemplate Template;
	local X2Effect_SetUnitValue Effect;
	local XMBCondition_AbilityHitResult HitResultCondition;
	local X2Condition_Untouchable UntouchableCondition;

	Effect = new class'X2Effect_SetUnitValue';
	Effect.UnitName = 'DevilsLuckUsed';
	Effect.NewValueToSet = 1;
	Effect.CleanupType = eCleanup_BeginTactical;

	// TODO: icon
	Template = SelfTargetTrigger('ShadowOps_DevilsLuckTrigger', "img:///UILibrary_BlackOps.UIPerk_devilsluck", false, Effect, 'AbilityActivated', eFilter_None);
	XMBAbilityTrigger_EventListener(Template.AbilityTriggers[0]).bAsTarget = true;

	HitResultCondition = new class'XMBCondition_AbilityHitResult';
	HitResultCondition.IncludeHitResults.AddItem(eHit_Untouchable);
	AddTriggerTargetCondition(Template, HitResultCondition);

	UntouchableCondition = new class'X2Condition_Untouchable';
	UntouchableCondition.AddCheckValue(0, eCheck_LessThan);
	AddTriggerTargetCondition(Template, UntouchableCondition);

	// Increment Untouchable so it goes back to 0
	Template.AddTargetEffect(new class'X2Effect_IncrementUntouchable');

	return Template;
}

static function X2AbilityTemplate Mayhem()
{
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_AbilityName Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(default.MayhemDamageBonus);

	Condition = new class'XMBCondition_AbilityName';
	Condition.ExcludeAbilityNames = default.MayhemExcludeAbilities;
	Effect.AbilityTargetConditions.AddItem(Condition);

	// TODO: icon
	return Passive('ShadowOps_Mayhem', "img:///UILibrary_BlackOps.UIPerk_mayhem", true, Effect);
}

static function X2AbilityTemplate Saboteur()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local XMBCondition_AbilityName AbilityNameCondition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(default.SaboteurDamageBonus);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeAlive = true;
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.FailOnNonUnits = false;
	Effect.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('StandardShot');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	// TODO: icon
	return Passive('ShadowOps_Saboteur', "img:///UILibrary_BlackOps.UIPerk_saboteur", false, Effect);
}

static function X2AbilityTemplate Anatomist()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(default.AnatomistDamageBonus, eHit_Crit);

	Effect.ScaleValue = new class'X2Value_Anatomist';
	Effect.ScaleMax = default.AnatomistMaxKills;

	return Passive('ShadowOps_Anatomist', "img:///UILibrary_BlackOps.UIPerk_anatomist", true, Effect);
}

static function X2AbilityTemplate ExtraMunitions()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	Template = Passive('ShadowOps_ExtraMunitions', "img:///UILibrary_BlackOps.UIPerk_extramunitions", true);

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'FragGrenade';
	Template.AddTargetEffect(ItemEffect);

	return Template;
}
