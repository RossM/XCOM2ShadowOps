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
}

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
	case 'RenameAWCAbilities':
		RenameAWCAbilities(NewGameState);
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

function RenameAWCAbilities(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local ClassAgnosticAbility AWCAbility;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local int i;
	local name NewTemplateName;

	History = `XCOMHISTORY;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		for (i = 0; i < UnitState.AWCAbilities.Length; i++)
		{
			AWCAbility = UnitState.AWCAbilities[i];

			if (AbilityTemplateManager.FindAbilityTemplate(AWCAbility.AbilityType.AbilityName) == none)
			{
				NewTemplateName = name('ShadowOps_' $ AWCAbility.AbilityType.AbilityName);

				if (AbilityTemplateManager.FindAbilityTemplate(NewTemplateName) != none)
				{
					UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
					NewGameState.AddStateObject(UnitState);

					UnitState.AWCAbilities[i].AbilityType.AbilityName = NewTemplateName;
				}
			}
		}
	}
}