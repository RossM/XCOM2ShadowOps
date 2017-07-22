class X2Ability_EngineerAbilitySet extends XMBAbility
	config(GameData_SoldierSkills);

var config int AggressionCritModifier, AggressionMaxCritModifier, AggressionGrenadeCritDamage;
var config int BreachEnvironmentalDamage;
var config float BreachRange, BreachRadius;
var config array<name> DangerZoneAbilityName;
var config array<int> DangerZoneAbilityBonusRadius;
var config int MovingTargetDefenseBonus, MovingTargetDodgeBonus;
var config int EntrenchDefense, EntrenchDodge;
var config int FocusedDefenseDefense, FocusedDefenseDodge;
var config int FractureCritModifier;
var config int LineEmUpOffense, LineEmUpCrit;
var config int MayhemDamageBonus, MayhemLW2DamageBonus, MayhemLW2DamageOverTimeBonus;
var config array<name> MayhemExcludeAbilities;
var config int SaboteurDamageBonus;
var config int AnatomistDamageBonus, AnatomistMaxKills;
var config float HeatAmmoDamageMultiplier;
var config WeaponDamageValue BullRushDamage;
var config int BullRushHitModifier, BullRushCritModifier;
var config float BareKnuckleDamageBonus, BareKnuckleDamageBonusPerRank;
var config int DemoGrenadesEnvironmentDamageBonus;
var config int ElusiveDodge, ElusiveRange;
var config array<name> MadBomberGrenades;
var config array<ExtShotModifierInfo> FractureLW2Modifiers;
var config array<name> ExplosiveGrenades;
var config int CombatDrugsOffenseBonus, CombatDrugsWillBonus, CombatDrugsDuration;
var config float DenseSmokeBonusRadius;

var config int BreachCooldown, FastballCooldown, FractureCooldown, SlamFireCooldown;
var config int BreachAmmo, FractureAmmo;

var localized string CombatDrugsName, CombatDrugsDescription;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(DeepPockets());
	Templates.AddItem(DenseSmoke());			// Non-LW only
	Templates.AddItem(SmokeAndMirrors());
	Templates.AddItem(SmokeAndMirrors_LW2());
	Templates.AddItem(Breach());
	Templates.AddItem(Fastball());
	Templates.AddItem(FractureAbility());
	Templates.AddItem(FractureDamage());
	Templates.AddItem(Packmaster());
	Templates.AddItem(Entrench());
	Templates.AddItem(Aggression());			// Non-LW only
	Templates.AddItem(PurePassive('ShadowOps_CombatDrugs', "img:///UILibrary_SOCombatEngineer.UIPerk_combatdrugs", true));
	Templates.AddItem(SlamFire());
	Templates.AddItem(DangerZone());
	Templates.AddItem(ChainReaction());			// Unused
	Templates.AddItem(ChainReactionFuse());		// Unused
	Templates.AddItem(HeatAmmo());
	Templates.AddItem(MovingTarget());
	Templates.AddItem(Pyromaniac());
	Templates.AddItem(HitAndRun());
	Templates.AddItem(FocusedDefense());
	Templates.AddItem(LineEmUp());				// Unused
	Templates.AddItem(ControlledDetonation());	// Unused
	Templates.AddItem(DevilsLuck());
	Templates.AddItem(Mayhem());
	Templates.AddItem(Mayhem_LW2());
	Templates.AddItem(Saboteur());
	Templates.AddItem(Anatomist());
	Templates.AddItem(ExtraMunitions());
	Templates.AddItem(ExtraMunitions_LW2());
	Templates.AddItem(BullRush());
	Templates.AddItem(BareKnuckle());
	Templates.AddItem(PurePassive('ShadowOps_DemoGrenades', "img:///UILibrary_SOCombatEngineer.UIPerk_demogrenades", false));
	Templates.AddItem(Elusive());
	Templates.AddItem(MadBomber());
	Templates.AddItem(Fracture_LW2());

	return Templates;
}

