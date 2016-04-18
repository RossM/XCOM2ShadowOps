class TemplateEditors_Items extends Object;

static function EditTemplates()
{
	ChangeToStartingItem('FlashbangGrenade');
	ChangeToStartingItem('SmokeGrenade');
	ChangeToStartingItem('NanofiberVest');
	DisableItem('SmokeGrenadeMk2');
	EditPlatedVest('PlatedVest');
}

static function ChangeToStartingItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local X2ItemTemplate				Template;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = ItemManager.FindItemTemplate(ItemName);

	DisableItem(ItemName);
	Template.StartingItem = true;
}

static function EditPlatedVest(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local X2EquipmentTemplate			Template;
	local ArtifactCost					Resources, Artifacts;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2EquipmentTemplate(ItemManager.FindItemTemplate(ItemName));

	DisableItem(ItemName);

	Template.CanBeBuilt = true;
	Template.TradingPostValue = 15;
	Template.PointsToComplete = 0;
	Template.Tier = 1;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 30;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Artifacts.ItemTemplateName = 'CorpseAdventTrooper';
	Artifacts.Quantity = 2;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);
}

static function DisableItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local X2ItemTemplate				Template, BaseTemplate;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = ItemManager.FindItemTemplate(ItemName);

	if (Template.BaseItem != '')
		BaseTemplate = ItemManager.FindItemTemplate(Template.BaseItem);

	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.RewardDecks.Length = 0;
	Template.CreatorTemplateName = '';
	Template.BaseItem = '';
	Template.Cost.ResourceCosts.Length = 0;

	if (BaseTemplate != none)
	{
		BaseTemplate.HideIfResearched = '';
	}
}