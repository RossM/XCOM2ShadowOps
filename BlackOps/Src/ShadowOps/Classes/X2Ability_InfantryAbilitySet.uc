class X2Ability_InfantryAbilitySet extends XMBAbility
	config(GameData_SoldierSkills);

var name AlwaysReadyEffectName, FlushEffectName;

var config int MagnumDamageBonus, MagnumOffenseBonus;
var config int FullAutoHitModifier;
var config int ZeroInOffenseBonus;
var config int AdrenalineSurgeCritBonus, AdrenalineSurgeMobilityBonus, AdrenalineSurgeCooldown;
var config int FortressDefenseModifier;
var config int RifleSuppressionAimBonus;

var config name FreeAmmoForPocket;

var config int FullAutoActions;
var config int FullAutoCooldown, ZoneOfControlCooldown, FlushCooldown;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(PurePassive('ShadowOps_BulletSwarm', "img:///UILibrary_BlackOps.UIPerk_bulletswarm", true));
	Templates.AddItem(Bandolier());
	Templates.AddItem(SwapAmmo());
	Templates.AddItem(Magnum());
	Templates.AddItem(GoodEye());
	Templates.AddItem(AlwaysReady());
	Templates.AddItem(AlwaysReadyTrigger());
	Templates.AddItem(FullAuto());
	Templates.AddItem(FullAuto2());
	Templates.AddItem(ZoneOfControl());
	Templates.AddItem(ZoneOfControlShot());
	Templates.AddItem(ZoneOfControlPistolShot());
	Templates.AddItem(ZeroIn());
	Templates.AddItem(Flush());
	Templates.AddItem(FlushShot());
	Templates.AddItem(RifleSuppression());
	Templates.AddItem(Focus());
	Templates.AddItem(Resilience());
	Templates.AddItem(AdrenalineSurge());
	Templates.AddItem(AdrenalineSurgeTrigger());
	Templates.AddItem(Fortify());
	Templates.AddItem(FortifyTrigger());
	Templates.AddItem(FirstAid());
	Templates.AddItem(SecondWind());
	Templates.AddItem(SecondWindTrigger());

	return Templates;
}

static function X2AbilityTemplate Bandolier()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('ShadowOps_Bandolier', "img:///UILibrary_PerkIcons.UIPerk_wholenineyards");

	Template.SoldierAbilityPurchasedFn = BandolierPurchased;

	Template.bCrossClassEligible = true;

	return Template;
}