static function X2Effect CombatDrugsEffect()
{
	local X2Effect_PersistentStatChange Effect;
	local XMBCondition_SourceAbilities Condition;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'CombatDrugs';
	Effect.DuplicateResponse = eDupe_Refresh;
	Effect.AddPersistentStatChange(eStat_Offense, default.CombatDrugsOffenseBonus);
	Effect.AddPersistentStatChange(eStat_Will, default.CombatDrugsWillBonus);
	Effect.BuildPersistentEffect(default.CombatDrugsDuration, false, false, false, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, default.CombatDrugsName, default.CombatDrugsDescription, "img:///UILibrary_SOCombatEngineer.UIPerk_combatdrugs", true,,'eAbilitySource_Perk');

	Condition = new class'XMBCondition_SourceAbilities';
	Condition.AddRequireAbility('ShadowOps_CombatDrugs', 'AA_UnitIsImmune');
	Effect.TargetConditions.AddItem(Condition);

	return Effect;
}

static function X2AbilityTemplate SmokeAndMirrors()
{
	local X2AbilityTemplate Template;
	local X2Effect_AddGrenade Effect;
	local XMBEffect_DoNotConsumeAllPoints CostEffect;
	local XMBCondition_WeaponName Condition;

	Effect = new class'X2Effect_AddGrenade';
	Effect.DataName = 'SmokeGrenade';
	Effect.BaseCharges = 1;
	Effect.SkipAbilities.AddItem('SmallItemWeight');

	CostEffect = new class'XMBEffect_DoNotConsumeAllPoints';
	CostEffect.AbilityNames = class'TemplateEditors_CombatEngineer'.default.GrenadeAbilities;
	Condition = new class'XMBCondition_WeaponName';
	Condition.IncludeWeaponNames = class'X2AbilityCost_GrenadeActionPoints'.default.SmokeGrenadeTemplates;
	Condition.bCheckAmmo = true;
	CostEffect.AbilityTargetConditions.AddItem(Condition);

	Template = Passive('ShadowOps_SmokeAndMirrors', "img:///UILibrary_SOCombatEngineer.UIPerk_smokeandmirrors", false, Effect);
	AddSecondaryEffect(Template, CostEffect);
	return Template;
}

static function X2AbilityTemplate SmokeAndMirrors_LW2()
{
	local X2AbilityTemplate Template;
	local XMBEffect_DoNotConsumeAllPoints CostEffect;
	local XMBEffect_AddItemCharges BonusItemEffect;
	local XMBCondition_WeaponName Condition;

	CostEffect = new class'XMBEffect_DoNotConsumeAllPoints';
	CostEffect.AbilityNames = class'TemplateEditors_CombatEngineer'.default.GrenadeAbilities;
	Condition = new class'XMBCondition_WeaponName';
	Condition.IncludeWeaponNames = class'X2AbilityCost_GrenadeActionPoints'.default.SmokeGrenadeTemplates;
	Condition.bCheckAmmo = true;
	CostEffect.AbilityTargetConditions.AddItem(Condition);

	Template = Passive('ShadowOps_SmokeAndMirrors_LW2', "img:///UILibrary_SOCombatEngineer.UIPerk_smokeandmirrors", false, CostEffect);

	BonusItemEffect = new class'XMBEffect_AddItemCharges';
	BonusItemEffect.PerItemBonus = 1;
	BonusItemEffect.ApplyToNames = class'X2AbilityCost_GrenadeActionPoints'.default.SmokeGrenadeTemplates;
	AddSecondaryEffect(Template, BonusItemEffect);

	return Template;
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
	Template.IconImage = "img:///UILibrary_SOCombatEngineer.UIPerk_breach";
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
	local XMBEffect_AbilityCostRefund		FastballEffect;
	local XMBCondition_AbilityName			NameCondition;

	FastballEffect = new class'XMBEffect_AbilityCostRefund';
	FastballEffect.TriggeredEvent = 'Fastball';
	FastballEffect.bShowFlyOver = true;
	FastballEffect.CountValueName = 'FastballUses';
	FastballEffect.MaxRefundsPerTurn = 1;
	FastballEffect.bFreeCost = true;
	FastballEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	NameCondition = new class'XMBCondition_AbilityName';
	NameCondition.IncludeAbilityNames = class'TemplateEditors_CombatEngineer'.default.GrenadeAbilities;
	FastballEffect.AbilityTargetConditions.AddItem(NameCondition);

	Template = SelfTargetActivated('ShadowOps_Fastball', "img:///UILibrary_SOCombatEngineer.UIPerk_fastball", true, FastballEffect,, eCost_Free);
	AddCooldown(Template, default.FastballCooldown);

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_HasGrenade');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');

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

	Template.IconImage = "img:///UILibrary_SOCombatEngineer.UIPerk_fracture";
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

	return Passive('ShadowOps_Aggression', "img:///UILibrary_SOCombatEngineer.UIPerk_aggression", true, Effect);
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

	Template = SelfTargetActivated('ShadowOps_SlamFire', "img:///UILibrary_SOCombatEngineer.UIPerk_slamfire", true, SlamFireEffect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Free);
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
	local XMBEffect_AddItemCharges            ItemChargesEffect;
	local X2Effect_Persistent					PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Packmaster');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_SOCombatEngineer.UIPerk_packmaster";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	ItemChargesEffect = new class'XMBEffect_AddItemCharges';
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
	Effect.BonusAbilityName = 'ShadowOps_DangerZone';
	Effect.AbilityNames = default.DangerZoneAbilityName;
	Effect.BonusRadius = default.DangerZoneAbilityBonusRadius;

	return Passive('ShadowOps_DangerZone', "img:///UILibrary_SOCombatEngineer.UIPerk_dangerzone", true, Effect);
}

