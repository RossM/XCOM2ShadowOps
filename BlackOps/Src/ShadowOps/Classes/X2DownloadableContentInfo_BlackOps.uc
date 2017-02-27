//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_BlackOps.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_BlackOps extends X2DownloadableContentInfo config(GameCore);

var config name ModVersion;
var localized string ModUpgradeLabel;
var localized string ModUpgradeSummary;
var localized string ModUpgradeAcceptLabel;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Shadow Ops Upgrade State");

	CreateInitialUpgradeInfo(NewGameState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	CreateInitialUpgradeInfo(StartState);
}

static function CreateInitialUpgradeInfo(XComGameState StartState)
{
	local XComGameState_ShadowOpsUpgradeInfo UpgradeInfo;

	UpgradeInfo = XComGameState_ShadowOpsUpgradeInfo(StartState.CreateStateObject(class'XComGameState_ShadowOpsUpgradeInfo'));
	StartState.AddStateObject(UpgradeInfo);

	UpgradeInfo.InitializeForNewGame();
}

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	local array<object> DefaultObjects;
	local object Obj;

	class'TemplateEditors'.static.EditTemplates();

	DefaultObjects = class'XComEngine'.static.GetClassDefaultObjects(class'X2DownloadableContentInfo');
	foreach DefaultObjects(Obj)
	{
		`Log("Found X2DownloadableContentInfo" @ Obj.class);
	}
	DefaultObjects = class'XComEngine'.static.GetClassDefaultObjects(class'X2DataSet');
	foreach DefaultObjects(Obj)
	{
		`Log("Found X2DataSet" @ Obj.class);
	}
}