static function BandolierPurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local X2ItemTemplate FreeItem;
	local XComGameState_Item ItemState;

	// TODO: If the unit already has an ammo item equipped, move it to the pocket.

	if (!UnitState.HasAmmoPocket())
	{
		`RedScreen("AmmoPocketPurchased called but the unit doesn't have one? -jbouscher / @gameplay" @ UnitState.ToString());
		return;
	}
	FreeItem = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(default.FreeAmmoForPocket);
	if (FreeItem == none)
	{
		`RedScreen("Free ammo '" $ default.FreeAmmoForPocket $ "' is not a valid item template.");
		return;
	}
	ItemState = FreeItem.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(ItemState);
	if (!UnitState.AddItemToInventory(ItemState, eInvSlot_AmmoPocket, NewGameState))
	{
		`RedScreen("Unable to add free ammo to unit's inventory. Sadness." @ UnitState.ToString());
		return;
	}
}

static function X2AbilityTemplate SwapAmmo()
{
	local X2AbilityTemplate                 Template;	
	local X2Condition_UnitProperty          ShooterPropertyCondition;
	local X2Condition_SwapAmmo				WeaponCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_SwapAmmo');
	
	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Single));

	ShooterPropertyCondition = new class'X2Condition_UnitProperty';	
	ShooterPropertyCondition.ExcludeDead = true;                    //Can't reload while dead
	Template.AbilityShooterConditions.AddItem(ShooterPropertyCondition);
	WeaponCondition = new class'X2Condition_SwapAmmo';
	Template.AbilityShooterConditions.AddItem(WeaponCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.AbilityToHitCalc = default.DeadEye;
	
	Template.AbilityTargetStyle = default.SelfTarget;
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_swapammo";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.RELOAD_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.ActivationSpeech = 'Reloading';

	Template.BuildNewGameStateFn = SwapAmmo_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.ReloadAbility_BuildVisualization;

	Template.Hostility = eHostility_Neutral;

	Template.CinescriptCameraType="GenericAccentCam";

	return Template;	
}

simulated function XComGameState SwapAmmo_BuildGameState( XComGameStateContext Context )
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState, NewWeaponState, AmmoState, LoadedAmmoState;
	local array<XComGameState_Item> InventoryItems;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);	
	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID( AbilityContext.InputContext.AbilityRef.ObjectID ));

	AmmoState = AbilityState.GetSourceWeapon();

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));	
	InventoryItems = UnitState.GetAllInventoryItems(NewGameState);

	foreach InventoryItems(WeaponState)
	{
		LoadedAmmoState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponState.LoadedAmmo.ObjectID));
		if (LoadedAmmoState == none || !LoadedAmmoState.GetMyTemplate().IsA('X2AmmoTemplate'))
			continue;

		NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', WeaponState.ObjectID));
		//  apply new ammo
		NewWeaponState.LoadedAmmo = AmmoState.GetReference();
		//  refill the weapon's ammo	
		NewWeaponState.Ammo = NewWeaponState.GetClipSize();

		NewGameState.AddStateObject(NewWeaponState);
	}

	AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, UnitState, NewWeaponState, NewGameState);	

	NewGameState.AddStateObject(UnitState);

	return NewGameState;	
}

static function X2AbilityTemplate Magnum()
{
	local XMBEffect_ConditionalBonus              MagnumEffect;

	MagnumEffect = new class'XMBEffect_ConditionalBonus';
	MagnumEffect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);
	MagnumEffect.AddDamageModifier(default.MagnumDamageBonus);
	MagnumEffect.AddToHitModifier(default.MagnumOffenseBonus);

	return Passive('ShadowOps_Magnum', "img:///UILibrary_BlackOps.UIPerk_magnum", false, MagnumEffect);
}

static function X2AbilityTemplate GoodEye()
{
	local X2Effect_GoodEye                      GoodEyeEffect;

	GoodEyeEffect = new class'X2Effect_GoodEye';

	return Passive('ShadowOps_GoodEye', "img:///UILibrary_BlackOps.UIPerk_zeroin", true, GoodEyeEffect);
}

static function X2AbilityTemplate AlwaysReady()
{
	local X2AbilityTemplate         Template;

	Template = PurePassive('ShadowOps_AlwaysReady', "img:///UILibrary_BlackOps.UIPerk_alwaysready");
	Template.AdditionalAbilities.AddItem('ShadowOps_AlwaysReadyTrigger');

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate AlwaysReadyTrigger()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_ReserveActionPoints      ReserveActionPointsEffect;
	local array<name>                       SkipExclusions;
	local X2Effect_CoveringFire             CoveringFireEffect;
	local X2Condition_AbilityProperty       CoveringFireCondition;
	local X2Condition_UnitProperty          ConcealedCondition;
	local X2Effect_SetUnitValue             UnitValueEffect;
	local X2Condition_UnitEffects           SuppressedCondition;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_AlwaysReadyTrigger');
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_AlwaysReady');
	
	ReserveActionPointsEffect = new class'X2Effect_ReserveActionPoints';
	ReserveActionPointsEffect.ReserveType = class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint;
	Template.AddTargetEffect(ReserveActionPointsEffect);

	CoveringFireEffect = new class'X2Effect_CoveringFire';
	CoveringFireEffect.AbilityToActivate = 'PistolOverwatchShot';
	CoveringFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	CoveringFireCondition = new class'X2Condition_AbilityProperty';
	CoveringFireCondition.OwnerHasSoldierAbilities.AddItem('CoveringFire');
	CoveringFireEffect.TargetConditions.AddItem(CoveringFireCondition);
	Template.AddTargetEffect(CoveringFireEffect);

	ConcealedCondition = new class'X2Condition_UnitProperty';
	ConcealedCondition.ExcludeFriendlyToSource = false;
	ConcealedCondition.IsConcealed = true;
	UnitValueEffect = new class'X2Effect_SetUnitValue';
	UnitValueEffect.UnitName = class 'X2Ability_DefaultAbilitySet'.default.ConcealedOverwatchTurn;
	UnitValueEffect.CleanupType = eCleanup_BeginTurn;
	UnitValueEffect.NewValueToSet = 1;
	UnitValueEffect.TargetConditions.AddItem(ConcealedCondition);
	Template.AddTargetEffect(UnitValueEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'PlayerTurnEnded';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_pistoloverwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.PISTOL_OVERWATCH_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.AbilityConfirmSound = "Unreal2DSounds_OverWatch";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class 'X2Ability_DefaultAbilitySet'.static.OverwatchAbility_BuildVisualization;
	Template.CinescriptCameraType = "Overwatch";

	Template.Hostility = eHostility_Defensive;

	return Template;
}

static function X2AbilityTemplate FullAuto()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		AbilityActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2AbilityCooldown                 Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_FullAuto');

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fullauto";
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	

	AbilityActionPointCost = new class'X2AbilityCost_ActionPoints';
	AbilityActionPointCost.iNumPoints = default.FullAutoActions;
	AbilityActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(AbilityActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.FullAutoCooldown;
	Template.AbilityCooldown = Cooldown;

	//  require 2 ammo to be present so that both shots can be taken
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 2;
	AmmoCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(AmmoCost);
	//  actually charge 1 ammo for this shot. the 2nd shot will charge the extra ammo.
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.FullAutoHitModifier;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AssociatedPassives.AddItem('HoloTargeting');
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.AddTargetEffect(class'X2Ability'.default.WeaponUpgradeMissDamage);
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.AdditionalAbilities.AddItem('ShadowOps_FullAuto2');
	Template.PostActivationEvents.AddItem('ShadowOps_FullAuto2');
	Template.CinescriptCameraType = "StandardGunFiring";

	//Template.DamagePreviewFn = FullAutoDamagePreview;

	Template.bPreventsTargetTeleport = true;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate FullAuto2()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2AbilityTrigger_EventListener    Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_FullAuto2');

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.FullAutoHitModifier;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AssociatedPassives.AddItem('HoloTargeting');
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.AddTargetEffect(class'X2Ability'.default.WeaponUpgradeMissDamage);
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'ShadowOps_FullAuto2';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.ChainShotListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fullauto";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.AdditionalAbilities.AddItem('ShadowOps_FullAuto2');
	Template.PostActivationEvents.AddItem('ShadowOps_FullAuto2');
	Template.bShowActivation = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	return Template;
}

static function X2AbilityTemplate ZoneOfControl()
{
	local X2AbilityTemplate             Template;
	local X2AbilityCooldown             Cooldown;
	local X2Effect_ReserveActionPoints  ReservePointsEffect;
	local X2Condition_UnitEffects           SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ZoneOfControl');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_zoneofcontrol";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.Hostility = eHostility_Defensive;
	Template.AbilityConfirmSound = "Unreal2DSounds_OverWatch";

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Overwatch));

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.ZoneOfControlCooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	ReservePointsEffect = new class'X2Effect_ReserveActionPoints';
	ReservePointsEffect.ReserveType = 'ZoneOfControl';
	Template.AddShooterEffect(ReservePointsEffect);

	Template.AdditionalAbilities.AddItem('ShadowOps_ZoneOfControlShot');
	Template.AdditionalAbilities.AddItem('ShadowOps_ZoneOfControlPistolShot');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;

	Template.ActivationSpeech = 'KillZone';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate ZoneOfControlShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Single            SingleTarget;
	local X2AbilityTrigger_Event	        Trigger;
	local X2Effect_Persistent               ZoneOfControlEffect;
	local X2Condition_UnitEffectsWithAbilitySource  ZoneOfControlCondition;
	local X2Condition_Visibility            TargetVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ZoneOfControlShot');

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.bFreeCost = true;
	ReserveActionPointCost.AllowedTypes.AddItem('ZoneOfControl');
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	Template.AbilityToHitCalc = StandardAim;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	//  Do not shoot targets that were already hit by this unit this turn with this ability
	ZoneOfControlCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	ZoneOfControlCondition.AddExcludeEffect('ZoneOfControlTarget', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(ZoneOfControlCondition);
	//  Mark the target as shot by this unit so it cannot be shot again this turn
	ZoneOfControlEffect = new class'X2Effect_Persistent';
	ZoneOfControlEffect.EffectName = 'ZoneOfControlTarget';
	ZoneOfControlEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	ZoneOfControlEffect.SetupEffectOnShotContextResult(true, true);      //  mark them regardless of whether the shot hit or missed
	Template.AddTargetEffect(ZoneOfControlEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate ZoneOfControlPistolShot()
{
	local X2AbilityTemplate					BaseTemplate;
	local X2AbilityTemplate_BO              Template;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Single            SingleTarget;
	local X2AbilityTrigger_Event	        Trigger;
	local X2Effect_Persistent               ZoneOfControlEffect;
	local X2Condition_UnitEffectsWithAbilitySource  ZoneOfControlCondition;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2Condition_UnitInventory			HasPistolCondition;

	`CREATE_X2ABILITY_TEMPLATE(BaseTemplate, 'ShadowOps_ZoneOfControlPistolShot');
	Template = new class'X2AbilityTemplate_BO'(BaseTemplate);

	// This ability applies to the pistol, if one is equipped.
	Template.ApplyToWeaponSlot = eInvSlot_SecondaryWeapon;

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.bFreeCost = true;
	ReserveActionPointCost.AllowedTypes.AddItem('ZoneOfControl');
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	HasPistolCondition = new class'X2Condition_UnitInventory';
	HasPistolCondition.RelevantSlot = eInvSlot_SecondaryWeapon;
	HasPistolCondition.RequireWeaponCategory = 'pistol';
	Template.AbilityShooterConditions.AddItem(HasPistolCondition);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	Template.AbilityToHitCalc = StandardAim;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	//  Do not shoot targets that were already hit by this unit this turn with this ability
	ZoneOfControlCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	ZoneOfControlCondition.AddExcludeEffect('ZoneOfControlTarget', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(ZoneOfControlCondition);
	//  Mark the target as shot by this unit so it cannot be shot again this turn
	ZoneOfControlEffect = new class'X2Effect_Persistent';
	ZoneOfControlEffect.EffectName = 'ZoneOfControlTarget';
	ZoneOfControlEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	ZoneOfControlEffect.SetupEffectOnShotContextResult(true, true);      //  mark them regardless of whether the shot hit or missed
	Template.AddTargetEffect(ZoneOfControlEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate ZeroIn()
{
	local X2Effect_ZeroIn               ZeroInEffect;

	ZeroInEffect = new class'X2Effect_ZeroIn';
	ZeroInEffect.AccuracyBonus = default.ZeroInOffenseBonus;

	return Passive('ShadowOps_ZeroIn', "img:///UILibrary_BlackOps.UIPerk_goodeye", true, ZeroInEffect);
}

static function X2AbilityTemplate Flush()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2Condition_Visibility            VisibilityCondition;
	local X2Condition_UnitProperty			PropertyCondition;
	local X2Condition_CanActivateAbility	AbilityCondition;
	local X2Effect_GrantActionPoints		ActionPointEffect;
	local X2Effect_RunBehaviorTree			FlushEffect;
	local X2Effect_Persistent				PersistentEffect;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_SaveHitResult			SaveHitResultEffect;
	local X2Effect_PreviewDamage			PreviewDamageEffect;

	// Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Flush');
	Template.AdditionalAbilities.AddItem('ShadowOps_FlushShot');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_flush";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	

	Template.AddShooterEffectExclusions();

	// Targeting Details
	// Can only shoot visible enemies
	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);

	PropertyCondition = new class'X2Condition_UnitProperty';
	PropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(PropertyCondition);

	// Require that the target can take a move
	AbilityCondition = new class'X2Condition_CanActivateAbility';
	AbilityCondition.AbilityName = 'StandardMove';
	AbilityCondition.bIgnoreCosts = true;
	Template.AbilityTargetConditions.AddItem(AbilityCondition);

	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_WeaponConsumeAll));	

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;  // Will be used by the actual shot
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = false;
	Template.bAllowBonusWeaponEffects = false;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.FlushCooldown;
	Template.AbilityCooldown = Cooldown;
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	Template.AbilityToHitCalc = StandardAim;

	SaveHitResultEffect = new class'X2Effect_SaveHitResult';
	SaveHitResultEffect.bApplyOnHit = true;
	SaveHitResultEffect.bApplyOnMiss = true;
	Template.AddShooterEffect(SaveHitResultEffect);

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.EffectName = default.FlushEffectName;
	PersistentEffect.BuildPersistentEffect(1, false, true,, eGameRule_PlayerTurnEnd);
	PersistentEffect.bApplyOnHit = true;
	PersistentEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(PersistentEffect);
			
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
	ActionPointEffect.bApplyOnHit = true;
	ActionPointEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(ActionPointEffect);

	FlushEffect = new class'X2Effect_RunBehaviorTree';
	FlushEffect.BehaviorTreeName = 'FlushMove';
	FlushEffect.bApplyOnHit = true;
	FlushEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(FlushEffect);

	PreviewDamageEffect = new class'X2Effect_PreviewDamage';
	PreviewDamageEffect.WrappedEffect = class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect();
	Template.AddTargetEffect(PreviewDamageEffect);

	// Use top-down targeting to reduce switches between top-down and shooter as the enemy runs
	Template.TargetingMethod = class'X2TargetingMethod_TopDown';

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "StandardSuppression";

	// This forces the shot to visually miss
	Template.bIsASuppressionEffect = true;

	// This is supposed to play a miss animation for the initial shot before the target leaves cover
	Template.ActionFireClass = class'X2Action_Fire_Miss';

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.bCrossClassEligible = false;

	return Template;	
}

