class X2AbilityOverrides_BO extends X2Ability config(GameData_SoldierSkills);

// This class replaces some abilities from the base game with modified versions.

var config int SuppressionHitModifier;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(ThrowGrenade());
	Templates.AddItem(LaunchGrenade());
	Templates.AddItem(AddHunkerDownAbility());
	Templates.AddItem(SuppressionShot());
	Templates.AddItem(HotLoadAmmo());

	return Templates;
}

// This function causes templates defined in this file to replace the base game templates with the same name.
static event array<X2DataTemplate> CreateTemplatesEvent()
{
	local array<X2DataTemplate> NewTemplates;
	local int Index;
	local X2AbilityTemplateManager AbilityManager;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	NewTemplates = super.CreateTemplatesEvent();

	for( Index = 0; Index < NewTemplates.Length; ++Index )
	{
		AbilityManager.AddAbilityTemplate(X2AbilityTemplate(NewTemplates[Index]), true);
	}

	NewTemplates.Length = 0;
	return NewTemplates;
}

// Modified for Smoke and Mirrors, and Fastball.
static function X2AbilityTemplate ThrowGrenade()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_SoldierBonusRadius RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2Condition_UnitInventory         UnitInventoryCondition;
	local X2Condition_AbilitySourceWeapon   GrenadeCondition, ProximityMineCondition;
	local X2Condition_UnitEffects			ExcludeEffects;
	local X2Effect_ProximityMine            ProximityMineEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ThrowGrenade');	
	
	Template.bDontDisplayInAbilitySummary = true;
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_GrenadeActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Salvo');
	ActionPointCost.AllowedTypes.AddItem('grenade');
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bIndirectFire = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;
	
	Template.bUseThrownGrenadeEffects = true;
	Template.bHideWeaponDuringFire = true;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_SoldierBonusRadius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.SoldierAbilityName = 'VolatileMix';
	RadiusMultiTarget.BonusRadius = class'X2Ability_GrenadierAbilitySet'.default.VOLATILE_RADIUS;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(ExcludeEffects);

	UnitInventoryCondition = new class'X2Condition_UnitInventory';
	UnitInventoryCondition.RelevantSlot = eInvSlot_SecondaryWeapon;
	UnitInventoryCondition.ExcludeWeaponCategory = 'grenade_launcher';
	Template.AbilityShooterConditions.AddItem(UnitInventoryCondition);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.FailOnNonUnits = false; //The grenade can affect interactive objects, others
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	GrenadeCondition = new class'X2Condition_AbilitySourceWeapon';
	GrenadeCondition.CheckGrenadeFriendlyFire = true;
	Template.AbilityMultiTargetConditions.AddItem(GrenadeCondition);

	Template.AddShooterEffectExclusions();

	Template.bRecordValidTiles = true;

	ProximityMineEffect = new class'X2Effect_ProximityMine';
	ProximityMineEffect.BuildPersistentEffect(1, true, false, false);
	ProximityMineCondition = new class'X2Condition_AbilitySourceWeapon';
	ProximityMineCondition.MatchGrenadeType = 'ProximityMine';
	ProximityMineEffect.TargetConditions.AddItem(ProximityMineCondition);
	Template.AddShooterEffect(ProximityMineEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_WeaponIncompatible');
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fraggrenade";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bUseAmmoAsChargesForHUD = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.DamagePreviewFn = class'X2Ability_Grenades'.static.GrenadeDamagePreview;
	Template.TargetingMethod = class'X2TargetingMethod_Grenade';
	Template.CinescriptCameraType = "StandardGrenadeFiring";

	Template.PostActivationEvents.AddItem('GrenadeUsed');

	// This action is considered 'hostile' and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	return Template;	
}

