class X2Condition_CanActivateAbility extends X2Condition;

var name AbilityName;
var bool bIgnoreCosts;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	AbilityRef = TargetUnit.FindAbility(AbilityName);
	if (AbilityRef.ObjectID == 0)
		return 'AA_AbilityUnavailable';

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
	return AbilityState.CanActivateAbility(TargetUnit,, bIgnoreCosts);
}