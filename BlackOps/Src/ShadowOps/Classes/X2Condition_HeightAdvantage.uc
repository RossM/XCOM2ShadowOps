class X2Condition_HeightAdvantage extends X2Condition;

var bool bRequireHeightAdvantage, bRequireHeightDisadvantage;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit TargetState, SourceState;

	TargetState = XComGameState_Unit(kTarget);
	if (TargetState == none)
		return 'AA_NotAUnit';

	SourceState = XComGameState_Unit(kSource);
	if (SourceState == none)
		return 'AA_NotAUnit';

	if (bRequireHeightDisadvantage && !SourceState.HasHeightAdvantageOver(TargetState, true))
		return 'AA_ValueCheckFailed';

	if (bRequireHeightAdvantage && !TargetState.HasHeightAdvantageOver(SourceState, false))
		return 'AA_ValueCheckFailed';

	return 'AA_Success';
}