class X2Condition_SwapAmmo extends X2Condition;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit UnitState;
	local XComGameState_Item SourceWeapon, PrimaryWeapon;

	SourceWeapon = kAbility.GetSourceWeapon();
	if (SourceWeapon != none)
	{
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

		PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
		if (PrimaryWeapon != none && PrimaryWeapon.LoadedAmmo.ObjectID == SourceWeapon.ObjectID)
			return 'AA_AmmoAlreadyFull';
	}

	return 'AA_Success';
}