class X2Condition_HasGrenade extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;
	local StateObjectReference ItemRef, AbilityRef;
	local XComGameState_Item ItemState;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	foreach TargetUnit.Abilities(AbilityRef)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

		// This is kind of hacky but these are the only two abilities Fastball works with
		if (AbilityState.GetMyTemplateName() != 'ThrowGrenade' && AbilityState.GetMyTemplateName() != 'LaunchGrenade')
			continue;

		if (AbilityState.SourceAmmo.ObjectID != 0)
			ItemRef = AbilityState.SourceAmmo;
		else if (AbilityState.SourceWeapon.ObjectID != 0)
			ItemRef = AbilityState.SourceWeapon;
		else
			continue;

		ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));

		if (ItemState.Ammo > 0)
		{
			return 'AA_Success';
		}
	}

	return 'AA_CannotAfford_AmmoCost';
}