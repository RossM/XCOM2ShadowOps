class UIArmory_Loadout_BO extends UIArmory_Loadout;

simulated function bool ShowInLockerList(XComGameState_Item Item, EInventorySlot SelectedSlot)
{
	local X2ItemTemplate ItemTemplate;
	local X2GrenadeTemplate GrenadeTemplate;
	local X2EquipmentTemplate EquipmentTemplate;
	local XComGameState_Unit Unit;

	ItemTemplate = Item.GetMyTemplate();
	Unit = GetUnit();
	
	if(MeetsAllStrategyRequirements(ItemTemplate.ArmoryDisplayRequirements) && MeetsDisplayRequirement(ItemTemplate))
	{
		switch(SelectedSlot)
		{
		case eInvSlot_GrenadePocket:
			GrenadeTemplate = X2GrenadeTemplate(ItemTemplate);
			return GrenadeTemplate != none;
		case eInvSlot_AmmoPocket:
			return ItemTemplate.ItemCat == 'ammo';
		default:
			EquipmentTemplate = X2EquipmentTemplate(ItemTemplate);

			if (ItemTemplate.ItemCat == 'ammo' && Unit.HasAmmoPocket())
				return false;

			// xpad is only item with size 0, that is always equipped
			return (EquipmentTemplate != none && EquipmentTemplate.iItemSize > 0 && EquipmentTemplate.InventorySlot == SelectedSlot);
		}
	}

	return false;
}
