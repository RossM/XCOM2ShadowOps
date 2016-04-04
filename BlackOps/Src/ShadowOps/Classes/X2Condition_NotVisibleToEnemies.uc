class X2Condition_NotVisibleToEnemies extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	if (class'X2TacticalVisibilityHelpers'.static.GetNumEnemyViewersOfTarget(kTarget.ObjectID) > 0)
		return 'AA_UnitIsFlanked';

	return 'AA_Success'; 
}