class XMBEffect_AddGrenade extends X2Effect_Persistent;

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

	// Add abilities - TODO: right now we only support grenades
	if (NewUnit.HasSoldierAbility('LaunchGrenade'))
	{
		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('LaunchGrenade');
		`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, NewUnit.GetItemInSlot(eInvSlot_SecondaryWeapon, NewGameState).GetReference(), ItemState.GetReference());
	}
	else if (NewUnit.HasSoldierAbility('ThrowGrenade'))
	{
		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('ThrowGrenade');
		`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, ItemState.GetReference());
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
