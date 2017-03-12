class UIInventory_Implants_BO extends UIInventory_Implants;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local XComGameState_Unit Unit;

	super.InitScreen(InitController, InitMovie, InitName);

	`Log("Init UIInventory_Implants_BO");

	if (`HQPRES.ScreenStack.IsNotInStack(class'UIArmory_Implants_BO'))
	{
		Unit = UIArmory(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory')).GetUnit();

		if (Unit.GetCurrentStat(eStat_CombatSims) > 1 || Unit.HasSoldierAbility('ShadowOps_DigitalWarfare'))
		{
			`Log("Switching to UIArmory_Implants_BO");
			`HQPRES.ScreenStack.Pop(self);
			UIArmory_Implants(`HQPRES.ScreenStack.Push(Spawn(class'UIArmory_Implants_BO', `HQPRES), `HQPRES.Get3DMovie())).InitImplants(Unit.GetReference());
		}
	}
}

simulated function OnReceiveFocus()
{
	local XComGameState_Unit Unit;

	super.OnReceiveFocus();

	if (`HQPRES.ScreenStack.IsNotInStack(class'UIArmory_Implants_BO'))
	{
		Unit = UIArmory(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory')).GetUnit();

		if (Unit.GetCurrentStat(eStat_CombatSims) > 1 || Unit.HasSoldierAbility('ShadowOps_DigitalWarfare'))
		{
			`Log("Switching to UIArmory_Implants_BO");
			`HQPRES.ScreenStack.Pop(self);
			UIArmory_Implants(`HQPRES.ScreenStack.Push(Spawn(class'UIArmory_Implants_BO', `HQPRES), `HQPRES.Get3DMovie())).InitImplants(Unit.GetReference());
		}
	}
}

simulated function PopulateData()
{
	local XComGameState_Item Implant;
	local UIInventory_ListItem ListItem;

	super(UIInventory).PopulateData();

	Implants = XComHQ.GetAllCombatSimsInInventory();
	Implants.Sort(SortImplants);
	Implants.Sort(SortImplantsStatType);
	Implants.Sort(SortItemsTier);

	foreach Implants(Implant)
	{
		ListItem = UIInventory_ListItem(List.CreateItem(class'UIInventory_ListItem'));
		ListItem.InitInventoryListItem(Implant.GetMyTemplate(), Implant.Quantity, Implant.GetReference());
		if (!CanEquipImplant(Implant.GetReference()))
			ListItem.SetDisabled(true);
	}

	if(List.ItemCount > 0)
	{
		ListItem = UIInventory_ListItem(List.GetItem(0));
		PopulateItemCard(ListItem.ItemTemplate, ListItem.ItemRef);
	}
	else
	{
		Spawn(class'UIText', ListContainer)
			.InitText('', class'UIUtilities_Text'.static.GetColoredText(m_strNoImplants, eUIState_Header, 24), true)
			.SetPosition(List.x + 20, List.y - 40);
	}

	List.SetSelectedIndex(0);
}

simulated function bool CanEquipImplant(StateObjectReference ImplantRef)
{
	local XComGameState_Unit Unit;
	local XComGameState_Item Implant, OtherImplant;
	local array<XComGameState_Item> EquippedImplants;
	local UIArmory Armory;
	local int SlotIndex, i;
	
	Armory = UIArmory(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory'));

	Implant = XComGameState_Item(History.GetGameStateForObjectID(ImplantRef.ObjectID));
	Unit = Armory.GetUnit();
	if (UIArmory_Implants(Armory) != none)
		SlotIndex = UIArmory_Implants(Armory).List.SelectedIndex;
	else
		SlotIndex = 0;
	EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);

	for (i = 0; i < EquippedImplants.Length; i++)
	{
		OtherImplant = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(EquippedImplants[i].ObjectID));

		if (i == SlotIndex)
		{
			if(X2EquipmentTemplate(Implant.GetMyTemplate()).Abilities.length == 0 &&
				class'UIUtilities_Strategy'.static.GetStatBoost(Implant).StatType == 
				class'UIUtilities_Strategy'.static.GetStatBoost(OtherImplant).StatType && 
				class'UIUtilities_Strategy'.static.GetStatBoost(Implant).Boost <= 
				class'UIUtilities_Strategy'.static.GetStatBoost(OtherImplant).Boost)
				return false;
		}
		else
		{
			if (X2EquipmentTemplate(Implant.GetMyTemplate()).Abilities.length == 0 &&
				class'UIUtilities_Strategy'.static.GetStatBoost(Implant).StatType == 
				class'UIUtilities_Strategy'.static.GetStatBoost(OtherImplant).StatType)
				return false;
			if (X2EquipmentTemplate(Implant.GetMyTemplate()).Abilities.length > 0 &&
				X2EquipmentTemplate(OtherImplant.GetMyTemplate()).Abilities.length > 0 &&
				X2EquipmentTemplate(Implant.GetMyTemplate()).Abilities[0] == X2EquipmentTemplate(OtherImplant.GetMyTemplate()).Abilities[0])
				return false;
		}
	}

	return X2EquipmentTemplate(Implant.GetMyTemplate()).Abilities.length > 0 ||
		class'UIUtilities_Strategy'.static.GetStatBoost(Implant).StatType != eStat_PsiOffense || Unit.IsPsiOperative();
}

simulated function SelectedItemChanged(UIList ContainerList, int ItemIndex)
{
	local int SlotIndex;
	local XComGameState_Unit Unit;
	local UISoldierHeader SoldierHeader;
	local array<XComGameState_Item> EquippedImplants;
	local XComGameState_Item ImplantToAdd, ImplantToRemove;
	local string Will, Aim, Health, Mobility, Tech, Psi;

	super(UIInventory).SelectedItemChanged(ContainerList, ItemIndex);

	Unit = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).GetUnit();
	SoldierHeader = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).Header;
	EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);
	SlotIndex = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).List.SelectedIndex;

	ImplantToAdd = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(Implants[List.SelectedIndex].ObjectID));
	if(SlotIndex < EquippedImplants.Length)
		ImplantToRemove = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(EquippedImplants[SlotIndex].ObjectID));
	
	Will = string( int(Unit.GetCurrentStat( eStat_Will )) ) $ GetStatBoostString(ImplantToAdd, ImplantToRemove, eStat_Will);
	Aim = string( int(Unit.GetCurrentStat( eStat_Offense )) ) $ GetStatBoostString(ImplantToAdd, ImplantToRemove, eStat_Offense);
	Health = string( int(Unit.GetCurrentStat( eStat_HP )) ) $ GetStatBoostString(ImplantToAdd, ImplantToRemove, eStat_HP);
	Mobility = string( int(Unit.GetCurrentStat( eStat_Mobility )) ) $ GetStatBoostString(ImplantToAdd, ImplantToRemove, eStat_Mobility);
	Tech = string( int(Unit.GetCurrentStat( eStat_Hacking )) ) $ GetStatBoostString(ImplantToAdd, ImplantToRemove, eStat_Hacking);

	if(Unit.IsPsiOperative())
		Psi = string( int(Unit.GetCurrentStat( eStat_PsiOffense )) ) $ GetStatBoostString(ImplantToAdd, ImplantToRemove, eStat_PsiOffense);

	SoldierHeader.SetSoldierStats(Will, Aim, Health, Mobility, Tech, Psi);
}

simulated function OnItemSelected(UIList ContainerList, int ItemIndex)
{
	local int SlotIndex;
	local XComGameState_Unit Unit;
	local array<XComGameState_Item> EquippedImplants;
	local StateObjectReference ImplantRef;

	ImplantRef = UIInventory_ListItem(ContainerList.GetItem(ItemIndex)).ItemRef;
	
	if (CanEquipImplant(ImplantRef))
	{
		Unit = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).GetUnit();
		SlotIndex = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).List.SelectedIndex;

		EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);
		
		if (XComHQ.bReuseUpgrades)
		{
			// Skip the popups if the continent bonus for reusing upgrades is active
			if (SlotIndex < EquippedImplants.Length)
				ConfirmImplantRemovalCallback(eUIAction_Accept);
			else
				ConfirmImplantInstallCallback(eUIAction_Accept);
		}
		else
		{
			// Unequip previous implant
			if (SlotIndex < EquippedImplants.Length)
				ConfirmImplantRemoval(EquippedImplants[SlotIndex].GetMyTemplate(), UIInventory_ListItem(List.GetSelectedItem()).ItemTemplate);
			else
				ConfirmImplantInstall(UIInventory_ListItem(List.GetSelectedItem()).ItemTemplate);
		}
	}
	else
		Movie.Pres.PlayUISound(eSUISound_MenuClose);
}

simulated function RemoveImplant()
{
	local int SlotIndex;	
	local XComGameState UpdatedState;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UpdatedUnit;
	local array<XComGameState_Item> EquippedImplants;

	UpdatedState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Remove Personal Combat Sim");

	UnitRef = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).GetUnit().GetReference();
	UpdatedUnit = XComGameState_Unit(UpdatedState.CreateStateObject(class'XComGameState_Unit', UnitRef.ObjectID));
	EquippedImplants = UpdatedUnit.GetAllItemsInSlot(eInvSlot_CombatSim);
	SlotIndex = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants')).List.SelectedIndex;

	if(UpdatedUnit.RemoveItemFromInventory(EquippedImplants[SlotIndex], UpdatedState)) 
	{
		UpdatedState.AddStateObject(UpdatedUnit);

		if (XComHQ.bReuseUpgrades) // Continent Bonus is letting us reuse upgrades, so put it back into the inventory
		{
			XComHQ = XComGameState_HeadquartersXCom(UpdatedState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
			UpdatedState.AddStateObject(XComHQ);
			XComHQ.PutItemInInventory(UpdatedState, EquippedImplants[SlotIndex]);
		}
		else
		{
			UpdatedState.RemoveStateObject(EquippedImplants[SlotIndex].ObjectID); // Combat sims cannot be reused
		}

		`GAMERULES.SubmitGameState(UpdatedState);
	}
	else
		`XCOMHISTORY.CleanupPendingGameState(UpdatedState);
}

simulated function InstallImplant()
{
	local XComGameState UpdatedState;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UpdatedUnit;
	local XComGameState_Item UpdatedImplant;
	local XComGameState_HeadquartersXCom UpdatedHQ;
	local UIArmory Armory;

	UpdatedState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Install Personal Combat Sim");

	Armory = UIArmory_Implants(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory_Implants'));
	if (Armory == none)
		Armory = UIArmory(Movie.Pres.ScreenStack.GetFirstInstanceOf(class'UIArmory'));
	
	UnitRef = Armory.GetUnit().GetReference();
	UpdatedHQ = XComGameState_HeadquartersXCom(UpdatedState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	UpdatedUnit = XComGameState_Unit(UpdatedState.CreateStateObject(class'XComGameState_Unit', UnitRef.ObjectID));
	UpdatedState.AddStateObject(UpdatedHQ);

	UpdatedHQ.GetItemFromInventory(UpdatedState, Implants[List.SelectedIndex].GetReference(), UpdatedImplant);
	
	UpdatedUnit.AddItemToInventory(UpdatedImplant, eInvSlot_CombatSim, UpdatedState);
	UpdatedState.AddStateObject(UpdatedUnit);
	
	`XEVENTMGR.TriggerEvent('PCSApplied', UpdatedUnit, UpdatedImplant, UpdatedState);
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Strategy_UI_PCS_Equip");

	`GAMERULES.SubmitGameState(UpdatedState);
}

