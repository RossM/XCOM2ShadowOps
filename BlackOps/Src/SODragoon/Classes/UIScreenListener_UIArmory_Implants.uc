class UIScreenListener_UIArmory_Implants extends UIScreenListener;

var UIArmory_Implants Implants;

event OnInit(UIScreen Screen)
{
	// Need to do a check here because LW Perk Pack replaces UIArmory_Implants
	if (!Screen.IsA('UIArmory_Implants'))
		return;

	Implants = UIArmory_Implants(Screen);

	Implants.MaxImplantSlots = 2;

	Implants.List.SetHeight(class'UIArmory_ImplantSlot'.default.Height * Implants.MaxImplantSlots);
	Implants.ListBG.SetHeight((Implants.List.y - Implants.ListBG.y) + Implants.List.height + 20);

	Implants.List.ClearItems();
	Implants.PopulateData();
}

defaultproperties
{
	ScreenClass = none
}