class UIScreenListener_UIAvengerHUD extends UIScreenListener;

var int LastGameIndex;

event OnInit(UIScreen Screen)
{
	local XComGameState_CampaignSettings CampaignSettingsStateObject;

	// Begin code stolen shamelessly from Long War Toolbox
	CampaignSettingsStateObject = XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings', true));
	if (CampaignSettingsStateObject == none) return;
	if (CampaignSettingsStateObject.GameIndex == LastGameIndex) return;

	LastGameIndex = CampaignSettingsStateObject.GameIndex;
	// End code stolen shamelessly from Long War Toolbox

	// This needs to be checked for each new save loaded
	CreateStartingItems();
}

// This function fixes up savefiles that are missing a starting item because the mod wasn't installed
// when the game was started, or because the item is new in the current version of the mod.
function CreateStartingItems()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Item NewItemState;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local bool bChanged;

	History = `XCOMHISTORY;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Starting Items");

	// Create one of each starting item that HQ doesn't already have
	foreach ItemTemplateMgr.IterateTemplates(DataTemplate, none)
	{
		ItemTemplate = X2ItemTemplate(DataTemplate);
		if (ItemTemplate != none && ItemTemplate.StartingItem && !XComHQ.HasItem(ItemTemplate))
		{
			NewItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(NewItemState);
			XComHQ.AddItemToHQInventory(NewItemState);
			bChanged = true;
		}
	}

	if (bChanged)
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	else
		History.CleanupPendingGameState(NewGameState);
}

defaultproperties
{
	ScreenClass = "UIAvengerHUD";
}