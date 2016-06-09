class XMBCondition_ReactionFire extends X2Condition;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local X2AbilityToHitCalc_StandardAim StandardAim;

	StandardAim = X2AbilityToHitCalc_StandardAim(kAbility.GetMyTemplate().AbilityToHitCalc);
	if (StandardAim == none || !StandardAim.bReactionFire)
		return 'AA_UnknownError';

	return 'AA_Success';
}