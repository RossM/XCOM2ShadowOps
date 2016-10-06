class X2Ability_HunterAbilitySet extends XMBAbility
	config(GameData_SoldierSkills);

var localized string FadePenaltyText, SnapShotPenaltyText, BullseyePenaltyName, BullseyePenaltyText;

var config int SnapShotHitModifier;
var config int HunterMarkHitModifier;
var config int PrecisionOffenseBonus;
var config int LowProfileDefenseBonus;
var config int SliceAndDiceHitModifier;
var config int BullseyeOffensePenalty, BullseyeDefensePenalty, BullseyeWillPenalty;
var config int FirstStrikeDamageBonus;
var config int DamnGoodGroundOffenseBonus, DamnGoodGroundDefenseBonus;
var config float TrackingRadius;
var config array<ExtShotModifierInfo> VitalPointModifiers;
var config float PointBlankMultiplier;
var config float ButcherDamageMultiplier;
var config int StalkerMobilityBonus;
var config int LastStandDuration, LastStandCharges;

var config int HunterMarkCooldown, SprintCooldown, FadeCooldown, SliceAndDiceCooldown, BullseyeCooldown, RepositionCooldown;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(SnapShot());
	Templates.AddItem(SnapShotShot());
	Templates.AddItem(SnapShotOverwatch());
	Templates.AddItem(HunterMark());
	Templates.AddItem(VitalPoint());
	Templates.AddItem(Precision());
	Templates.AddItem(LowProfile());
	Templates.AddItem(Sprint());
	Templates.AddItem(Assassin());
	Templates.AddItem(AssassinTrigger());
	Templates.AddItem(Fade());
	Templates.AddItem(SliceAndDice());
	Templates.AddItem(SliceAndDice2());
	Templates.AddItem(Tracking());
	Templates.AddItem(TrackingTrigger());
	Templates.AddItem(TrackingSpawnTrigger());
	Templates.AddItem(Bullseye());
	Templates.AddItem(FirstStrike());
	Templates.AddItem(DamnGoodGround());
	Templates.AddItem(PointBlank());
	Templates.AddItem(Butcher());
	Templates.AddItem(Reposition());
	Templates.AddItem(Evasive());
	Templates.AddItem(Stalker());
	Templates.AddItem(LastStand());

	return Templates;
}

static function X2AbilityTemplate SnapShot()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('ShadowOps_SnapShot', "img:///UILibrary_PerkIcons.UIPerk_snapshot", false);
	Template.AdditionalAbilities.AddItem('ShadowOps_SnapShotShot');
	Template.AdditionalAbilities.AddItem('ShadowOps_SnapShotOverwatch');

	return Template;
}

static function X2AbilityTemplate SnapShotShot()
{
	local X2AbilityTemplate					Template;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('ShadowOps_SnapShotShot');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_snapshot_shot";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
	Template.HideIfAvailable.AddItem('SniperStandardFire');

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.SnapShotHitModifier;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	return Template;
}

static function X2AbilityTemplate SnapShotOverwatch()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2Effect_ReserveActionPoints      ReserveActionPointsEffect;
	local array<name>                       SkipExclusions;
	local X2Effect_CoveringFire             CoveringFireEffect;
	local X2Condition_AbilityProperty       CoveringFireCondition;
	local X2Condition_UnitProperty          ConcealedCondition;
	local X2Effect_SetUnitValue             UnitValueEffect;
	local X2Condition_UnitEffects           SuppressedCondition;
	local X2Effect_PersistentStatChange		LowerAimEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_SnapShotOverwatch');
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;                  //  ammo is consumed by the shot, not by this, but this should verify ammo is available
	Template.AbilityCosts.AddItem(AmmoCost);
	
	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Overwatch));
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);
	
	ReserveActionPointsEffect = new class'X2Effect_ReserveOverwatchPoints';
	Template.AddTargetEffect(ReserveActionPointsEffect);

	LowerAimEffect = new class'X2Effect_PersistentStatChange';
	LowerAimEffect.BuildPersistentEffect(1,,,,eGameRule_PlayerTurnBegin);
	LowerAimEffect.AddPersistentStatChange(eStat_Offense, default.SnapShotHitModifier);
	LowerAimEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, default.SnapShotPenaltyText, "img:///UILibrary_PerkIcons.UIPerk_snapshot", true);
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
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
	Template.HideIfAvailable.AddItem('SniperRifleOverwatch');
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_snapshot_overwatch";
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
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_Visibility TargetVisibilityCondition;
	local X2Condition_UnitEffects UnitEffectsCondition;
	local X2AbilityTarget_Single SingleTarget;
	local X2AbilityTrigger_PlayerInput InputTrigger;
	local X2Effect_Persistent MarkedEffect;
	local X2AbilityCooldown Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_HunterMark');

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_huntermark";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HunterMarkCooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Single));

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

	// Create the Marked effect
	MarkedEffect = CreateMarkedEffect(1, true);

	Template.AddTargetEffect(MarkedEffect); //BMU - changing to an immediate execution for evaluation

	Template.CustomFireAnim = 'HL_SignalPoint';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = HunterMark_BuildVisualization;
	Template.CinescriptCameraType = "Mark_Target";
	
	Template.bCrossClassEligible = true;

	return Template;
}

