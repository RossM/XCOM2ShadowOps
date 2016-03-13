class X2Effect_HunterLowProfile extends X2Effect_Persistent;

var int Defense;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotInfo;
	local GameRulesCache_VisibilityInfo VisInfo;

	if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo))
	{
		if (VisInfo.TargetCover == CT_MidLevel)
		{
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = -Defense;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}
