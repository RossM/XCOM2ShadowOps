class XComGameState_ShadowOpsUpgradeInfo extends XComGameState_BaseObject;

var array<name> UpgradesPerformed;

function bool PerformUpgrade(name UpgradeName, XComGameState NewGameState)
{
	if (UpgradesPerformed.Find(UpgradeName) != INDEX_NONE)
		return false;

	`Log("Performing Shadow Ops save upgrade" @ UpgradeName);

	switch (UpgradeName)
	{
	case 'RenameSoldierClasses':
		RenameSoldierClasses(NewGameState);
		UpgradesPerformed.AddItem(UpgradeName);
		return true;
	}

	return false;
}

function RenameSoldierClasses(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		switch (UnitState.GetSoldierClassTemplateName())
		{
		case 'Engineer':
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.SetSoldierClassTemplate('ShadowOps_CombatEngineer');
			NewGameState.AddStateObject(UnitState);
			`Log("Updating unit id" @ UnitState.ObjectId @ "to" @ UnitState.GetSoldierClassTemplateName()); 
			break;
		case 'Dragoon':
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.SetSoldierClassTemplate('ShadowOps_Dragoon');
			NewGameState.AddStateObject(UnitState);
			`Log("Updating unit id" @ UnitState.ObjectId @ "to" @ UnitState.GetSoldierClassTemplateName()); 
			break;
		case 'Hunter':
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.SetSoldierClassTemplate('ShadowOps_Hunter');
			NewGameState.AddStateObject(UnitState);
			`Log("Updating unit id" @ UnitState.ObjectId @ "to" @ UnitState.GetSoldierClassTemplateName()); 
			break;
		case 'Infantry':
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.SetSoldierClassTemplate('ShadowOps_Infantry');
			NewGameState.AddStateObject(UnitState);
			`Log("Updating unit id" @ UnitState.ObjectId @ "to" @ UnitState.GetSoldierClassTemplateName()); 
			break;
		}
	}
}