static function X2Effect_PersistentStatChange CreateMarkedEffect(int NumTurns, bool bIsInfinite)
{
	local X2Effect_PersistentStatChange MarkedEffect;

	MarkedEffect = new class 'X2Effect_PersistentStatChange';
	MarkedEffect.EffectName = class'X2StatusEffects'.default.MarkedName;
	MarkedEffect.DuplicateResponse = eDupe_Ignore;
	MarkedEffect.AddPersistentStatChange(eStat_Defense, -default.HunterMarkHitModifier);
	MarkedEffect.BuildPersistentEffect(NumTurns, bIsInfinite, true,,eGameRule_PlayerTurnEnd);
	MarkedEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.MarkedFriendlyName, class'X2StatusEffects'.default.MarkedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_mark");
	MarkedEffect.VisualizationFn = class'X2StatusEffects'.static.MarkedVisualization;
	MarkedEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.MarkedVisualizationTicked;
	MarkedEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.MarkedVisualizationRemoved;
	MarkedEffect.bRemoveWhenTargetDies = true;
	MarkedEffect.bUniqueTarget = true;

	return MarkedEffect;
}

function HunterMark_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameState_Effect		EffectState;
	local VisualizationTrack        EmptyTrack;
	local VisualizationTrack        BuildTrack;
	local Actor                     TargetVisualizer;
	local XComGameStateHistory      History;
	local name						EffectApplyResult;
	local X2Effect_Persistent		Effect;
	local XComGameStateContext_Ability  Context;
	
	TypicalAbility_BuildVisualization(VisualizeGameState, OutVisualizationTracks);
		
	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	//  We are assuming that any removed effects were cleansed by the RemoveEffects. If this turns out to not be a good assumption, something will have to change.
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		if (EffectState.bRemoved)
		{
			TargetVisualizer = History.GetVisualizer(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

			BuildTrack = EmptyTrack;
			BuildTrack.TrackActor = TargetVisualizer;
			BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

			Effect = EffectState.GetX2Effect();
			EffectApplyResult = Context.FindTargetEffectApplyResult(Effect);
			Effect.AddX2ActionsForVisualization_Removed(VisualizeGameState, BuildTrack, EffectApplyResult, EffectState);

			OutVisualizationTracks.AddItem(BuildTrack);
		}
	}		
}

static function X2AbilityTemplate VitalPoint()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.Modifiers = default.VitalPointModifiers;
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	return Passive('ShadowOps_VitalPoint', "img:///UILibrary_BlackOps.UIPerk_vitalpoint", false, Effect);
}

static function X2AbilityTemplate Precision()
{
	local XMBEffect_ConditionalBonus             PrecisionEffect;

	PrecisionEffect = new class'XMBEffect_ConditionalBonus';
	PrecisionEffect.AbilityTargetConditions.AddItem(default.FullCoverCondition);
	PrecisionEffect.AddToHitModifier(default.PrecisionOffenseBonus);

	return Passive('ShadowOps_Precision', "img:///UILibrary_BlackOps.UIPerk_precision", true, PrecisionEffect);
}