static function X2AbilityTemplate DenseSmoke()
{
	local XMBEffect_BonusRadius Effect;

	Effect = new class'XMBEffect_BonusRadius';
	Effect.EffectName = 'DenseSmokeRadius';
	Effect.fBonusRadius = default.DenseSmokeBonusRadius;
	Effect.IncludeItemNames.AddItem('SmokeGrenade');
	Effect.IncludeItemNames.AddItem('SmokeGrenadeMk2');

	return Passive('ShadowOps_DenseSmoke', "img:///UILibrary_SOCombatEngineer.UIPerk_densesmoke", true, Effect);
}

static function X2AbilityTemplate HeatAmmo()
{
	local X2Effect_HeatAmmo Effect;

	Effect = new class'X2Effect_HeatAmmo';
	Effect.DamageMultiplier = default.HeatAmmoDamageMultiplier;

	return Passive('ShadowOps_HeatAmmo', "img:///UILibrary_SOCombatEngineer.UIPerk_heatammo", true, Effect);
}

static function X2AbilityTemplate MovingTarget()
{
	local XMBEffect_ConditionalBonus             Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AbilityTargetConditionsAsTarget.AddItem(default.ReactionFireCondition);
	Effect.AddToHitAsTargetModifier(-default.MovingTargetDefenseBonus);
	Effect.AddToHitAsTargetModifier(default.MovingTargetDodgeBonus, eHit_Graze);

	return Passive('ShadowOps_MovingTarget', "img:///UILibrary_SOCombatEngineer.UIPerk_movingtarget", true, Effect);
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

static function X2AbilityTemplate Pyromaniac()
{
	local X2Effect_AddGrenade ItemEffect;

	ItemEffect = new class 'X2Effect_AddGrenade';
	ItemEffect.DataName = 'Firebomb';
	ItemEffect.SkipAbilities.AddItem('SmallItemWeight');

	return Passive('ShadowOps_Pyromaniac', "img:///UILibrary_SOCombatEngineer.UIPerk_pyromaniac", true, ItemEffect);
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
	local X2Condition_UnitActionPoints ActionPointCondition;

	// Add a single movement-only action point to the unit
	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;

	// Create a triggered ability that will activate whenever the unit uses an ability that meets the condition
	// TODO: icon
	Template = SelfTargetTrigger('ShadowOps_HitAndRun', "img:///UILibrary_SOCombatEngineer.UIPerk_skirmisher", true, Effect, 'AbilityActivated');

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

	// Don't trigger if there are any reserved action points
	ActionPointCondition = new class'X2Condition_UnitActionPoints';
	ActionPointCondition.AddActionPointCheck(0,, true);
	Template.AbilityShooterConditions.AddItem(ActionPointCondition);

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
	return Passive('ShadowOps_FocusedDefense', "img:///UILibrary_SOCombatEngineer.UIPerk_focuseddefense", true, Effect);
}

static function X2AbilityTemplate LineEmUp()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.LineEmUpOffense, eHit_Success);
	Effect.AddToHitModifier(default.LineEmUpCrit, eHit_Crit);

	Effect.AbilityTargetConditions.AddItem(new class'X2Condition_ClosestVisibleEnemy');
	Effect.AbilityTargetConditions.AddItem(default.RangedCondition);

	// TODO: icon
	return Passive('ShadowOps_LineEmUp', "img:///UILibrary_SOCombatEngineer.UIPerk_lineemup", true, Effect);
}

