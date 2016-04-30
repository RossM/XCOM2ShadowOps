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
	local name NewTemplateName;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		NewTemplateName = '';

		switch (UnitState.GetSoldierClassTemplateName())
		{
		case 'Engineer':
			NewTemplateName = 'ShadowOps_CombatEngineer';
			break;
		case 'Dragoon':
			NewTemplateName = 'ShadowOps_Dragoon';
			break;
		case 'Hunter':
			NewTemplateName = 'ShadowOps_Hunter';
			break;
		case 'Infantry':
			NewTemplateName = 'ShadowOps_Infantry';
			break;
		}
		
		if (NewTemplateName != '')
		{
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.SetSoldierClassTemplate(NewTemplateName);
			NewGameState.AddStateObject(UnitState);
			`Log("Updating unit id" @ UnitState.ObjectId @ "to" @ NewTemplateName); 
		}
	}
}