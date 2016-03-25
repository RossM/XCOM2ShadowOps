// This file is for documentation purposes only. Game state classes cannot be overridden in mods.
// The relevant functions have been copied to the corresponding base game classes.

class XComGameState_Unit_BO extends XComGameState_Unit;

// Modified for Bandolier ability
function bool HasAmmoPocket()
{
	return (!IsMPCharacter() && HasSoldierAbility('Bandolier'));
}

// Modified for Rocketeer and Packmaster abilities
function protected MergeAmmoAsNeeded(XComGameState StartState)
{
	local XComGameState_Item ItemIter, ItemInnerIter;
	local X2WeaponTemplate MergeTemplate;
	local int Idx, InnerIdx, BonusAmmo;
	local bool bFieldMedic, bHeavyOrdnance, bRocketeer, bPackmaster;

	bFieldMedic = HasSoldierAbility('FieldMedic');
	bHeavyOrdnance = HasSoldierAbility('HeavyOrdnance');
	bRocketeer = HasSoldierAbility('Rocketeer');
	bPackmaster = HasSoldierAbility('Packmaster');

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
				if (bPackmaster && (ItemIter.InventorySlot == eInvSlot_Utility || ItemIter.InventorySlot == eInvSlot_GrenadePocket))
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
						if (bPackmaster && (ItemInnerIter.InventorySlot == eInvSlot_Utility || ItemInnerIter.InventorySlot == eInvSlot_GrenadePocket))
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

function string GetSoldierClassDisplayName()
{
	local X2SoldierClassTemplate SoldierClassTemplate;
	local int iLeftCount, iRightCount, i;

	SoldierClassTemplate = GetSoldierClassTemplate();

	for (i = 0; i < m_SoldierProgressionAbilties.Length; i++)
	{
		if (m_SoldierProgressionAbilties[i].iRank <= 0)
			continue;

		if (m_SoldierProgressionAbilties[i].iBranch == 0)
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

	return GetSoldierClassTemplate().DisplayName;
}

// Modified to choose a loadout randomly if there are multiple options
function ApplyInventoryLoadout(XComGameState ModifyGameState, optional name NonDefaultLoadout)
{
	local X2ItemTemplateManager ItemTemplateManager;
	local InventoryLoadout Loadout;
	local InventoryLoadoutItem LoadoutItem;
	local X2EquipmentTemplate EquipmentTemplate;
	local XComGameState_Item NewItem;
	local name UseLoadoutName, RequiredLoadout;
	local X2SoldierClassTemplate SoldierClassTemplate;
	local array<InventoryLoadout> FoundLoadouts;

	if (NonDefaultLoadout != '')      
	{
		//  If loadout is specified, always use that.
		UseLoadoutName = NonDefaultLoadout;
	}
	else
	{
		//  If loadout was not specified, use the character template's default loadout, or the squaddie loadout for the soldier class (if any).
		UseLoadoutName = GetMyTemplate().DefaultLoadout;
		SoldierClassTemplate = GetSoldierClassTemplate();
		if (SoldierClassTemplate != none && SoldierClassTemplate.SquaddieLoadout != '')
			UseLoadoutName = SoldierClassTemplate.SquaddieLoadout;
	}

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	foreach ItemTemplateManager.Loadouts(Loadout)
	{
		if (Loadout.LoadoutName == UseLoadoutName)
		{
			FoundLoadouts.AddItem(Loadout);
		}
	}
	if (FoundLoadouts.Length >= 1)
	{
		Loadout = FoundLoadouts[`SYNC_RAND(FoundLoadouts.Length)];
		foreach Loadout.Items(LoadoutItem)
		{
			EquipmentTemplate = X2EquipmentTemplate(ItemTemplateManager.FindItemTemplate(LoadoutItem.Item));
			if (EquipmentTemplate != none)
			{
				NewItem = EquipmentTemplate.CreateInstanceFromTemplate(ModifyGameState);

				//Transfer settings that were configured in the character pool with respect to the weapon. Should only be applied here
				//where we are handing out generic weapons.
				if(EquipmentTemplate.InventorySlot == eInvSlot_PrimaryWeapon || EquipmentTemplate.InventorySlot == eInvSlot_SecondaryWeapon)
				{
					NewItem.WeaponAppearance.iWeaponTint = kAppearance.iWeaponTint;
					NewItem.WeaponAppearance.nmWeaponPattern = kAppearance.nmWeaponPattern;
				}

				AddItemToInventory(NewItem, EquipmentTemplate.InventorySlot, ModifyGameState);
				ModifyGameState.AddStateObject(NewItem);
			}
		}
	}
	//  Always apply the template's required loadout.
	RequiredLoadout = GetMyTemplate().RequiredLoadout;
	if (RequiredLoadout != '' && RequiredLoadout != UseLoadoutName && !HasLoadout(RequiredLoadout, ModifyGameState))
		ApplyInventoryLoadout(ModifyGameState, RequiredLoadout);

	// Give Kevlar armor if Unit's armor slot is empty
	if(IsASoldier() && GetItemInSlot(eInvSlot_Armor, ModifyGameState) == none)
	{
		EquipmentTemplate = X2EquipmentTemplate(ItemTemplateManager.FindItemTemplate('KevlarArmor'));
		NewItem = EquipmentTemplate.CreateInstanceFromTemplate(ModifyGameState);
		AddItemToInventory(NewItem, eInvSlot_Armor, ModifyGameState);
		ModifyGameState.AddStateObject(NewItem);
	}
}

//------------------------------------------------------
function XComGameState_Item GetBestPrimaryWeapon(XComGameState NewGameState)
{
	local array<X2WeaponTemplate> PrimaryWeaponTemplates;
	local XComGameState_Item ItemState;

	PrimaryWeaponTemplates = GetBestPrimaryWeaponTemplates();

	if (PrimaryWeaponTemplates.Length == 0)
	{
		return none;
	}
	
	ItemState = PrimaryWeaponTemplates[`SYNC_RAND(PrimaryWeaponTemplates.Length)].CreateInstanceFromTemplate(NewGameState);

	//Transfer settings that were configured in the character pool with respect to the weapon. Should only be applied here
	//where we are handing out generic weapons.
	ItemState.WeaponAppearance.iWeaponTint = kAppearance.iWeaponTint;
	ItemState.WeaponAppearance.nmWeaponPattern = kAppearance.nmWeaponPattern;

	NewGameState.AddStateObject(ItemState);
	
	return ItemState;
}

//------------------------------------------------------
function XComGameState_Item GetBestSecondaryWeapon(XComGameState NewGameState)
{
	local array<X2WeaponTemplate> SecondaryWeaponTemplates;
	local XComGameState_Item ItemState;

	SecondaryWeaponTemplates = GetBestSecondaryWeaponTemplates();

	if (SecondaryWeaponTemplates.Length == 0)
	{
		return none;
	}

	ItemState = SecondaryWeaponTemplates[`SYNC_RAND(SecondaryWeaponTemplates.Length)].CreateInstanceFromTemplate(NewGameState);

	//Transfer settings that were configured in the character pool with respect to the weapon. Should only be applied here
	//where we are handing out generic weapons.
	ItemState.WeaponAppearance.iWeaponTint = kAppearance.iWeaponTint;
	ItemState.WeaponAppearance.nmWeaponPattern = kAppearance.nmWeaponPattern;

	NewGameState.AddStateObject(ItemState);
	
	return ItemState;
}

//  Called only when ranking up from rookie to squaddie. Applies items per configured loadout, safely removing
//  items and placing them back into HQ's inventory.
function ApplySquaddieLoadout(XComGameState GameState, optional XComGameState_HeadquartersXCom XHQ = none)
{
	local X2ItemTemplateManager ItemTemplateMan;
	local X2EquipmentTemplate ItemTemplate;
	local InventoryLoadout Loadout;
	local name SquaddieLoadout;
	local bool bFoundLoadout;
	local XComGameState_Item ItemState;
	local array<XComGameState_Item> UtilityItems;
	local int i;

	`assert(GameState != none);

	SquaddieLoadout = GetSoldierClassTemplate().SquaddieLoadout;
	ItemTemplateMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	foreach ItemTemplateMan.Loadouts(Loadout)
	{
		if (Loadout.LoadoutName == SquaddieLoadout)
		{
			bFoundLoadout = true;
			break;
		}
	}
	if (bFoundLoadout)
	{
		for (i = 0; i < Loadout.Items.Length; ++i)
		{
			ItemTemplate = X2EquipmentTemplate(ItemTemplateMan.FindItemTemplate(Loadout.Items[i].Item));
			if (ItemTemplate != none)
			{
				ItemState = none;
				if (ItemTemplate.InventorySlot == eInvSlot_Utility)
				{
					//  If we can't add a utility item, remove the first one. That should fix it. If not, we may need more logic later.
					if (!CanAddItemToInventory(ItemTemplate, ItemTemplate.InventorySlot, GameState))
					{
						UtilityItems = GetAllItemsInSlot(ItemTemplate.InventorySlot, GameState);
						if (UtilityItems.Length > 0)
						{
							ItemState = UtilityItems[0];
						}
					}
				}
				else
				{
					//  If we can't add an item, there's probably one occupying the slot already, so remove it.
					if (!CanAddItemToInventory(ItemTemplate, ItemTemplate.InventorySlot, GameState))
					{
						ItemState = GetItemInSlot(ItemTemplate.InventorySlot, GameState);
					}
				}
				//  ItemState will be populated with an item we need to remove in order to place the new item in (if any).
				if (ItemState != none)
				{
					if (ItemState.GetMyTemplateName() == ItemTemplate.DataName)
						continue;
					if (!RemoveItemFromInventory(ItemState, GameState))
					{
						`RedScreen("Unable to remove item from inventory. Squaddie loadout will be affected." @ ItemState.ToString());
						continue;
					}

					if(XHQ != none)
					{
						XHQ.PutItemInInventory(GameState, ItemState);
					}
				}
				if (!CanAddItemToInventory(ItemTemplate, ItemTemplate.InventorySlot, GameState))
				{
					`RedScreen("Unable to add new item to inventory. Squaddie loadout will be affected." @ ItemTemplate.DataName);
					continue;
				}
				ItemState = ItemTemplate.CreateInstanceFromTemplate(GameState);

				//Transfer settings that were configured in the character pool with respect to the weapon. Should only be applied here
				//where we are handing out generic weapons.
				if(ItemTemplate.InventorySlot == eInvSlot_PrimaryWeapon || ItemTemplate.InventorySlot == eInvSlot_SecondaryWeapon)
				{
					ItemState.WeaponAppearance.iWeaponTint = kAppearance.iWeaponTint;
					ItemState.WeaponAppearance.nmWeaponPattern = kAppearance.nmWeaponPattern;
				}

				AddItemToInventory(ItemState, ItemTemplate.InventorySlot, GameState);
				GameState.AddStateObject(ItemState);
			}
			else
			{
				`RedScreen("Unknown item template" @ Loadout.Items[i].Item @ "specified in loadout" @ SquaddieLoadout);
			}
		}
	}

	// Give Kevlar armor if Unit's armor slot is empty
	if(IsASoldier() && GetItemInSlot(eInvSlot_Armor, GameState) == none)
	{
		ItemTemplate = X2EquipmentTemplate(ItemTemplateMan.FindItemTemplate('KevlarArmor'));
		ItemState = ItemTemplate.CreateInstanceFromTemplate(GameState);
		AddItemToInventory(ItemState, eInvSlot_Armor, GameState);
		GameState.AddStateObject(ItemState);
	}
}