static function X2AbilityTemplate LowProfile()
{
	local XMBEffect_ConditionalBonus             LowProfileEffect;

	LowProfileEffect = new class'XMBEffect_ConditionalBonus';
	LowProfileEffect.AbilityTargetConditionsAsTarget.AddItem(default.HalfCoverCondition);
	LowProfileEffect.AddToHitAsTargetModifier(-default.LowProfileDefenseBonus);

	return Passive('ShadowOps_LowProfile', "img:///UILibrary_BlackOps.UIPerk_lowprofile", true, LowProfileEffect);
}

static function X2AbilityTemplate Sprint()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_GrantActionPoints		ActionPointEffect;
	local X2AbilityTargetStyle              TargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Sprint');
	
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_sprint";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Free));
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SprintCooldown;
	Template.AbilityCooldown = Cooldown;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
	Template.AddTargetEffect(ActionPointEffect);

	Template.AddShooterEffectExclusions();

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	
	Template.bCrossClassEligible = true;

	return Template;	
}

static function X2AbilityTemplate Assassin()
{
	local X2AbilityTemplate						Template;
	local XMBEffect_AbilityTriggered						Effect;

	Effect = new class'XMBEffect_AbilityTriggered';
	Effect.EffectName = 'Assassin';
	Effect.TriggeredEvent = 'Assassin';
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);
	Effect.AbilityTargetConditions.AddItem(default.DeadCondition);
	Effect.AbilityTargetConditions.AddItem(default.NoCoverCondition);

	Template = Passive('ShadowOps_Assassin', "img:///UILibrary_BlackOps.UIPerk_assassin", true, Effect);
	Template.AdditionalAbilities.AddItem('ShadowOps_AssassinTrigger');

	return Template;
}


static function X2AbilityTemplate AssassinTrigger()
{
	local X2AbilityTemplate Template;
	local X2Effect_RangerStealth StealthEffect;

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;

	Template = SelfTargetTrigger('ShadowOps_AssassinTrigger', "img:///UILibrary_BlackOps.UIPerk_assassin", false, StealthEffect, 'Assassin');

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';

	return Template;
}

static function X2AbilityTemplate Fade()
{
	local X2AbilityTemplate						Template;
	local X2Effect_RangerStealth				StealthEffect;

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	StealthEffect.EffectAddedFn = Fade_EffectAdded;

	Template = SelfTargetActivated('ShadowOps_Fade', "img:///UILibrary_BlackOps.UIPerk_fade", true, StealthEffect, class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY, eCost_Single);
	AddCooldown(Template, default.FadeCooldown);

	StealthEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, default.FadePenaltyText, Template.IconImage, true);

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');
	Template.AddShooterEffectExclusions();
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());
	Template.ActivationSpeech = 'ActivateConcealment';

	return Template;
}

static function Fade_EffectAdded(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
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


static function X2AbilityTemplate SliceAndDice()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local X2AbilityCooldown                 Cooldown;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_SliceAndDice');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_sliceanddice";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_SingleConsumeAll));
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SliceAndDiceCooldown;
	Template.AbilityCooldown = Cooldown;

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	StandardMelee.BuiltInHitMod = default.SliceAndDiceHitModifier;
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.AdditionalAbilities.AddItem('ShadowOps_SliceAndDice2');
	Template.PostActivationEvents.AddItem('ShadowOps_SliceAndDice2');

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	Template.DamagePreviewFn = SliceAndDiceDamagePreview;

	Template.bCrossClassEligible = false;

	return Template;
}

function bool SliceAndDiceDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit AbilityOwner;
	local StateObjectReference SliceAndDice2Ref;
	local XComGameState_Ability SliceAndDice2Ability;
	local XComGameStateHistory History;

	AbilityState.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);

	History = `XCOMHISTORY;
	AbilityOwner = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	SliceAndDice2Ref = AbilityOwner.FindAbility('SliceAndDice2');
	SliceAndDice2Ability = XComGameState_Ability(History.GetGameStateForObjectID(SliceAndDice2Ref.ObjectID));
	if (SliceAndDice2Ability == none)
	{
		`RedScreenOnce("Unit has SliceAndDice but is missing SliceAndDice2. Not good. -jbouscher @gameplay");
	}
	else
	{
		SliceAndDice2Ability.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	}
	return true;
}

