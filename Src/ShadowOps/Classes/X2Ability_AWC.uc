class X2Ability_AWC extends XMBAbility
	config(GameData_SoldierSkills);

var config int HipFireHitModifier;
var config int HipFireCooldown;
var config float AnatomistCritModifier, AnatomistMaxCritModifier;
var config int WeaponmasterBonusDamage;
var config int AbsolutelyCriticalCritBonus;
var config float DevilsLuckHitChanceMultiplier, DevilsLuckCritChanceMultiplier;
var config int PyromaniacDamageBonus;
var config int SnakeBloodDodgeBonus;
var config int RageDuration, RageCharges;

var config array<name> HitAndRunExcludedAbilities;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(HipFire());
	Templates.AddItem(Scrounger());
	Templates.AddItem(ScroungerTrigger());
	Templates.AddItem(Weaponmaster());
	Templates.AddItem(AbsolutelyCritical());
	Templates.AddItem(SnakeBlood());
	Templates.AddItem(Rage());

	return Templates;
}

static function X2AbilityTemplate HipFire()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown					Cooldown;
	local X2AbilityToHitCalc_StandardAim	ToHitCalc;
	local X2AbilityCost						Cost;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('ShadowOps_HipFire');
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_AWC";

	foreach Template.AbilityCosts(Cost)
	{
		ActionPointCost = X2AbilityCost_ActionPoints(Cost);
		if (ActionPointCost != none)
		{
			ActionPointCost.bFreeCost = true;
			ActionPointCost.bConsumeAllPoints = false;
		}
	}

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HipFireCooldown;
	Template.AbilityCooldown = Cooldown;

	// Hit Calculation (Different weapons now have different calculations for range)
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.HipFireHitModifier;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Scrounger()
{
	local X2AbilityTemplate						Template;
	
	Template = PurePassive('ShadowOps_Scrounger', "img:///UILibrary_BlackOps.UIPerk_scrounger", true);
	Template.AdditionalAbilities.AddItem('ShadowOps_ScroungerTrigger');

	return Template;
}

