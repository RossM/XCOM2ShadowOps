class X2Effect_Precision extends X2Effect_Persistent;

var int Aim;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotInfo;
	local GameRulesCache_VisibilityInfo VisInfo;

	if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo))
	{
		if (VisInfo.TargetCover == CT_Standing)
		{
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = Aim;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}
