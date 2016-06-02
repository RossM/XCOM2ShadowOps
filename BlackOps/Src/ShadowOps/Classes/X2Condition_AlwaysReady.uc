class X2Condition_AlwaysReady extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (TargetUnit.NumAllReserveActionPoints() != 0)
		return 'AA_AbilityUnavailable';

	return 'AA_Success';
}