static function X2AbilityTemplate SliceAndDice2()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;
	local array<name>                       SkipExclusions;
	local X2AbilityTrigger_EventListener    Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_SliceAndDice2');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_sliceanddice";

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'ShadowOps_SliceAndDice2';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.ChainShotListener;
	Template.AbilityTriggers.AddItem(Trigger);

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	StandardMelee.BuiltInHitMod = default.SliceAndDiceHitModifier;
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	return Template;
}

static function X2AbilityTemplate Tracking()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('ShadowOps_Tracking', "img:///UILibrary_BlackOps.UIPerk_tracking", true);
	Template.AdditionalAbilities.AddItem('ShadowOps_TrackingTrigger');
	Template.AdditionalAbilities.AddItem('ShadowOps_TrackingSpawnTrigger');

	return Template;
}

static function X2AbilityTemplate TrackingTrigger()
{
	local X2AbilityTemplate             Template;
	local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
	local XMBEffect_RevealUnit     TrackingEffect;
	local X2Condition_UnitProperty      TargetProperty;
	local X2Condition_UnitEffects		EffectsCondition;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_TrackingTrigger');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_tracking";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsNotPlayerControlled');
	Template.AbilityShooterConditions.AddItem(EffectsCondition);

	Template.AbilityTargetStyle = default.SelfTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.TrackingRadius;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.FailOnNonUnits = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	Template.AbilityMultiTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_Burrowed'.default.EffectName, 'AA_UnitIsBurrowed');
	Template.AbilityMultiTargetConditions.AddItem(EffectsCondition);

	TrackingEffect = new class'XMBEffect_RevealUnit';
	TrackingEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddMultiTargetEffect(TrackingEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitMoveFinished';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'PlayerTurnBegun';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

// This triggers whenever a unit is spawned within tracking radius. The most likely
// reason for this to happen is a Faceless transforming due to tracking being applied.
// The newly spawned Faceless unit won't have the tracking effect when this happens,
// so we apply it here.
static function X2AbilityTemplate TrackingSpawnTrigger()
{
	local X2AbilityTemplate             Template;
	local XMBEffect_RevealUnit     TrackingEffect;
	local X2Condition_UnitProperty      TargetProperty;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_TrackingSpawnTrigger');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_tracking";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.FailOnNonUnits = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = default.TrackingRadius * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	TrackingEffect = new class'XMBEffect_RevealUnit';
	TrackingEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddTargetEffect(TrackingEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitSpawned';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	EventListener.ListenerData.Filter = eFilter_None;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate Bullseye()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_Visibility			TargetVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Bullseye');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_bullseye";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.DisplayTargetHitChance = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// *** VALIDITY CHECKS *** //
	Template.AddShooterEffectExclusions();

	// Targeting Details
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

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_WeaponConsumeAll));	

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.BullseyeCooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AddTargetEffect(BuildRattledEffect(Template.IconImage, Template.AbilitySourceName));

	// Weapon Upgrade Compatibility
	Template.bAllowFreeFireWeaponUpgrade = true;                                            // Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AssociatedPassives.AddItem('HoloTargeting');

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bHitsAreCrits = true;
	Template.AbilityToHitCalc = StandardAim;
	Template.AbilityToHitOwnerOnMissCalc = StandardAim;
		
	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	

	Template.bCrossClassEligible = false;

	return Template;	
}

static function X2Effect_Persistent BuildRattledEffect(string IconImage, name AbilitySourceName)
{
	local X2Effect_PersistentStatChange		RattledEffect;

	RattledEffect = new class'X2Effect_PersistentStatChange';
	RattledEffect.EffectName = 'Bullseye';
	RattledEffect.BuildPersistentEffect(1, true, true, true);
	RattledEffect.SetDisplayInfo(ePerkBuff_Penalty, default.BullseyePenaltyName, default.BullseyePenaltyText, IconImage,,,AbilitySourceName);
	RattledEffect.AddPersistentStatChange(eStat_Offense, default.BullseyeOffensePenalty);
	RattledEffect.AddPersistentStatChange(eStat_Defense, default.BullseyeDefensePenalty);
	RattledEffect.AddPersistentStatChange(eStat_Will, default.BullseyeWillPenalty);
	RattledEffect.VisualizationFn = RattledVisualization;

	return RattledEffect;
}

