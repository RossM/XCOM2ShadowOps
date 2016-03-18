class XComGameState_Unit_BO extends XComGameState_Unit;

// Modified for Bandolier ability
function bool HasAmmoPocket()
{
	return (!IsMPCharacter() && HasSoldierAbility('Bandolier'));
}

// Modified for Rocketeer ability
function protected MergeAmmoAsNeeded(XComGameState StartState)
{
	local XComGameState_Item ItemIter, ItemInnerIter;
	local X2WeaponTemplate MergeTemplate;
	local int Idx, InnerIdx, BonusAmmo;
	local bool bFieldMedic, bHeavyOrdnance, bRocketeer;

	bFieldMedic = HasSoldierAbility('FieldMedic');
	bHeavyOrdnance = HasSoldierAbility('HeavyOrdnance');
	bRocketeer = HasSoldierAbility('Rocketeer');

	for (Idx = 0; Idx < InventoryItems.Length; ++Idx)
	{
		ItemIter = XComGameState_Item(StartState.GetGameStateForObjectID(InventoryItems[Idx].ObjectID));
		if (ItemIter != none && !ItemIter.bMergedOut)
		{
			MergeTemplate = X2WeaponTemplate(ItemIter.GetMyTemplate());
			if (MergeTemplate != none && MergeTemplate.bMergeAmmo)
			{
				BonusAmmo = 0;

				if (bFieldMedic && ItemIter.GetWeaponCategory() == class'X2Item_DefaultUtilityItems'.default.MedikitCat)
					BonusAmmo += class'X2Ability_SpecialistAbilitySet'.default.FIELD_MEDIC_BONUS;
				if (bHeavyOrdnance && ItemIter.InventorySlot == eInvSlot_GrenadePocket)
					BonusAmmo += class'X2Ability_GrenadierAbilitySet'.default.ORDNANCE_BONUS;
				if (bRocketeer && ItemIter.InventorySlot == eInvSlot_HeavyWeapon)
					BonusAmmo += 1;

				ItemIter.MergedItemCount = 1;
				for (InnerIdx = Idx + 1; InnerIdx < InventoryItems.Length; ++InnerIdx)
				{
					ItemInnerIter = XComGameState_Item(StartState.GetGameStateForObjectID(InventoryItems[InnerIdx].ObjectID));
					if (ItemInnerIter != none && ItemInnerIter.GetMyTemplate() == MergeTemplate)
					{
						if (bFieldMedic && ItemInnerIter.GetWeaponCategory() == class'X2Item_DefaultUtilityItems'.default.MedikitCat)
							BonusAmmo += class'X2Ability_SpecialistAbilitySet'.default.FIELD_MEDIC_BONUS;
						if (bHeavyOrdnance && ItemInnerIter.InventorySlot == eInvSlot_GrenadePocket)
							BonusAmmo += class'X2Ability_GrenadierAbilitySet'.default.ORDNANCE_BONUS;
						if (bRocketeer && ItemInnerIter.InventorySlot == eInvSlot_HeavyWeapon)
							BonusAmmo += 1;
						ItemInnerIter.bMergedOut = true;
						ItemInnerIter.Ammo = 0;
						ItemIter.MergedItemCount++;
					}
				}
				ItemIter.Ammo = ItemIter.GetClipSize() * ItemIter.MergedItemCount + BonusAmmo;
			}
		}
	}
}

// Modified for Deep Pockets ability
simulated function bool RemoveItemFromInventory(XComGameState_Item Item, optional XComGameState CheckGameState)
{
	local int i;
	local int slots;

	if (CanRemoveItemFromInventory(Item, CheckGameState))
	{		
		for (i = 0; i < InventoryItems.Length; ++i)
		{
			if (InventoryItems[i].ObjectID == Item.ObjectID)
			{
				InventoryItems.Remove(i, 1);
				Item.OwnerStateObject.ObjectID = 0;

				switch(Item.InventorySlot)
				{
				case eInvSlot_Armor:
					if(!IsMPCharacter() && X2ArmorTemplate(Item.GetMyTemplate()).bAddsUtilitySlot)
					{
						slots = 1;
						if (HasSoldierAbility('DeepPockets'))
							slots += 1;
						SetBaseMaxStat(eStat_UtilityItems, slots);
						SetCurrentStat(eStat_UtilityItems, slots);
					}
					break;
				case eInvSlot_Backpack:
					ModifyCurrentStat(eStat_BackpackSize, Item.GetItemSize());
					break;
				case eInvSlot_CombatSim:
					UnapplyCombatSimStats(Item);
					break;
				}

				Item.InventorySlot = eInvSlot_Unknown;
				return true;
			}
		}
	}
	return false;
}

