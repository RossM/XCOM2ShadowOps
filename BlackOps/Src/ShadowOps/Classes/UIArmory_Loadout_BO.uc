class UIArmory_Loadout_BO extends UIArmory_Loadout;

simulated function bool EquipItem(UIArmory_LoadoutItem Item)
{
	local StateObjectReference PrevItemRef, NewItemRef;
	local XComGameState_Item PrevItem, NewItem;
	local bool CanEquip, EquipSucceeded, AddToFront;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComNarrativeMoment EquipNarrativeMoment;
	local XGWeapon Weapon;
	local array<XComGameState_Item> PrevUtilityItems;
	local XComGameState_Unit UpdatedUnit;
	local XComGameState UpdatedState;
	local X2EquipmentTemplate EquipmentTemplate;

	UpdatedState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Equip Item");
	UpdatedUnit = XComGameState_Unit(UpdatedState.CreateStateObject(class'XComGameState_Unit', GetUnit().ObjectID));
	UpdatedState.AddStateObject(UpdatedUnit);
	
	PrevUtilityItems = class'UnitUtilities_BO'.static.GetEquippedUtilityItems(UpdatedUnit, UpdatedState);

	NewItemRef = Item.ItemRef;
	PrevItemRef = UIArmory_LoadoutItem(EquippedList.GetSelectedItem()).ItemRef;
	PrevItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(PrevItemRef.ObjectID));

	if(PrevItem != none)
	{
		PrevItem = XComGameState_Item(UpdatedState.CreateStateObject(class'XComGameState_Item', PrevItem.ObjectID));
		UpdatedState.AddStateObject(PrevItem);
	}

	foreach UpdatedState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if(XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(UpdatedState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		UpdatedState.AddStateObject(XComHQ);
	}

	// Attempt to remove previously equipped primary or secondary weapons - NOT WORKING, TODO FIX ME
	if( PrevItem != none && 
		X2WeaponTemplate(PrevItem.GetMyTemplate()) != none && 
		X2WeaponTemplate(PrevItem.GetMyTemplate()).InventorySlot == eInvSlot_PrimaryWeapon || 
		X2WeaponTemplate(PrevItem.GetMyTemplate()).InventorySlot == eInvSlot_SecondaryWeapon)
	{
		Weapon = XGWeapon(PrevItem.GetVisualizer());
		// Weapon must be graphically detach, otherwise destroying it leaves a NULL component attached at that socket
		XComUnitPawn(ActorPawn).DetachItem(Weapon.GetEntity().Mesh);

		Weapon.Destroy();
	}

	CanEquip = ((PrevItem == none || UpdatedUnit.RemoveItemFromInventory(PrevItem, UpdatedState)) && class'UnitUtilities_BO'.static.CanAddItemToInventory(UpdatedUnit, Item.ItemTemplate, GetSelectedSlot(), UpdatedState));

	if(CanEquip)
	{
		GetItemFromInventory(UpdatedState, NewItemRef, NewItem);
		NewItem = XComGameState_Item(UpdatedState.CreateStateObject(class'XComGameState_Item', NewItem.ObjectID));
		UpdatedState.AddStateObject(NewItem);

		// Fix for TTP 473, preserve the order of Utility items
		if(PrevUtilityItems.Length > 0)
		{
			AddToFront = PrevItemRef.ObjectID == PrevUtilityItems[0].ObjectID;
		}
		
		EquipSucceeded = class'UnitUtilities_BO'.static.AddItemToInventory(UpdatedUnit, NewItem, GetSelectedSlot(), UpdatedState, AddToFront);

		if( EquipSucceeded )
		{
			if( PrevItem != none )
			{
				XComHQ.PutItemInInventory(UpdatedState, PrevItem);
			}

			EquipmentTemplate = X2EquipmentTemplate(Item.ItemTemplate);
			if (EquipmentTemplate != none && (EquipmentTemplate.InventorySlot == eInvSlot_PrimaryWeapon || EquipmentTemplate.InventorySlot == eInvSlot_SecondaryWeapon))
			{
				NewItem.WeaponAppearance.iWeaponTint = UpdatedUnit.kAppearance.iWeaponTint;
				NewItem.WeaponAppearance.nmWeaponPattern = UpdatedUnit.kAppearance.nmWeaponPattern;
			}

			if(class'XComGameState_HeadquartersXCom'.static.GetObjectiveStatus('T0_M5_EquipMedikit') == eObjectiveState_InProgress &&
			   NewItem.GetMyTemplateName() == class'UIInventory_BuildItems'.default.TutorialBuildItem)
			{
				`XEVENTMGR.TriggerEvent('TutorialItemEquipped', , , UpdatedState);
				bTutorialJumpOut = true;
			}
		}
		else
		{
			if(PrevItem != none)
			{
				class'UnitUtilities_BO'.static.AddItemToInventory(UpdatedUnit, PrevItem, GetSelectedSlot(), UpdatedState);
			}

			XComHQ.PutItemInInventory(UpdatedState, NewItem);
		}
	}

	UpdatedUnit.ValidateLoadout(UpdatedState);
	`XCOMGAME.GameRuleset.SubmitGameState(UpdatedState);

	if( EquipSucceeded && X2EquipmentTemplate(Item.ItemTemplate) != none)
	{
		if(X2EquipmentTemplate(Item.ItemTemplate).EquipSound != "")
		{
			`XSTRATEGYSOUNDMGR.PlaySoundEvent(X2EquipmentTemplate(Item.ItemTemplate).EquipSound);
		}

		if(X2EquipmentTemplate(Item.ItemTemplate).EquipNarrative != "")
		{
			EquipNarrativeMoment = XComNarrativeMoment(`CONTENT.RequestGameArchetype(X2EquipmentTemplate(Item.ItemTemplate).EquipNarrative));
			XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
			if(EquipNarrativeMoment != None && XComHQ.CanPlayArmorIntroNarrativeMoment(EquipNarrativeMoment))
			{
				UpdatedState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update Played Armor Intro List");
				XComHQ = XComGameState_HeadquartersXCom(UpdatedState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
				UpdatedState.AddStateObject(XComHQ);
				XComHQ.UpdatePlayedArmorIntroNarrativeMoments(EquipNarrativeMoment);
				`XCOMGAME.GameRuleset.SubmitGameState(UpdatedState);

				`HQPRES.UIArmorIntroCinematic(EquipNarrativeMoment.nmRemoteEvent, 'CIN_ArmorIntro_Done', UnitReference);
			}
		}	
	}

	return EquipSucceeded;
}

simulated function UpdateEquippedList()
{
	local int i, numUtilityItems;
	local UIArmory_LoadoutItem Item;
	local array<XComGameState_Item> UtilityItems;
	local XComGameState_Unit UpdatedUnit;

	UpdatedUnit = GetUnit();
	EquippedList.ClearItems();

	// Clear out tooltips from removed list items
	Movie.Pres.m_kTooltipMgr.RemoveTooltipsByPartialPath(string(EquippedList.MCPath));

	// units can only have one item equipped in the slots bellow
	Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
	Item.InitLoadoutItem(GetEquippedItem(eInvSlot_Armor), eInvSlot_Armor, true);

	Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
	Item.InitLoadoutItem(GetEquippedItem(eInvSlot_PrimaryWeapon), eInvSlot_PrimaryWeapon, true);

	// don't show secondary weapon slot on rookies
	if(UpdatedUnit.GetRank() > 0)
	{
		Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
		Item.InitLoadoutItem(GetEquippedItem(eInvSlot_SecondaryWeapon), eInvSlot_SecondaryWeapon, true);
	}
	if (UpdatedUnit.HasHeavyWeapon(CheckGameState))
	{
		Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
		Item.InitLoadoutItem(GetEquippedItem(eInvSlot_HeavyWeapon), eInvSlot_HeavyWeapon, true);
	}

	// units can have multiple utility items
	numUtilityItems = GetNumAllowedUtilityItems();
	UtilityItems = class'UnitUtilities_BO'.static.GetEquippedUtilityItems(UpdatedUnit, CheckGameState);
	
	for(i = 0; i < numUtilityItems; ++i)
	{
		Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));

		if(UtilityItems.Length >= (i + 1))
		{
			Item.InitLoadoutItem(UtilityItems[i], eInvSlot_Utility, true);
		}
		else
		{
			Item.InitLoadoutItem(none, eInvSlot_Utility, true);
		}
	}

	if (UpdatedUnit.HasGrenadePocket())
	{
		Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
		Item.InitLoadoutItem(GetEquippedItem(eInvSlot_GrenadePocket), eInvSlot_GrenadePocket, true);
	}
	if (class'UnitUtilities_BO'.static.HasAmmoPocket(UpdatedUnit))
	{
		Item = UIArmory_LoadoutItem(EquippedList.CreateItem(class'UIArmory_LoadoutItem'));
		Item.InitLoadoutItem(GetEquippedItem(eInvSlot_AmmoPocket), eInvSlot_AmmoPocket, true);
	}
}

simulated function bool ShowInLockerList(XComGameState_Item Item, EInventorySlot SelectedSlot)
{
	local X2ItemTemplate ItemTemplate;
	local X2GrenadeTemplate GrenadeTemplate;
	local X2EquipmentTemplate EquipmentTemplate;
	local bool bAmmoPocket;

	ItemTemplate = Item.GetMyTemplate();
	bAmmoPocket = class'UnitUtilities_BO'.static.HasAmmoPocket(GetUnit());
	
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
			if (bAmmoPocket && ItemTemplate.ItemCat == 'ammo')
			{
				return false;
			}
			EquipmentTemplate = X2EquipmentTemplate(ItemTemplate);
			// xpad is only item with size 0, that is always equipped
			return (EquipmentTemplate != none && EquipmentTemplate.iItemSize > 0 && EquipmentTemplate.InventorySlot == SelectedSlot);
		}
	}

	return false;
}
