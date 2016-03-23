class X2AbilityToHitCalc_StandardAim_BO extends X2AbilityToHitCalc_StandardAim config(GameCore);

var localized string LowHitChanceCritModifier;

var config float MinimumHitChanceForNoCritPenalty;
var config float HitChanceCritPenaltyScale;

protected function FinalizeHitChance()
{
	local float Adjust;

	if (m_ShotBreakdown.ResultTable[eHit_Success] < MinimumHitChanceForNoCritPenalty)
	{
		Adjust = (MinimumHitChanceForNoCritPenalty - m_ShotBreakdown.ResultTable[eHit_Success]) * HitChanceCritPenaltyScale;
		Adjust = min(Adjust, m_ShotBreakdown.ResultTable[eHit_Crit]);
		AddModifier(-int(Adjust), LowHitChanceCritModifier, eHit_Crit);
	}

	super.FinalizeHitChance();
}