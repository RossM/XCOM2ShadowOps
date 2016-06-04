class XMBEffect_AddUtilityItem extends X2Effect_Persistent;

var name DataName;
var int Quantity;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2EquipmentTemplate EquipmentTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Unit NewUnit;
	local XComGameState_Item ItemState;
	local X2AbilityTemplateManager AbilityTemplateMan;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameStateHistory History;
	local name AbilityName;
	local array<SoldierClassAbilityType> EarnedSoldierAbilities;
	local int idx;

	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	History = `XCOMHISTORY;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	EquipmentTemplate = X2EquipmentTemplate(ItemTemplateMgr.FindItemTemplate(DataName));
	if (EquipmentTemplate == none)
	{
		`RedScreen(`location $": Missing equipment template for" @ DataName);
		return;
	}

	// Check for items that can be merged
	WeaponTemplate = X2WeaponTemplate(EquipmentTemplate);
	if (WeaponTemplate != none && WeaponTemplate.bMergeAmmo)
	{
		for (idx = 0; idx < NewUnit.InventoryItems.Length; idx++)
		{
			ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(NewUnit.InventoryItems[idx].ObjectID));
			if (ItemState == none)
				ItemState = XComGameState_Item(History.GetGameStateForObjectID(NewUnit.InventoryItems[idx].ObjectID));
			if (ItemState != none && !ItemState.bMergedOut && ItemState.GetMyTemplate() == WeaponTemplate)
			{
				ItemState = XComGameState_Item(NewGameState.CreateStateObject(ItemState.Class, ItemState.ObjectID));
				ItemState.Ammo += Quantity;
				NewGameState.AddStateObject(ItemState);
				return;
			}
		}
	}

	// Create item
	ItemState = EquipmentTemplate.CreateInstanceFromTemplate(NewGameState);
	ItemState.Ammo = Quantity;
	NewGameState.AddStateObject(ItemState);

	NewEffectState.CreatedObjectReference = ItemState.GetReference();

	// Add abilities - TODO: we don't support ability overrides or additional abilities yet

	// Add abilities from the equipment item itself
	foreach EquipmentTemplate.Abilities(AbilityName)
	{
		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AbilityName);
		`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, ItemState.GetReference());
	}

	// Add equipment-dependent soldier abilities
	EarnedSoldierAbilities = NewUnit.GetEarnedSoldierAbilities();
	for (idx = 0; idx < EarnedSoldierAbilities.Length; ++idx)
	{
		AbilityName = EarnedSoldierAbilities[idx].AbilityName;
		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AbilityName);

		// Add utility-item abilities
		if (EarnedSoldierAbilities[idx].ApplyToWeaponSlot == eInvSlot_Utility &&
			EarnedSoldierAbilities[idx].UtilityCat == ItemState.GetWeaponCategory())
		{
			`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, ItemState.GetReference());
		}

		// Add grenade abilities
		if (AbilityTemplate.bUseLaunchedGrenadeEffects && X2GrenadeTemplate(EquipmentTemplate) != none)
		{
			`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, NewUnit.GetItemInSlot(EarnedSoldierAbilities[idx].ApplyToWeaponSlot, NewGameState).GetReference(), ItemState.GetReference());
		}
	}
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Item ItemState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	ItemState = XComGameState_Item(History.GetGameStateForObjectID(RemovedEffectState.CreatedObjectReference.ObjectID));	

	if(ItemState == none)
		return;

	NewGameState.RemoveStateObject(RemovedEffectState.CreatedObjectReference.ObjectID);
}