// Bugfix: Keep the weapon color and pattern configured in the character pool when upgrading equipment
function bool UpgradeEquipment(XComGameState NewGameState, XComGameState_Item CurrentEquipment, array<X2EquipmentTemplate> UpgradeTemplates, EInventorySlot Slot, optional out XComGameState_Item UpgradeItem)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item EquippedItem;
	local X2EquipmentTemplate UpgradeTemplate;
	local int idx;

	if(UpgradeTemplates.Length == 0)
	{
		return false;
	}

	// Grab HQ Object
	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
	}
	
	if (CurrentEquipment == none)
	{
		// Make an instance of the best equipment we found and equip it
		UpgradeItem = UpgradeTemplates[0].CreateInstanceFromTemplate(NewGameState);

		//Transfer settings that were configured in the character pool with respect to the weapon. Should only be applied here
		//where we are handing out generic weapons.
		if(UpgradeTemplates[0].InventorySlot == eInvSlot_PrimaryWeapon || UpgradeTemplates[0].InventorySlot == eInvSlot_SecondaryWeapon)
		{
			UpgradeItem.WeaponAppearance.iWeaponTint = kAppearance.iWeaponTint;
			UpgradeItem.WeaponAppearance.nmWeaponPattern = kAppearance.nmWeaponPattern;
		}

		NewGameState.AddStateObject(UpgradeItem);
		
		return AddItemToInventory(UpgradeItem, Slot, NewGameState, (Slot == eInvSlot_Utility));
	}
	else
	{
		for(idx = 0; idx < UpgradeTemplates.Length; idx++)
		{
			UpgradeTemplate = UpgradeTemplates[idx];

			if(UpgradeTemplate.Tier > CurrentEquipment.GetMyTemplate().Tier)
			{
				if(X2WeaponTemplate(UpgradeTemplate) != none && X2WeaponTemplate(UpgradeTemplate).WeaponCat != X2WeaponTemplate(CurrentEquipment.GetMyTemplate()).WeaponCat)
				{
					continue;
				}

				// Remove the equipped item and put it back in HQ inventory
				EquippedItem = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', CurrentEquipment.ObjectID));
				NewGameState.AddStateObject(EquippedItem);
				RemoveItemFromInventory(EquippedItem, NewGameState);
				XComHQ.PutItemInInventory(NewGameState, EquippedItem);

				// Make an instance of the best equipment we found and equip it
				UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(NewGameState);

				//Transfer settings that were configured in the character pool with respect to the weapon. Should only be applied here
				//where we are handing out generic weapons.
				if(UpgradeTemplates[0].InventorySlot == eInvSlot_PrimaryWeapon || UpgradeTemplates[0].InventorySlot == eInvSlot_SecondaryWeapon)
				{
					UpgradeItem.WeaponAppearance.iWeaponTint = kAppearance.iWeaponTint;
					UpgradeItem.WeaponAppearance.nmWeaponPattern = kAppearance.nmWeaponPattern;
				}

				NewGameState.AddStateObject(UpgradeItem);
				return AddItemToInventory(UpgradeItem, Slot, NewGameState);
			}
		}
	}

	return false;
}

