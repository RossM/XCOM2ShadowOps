class UnitUtilities_BO extends Object config(GameCore);

var config bool bDisplaySubclassNames;

// This class contains functions that augment or replace functions on XComGameState_Unit, since
// those can't be overridden in a mod.

static function string GetSoldierClassDisplayName(XComGameState_Unit Unit)
{
	local X2SoldierClassTemplate SoldierClassTemplate;
	local int iLeftCount, iRightCount, i;

	SoldierClassTemplate = Unit.GetSoldierClassTemplate();

	if (!default.bDisplaySubclassNames)
		return SoldierClassTemplate.DisplayName;

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
	return (!Unit.IsMPCharacter() && Unit.HasSoldierAbility('ShadowOps_Bandolier'));
}

static simulated function int GetUIStatBonusFromItem(XComGameState_Unit Unit, ECharStatType Stat, XComGameState_Item InventoryItem)
{
	local int Result;
	local X2ArmorTemplate ArmorTemplate;
	local X2WeaponTemplate WeaponTemplate;

	WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
	if (WeaponTemplate != none && WeaponTemplate.WeaponCat == 'rifle' && Unit.HasSoldierAbility('ShadowOps_Finesse'))
	{
		if (Stat == eStat_Mobility)
			Result += class'X2Ability_DragoonAbilitySet'.default.FinesseMobilityBonus;
		else if (Stat == eStat_Offense)
			Result += class'X2Ability_DragoonAbilitySet'.default.FinesseOffenseBonus;
	}

	ArmorTemplate = X2ArmorTemplate(InventoryItem.GetMyTemplate());
	if (ArmorTemplate != none && ArmorTemplate.bHeavyWeapon && Unit.HasSoldierAbility('ShadowOps_HeavyArmor'))
	{
		if (Stat == eStat_ArmorMitigation)
			Result += class'X2Ability_DragoonAbilitySet'.default.HeavyArmorBonus;
	}

	return Result;
}

// Copied from UIUtilities_Strategy and changed to account for ammo pocket
simulated static function array<XComGameState_Item> GetEquippedItemsInSlot(XComGameState_Unit Unit, EInventorySlot SlotType, optional XComGameState CheckGameState)
{
	local StateObjectReference ItemRef;
	local XComGameState_Item ItemState;
	local X2EquipmentTemplate EquipmentTemplate;
	local array<XComGameState_Item> arrItems;

	foreach Unit.InventoryItems(ItemRef)
	{
		ItemState = Unit.GetItemGameState(ItemRef, CheckGameState);
		EquipmentTemplate = X2EquipmentTemplate(ItemState.GetMyTemplate());

		// xpad is only item with size 0, that is always equipped
		if (ItemState.GetItemSize() > 0 && (ItemState.InventorySlot == SlotType || (EquipmentTemplate != None && EquipmentTemplate.InventorySlot == SlotType)))
		{
			// Ignore any items in the grenade pocket when checking for utility items, since otherwise grenades get added as utility items
			if (SlotType == eInvSlot_Utility)
			{
				if (ItemState.InventorySlot != eInvSlot_GrenadePocket && ItemState.InventorySlot != eInvSlot_AmmoPocket)
					arrItems.AddItem(ItemState);
			}
			else
				arrItems.AddItem(ItemState);
		}
	}
	
	return arrItems;
}

simulated static function array<XComGameState_Item> GetEquippedUtilityItems(XComGameState_Unit Unit, optional XComGameState CheckGameState)
{
	return GetEquippedItemsInSlot(Unit, eInvSlot_Utility, CheckGameState);
}

