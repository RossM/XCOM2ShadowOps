//---------------------------------------------------------------------------------------
//  FILE:    XMBAbility.uc
//  AUTHOR:  xylthixlm
//
//  This class provides additional helpers for defining ability templates. Simply
//  declare your ability sets to extend XMBAbility instead of X2Ability, and then use
//  whatever helpers you need.
//
//  USAGE
//
//  class X2Ability_MyClassAbilitySet extends XMBAbility;
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  XMBCondition_CoverType.uc
//  XMBCondition_HeightAdvantage.uc
//  XMBCondition_ReactionFire.uc
//  XMBCondition_Dead.uc
//---------------------------------------------------------------------------------------

class XMBAbility extends X2Ability;

var const X2Condition FullCoverCondition, HalfCoverCondition, NoCoverCondition, FlankedCondition;
var const X2Condition HeightAdvantageCondition, HeightDisadvantageCondition;
var const X2Condition ReactionFireCondition;
var const X2Condition DeadCondition;
var const X2Condition HitCondition, MissCondition, CritCondition, GrazeCondition;

// Helper method for quickly defining a non-pure passive.
static function X2AbilityTemplate Passive(name DataName, string IconImage, bool bCrossClassEligible, X2Effect_Persistent Effect)
{
	local X2AbilityTemplate						Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);
	Template.IconImage = IconImage;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

simulated static function EffectFlyOver_Visualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local EWidgetColor					MessageColor;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	
	MessageColor = AbilityTemplate.Hostility == eHostility_Offensive ? eColor_Bad : eColor_Good;

	if (EffectApplyResult == 'AA_Success' && XGUnit(BuildTrack.TrackActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', MessageColor, AbilityTemplate.IconImage);
	}
}

defaultproperties
{
	Begin Object Class=XMBCondition_CoverType Name=DefaultFullCoverCondition
		AllowedCoverTypes[0] = CT_Standing
	End Object
	FullCoverCondition = DefaultFullCoverCondition

	Begin Object Class=XMBCondition_CoverType Name=DefaultHalfCoverCondition
		AllowedCoverTypes[0] = CT_MidLevel
	End Object
	HalfCoverCondition = DefaultHalfCoverCondition

	Begin Object Class=XMBCondition_CoverType Name=DefaultNoCoverCondition
		AllowedCoverTypes[0] = CT_None
	End Object
	NoCoverCondition = DefaultNoCoverCondition

	Begin Object Class=XMBCondition_CoverType Name=DefaultFlankedCondition
		AllowedCoverTypes[0] = CT_None
		bRequireCanTakeCover = true
	End Object
	FlankedCondition = DefaultFlankedCondition

	Begin Object Class=XMBCondition_HeightAdvantage Name=DefaultHeightAdvantageCondition
		bRequireHeightAdvantage = true
	End Object
	HeightAdvantageCondition = DefaultHeightAdvantageCondition

	Begin Object Class=XMBCondition_HeightAdvantage Name=DefaultHeightDisadvantageCondition
		bRequireHeightDisadvantage = true
	End Object
	HeightDisadvantageCondition = DefaultHeightDisadvantageCondition

	Begin Object Class=XMBCondition_ReactionFire Name=DefaultReactionFireCondition
	End Object
	ReactionFireCondition = DefaultReactionFireCondition

	Begin Object Class=XMBCondition_Dead Name=DefaultDeadCondition
	End Object
	DeadCondition = DefaultDeadCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultHitCondition
		bRequireHit = true
	End Object
	HitCondition = DefaultHitCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultMissCondition
		bRequireMiss = true
	End Object
	MissCondition = DefaultMissCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultCritCondition
		IncludeHitResults[0] = eHit_Crit
	End Object
	CritCondition = DefaultCritCondition

	Begin Object Class=XMBCondition_AbilityHitResult Name=DefaultGrazeCondition
		IncludeHitResults[0] = eHit_Graze
	End Object
	GrazeCondition = DefaultGrazeCondition
}