static function X2AbilityTemplate FlushShot()
{
	local X2AbilityTemplate							Template;
	local X2AbilityCost_Ammo						AmmoCost;
	local X2Condition_UnitEffectsWithAbilitySource	EffectsCondition;
	local X2AbilityTarget_Single					SingleTarget;
	local X2AbilityTrigger_Event					Trigger;
	local X2Effect									Effect;
	local X2Effect_RemoveEffects					RemoveEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_FlushShot');

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_UseSavedHitResult';

	EffectsCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	EffectsCondition.AddRequireEffect(default.FlushEffectName, 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	// None of the normal target conditions to ensure the reaction shot is used

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem(default.FlushEffectName);
	Template.AddTargetEffect(RemoveEffect);

	Effect = class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect();
	Effect.TargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AddTargetEffect(Effect);
	Effect = class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect();
	Effect.TargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AddTargetEffect(Effect);

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = FlushShot_BuildVisualization;
	Template.CinescriptCameraType = "StandardGunFiring";

	return Template;
}

function FlushShot_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{		
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local XComGameState_Unit			OldTargetState;
	local XComGameStateHistory			History;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;

	OldTargetState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID,, VisualizeGameState.HistoryIndex - 1));

	// Don't show any visualization if the target is dead
	if (OldTargetState != none && OldTargetState.IsAlive())
		TypicalAbility_BuildVisualization(VisualizeGameState, OutVisualizationTracks);
}

