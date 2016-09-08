class X2Condition_KilledByExplosion extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (!TargetUnit.bKilledByExplosion)
		return 'AA_UnknownError';

	return 'AA_Success'; 
}