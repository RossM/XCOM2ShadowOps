class X2AbilityOverrides_BO extends X2Ability config(GameData_SoldierSkills);

// This class replaces some abilities from the base game with modified versions.

var config int SuppressionHitModifier;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AddHunkerDownAbility());

	if (class'ModConfig'.default.bEnableRulesTweaks)
	{
		Templates.AddItem(AddPanicAbility_Damage());
		Templates.AddItem(AddPanicAbility_UnitPanicked());
	}

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

simulated static function XComGameState HotLoadAmmo_BuildGameState(XComGameStateContext Context)
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

static function X2AbilityTemplate AddPanicAbility_Damage()
{
	local X2AbilityTemplate                 Template;
	local X2Condition_UnitProperty          Condition;
	local X2AbilityTrigger_EventListener EventListener;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_PanicCheck     PanicHitCalc;
	local X2Effect_PanickedWill             PanickedWillEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Panicked');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.CinescriptCameraType = "Panic";

	PanicHitCalc = new class'X2AbilityToHitCalc_PanicCheck';
	Template.AbilityToHitCalc = PanicHitCalc;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilitySourceName = 'eAbilitySource_Standard';

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitTakeEffectDamage';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.PanicTriggerListener;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.PostActivationEvents.AddItem('UnitPanicked');

	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Panic');
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_TookDamage');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AddShooterEffect(class'X2StatusEffects'.static.CreatePanickedStatusEffect());

	PanickedWillEffect = new class'X2Effect_PanickedWill';
	PanickedWillEffect.BuildPersistentEffect(1, true, true, false);
	Template.AddShooterEffect(PanickedWillEffect);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeRobotic = true;
	Condition.ExcludeImpaired = true;
	Condition.ExcludePanicked = true;
	Template.AbilityShooterConditions.AddItem(Condition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.AdditionalAbilities.AddItem('ShadowOps_Panicked_UnitPanicked');

	return Template;
}

static function X2AbilityTemplate AddPanicAbility_UnitPanicked()
{
	local X2AbilityTemplate                 Template;
	local X2Condition_UnitProperty          Condition;
	local X2AbilityTrigger_EventListener EventListener;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_PanicCheck     PanicHitCalc;
	local X2Effect_PanickedWill             PanickedWillEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Panicked_UnitPanicked');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.CinescriptCameraType = "Panic";

	PanicHitCalc = new class'X2AbilityToHitCalc_PanicCheck';
	Template.AbilityToHitCalc = PanicHitCalc;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilitySourceName = 'eAbilitySource_Standard';

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitPanicked';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.PanicTriggerListener;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.PostActivationEvents.AddItem('UnitPanicked');

	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Panic');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AddShooterEffect(class'X2StatusEffects'.static.CreatePanickedStatusEffect());

	PanickedWillEffect = new class'X2Effect_PanickedWill';
	PanickedWillEffect.BuildPersistentEffect(1, true, true, false);
	Template.AddShooterEffect(PanickedWillEffect);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeRobotic = true;
	Condition.ExcludeImpaired = true;
	Condition.ExcludePanicked = true;
	Template.AbilityShooterConditions.AddItem(Condition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;


	return Template;
}

defaultproperties
{
	Begin Object Class=X2AbilityToHitCalc_StandardAim_XModBase Name=DefaultSimpleStandardAim
	End Object
	SimpleStandardAim = DefaultSimpleStandardAim;
}