static function X2AbilityTemplate ControlledDetonation()
{
	local X2Effect_ControlledDetonation Effect;

	Effect = new class'X2Effect_ControlledDetonation';

	// TODO: icon
	return Passive('ShadowOps_ControlledDetonation', "img:///UILibrary_SOCombatEngineer.UIPerk_controlleddetonation", true, Effect);
}

static function X2AbilityTemplate DevilsLuck()
{
	local X2AbilityTemplate Template;

	// TODO: icon
	Template = Passive('ShadowOps_DevilsLuck', "img:///UILibrary_SOCombatEngineer.UIPerk_devilsluck", true, new class'X2Effect_DevilsLuck');

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
	Template = SelfTargetTrigger('ShadowOps_DevilsLuckTrigger', "img:///UILibrary_SOCombatEngineer.UIPerk_devilsluck", false, Effect, 'AbilityActivated', eFilter_None);
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
	return Passive('ShadowOps_Mayhem', "img:///UILibrary_SOCombatEngineer.UIPerk_mayhem", true, Effect);
}

static function X2AbilityTemplate Mayhem_LW2()
{
	local X2Effect_HeavyHitter Effect;

	Effect = new class'X2Effect_HeavyHitter';
	Effect.BonusDamage = default.MayhemLW2DamageBonus;
	Effect.BonusDamageOverTime = default.MayhemLW2DamageOverTimeBonus;

	// TODO: icon
	return Passive('ShadowOps_Mayhem_LW2', "img:///UILibrary_SOCombatEngineer.UIPerk_heavyhitter", true, Effect);
}

static function X2AbilityTemplate Saboteur()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local XMBCondition_AbilityName AbilityNameCondition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddPercentDamageModifier(default.SaboteurDamageBonus);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeAlive = true;
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.FailOnNonUnits = false;
	Effect.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('StandardShot');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	// TODO: icon
	return Passive('ShadowOps_Saboteur', "img:///UILibrary_SOCombatEngineer.UIPerk_saboteur", false, Effect);
}

static function X2AbilityTemplate Anatomist()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(default.AnatomistDamageBonus, eHit_Crit);

	Effect.ScaleValue = new class'X2Value_Anatomist';
	Effect.ScaleMax = default.AnatomistMaxKills;

	return Passive('ShadowOps_Anatomist', "img:///UILibrary_SOCombatEngineer.UIPerk_anatomist", true, Effect);
}

static function X2AbilityTemplate ExtraMunitions()
{
	local X2Effect_AddGrenade ItemEffect;

	ItemEffect = new class 'X2Effect_AddGrenade';
	ItemEffect.DataName = 'FragGrenade';
	ItemEffect.SkipAbilities.AddItem('SmallItemWeight');

	return Passive('ShadowOps_ExtraMunitions', "img:///UILibrary_SOCombatEngineer.UIPerk_extramunitions", true, ItemEffect);
}

static function X2AbilityTemplate ExtraMunitions_LW2()
{
	local XMBEffect_AddItemCharges ItemEffect;

	ItemEffect = new class 'XMBEffect_AddItemCharges';
	ItemEffect.PerItemBonus = 1;
	ItemEffect.ApplyToNames = default.ExplosiveGrenades;

	return Passive('ShadowOps_ExtraMunitions_LW2', "img:///UILibrary_SOCombatEngineer.UIPerk_extramunitions", true, ItemEffect);
}

