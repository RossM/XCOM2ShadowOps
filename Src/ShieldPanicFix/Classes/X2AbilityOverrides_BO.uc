class X2AbilityOverrides_BO extends X2Ability config(GameData_SoldierSkills);

// This class replaces some abilities from the base game with modified versions.

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AddPanicAbility_Damage());
	Templates.AddItem(AddPanicAbility_UnitPanicked());

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
