class X2AbilityCost_GrenadeActionPoints extends X2AbilityCost_ActionPoints;

simulated function int GetPointCost(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	if (AbilityOwner.IsUnitAffectedByEffectName('Fastball'))
		return 0;

	return super.GetPointCost(AbilityState, AbilityOwner);
}

simulated function bool ConsumeAllPoints(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	local XComGameState_Item ItemState;
	local X2GrenadeTemplate GrenadeTemplate;
	local int i;

	ItemState = AbilityState.GetSourceAmmo();
	if (ItemState == none)
		ItemState = AbilityState.GetSourceWeapon();

	if (ItemState != none)
	{
		GrenadeTemplate = X2GrenadeTemplate(ItemState.GetMyTemplate());
		if (GrenadeTemplate != none)
		{
			if (GrenadeTemplate.DataName == 'SmokeGrenade' ||
				GrenadeTemplate.DataName == 'SmokeGrenadeMk2')
			{
				if (AbilityOwner.HasSoldierAbility('ShadowOps_SmokeAndMirrors'))
					return false;
			}
		}

	}

	if (bConsumeAllPoints)
	{
		for (i = 0; i < DoNotConsumeAllEffects.Length; ++i)
		{
			if (AbilityOwner.IsUnitAffectedByEffectName(DoNotConsumeAllEffects[i]))
				return false;
		}
		for (i = 0; i < DoNotConsumeAllSoldierAbilities.Length; ++i)
		{
			if (DoNotConsumeAllSoldierAbilities[i] == 'ShadowOps_SmokeAndMirrors')
				continue;
			if (AbilityOwner.HasSoldierAbility(DoNotConsumeAllSoldierAbilities[i]))
				return false;
		}
	}

	return bConsumeAllPoints;
}
