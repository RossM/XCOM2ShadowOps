class UIScreenListener_UIArmory_Implants extends UIScreenListener;

var UIArmory_Implants Implants;

event OnInit(UIScreen Screen)
{
	local XComGameState_Unit Unit;
	local UIArmory_ImplantSlot Item;
	local array<XComGameState_Item> EquippedImplants;
	local int i, AvailableSlots;

	// Need to do a check here because LW Perk Pack replaces UIArmory_Implants
	if (!Screen.IsA('UIArmory_Implants'))
		return;

	Implants = UIArmory_Implants(Screen);

	Unit = Implants.GetUnit();
	EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);

	Implants.MaxImplantSlots = 2;

	Implants.List.SetHeight(class'UIArmory_ImplantSlot'.default.Height * Implants.MaxImplantSlots);
	Implants.ListBG.SetHeight((Implants.List.y - Implants.ListBG.y) + Implants.List.height + 20);

	Implants.List.ClearItems();

	AvailableSlots = Unit.GetCurrentStat(eStat_CombatSims);
	if (Unit.HasSoldierAbility('ShadowOps_DigitalWarfare'))
		AvailableSlots++;

	for(i = 0; i < Implants.MaxImplantSlots; ++i)
	{
		Item = UIArmory_ImplantSlot(Implants.List.GetItem(i));
		
		if(Item == none)
			Item = UIArmory_ImplantSlot(Implants.List.CreateItem(class'UIArmory_ImplantSlot')).InitImplantSlot(i);

		if(i < AvailableSlots && i < EquippedImplants.Length)
			Item.SetAvailable(EquippedImplants[i]);
		else if(i < AvailableSlots)
			Item.SetAvailable();
		else
			Item.SetLocked(Unit);
	}

}

defaultproperties
{
	ScreenClass = none
}