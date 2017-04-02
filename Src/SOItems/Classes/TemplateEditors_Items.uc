// This is an Unreal Script
class TemplateEditors_Items extends Object config(GameCore);

struct TemplateEdit
{
	var name ItemName;
	var array<name> RequiredTechs;
	var StrategyCost Cost;
	var int TradingPostValue;
	var int Tier;
};

var config array<name> ExtraStartingItems, DisabledItems, InfiniteItems;
var config array<TemplateEdit> BuildableItems;

static function EditTemplates()
{
	local name DataName;
	local TemplateEdit Edit;

	foreach default.ExtraStartingItems(DataName)
	{
		`Log("SOItems: ChangeToStartingItem" @ DataName);
		ChangeToStartingItem(DataName);
	}
	foreach default.InfiniteItems(DataName)
	{
		`Log("SOItems: ChangeToInfiniteItem" @ DataName);
		ChangeToInfiniteItem(DataName);
	}
	foreach default.DisabledItems(DataName)
	{
		`Log("SOItems: DisableItem" @ DataName);
		DisableItem(DataName);
	}
	foreach default.BuildableItems(Edit)
	{
		`Log("SOItems: ApplyTemplateEdit" @ Edit.ItemName);
		ApplyTemplateEdit(Edit);
	}
}

static function ChangeToStartingItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2ItemTemplate				Template;
	
	DisableItem(ItemName);

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2ItemTemplate(DataTemplate);

		Template.bInfiniteItem = true;
		Template.StartingItem = true;
		Template.TradingPostValue = 0;
	}
}

static function ChangeToInfiniteItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2ItemTemplate				Template;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2ItemTemplate(DataTemplate);

		Template.bInfiniteItem = true;
		Template.TradingPostValue = 0;
		Template.Cost.ResourceCosts.Length = 0;
		Template.Cost.ArtifactCosts.Length = 0;
	}
}

static function ApplyTemplateEdit(TemplateEdit Edit)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2EquipmentTemplate			Template;
	
	DisableItem(Edit.ItemName);

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(Edit.ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2EquipmentTemplate(DataTemplate);

		Template.CanBeBuilt = true;
		Template.TradingPostValue = Edit.TradingPostValue;
		Template.PointsToComplete = 0;
		Template.Tier = Edit.Tier;
		Template.Requirements.RequiredTechs = Edit.RequiredTechs;
		Template.Cost = Edit.Cost;
	}
}

static function DisableItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2ItemTemplate				Template;
	local name							BaseItem;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2ItemTemplate(DataTemplate);

		if (Template.BaseItem != '')
			BaseItem = Template.BaseItem;

		Template.StartingItem = false;
		Template.CanBeBuilt = false;
		Template.RewardDecks.Length = 0;
		Template.CreatorTemplateName = '';
		Template.BaseItem = '';
		Template.Cost.ResourceCosts.Length = 0;
		Template.Cost.ArtifactCosts.Length = 0;
		Template.Requirements.RequiredTechs.Length = 0;
	}

	if (BaseItem != '')
	{
		ItemManager.FindDataTemplateAllDifficulties(BaseItem, DataTemplateAllDifficulties);
		foreach DataTemplateAllDifficulties(DataTemplate)
		{
			Template = X2ItemTemplate(DataTemplate);

			Template.HideIfResearched = '';
		}
	}
}

