class XMBCondition_CoverType extends X2Condition;

var array<ECoverType> AllowedCoverTypes;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local GameRulesCache_VisibilityInfo VisInfo;

	if (AllowedCoverTypes.Length > 0)
	{
		if (kTarget == none)
			return 'AA_NoTargets';
		if (!`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(kSource.ObjectID, kTarget.ObjectID, VisInfo))
			return 'AA_NotInRange';
		if (AllowedCoverTypes.Find(VisInfo.TargetCover) == INDEX_NONE)
			return 'AA_InvalidTargetCoverType';
	}
	
	return 'AA_Success';
}