static function X2AbilityTemplate RifleSuppression()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2Effect_ReserveActionPoints      ReserveActionPointsEffect;
	local X2Effect_Suppression              SuppressionEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_RifleSuppression');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_riflesupression";
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 2;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Overwatch));
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	Template.AddShooterEffectExclusions();
	
	ReserveActionPointsEffect = new class'X2Effect_ReserveActionPoints';
	ReserveActionPointsEffect.ReserveType = 'Suppression';
	Template.AddShooterEffect(ReserveActionPointsEffect);

	Template.AbilityToHitCalc = default.DeadEye;	
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SuppressionEffect = new class'X2Effect_Suppression';
	SuppressionEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	SuppressionEffect.bRemoveWhenTargetDies = true;
	SuppressionEffect.bRemoveWhenSourceDamaged = true;
	SuppressionEffect.bBringRemoveVisualizationForward = true;
	SuppressionEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, class'X2Ability_GrenadierAbilitySet'.default.SuppressionTargetEffectDesc, Template.IconImage);
	SuppressionEffect.SetSourceDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, class'X2Ability_GrenadierAbilitySet'.default.SuppressionSourceEffectDesc, Template.IconImage);
	Template.AddTargetEffect(SuppressionEffect);
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.AdditionalAbilities.AddItem('SuppressionShot');
	Template.bIsASuppressionEffect = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.AssociatedPassives.AddItem('HoloTargeting');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = SuppressionBuildVisualization;
	// Template.BuildVisualizationFn = class'X2Ability_GrenadierAbilitySet'.static.SuppressionBuildVisualization;
	Template.BuildAppliedVisualizationSyncFn = class'X2Ability_GrenadierAbilitySet'.static.SuppressionBuildVisualizationSync;
	Template.CinescriptCameraType = "StandardSuppression";

	Template.Hostility = eHostility_Offensive;

	AddSecondaryAbility(Template, RifleSuppressionBonus());

	return Template;	
}

