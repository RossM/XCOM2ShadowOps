class X2Ability_Universal_BO extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(UniversalAbility());
	Templates.AddItem(ConsumeAllActions());

	return Templates;
}

static function X2AbilityTemplate UniversalAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_Universal_BO                 Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_UniversalAbility');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_unknown";

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	Effect = new class'X2Effect_Universal_BO';
	Effect.BuildPersistentEffect(1, true, true, true);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate ConsumeAllActions()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			AbilityCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ConsumeAllActions');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	AbilityCost = ActionPointCost(eCost_SingleConsumeAll);
	AbilityCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
	Template.AbilityCosts.AddItem(AbilityCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
	}