// Perk name:		Bull Rush
// Perk effect:		Make an unarmed melee attack that stuns the target. Whenever you take damage, this ability's cooldown resets.
// Localized text:	"Make an unarmed melee attack that stuns the target. Whenever you take damage, this ability's cooldown resets."
// Config:			(AbilityName="XMBExample_BullRush")
static function X2AbilityTemplate BullRush()
{
	local X2AbilityTemplate Template;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2Effect_Persistent StunnedEffect;
	local X2AbilityToHitCalc_StandardMelee ToHitCalc;

	// Create a damage effect. X2Effect_ApplyWeaponDamage is used to apply all types of damage, not
	// just damage from weapon attacks.
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';

	DamageEffect.EffectDamageValue = default.BullRushDamage;
	DamageEffect.bIgnoreBaseDamage = true;

	Template = MeleeAttack('ShadowOps_BullRush', "img:///UILibrary_SOCombatEngineer.UIPerk_bullrush", true, DamageEffect,, eCost_SingleConsumeAll);
	
	// The default hit chance for melee attacks is low. Add +20 to the attack to match swords.
	ToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	ToHitCalc.BuiltInHitMod = default.BullRushHitModifier;
	ToHitCalc.BuiltInCritMod = default.BullRushCritModifier;
	Template.AbilityToHitCalc = ToHitCalc;

	// Create a stun effect that removes 2 actions and has a 100% chance of success if the attack hits.
	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false);
	StunnedEffect.VisualizationFn = EffectFlyOver_Visualization;
	Template.AddTargetEffect(StunnedEffect);

	// The default fire animation depends on the ability's associated weapon - shooting for a gun or 
	// slashing for a sword. If the ability has no associated weapon, no animation plays. Use an
	// alternate animation, FF_Melee, which is a generic melee attack that works with any weapon.
	Template.CustomFireAnim = 'FF_Melee';

	return Template;
}

static function X2AbilityTemplate BareKnuckle()
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(1);
	Effect.AbilityTargetConditions.AddItem(default.MeleeCondition);

	Effect.ScaleBase = default.BareKnuckleDamageBonus;
	Effect.ScaleMultiplier = default.BareKnuckleDamageBonusPerRank;
	Effect.ScaleValue = new class'X2Value_SoldierRank';

	return Passive('ShadowOps_BareKnuckle', "img:///UILibrary_SOCombatEngineer.UIPerk_bareknuckle", false, Effect);
}

static function X2AbilityTemplate Elusive()
{
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_Visibility Value;
	
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitAsTargetModifier(default.ElusiveDodge, eHit_Graze);

	Value = new class'XMBValue_Visibility';
	Value.RequiredConditions.AddItem(class'X2TacticalVisibilityHelpers'.default.GameplayVisibilityCondition);
	Value.RequiredConditions.AddItem(class'X2TacticalVisibilityHelpers'.default.AliveUnitPropertyCondition);
	Value.RequiredConditions.AddItem(TargetWithinTiles(default.ElusiveRange));
	Value.bCountEnemies = true;
	Effect.ScaleValue = Value;

	return Passive('ShadowOps_Elusive', "img:///UILibrary_SOCombatEngineer.UIPerk_elusive", true, Effect);
}

static function X2AbilityTemplate MadBomber()
{
	local X2Effect_AddGrenade Effect;
	local X2AbilityTemplate Template;

	Effect = new class'X2Effect_AddGrenade';
	Effect.RandomGrenades = default.MadBomberGrenades;
	Effect.SkipAbilities.AddItem('SmallItemWeight');

	Template = Passive('ShadowOps_MadBomber', "img:///UILibrary_SOCombatEngineer.UIPerk_madbomber", true, Effect);
	AddSecondaryEffect(Template, Effect); // Grant a second grenade

	return Template;
}

static function X2AbilityTemplate Fracture_LW2()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.Modifiers = default.FractureLW2Modifiers;
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeOrganic = true;
	Condition.IncludeWeakAgainstTechLikeRobot = true;
	Effect.AbilityTargetConditions.AddItem(Condition);

	return Passive('ShadowOps_Fracture_LW2', "img:///UILibrary_SOCombatEngineer.UIPerk_fracture", false, Effect);
}