// Modified for Deep Pockets ability
function ValidateLoadout(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item EquippedArmor, EquippedPrimaryWeapon, EquippedSecondaryWeapon; // Default slots
	local XComGameState_Item EquippedHeavyWeapon, EquippedGrenade, EquippedAmmo, UtilityItem; // Special slots
	local array<XComGameState_Item> EquippedUtilityItems; // Utility Slots
	local int idx;
	local int slots;

	// Grab HQ Object
	History = `XCOMHISTORY;
	
	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if(XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
	}

	// Armor Slot
	EquippedArmor = GetItemInSlot(eInvSlot_Armor, NewGameState);
	if(EquippedArmor == none)
	{
		EquippedArmor = GetDefaultArmor(NewGameState);
		AddItemToInventory(EquippedArmor, eInvSlot_Armor, NewGameState);
	}

	// Primary Weapon Slot
	EquippedPrimaryWeapon = GetItemInSlot(eInvSlot_PrimaryWeapon, NewGameState);
	if(EquippedPrimaryWeapon == none)
	{
		EquippedPrimaryWeapon = GetBestPrimaryWeapon(NewGameState);
		AddItemToInventory(EquippedPrimaryWeapon, eInvSlot_PrimaryWeapon, NewGameState);
	}

	// Check Ammo Item compatibility (utility slot)
	EquippedUtilityItems = GetAllItemsInSlot(eInvSlot_Utility, NewGameState, ,true);
	for(idx = 0; idx < EquippedUtilityItems.Length; idx++)
	{
		if(X2AmmoTemplate(EquippedUtilityItems[idx].GetMyTemplate()) != none && 
		   !X2AmmoTemplate(EquippedUtilityItems[idx].GetMyTemplate()).IsWeaponValidForAmmo(X2WeaponTemplate(EquippedPrimaryWeapon.GetMyTemplate())))
		{
			EquippedAmmo = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', EquippedUtilityItems[idx].ObjectID));
			NewGameState.AddStateObject(EquippedAmmo);
			RemoveItemFromInventory(EquippedAmmo, NewGameState);
			XComHQ.PutItemInInventory(NewGameState, EquippedAmmo);
			EquippedAmmo = none;
			EquippedUtilityItems.Remove(idx, 1);
			idx--;
		}
	}

	// Secondary Weapon Slot
	EquippedSecondaryWeapon = GetItemInSlot(eInvSlot_SecondaryWeapon, NewGameState);
	if(EquippedSecondaryWeapon == none && NeedsSecondaryWeapon())
	{
		EquippedSecondaryWeapon = GetBestSecondaryWeapon(NewGameState);
		AddItemToInventory(EquippedSecondaryWeapon, eInvSlot_SecondaryWeapon, NewGameState);
	}
	else if(EquippedSecondaryWeapon != none && !NeedsSecondaryWeapon())
	{
		EquippedSecondaryWeapon = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', EquippedSecondaryWeapon.ObjectID));
		NewGameState.AddStateObject(EquippedSecondaryWeapon);
		RemoveItemFromInventory(EquippedSecondaryWeapon, NewGameState);
		XComHQ.PutItemInInventory(NewGameState, EquippedSecondaryWeapon);
		EquippedSecondaryWeapon = none;
	}

	// Heavy Weapon Slot
	EquippedHeavyWeapon = GetItemInSlot(eInvSlot_HeavyWeapon, NewGameState);
	if(EquippedHeavyWeapon == none && EquippedArmor.AllowsHeavyWeapon())
	{
		EquippedHeavyWeapon = GetBestHeavyWeapon(NewGameState);
		AddItemToInventory(EquippedHeavyWeapon, eInvSlot_HeavyWeapon, NewGameState);
	}
	else if(EquippedHeavyWeapon != none && !EquippedArmor.AllowsHeavyWeapon())
	{
		EquippedHeavyWeapon = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', EquippedHeavyWeapon.ObjectID));
		NewGameState.AddStateObject(EquippedHeavyWeapon);
		RemoveItemFromInventory(EquippedHeavyWeapon, NewGameState);
		XComHQ.PutItemInInventory(NewGameState, EquippedHeavyWeapon);
		EquippedHeavyWeapon = none;
	}

	// Grenade Pocket
	EquippedGrenade = GetItemInSlot(eInvSlot_GrenadePocket, NewGameState);
	if(EquippedGrenade == none && HasGrenadePocket())
	{
		EquippedGrenade = GetBestGrenade(NewGameState);
		AddItemToInventory(EquippedGrenade, eInvSlot_GrenadePocket, NewGameState);
	}
	else if(EquippedGrenade != none && !HasGrenadePocket())
	{
		EquippedGrenade = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', EquippedGrenade.ObjectID));
		NewGameState.AddStateObject(EquippedGrenade);
		RemoveItemFromInventory(EquippedGrenade, NewGameState);
		XComHQ.PutItemInInventory(NewGameState, EquippedGrenade);
		EquippedGrenade = none;
	}

	// UtilitySlots (Already grabbed equipped)
	if(!IsMPCharacter())
	{
		slots = 1;
		if(X2ArmorTemplate(EquippedArmor.GetMyTemplate()).bAddsUtilitySlot)
			slots += 1;
		if (HasSoldierAbility('DeepPockets'))
			slots += 1;

		SetBaseMaxStat(eStat_UtilityItems, slots);
		SetCurrentStat(eStat_UtilityItems, slots);
	}

	// Remove Extra Utility Items
	for(idx = GetCurrentStat(eStat_UtilityItems); idx < EquippedUtilityItems.Length; idx++)
	{
		if(idx >= EquippedUtilityItems.Length)
		{
			break;
		}

		UtilityItem = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', EquippedUtilityItems[idx].ObjectID));
		NewGameState.AddStateObject(UtilityItem);
		RemoveItemFromInventory(UtilityItem, NewGameState);
		XComHQ.PutItemInInventory(NewGameState, UtilityItem);
		UtilityItem = none;
		EquippedUtilityItems.Remove(idx, 1);
		idx--;
	}

	// Equip Default Utility Item in first slot if needed
	while(EquippedUtilityItems.Length < 1)
	{
		UtilityItem = GetBestUtilityItem(NewGameState);
		AddItemToInventory(UtilityItem, eInvSlot_Utility, NewGameState);
		EquippedUtilityItems.AddItem(UtilityItem);
	}
}

// New function, added to make Finesse and Heavy Armor work correctly
simulated function int GetUIStatFromItem(ECharStatType Stat, XComGameState_Item InventoryItem)
{
	local int Result;
	local X2EquipmentTemplate EquipmentTemplate;
	local X2ArmorTemplate ArmorTemplate;
	local X2WeaponTemplate WeaponTemplate;

	EquipmentTemplate = X2EquipmentTemplate(InventoryItem.GetMyTemplate());
	if (EquipmentTemplate != none)
	{
		// Don't include sword boosts or any other equipment in the EquipmentExcludedFromStatBoosts array
		if(class'UISoldierHeader'.default.EquipmentExcludedFromStatBoosts.Find(EquipmentTemplate.DataName) == INDEX_NONE)
			Result += EquipmentTemplate.GetUIStatMarkup(Stat, InventoryItem);
	}

	WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
	if (WeaponTemplate != none && WeaponTemplate.WeaponCat == 'rifle' && HasSoldierAbility('Finesse'))
	{
		if (Stat == eStat_Mobility)
			Result += 3;
		else if (Stat == eStat_Offense)
			Result += 10;
	}

	ArmorTemplate = X2ArmorTemplate(InventoryItem.GetMyTemplate());
	if (ArmorTemplate != none && ArmorTemplate.bHeavyWeapon && HasSoldierAbility('HeavyArmor'))
	{
		if (Stat == eStat_ArmorMitigation)
			Result += 1;
	}

	return Result;
}

// Modified for Finesse and Heavy Armor
simulated function int GetUIStatFromInventory(ECharStatType Stat, optional XComGameState CheckGameState)
{
	local int Result;
	local XComGameState_Item InventoryItem;
	local array<XComGameState_Item> CurrentInventory;

	//  Gather abilities from the unit's inventory
	CurrentInventory = GetAllInventoryItems(CheckGameState);
	foreach CurrentInventory(InventoryItem)
	{
		Result += GetUIStatFromItem(Stat, InventoryItem);
	}	

	return Result;
}