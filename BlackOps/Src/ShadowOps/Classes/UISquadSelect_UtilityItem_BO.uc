class UISquadSelect_UtilityItem_BO extends UISquadSelect_UtilityItem;

simulated function GoToUtilityItem()
{
	`HQPRES.UIArmory_Loadout(UISquadSelect_ListItem(GetParent(class'UISquadSelect_ListItem')).GetUnitRef(), CannotEditSlots);

	if (CannotEditSlots.Find(eInvSlot_Utility) == INDEX_NONE)
	{
		UIArmory_Loadout(Movie.Stack.GetScreen(class'UIArmory_Loadout_BO')).SelectItemSlot(SlotType, SlotIndex);
	}
}