// Modified for Smoke and Mirrors, and Fastball.
static function X2DataTemplate LaunchGrenade()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_SoldierBonusRadius RadiusMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2Condition_AbilitySourceWeapon   GrenadeCondition, ProximityMineCondition;
	local X2Condition_UnitEffects			ExcludeEffects;
	local X2Effect_ProximityMine            ProximityMineEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LaunchGrenade');

	Template.SoldierAbilityPurchasedFn = class'X2Ability_GrenadierAbilitySet'.static.GrenadePocketPurchased;
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	AmmoCost.UseLoadedAmmo = true;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_GrenadeActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Salvo');
	ActionPointCost.AllowedTypes.AddItem('grenade');
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bIndirectFire = true;
	StandardAim.bAllowCrit = false;
	Template.AbilityToHitCalc = StandardAim;
	
	Template.bUseLaunchedGrenadeEffects = true;
	Template.bHideAmmoWeaponDuringFire = true; // hide the grenade
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_SoldierBonusRadius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.SoldierAbilityName = 'VolatileMix';
	RadiusMultiTarget.BonusRadius = class'X2Ability_GrenadierAbilitySet'.default.VOLATILE_RADIUS;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(ExcludeEffects);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	GrenadeCondition = new class'X2Condition_AbilitySourceWeapon';
	GrenadeCondition.CheckGrenadeFriendlyFire = true;
	Template.AbilityMultiTargetConditions.AddItem(GrenadeCondition);

	Template.AddShooterEffectExclusions();

	Template.bRecordValidTiles = true;

	ProximityMineEffect = new class'X2Effect_ProximityMine';
	ProximityMineEffect.BuildPersistentEffect(1, true, false, false);
	ProximityMineCondition = new class'X2Condition_AbilitySourceWeapon';
	ProximityMineCondition.MatchGrenadeType = 'ProximityMine';
	ProximityMineEffect.TargetConditions.AddItem(ProximityMineCondition);
	Template.AddShooterEffect(ProximityMineEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_AmmoCost');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_grenade_launcher";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;
	Template.bUseAmmoAsChargesForHUD = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	// Scott W says a Launcher VO cue doesn't exist, so I should use this one.  mdomowicz 2015_08_24
	Template.ActivationSpeech = 'ThrowGrenade';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.DamagePreviewFn = class'X2Ability_Grenades'.static.GrenadeDamagePreview;
	Template.TargetingMethod = class'X2TargetingMethod_Grenade';
	Template.CinescriptCameraType = "Grenadier_GrenadeLauncher";

	Template.PostActivationEvents.AddItem('GrenadeUsed');

	// This action is considered 'hostile' and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;	

	return Template;
}

// Modified for Entrench
static function X2AbilityTemplate AddHunkerDownAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Condition_UnitProperty          PropertyCondition;
//	local X2Condition_AbilityProperty       DefenseIncreaseEffectCondition;
	local X2Effect_PersistentStatChange     PersistentStatChangeEffect;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local array<name>                       SkipExclusions;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HunkerDown');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_takecover";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.HUNKER_DOWN_PRIORITY;
	Template.bDisplayInUITooltip = false;

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.HunkerDownAbility_BuildVisualization;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Entrench');
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
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	Template.AbilityTargetStyle = default.SelfTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	PersistentStatChangeEffect = new class'X2Effect_HunkerDown';
	PersistentStatChangeEffect.BuildPersistentEffect(1 /* Turns */,,,,eGameRule_PlayerTurnBegin);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, class'X2Ability_DefaultAbilitySet'.default.HUNKERDOWN_DODGE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, class'X2Ability_DefaultAbilitySet'.default.HUNKERDOWN_DEFENSE);
	PersistentStatChangeEffect.DuplicateResponse = eDupe_Refresh;
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.AddTargetEffect(class'X2Ability_SharpshooterAbilitySet'.static.SharpshooterAimEffect());

	Template.Hostility = eHostility_Defensive;

	return Template;
}