static function RattledVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	
	if (EffectApplyResult == 'AA_Success')
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, default.BullseyePenaltyName, '', eColor_Bad);
	}
}

static function X2AbilityTemplate FirstStrike()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_FirstStrike Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(default.FirstStrikeDamageBonus);
	Effect.bIgnoreSquadSightPenalty = true;
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	Condition = new class'X2Condition_FirstStrike';
	Effect.AbilityTargetConditions.AddItem(Condition);

	return Passive('ShadowOps_FirstStrike', "img:///UILibrary_BlackOps.UIPerk_firststrike", true, Effect);
}

static function X2AbilityTemplate DamnGoodGround()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'DamnGoodGround';
	Effect.AddToHitModifier(default.DamnGoodGroundOffenseBonus);
	Effect.AddToHitAsTargetModifier(-default.DamnGoodGroundDefenseBonus);

	// This condition applies when the unit is the target
	Effect.AbilityTargetConditionsAsTarget.AddItem(default.HeightAdvantageCondition);

	// This condition applies when the unit is the attacker
	Effect.AbilityTargetConditions.AddItem(default.HeightDisadvantageCondition);

	return Passive('ShadowOps_DamnGoodGround', "img:///UILibrary_BlackOps.UIPerk_damngoodground", true, Effect);
}

static function X2AbilityTemplate PointBlank()
{
	local X2Effect_PointBlank Effect;

	Effect = new class'X2Effect_PointBlank';
	Effect.RangePenaltyMultiplier = default.PointBlankMultiplier;

	return Passive('ShadowOps_PointBlank', "img:///UILibrary_BlackOps.UIPerk_AWC", false, Effect);
}

static function X2AbilityTemplate Butcher()
{
	local X2Effect_Butcher Effect;

	Effect = new class'X2Effect_Butcher';
	Effect.DamageMultiplier = default.ButcherDamageMultiplier;

	return Passive('ShadowOps_Butcher', "img:///UILibrary_BlackOps.UIPerk_AWC", false, Effect);
}

static function X2AbilityTemplate Reposition()
{
	local X2AbilityTemplate Template, SecondaryTemplate;
	local X2Effect_GrantActionPoints Effect;

	Template = Attack('ShadowOps_Reposition', "img:///UILibrary_BlackOps.UIPerk_reposition", false,, class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY + 10, eCost_WeaponConsumeAll);
	Template.PostActivationEvents.AddItem('RepositionActivated');
	AddCooldown(Template, default.RepositionCooldown);

	Effect = new class'X2Effect_GrantActionPoints';
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
	Effect.NumActionPoints = 1;
	SecondaryTemplate = SelfTargetTrigger('ShadowOps_RepositionTrigger', "img:///UILibrary_BlackOps.UIPerk_reposition", false, Effect, 'RepositionActivated');
	SecondaryTemplate.bShowActivation = true;

	AddSecondaryAbility(Template, SecondaryTemplate);

	return Template;
}

static function X2AbilityTemplate Evasive()
{
	return Passive('ShadowOps_Evasive', "img:///UILibrary_BlackOps.UIPerk_AWC", false, new class'X2Effect_Evasive');
}

static function X2AbilityTemplate Stalker()
{
	local XMBEffect_ConditionalStatChange Effect;

	Effect = new class'XMBEffect_ConditionalStatChange';
	Effect.AddPersistentStatChange(eStat_Mobility, default.StalkerMobilityBonus);
	Effect.Conditions.AddItem(new class'XMBCondition_Concealed');

	return Passive('ShadowOps_Stalker', "img:///UILibrary_BlackOps.UIPerk_AWC", false, Effect);
}

static function X2AbilityTemplate LastStand()
{
	local X2Effect_LastStand Effect;
	local X2AbilityTemplate Template;

	Effect = new class'X2Effect_LastStand';
	Effect.BuildPersistentEffect(default.LastStandDuration, false, true, false, eGameRule_PlayerTurnEnd);

	Template = SelfTargetActivated('ShadowOps_LastStand', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect,, eCost_Free);
	AddCharges(Template, default.LastStandCharges);

	return Template;
}