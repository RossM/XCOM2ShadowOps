class UISquadSelect_UtilityItem_BO extends UISquadSelect_UtilityItem;

simulated function GoToUtilityItem()
{
	`HQPRES.UIArmory_Loadout(UISquadSelect_ListItem(GetParent(class'UISquadSelect_ListItem', true)).GetUnitRef());
	UIArmory_Loadout(Movie.Stack.GetScreen(class'UIArmory_Loadout_BO')).SelectItemSlot(SlotType, SlotIndex);
}

