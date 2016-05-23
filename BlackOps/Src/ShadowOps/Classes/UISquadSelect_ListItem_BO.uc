class UISquadSelect_ListItem_BO extends UISquadSelect_ListItem;

simulated function GoToPrimaryWeapon()
{
	`HQPRES.UIArmory_Loadout(GetUnitRef(), CannotEditSlots);
	
	if (CannotEditSlots.Find(eInvSlot_PrimaryWeapon) == INDEX_NONE)
	{
		UIArmory_Loadout(Movie.Stack.GetScreen(class'UIArmory_Loadout_BO')).SelectWeapon(eInvSlot_PrimaryWeapon);
	}
}

simulated function GoToHeavyWeapon()
{
	`HQPRES.UIArmory_Loadout(GetUnitRef(), CannotEditSlots);

	if (CannotEditSlots.Find(eInvSlot_HeavyWeapon) == INDEX_NONE)
	{
		UIArmory_Loadout(Movie.Stack.GetScreen(class'UIArmory_Loadout_BO')).SelectWeapon(eInvSlot_HeavyWeapon);
	}
}