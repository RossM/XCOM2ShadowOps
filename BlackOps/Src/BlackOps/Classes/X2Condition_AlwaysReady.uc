class X2Condition_AlwaysReady extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;
	local UnitValue AttacksThisTurn;
	local bool GotValue;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (TargetUnit.NumAllReserveActionPoints() != 0)
		return 'AA_AbilityUnavailable';

	GotValue = TargetUnit.GetUnitValue('AttacksThisTurn', AttacksThisTurn);
	if (GotValue && AttacksThisTurn.fValue > 0)
		return 'AA_AbilityUnavailable';

	return 'AA_Success';
}