// Given an Aim bonus
static function X2AbilityTemplate SuppressionShot()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityTrigger_Event	        Trigger;
	local array<name>                       SkipExclusions;
	local X2Condition_UnitEffectsWithAbilitySource TargetEffectCondition;
	local X2Effect_RemoveEffects            RemoveSuppression;
	local X2Effect                          ShotEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SuppressionShot');

	Template.bDontDisplayInAbilitySummary = true;
	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem('Suppression');
	Template.AbilityCosts.AddItem(ReserveActionPointCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	StandardAim.BuiltInHitMod = default.SuppressionHitModifier;
	Template.AbilityToHitCalc = StandardAim;
	Template.AbilityToHitOwnerOnMissCalc = StandardAim;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	TargetEffectCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	TargetEffectCondition.AddRequireEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsNotSuppressed');
	Template.AbilityTargetConditions.AddItem(TargetEffectCondition);

	TargetVisibilityCondition = new class'X2Condition_Visibility';	
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	Template.bAllowAmmoEffects = true;

	RemoveSuppression = new class'X2Effect_RemoveEffects';
	RemoveSuppression.EffectNamesToRemove.AddItem(class'X2Effect_Suppression'.default.EffectName);
	RemoveSuppression.bCheckSource = true;
	RemoveSuppression.SetupEffectOnShotContextResult(true, true);
	Template.AddShooterEffect(RemoveSuppression);
	
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_supression";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	//don't want to exit cover, we are already in suppression/alert mode.
	Template.bSkipExitCoverWhenFiring = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bAllowFreeFireWeaponUpgrade = true;	

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	ShotEffect = class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect();
	ShotEffect.TargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());
	Template.AddTargetEffect(ShotEffect);
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	ShotEffect = class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect();
	ShotEffect.TargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());
	Template.AddTargetEffect(ShotEffect);
	
	return Template;	
}


static function X2DataTemplate HotLoadAmmo()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_UnitPostBeginPlay PostBeginPlayTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HotLoadAmmo');

	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SelfTarget;

	PostBeginPlayTrigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	PostBeginPlayTrigger.Priority -= 10;        // Lower priority to guarantee ammo modifying effects (e.g. Deep Pockets) already run.
	Template.AbilityTriggers.AddItem(PostBeginPlayTrigger);

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.BuildNewGameStateFn = HotLoadAmmo_BuildGameState;
	Template.BuildVisualizationFn = none;

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	return Template;
}

simulated function XComGameState HotLoadAmmo_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item AmmoState, WeaponState, NewWeaponState;
	local array<XComGameState_Item> UtilityItems;
	local X2AmmoTemplate AmmoTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local bool FoundAmmo;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	AbilityContext = XComGameStateContext_Ability(Context);
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));
	WeaponState = AbilityState.GetSourceWeapon();
	NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', WeaponState.ObjectID));
	WeaponTemplate = X2WeaponTemplate(WeaponState.GetMyTemplate());

	UtilityItems = UnitState.GetAllItemsInSlot(eInvSlot_AmmoPocket);
	foreach UtilityItems(AmmoState)
	{
		AmmoTemplate = X2AmmoTemplate(AmmoState.GetMyTemplate());
		if (AmmoTemplate != none && AmmoTemplate.IsWeaponValidForAmmo(WeaponTemplate))
		{
			FoundAmmo = true;
			break;
		}
	}
	if (!FoundAmmo)
	{
		UtilityItems = UnitState.GetAllItemsInSlot(eInvSlot_Utility);
		foreach UtilityItems(AmmoState)
		{
			AmmoTemplate = X2AmmoTemplate(AmmoState.GetMyTemplate());
			if (AmmoTemplate != none && AmmoTemplate.IsWeaponValidForAmmo(WeaponTemplate))
			{
				FoundAmmo = true;
				break;
			}
		}
	}

	if (FoundAmmo)
	{
		NewWeaponState.LoadedAmmo = AmmoState.GetReference();
		NewWeaponState.Ammo += AmmoState.GetClipSize();
	}

	NewGameState.AddStateObject(UnitState);
	NewGameState.AddStateObject(NewWeaponState);

	return NewGameState;
}

defaultproperties
{
	Begin Object Class=X2AbilityToHitCalc_StandardAim_BO Name=DefaultSimpleStandardAim
	End Object
	SimpleStandardAim = DefaultSimpleStandardAim;
}