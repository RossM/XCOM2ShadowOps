class UIArmory_Implants_BO extends UIArmory_Implants;

simulated function PopulateData()
{
	local int i, AvailableSlots;
	local XComGameState_Unit Unit;
	local UIArmory_ImplantSlot Item;
	local array<XComGameState_Item> EquippedImplants;

	// We don't need to clear the list, or recreate the pawn here -sbatista
	//super.PopulateData();
	Unit = GetUnit();

	if(ActorPawn == none)
	{
		super(UIArmory).CreateSoldierPawn();
	}

	EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);
	AvailableSlots = Unit.GetCurrentStat(eStat_CombatSims);
	if (Unit.HasSoldierAbility('ShadowOps_DigitalWarfare'))
		AvailableSlots++;

	for(i = 0; i < MaxImplantSlots; ++i)
	{
		Item = UIArmory_ImplantSlot(List.GetItem(i));
		
		if(Item == none)
			Item = UIArmory_ImplantSlot(List.CreateItem(class'UIArmory_ImplantSlot')).InitImplantSlot(i);

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
	MaxImplantSlots = 2;
	DisplayTag = "UIBlueprint_CustomizeMenu";
	CameraTag = "UIBlueprint_CustomizeMenu";
}