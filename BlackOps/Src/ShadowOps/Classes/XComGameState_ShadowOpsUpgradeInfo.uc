class XComGameState_ShadowOpsUpgradeInfo extends XComGameState_BaseObject;

var array<name> UpgradesPerformed;

var name ModVersion;

function bool ShowUpgradePopupIfNeeded()
{
	local TDialogueBoxData kDialogData;

	if (ModVersion == class'X2DownloadableContentInfo_BlackOps'.default.ModVersion)
		return false;

	kDialogData.eType = eDialog_Normal;
	kDialogData.strTitle = class'X2DownloadableContentInfo_BlackOps'.default.ModUpgradeLabel;
	kDialogData.strText = class'X2DownloadableContentInfo_BlackOps'.default.ModUpgradeSummary;
	kDialogData.strAccept = class'X2DownloadableContentInfo_BlackOps'.default.ModUpgradeAcceptLabel;

	`HQPRES.UIRaiseDialog(kDialogData);

	ModVersion = class'X2DownloadableContentInfo_BlackOps'.default.ModVersion;

	return true;
}

function InitializeForNewGame()
{
	UpgradesPerformed.AddItem('RenameSoldierClasses');
	UpgradesPerformed.AddItem('RenameAWCAbilities');
	UpgradesPerformed.AddItem('GrantFreeRespecs1');
}

function bool PerformUpgrade(name UpgradeName, XComGameState NewGameState)
{
	if (UpgradesPerformed.Find(UpgradeName) != INDEX_NONE)
		return false;

	`Log("Performing Shadow Ops save upgrade" @ UpgradeName);

	switch (UpgradeName)
	{
	case 'GrantFreeRespecs1':
		GrantFreeRespecs(NewGameState);
		UpgradesPerformed.AddItem(UpgradeName);
		return true;
	}

	return false;
}

function GrantFreeRespecs(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_ShadowOpsUnitInfo UnitInfo;
	local bool bAllowRespec;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		bAllowRespec = false;

		switch (UnitState.GetSoldierClassTemplateName())
		{
		case 'ShadowOps_CombatEngineer':
		case 'ShadowOps_Dragoon':
		case 'ShadowOps_Hunter':
		case 'ShadowOps_Infantry':
			bAllowRespec = UnitState.GetSoldierRank() >= 2;
			break;
		}
		
		if (bAllowRespec)
		{
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitInfo = XComGameState_ShadowOpsUnitInfo(UnitState.FindComponentObject(class'XComGameState_ShadowOpsUnitInfo'));

			if (UnitInfo == none)
			{
				UnitInfo = XComGameState_ShadowOpsUnitInfo(NewGameState.CreateStateObject(class'XComGameState_ShadowOpsUnitInfo'));
				UnitState.AddComponentObject(UnitInfo);
			}

			UnitInfo.bFreeRespecAllowed = true;
			UnitInfo.iFreeRespecMaxRank = UnitState.GetSoldierRank();

			NewGameState.AddStateObject(UnitState);
			NewGameState.AddStateObject(UnitInfo);

			`Log("Set free respec on unit id" @ UnitState.ObjectId); 
		}
	}
}