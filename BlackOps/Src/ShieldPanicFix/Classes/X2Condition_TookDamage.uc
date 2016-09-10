class X2Condition_TookDamage extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;
	local UnitValue LastEffectDamage;
	local bool GotValue;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	GotValue = TargetUnit.GetUnitValue('LastEffectDamage', LastEffectDamage);
	if (GotValue && LastEffectDamage.fValue <= 0)
		return 'AA_UnitIsNotInjured';

	return 'AA_Success';
}