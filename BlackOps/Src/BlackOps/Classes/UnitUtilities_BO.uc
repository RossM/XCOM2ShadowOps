class UnitUtilities_BO extends Object;

// This class contains functions that augment or replace functions on XComGameState_Unit, since
// those can't be overridden in a mod.

static function string GetSoldierClassDisplayName(XComGameState_Unit Unit)
{
	local X2SoldierClassTemplate SoldierClassTemplate;
	local int iLeftCount, iRightCount, i;

	SoldierClassTemplate = Unit.GetSoldierClassTemplate();

	for (i = 0; i < Unit.m_SoldierProgressionAbilties.Length; i++)
	{
		if (Unit.m_SoldierProgressionAbilties[i].iRank <= 0)
			continue;

		if (Unit.m_SoldierProgressionAbilties[i].iBranch == 0)
		{
			iLeftCount++;
			if (iLeftCount >= 2)
				return SoldierClassTemplate.LeftAbilityTreeTitle;
		}
		else
		{
			iRightCount++;
			if (iRightCount >= 2)
				return SoldierClassTemplate.RightAbilityTreeTitle;
		}
	}

	return SoldierClassTemplate.DisplayName;
}

static function bool AddItemToInventory(XComGameState_Unit Unit, XComGameState_Item Item, EInventorySlot Slot, XComGameState NewGameState, optional bool bAddToFront)
{
	local X2ItemTemplate ItemTemplate;
	local bool Result;

	ItemTemplate = Item.GetMyTemplate();
	if (CanAddItemToInventory(Unit, ItemTemplate, Slot, NewGameState, Item.Quantity))
	{
		Unit.bIgnoreItemEquipRestrictions = true;
		Result = Unit.AddItemToInventory(Item, Slot, NewGameState, bAddToFront);
		Unit.bIgnoreItemEquipRestrictions = false;
		return Result;
	}
	return false;
}

static simulated function bool CanAddItemToInventory(XComGameState_Unit Unit, const X2ItemTemplate ItemTemplate, const EInventorySlot Slot, optional XComGameState NewGameState, optional int Quantity=1)
{
	if (ItemTemplate != none)
	{
		if (Slot == eInvSlot_AmmoPocket)
		{
			if (!HasAmmoPocket(Unit))
				return false;
			if (Unit.GetItemInSlot(eInvSlot_AmmoPocket, NewGameState) != none)
				return false;
			return ItemTemplate.ItemCat == 'ammo';
		}
		else if (HasAmmoPocket(Unit) && ItemTemplate.ItemCat == 'ammo')
		{
			return false;
		}
	}

	return Unit.CanAddItemToInventory(ItemTemplate, Slot, NewGameState, Quantity);
}

static function bool HasAmmoPocket(XComGameState_Unit Unit)
{
	return (!Unit.IsMPCharacter() && Unit.HasSoldierAbility('Bandolier'));
}
