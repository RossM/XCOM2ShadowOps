class TemplateEditors_Strategy extends UIScreenListener;

var array<bool> bEditedTemplatesForDifficulty;
var bool bEditedTemplates;

event OnInit(UIScreen Screen)
{
	if (!bEditedTemplates)
	{
		EditTemplates();
		CreateStartingItems();
		bEditedTemplates = true;
	}

	bEditedTemplatesForDifficulty.Length = 4;
	if (!bEditedTemplatesForDifficulty[`DifficultySetting])
	{
		EditTemplatesForDifficulty();
		bEditedTemplatesForDifficulty[`DifficultySetting] = true;
	}
}

function CreateStartingItems()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Item NewItemState;
	local X2DataTemplate DataTemplate;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Starting Items");

	// Create one of each starting item
	foreach ItemTemplateMgr.IterateTemplates(DataTemplate, none)
	{
		if( X2ItemTemplate(DataTemplate) != none && X2ItemTemplate(DataTemplate).StartingItem && !XComHQ.HasItem(X2ItemTemplate(DataTemplate)))
		{
			NewItemState = X2ItemTemplate(DataTemplate).CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(NewItemState);
			XComHQ.AddItemToHQInventory(NewItemState);
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

// The following template types have per-difficulty variants:
// X2CharacterTemplate (except civilians and characters who never appear in tactical play)
// X2FacilityTemplate
// X2FacilityUpgradeTemplate
// X2Item (grenades, weapons, and heavy weapons only) [bugged]
// X2MissionSourceTemplate
// X2SchematicTemplate
// X2SoldierClassTemplate
// X2SoldierUnlockTemplate
// X2SpecialRoomFeatureTemplate
// X2TechTemplate
function EditTemplatesForDifficulty()
{
	AddGtsUnlocks();
}

function EditTemplates()
{
	class'TemplateEditors_Items'.static.EditTemplates();
}

function AddGtsUnlocks()
{
	local X2StrategyElementTemplateManager StrategyManager;
	local X2FacilityTemplate Template;

	StrategyManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Template = X2FacilityTemplate(StrategyManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	Template.SoldierUnlockTemplates.AddItem('PackmasterUnlock');
	Template.SoldierUnlockTemplates.AddItem('DamnGoodGroundUnlock');
	Template.SoldierUnlockTemplates.AddItem('AdrenalineSurgeUnlock');
	Template.SoldierUnlockTemplates.AddItem('TacticalSenseUnlock');
}

defaultproperties
{
	ScreenClass = "UIAvengerHUD";
}