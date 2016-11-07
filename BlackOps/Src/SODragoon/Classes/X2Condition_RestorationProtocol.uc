class X2Condition_RestorationProtocol extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (TargetUnit.IsRobotic())
		return 'AA_UnitIsImmune';

	if (TargetUnit.GetCurrentStat(eStat_HP) < TargetUnit.GetMaxStat(eStat_HP))
		return 'AA_Success';

	if (!TargetUnit.GetMyTemplate().bCanBeRevived)
		return 'AA_UnitIsImmune';

	if (TargetUnit.IsPanicked() || TargetUnit.IsUnconscious() || TargetUnit.IsDisoriented())
		return 'AA_Success';

	return 'AA_UnitIsNotImpaired';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit SourceUnit, TargetUnit;

	SourceUnit = XComGameState_Unit(kSource);
	TargetUnit = XComGameState_Unit(kTarget);

	if (SourceUnit == none || TargetUnit == none)
		return 'AA_NotAUnit';

	if (SourceUnit.ControllingPlayer == TargetUnit.ControllingPlayer)
		return 'AA_Success';

	return 'AA_UnitIsHostile';
}