static function X2AbilityTemplate ScroungerTrigger()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ScroungerTrigger');
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_scrounger";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	MultiTargetStyle = new class'X2AbilityMultiTarget_AllUnits';
	MultiTargetStyle.bAcceptEnemyUnits = true;
	MultiTargetStyle.bRandomlySelectOne = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	Template.AddMultiTargetEffect(new class'X2Effect_DropLoot');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Weaponmaster()
{
	local XMBEffect_ConditionalBonus              Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(default.WeaponmasterBonusDamage);
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	return Passive('ShadowOps_Weaponmaster', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate AbsolutelyCritical()
{
	local XMBEffect_ConditionalBonus             Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AbilityTargetConditions.AddItem(default.NoCoverCondition);
	Effect.AddToHitModifier(default.AbsolutelyCriticalCritBonus, eHit_Crit);

	return Passive('ShadowOps_AbsolutelyCritical', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate SnakeBlood()
{
	local X2Effect_PersistentStatChange Effect;
	local X2Effect_DamageImmunity ImmunityEffect;
	local X2AbilityTemplate Template;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_Dodge, default.SnakeBloodDodgeBonus);

	Template = Passive('ShadowOps_SnakeBlood', "img:///UILibrary_PerkIcons.UIPerk_viper_getoverhere", true, Effect);

	ImmunityEffect = new class'X2Effect_DamageImmunity';
	ImmunityEffect.ImmuneTypes.AddItem('poison');
	Template.AddTargetEffect(ImmunityEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeLabel, eStat_Dodge, default.SnakeBloodDodgeBonus);

	return Template;
}

static function X2AbilityTemplate Rage()
{
	local X2AbilityTemplate				Template, EffectTemplate;
	local X2AbilityCost_ActionPoints    AbilityActionPointCost;
	local X2Effect_Implacable			ImplacableEffect;
	local X2Effect_Untouchable			UntouchableEffect;
	local X2Effect_Serial				SerialEffect;
	local X2Effect_AIControl			RageEffect;
	local X2AbilityTemplateManager		AbilityTemplateManager;
	local X2AbilityCharges              Charges;
	local X2AbilityCost_Charges         ChargeCost;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Rage');

	// Icon Properties
	Template.DisplayTargetHitChance = false;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                       // color of the icon
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_AWC";
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = default.RageCharges;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
	
	AbilityActionPointCost = new class'X2AbilityCost_ActionPoints';
	AbilityActionPointCost.iNumPoints = 2;
	AbilityActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(AbilityActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	RageEffect = new class'X2Effect_AIControl';
	RageEffect.EffectName = 'Rage';
	RageEffect.BehaviorTreeName = 'ShadowOps_Rage';
	RageEffect.EffectAddedFn = Rage_EffectAdded;
	RageEffect.BuildPersistentEffect(default.RageDuration, false, true, false, eGameRule_PlayerTurnBegin);
	Template.AddTargetEffect(RageEffect);

	ImplacableEffect = new class'X2Effect_Implacable';
	EffectTemplate = AbilityTemplateManager.FindAbilityTemplate('Implacable');
	ImplacableEffect.BuildPersistentEffect(default.RageDuration, false, true, false, eGameRule_PlayerTurnBegin);
	ImplacableEffect.SetDisplayInfo(ePerkBuff_Bonus, EffectTemplate.LocFriendlyName, EffectTemplate.GetMyHelpText(), EffectTemplate.IconImage, true, , EffectTemplate.AbilitySourceName);
	Template.AddTargetEffect(ImplacableEffect);

	UntouchableEffect = new class'X2Effect_Untouchable';
	EffectTemplate = AbilityTemplateManager.FindAbilityTemplate('Untouchable');
	UntouchableEffect.BuildPersistentEffect(default.RageDuration, false, true, false, eGameRule_PlayerTurnBegin);
	UntouchableEffect.SetDisplayInfo(ePerkBuff_Bonus, EffectTemplate.LocFriendlyName, EffectTemplate.GetMyHelpText(), EffectTemplate.IconImage, true, , EffectTemplate.AbilitySourceName);
	Template.AddTargetEffect(UntouchableEffect);

	SerialEffect = new class'X2Effect_Serial';
	EffectTemplate = AbilityTemplateManager.FindAbilityTemplate('Serial');
	SerialEffect.BuildPersistentEffect(default.RageDuration, false, true, false, eGameRule_PlayerTurnBegin);
	SerialEffect.SetDisplayInfo(ePerkBuff_Bonus, EffectTemplate.LocFriendlyName, EffectTemplate.GetMyHelpText(), EffectTemplate.IconImage, true, , EffectTemplate.AbilitySourceName);
	Template.AddTargetEffect(SerialEffect);

	Template.AbilityTargetStyle = default.SelfTarget;	
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.bShowActivation = false;
	Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = true;

	return Template;
}

function Rage_EffectAdded(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_AIUnitData NewAIUnitData;
	local XComGameState_Unit NewUnitState;
	local bool bDataChanged;
	local AlertAbilityInfo AlertInfo;
	local Vector PingLocation;
	local XComGameState_BattleData BattleData;

	NewUnitState = XComGameState_Unit(kNewTargetState);

	// Create an AI alert for the objective location

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	PingLocation = BattleData.MapData.ObjectiveLocation;
	AlertInfo.AlertTileLocation = `XWORLD.GetTileCoordinatesFromPosition(PingLocation);
	AlertInfo.AlertRadius = 500;
	AlertInfo.AlertUnitSourceID = 0;
	AlertInfo.AnalyzingHistoryIndex = NewGameState.HistoryIndex;

	// Add AI data with the alert

	NewAIUnitData = XComGameState_AIUnitData(NewGameState.CreateStateObject(class'XComGameState_AIUnitData', NewUnitState.GetAIUnitDataID()));
	if( NewAIUnitData.m_iUnitObjectID != NewUnitState.ObjectID )
	{
		NewAIUnitData.Init(NewUnitState.ObjectID);
		bDataChanged = true;
	}
	if( NewAIUnitData.AddAlertData(NewUnitState.ObjectID, eAC_MapwideAlert_Hostile, AlertInfo, NewGameState) )
	{
		bDataChanged = true;
	}

	if( bDataChanged )
	{
		NewGameState.AddStateObject(NewAIUnitData);
	}
	else
	{
		NewGameState.PurgeGameStateForObjectID(NewAIUnitData.ObjectID);
	}
}