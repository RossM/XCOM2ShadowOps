//---------------------------------------------------------------------------------------
//  FILE:    XMBAbility.uc
//  AUTHOR:  xylthixlm
//---------------------------------------------------------------------------------------

class XMBAbility extends X2Ability;

var const X2Condition FullCoverCondition, HalfCoverCondition, NoCoverCondition;
var const X2Condition HeightAdvantageCondition, HeightDisadvantageCondition;
var const X2Condition ReactionFireCondition;
var const X2Condition DeadCondition;

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

	Begin Object Class=XMBCondition_IsDead Name=DefaultDeadCondition
	End Object
	DeadCondition = DefaultDeadCondition
}