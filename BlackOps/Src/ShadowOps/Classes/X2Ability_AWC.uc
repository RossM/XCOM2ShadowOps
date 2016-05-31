class X2Ability_AWC extends XMBAbility
	config(GameData_SoldierSkills);

var config int HipFireHitModifier;
var config int HipFireCooldown;
var config float AnatomistCritModifier, AnatomistMaxCritModifier;
var config int WeaponmasterBonusDamage;
var config int AbsolutelyCriticalCritBonus;
var config float DevilsLuckHitChanceMultiplier, DevilsLuckCritChanceMultiplier;
var config int LightfoodMobilityBonus;
var config int PyromaniacDamageBonus;
var config int SnakeBloodDamageBonus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(HipFire());
	Templates.AddItem(Anatomist());
	Templates.AddItem(Scrounger());
	Templates.AddItem(ScroungerTrigger());
	Templates.AddItem(Weaponmaster());
	Templates.AddItem(AbsolutelyCritical());
	Templates.AddItem(HitAndRun());
	Templates.AddItem(DevilsLuck());
	Templates.AddItem(Lightfoot());
	Templates.AddItem(Pyromaniac());
	Templates.AddItem(SnakeBlood());

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

static function X2AbilityTemplate Anatomist()
{
	local X2Effect_Anatomist                    Effect;

	Effect = new class'X2Effect_Anatomist';
	Effect.CritModifier = default.AnatomistCritModifier;
	Effect.MaxCritModifier = default.AnatomistMaxCritModifier;

	return Passive('ShadowOps_Anatomist', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate Scrounger()
{
	local X2AbilityTemplate						Template;
	
	Template = PurePassive('ShadowOps_Scrounger', "img:///UILibrary_BlackOps.UIPerk_AWC", true);
	Template.AdditionalAbilities.AddItem('ShadowOps_ScroungerTrigger');

	return Template;
}

static function X2AbilityTemplate ScroungerTrigger()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ScroungerTrigger');
	Template.IconImage = "img:///UILibrary_BlackOps.UIPerk_AWC";

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
	Effect.bRequireAbilityWeapon = true;

	return Passive('ShadowOps_Weaponmaster', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate AbsolutelyCritical()
{
	local XMBEffect_ConditionalBonus             Effect;
	local X2Condition_Cover						Condition;

	Condition = new class'X2Condition_Cover';
	Condition.AllowedCoverTypes.AddItem(CT_NONE);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.OtherConditions.AddItem(Condition);
	Effect.AddToHitModifier(default.AbsolutelyCriticalCritBonus, eHit_Crit);

	return Passive('ShadowOps_AbsolutelyCritical', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate HitAndRun()
{
	local X2Effect_HitAndRun                    Effect;

	Effect = new class'X2Effect_HitAndRun';

	return Passive('ShadowOps_HitAndRun', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate DevilsLuck()
{
	local X2Effect_DevilsLuck                   Effect;

	Effect = new class'X2Effect_DevilsLuck';
	Effect.HitChanceMultiplier = default.DevilsLuckHitChanceMultiplier;
	Effect.CritChanceMultiplier = default.DevilsLuckCritChanceMultiplier;

	return Passive('ShadowOps_DevilsLuck', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate Lightfoot()
{
	local X2Effect_PersistentStatChange Effect;
	local X2AbilityTemplate Template;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_Mobility, default.LightfoodMobilityBonus);

	Template = Passive('ShadowOps_Lightfoot', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.LightfoodMobilityBonus);

	return Template;
}

static function X2AbilityTemplate Pyromaniac()
{
	local X2Effect_Pyromaniac Effect;

	Effect = new class'X2Effect_Pyromaniac';
	Effect.RequiredDamageTypes.AddItem('fire');
	Effect.DamageBonus = default.PyromaniacDamageBonus;

	return Passive('ShadowOps_Pyromaniac', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);
}

static function X2AbilityTemplate SnakeBlood()
{
	local X2Effect_Pyromaniac Effect;
	local X2Effect_DamageImmunity ImmunityEffect;
	local X2AbilityTemplate Template;

	Effect = new class'X2Effect_Pyromaniac';
	Effect.RequiredDamageTypes.AddItem('poison');
	Effect.DamageBonus = default.SnakeBloodDamageBonus;

	Template = Passive('ShadowOps_SnakeBlood', "img:///UILibrary_BlackOps.UIPerk_AWC", true, Effect);

	ImmunityEffect = new class'X2Effect_DamageImmunity';
	ImmunityEffect.ImmuneTypes.AddItem('poison');
	Template.AddTargetEffect(ImmunityEffect);

	return Template;
}