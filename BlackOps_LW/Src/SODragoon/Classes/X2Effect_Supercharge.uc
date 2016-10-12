class X2Effect_Supercharge extends XMBEffect_AddAbilityCharges;

function bool IsValidAbility(XComGameState_Ability AbilityState)
{
	return AbilityState.GetSourceWeapon().GetMyTemplate().IsA('X2GremlinTemplate');
}