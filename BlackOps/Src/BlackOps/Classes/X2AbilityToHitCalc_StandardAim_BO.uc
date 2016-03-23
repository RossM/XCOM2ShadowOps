class X2AbilityToHitCalc_StandardAim_BO extends X2AbilityToHitCalc_StandardAim;

var localized string LowHitChanceCritModifier;

protected function FinalizeHitChance()
{
	local float Adjust;

	if (m_ShotBreakdown.ResultTable[eHit_Success] < 85)
	{
		Adjust = (85 - m_ShotBreakdown.ResultTable[eHit_Success]) * 0.5;
		Adjust = min(Adjust, m_ShotBreakdown.ResultTable[eHit_Crit]);
		AddModifier(-int(Adjust), LowHitChanceCritModifier, eHit_Crit);
	}

	super.FinalizeHitChance();
}