// Stolen from Divine Lucubration's Suppression Visualization Fix mod
static simulated function SuppressionBuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability	Context;
	local StateObjectReference			InteractingUnitRef;

	local VisualizationTrack			EmptyTrack;
	local VisualizationTrack			BuildTrack;

	local XComGameState_Ability			Ability;
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;

	local XComUnitPawn					UnitPawn;
	local XComWeapon					Weapon;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.TrackActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	// Check the actor's pawn and weapon, see if they can play the suppression effect
	UnitPawn = XGUnit(BuildTrack.TrackActor).GetPawn();
	Weapon = XComWeapon(UnitPawn.Weapon);
	if (Weapon != None &&
		!UnitPawn.GetAnimTreeController().CanPlayAnimation(Weapon.WeaponSuppressionFireAnimSequenceName) &&
		!UnitPawn.GetAnimTreeController().CanPlayAnimation(class'XComWeapon'.default.WeaponSuppressionFireAnimSequenceName))
	{
		// The unit can't play their weapon's suppression effect. Replace it with the normal fire effect so at least they'll look like they're shooting
		Weapon.WeaponSuppressionFireAnimSequenceName = Weapon.WeaponFireAnimSequenceName;
	}
	
	class'X2Action_ExitCover'.static.AddToVisualizationTrack(BuildTrack, Context);
	class'X2Action_StartSuppression'.static.AddToVisualizationTrack(BuildTrack, Context);
	OutVisualizationTracks.AddItem(BuildTrack);
	//****************************************************************************************
	//Configure the visualization track for the target
	InteractingUnitRef = Context.InputContext.PrimaryTarget;
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.TrackActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, Context));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Ability.GetMyTemplate().LocFlyOverText, '', eColor_Bad);
	if (XComGameState_Unit(BuildTrack.StateObject_OldState).ReserveActionPoints.Length != 0 && XComGameState_Unit(BuildTrack.StateObject_NewState).ReserveActionPoints.Length == 0)
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(none, class'XLocalizedData'.default.OverwatchRemovedMsg, '', eColor_Bad);
	}
	OutVisualizationTracks.AddItem(BuildTrack);
}

