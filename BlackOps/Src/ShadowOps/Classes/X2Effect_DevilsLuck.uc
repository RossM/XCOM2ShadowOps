class X2Effect_DevilsLuck extends XMBEffect_Extended;

var float HitChanceMultiplier, CritChanceMultiplier;

function GetFinalToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local float BonusMultiplier;

	BonusMultiplier = 1.0;
	//if (Attacker.GetCurrentStat(eStat_HP) < Attacker.GetMaxStat(eState_HP))
		//BonusMultiplier += 1.0;
	//if (class'X2TacticalVisibilityHelpers'.static.GetNumEnemyViewersOfTarget(Attacker.ObjectID) >= 4)
		//BonusMultipler += 1.0;
	if (class'X2TacticalVisibilityHelpers'.static.GetNumFlankingEnemiesOfTarget(Attacker.ObjectID) >= 1)
		BonusMultiplier += 1.0;

	ModInfo.ModType = eHit_Success;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = max(Round(ShotBreakdown.ResultTable[eHit_Success] * HitChanceMultiplier * BonusMultiplier), 0);
	ShotModifiers.AddItem(ModInfo);

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = max(Round(ShotBreakdown.ResultTable[eHit_Crit] * CritChanceMultiplier * BonusMultiplier), 0);
	ShotModifiers.AddItem(ModInfo);
}