static function X2AbilityTemplate RifleSuppressionBonus()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_AbilityName Condition;

	// Create a conditional bonus effect
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'RifleSuppressionBonus';

	Effect.AddToHitModifier(default.RifleSuppressionAimBonus, eHit_Success);

	// The bonus only applies to suppression shots
	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('SuppressionShot');
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Create the template using a helper function
	Template = Passive('ShadowOps_RifleSuppressionBonus', "img:///UILibrary_BlackOps.UIPerk_riflesupression", false, Effect);

	HidePerkIcon(Template);

	return Template;
}

static function X2AbilityTemplate Focus()
{
	local X2Effect_Persistent                   Effect;

	Effect = new class'X2Effect_Focus';

	return Passive('ShadowOps_Focus', "img:///UILibrary_BlackOps.UIPerk_focus", true, Effect);
}

static function X2AbilityTemplate Resilience()
{
	local X2Effect_Persistent                   Effect;

	Effect = new class'X2Effect_Resilience';

	return Passive('ShadowOps_Resilience', "img:///UILibrary_BlackOps.UIPerk_resilience", true, Effect);
}

static function X2AbilityTemplate AdrenalineSurge()
{
	local X2AbilityTemplate         Template;

	Template = PurePassive('ShadowOps_AdrenalineSurge', "img:///UILibrary_PerkIcons.UIPerk_adrenalneurosympathy");
	Template.AdditionalAbilities.AddItem('ShadowOps_AdrenalineSurgeTrigger');

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate AdrenalineSurgeTrigger()
{
	local X2AbilityTemplate                 Template;	
	local array<name>                       SkipExclusions;
	local X2AbilityTrigger_EventListener	EventListener;
	local X2Effect_PersistentStatChange		AdrenalineEffect;
	local X2Effect_Persistent				CooldownEffect;
	local X2AbilityMultitarget_Radius		RadiusMultitarget;
	local X2Condition_UnitProperty			PropertyCondition;
	local X2Condition_UnitEffects			EffectsCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_AdrenalineSurgeTrigger');
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adrenalneurosympathy";
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = 12;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'KillMail';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	PropertyCondition = new class'X2Condition_UnitProperty';
	PropertyCondition.ExcludeDead = true;
	PropertyCondition.ExcludeHostileToSource = true;
	PropertyCondition.ExcludeFriendlyToSource = false;
	PropertyCondition.RequireSquadmates = true;

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('AdrenalineSurgeCooldown', 'AA_UnitIsImmune');

	AdrenalineEffect = new class'X2Effect_PersistentStatChange';
	AdrenalineEffect.EffectName = 'AdrenalineSurgeBonus';
	AdrenalineEffect.DuplicateResponse = eDupe_Refresh;
	AdrenalineEffect.AddPersistentStatChange(eStat_Mobility, default.AdrenalineSurgeMobilityBonus);
	AdrenalineEffect.AddPersistentStatChange(eStat_CritChance, default.AdrenalineSurgeCritBonus);
	AdrenalineEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	AdrenalineEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	AdrenalineEffect.TargetConditions.AddItem(PropertyCondition);
	AdrenalineEffect.TargetConditions.AddItem(EffectsCondition);
	AdrenalineEffect.VisualizationFn = EffectFlyOver_Visualization;
	Template.AddTargetEffect(AdrenalineEffect);
	Template.AddMultiTargetEffect(AdrenalineEffect);

	CooldownEffect = new class'X2Effect_Persistent';
	CooldownEffect.EffectName = 'AdrenalineSurgeCooldown';
	CooldownEffect.BuildPersistentEffect(default.AdrenalineSurgeCooldown, false, false, false, eGameRule_PlayerTurnEnd);
	CooldownEffect.TargetConditions.AddItem(PropertyCondition);
	CooldownEffect.TargetConditions.AddItem(EffectsCondition);
	Template.AddTargetEffect(CooldownEffect);
	Template.AddMultiTargetEffect(CooldownEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = false;
	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.Hostility = eHostility_Neutral;

	return Template;
}

static function X2AbilityTemplate Fortify()
{
	local X2AbilityTemplate         Template;

	Template = PurePassive('ShadowOps_Fortify', "img:///UILibrary_BlackOps.UIPerk_fortify");
	Template.AdditionalAbilities.AddItem('ShadowOps_FortifyTrigger');

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate FortifyTrigger()
{
	local X2AbilityTemplate					Template;
	local XMBEffect_ConditionalBonus			Effect;
	local X2AbilityTrigger_EventListener	Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_FortifyTrigger');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_fortify";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'OverwatchUsed';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitAsTargetModifier(-default.FortressDefenseModifier);
	Effect.BuildPersistentEffect(1, false, true,, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, ,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate FirstAid()
{
	local XMBEffect_AddUtilityItem Effect;

	Effect = new class'XMBEffect_AddUtilityItem';
	Effect.DataName = 'medikit';
	Effect.BaseCharges = 1;
	Effect.BonusCharges = 1;

	return Passive('ShadowOps_FirstAid', "img:///UILibrary_PerkIcons.UIPerk_supermedic", true, Effect);
}

static function X2AbilityTemplate SecondWind()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('ShadowOps_SecondWind', "img:///UILibrary_BlackOps.UIPerk_secondwind", false);
	Template.AdditionalAbilities.AddItem('ShadowOps_SecondWindTrigger');

	return Template;
}

static function X2AbilityTemplate SecondWindTrigger()
{
	local X2AbilityTemplate					Template;
	local X2Effect_GrantActionPoints		Effect;
	local X2AbilityTrigger_EventListener	Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_SecondWindTrigger');

	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_secondwind";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'MedikitUsed';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.RapidFireListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = SecondWind_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}

// This visualizer plays a flyover over each target.
function SecondWind_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{		
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	
	local Actor                     TargetVisualizer;
	local int                       TargetIndex;

	local VisualizationTrack        EmptyTrack;
	local VisualizationTrack        BuildTrack;
	local int						TrackIndex;
	local bool						bAlreadyAdded;
	local XComGameStateHistory      History;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);

	//Configure the visualization track for the target(s). This functionality uses the context primarily
	//since the game state may not include state objects for misses.
	//****************************************************************************************	
	if (AbilityTemplate.AbilityTargetEffects.Length > 0 &&			//There are effects to apply
		AbilityContext.PrimaryTarget.ObjectID > 0)				//There is a primary target
	{
		TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);

		BuildTrack = EmptyTrack;
		BuildTrack.TrackActor = TargetVisualizer;
		BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
		BuildTrack.StateObject_NewState = BuildTrack.StateObject_OldState;

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(none, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);

		OutVisualizationTracks.AddItem(BuildTrack);
	}

	//  Apply effects to multi targets
	if( AbilityTemplate.AbilityMultiTargetEffects.Length > 0 && AbilityContext.MultiTargets.Length > 0)
	{
		for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
		{	
			//Some abilities add the same target multiple times into the targets list - see if this is the case and avoid adding redundant tracks
			bAlreadyAdded = false;
			for( TrackIndex = 0; TrackIndex < OutVisualizationTracks.Length; ++TrackIndex )
			{
				if( OutVisualizationTracks[TrackIndex].StateObject_NewState.ObjectID == AbilityContext.MultiTargets[TargetIndex].ObjectID )
				{
					bAlreadyAdded = true;
				}
			}

			if( !bAlreadyAdded )
			{
				TargetVisualizer = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);

				BuildTrack = EmptyTrack;
				BuildTrack.TrackActor = TargetVisualizer;
				BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
				BuildTrack.StateObject_NewState = BuildTrack.StateObject_OldState;

				SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
				SoundAndFlyOver.SetSoundAndFlyOverParameters(none, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);

				OutVisualizationTracks.AddItem(BuildTrack);
			}
		}
	}
}

DefaultProperties
{
	AlwaysReadyEffectName = "AlwaysReadyTriggered";
	FlushEffectName = "FlushTarget";
}
