class UnitUtilities_BO extends Object config(ShadowOpsOptions);

static simulated function int GetUIStatBonusFromItem(XComGameState_Unit Unit, ECharStatType Stat, XComGameState_Item InventoryItem)
{
	local int Result;
	local array<SoldierClassAbilityType> AbilityTree;
	local SoldierClassAbilityType SoldierClassAbility;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate_Dragoon AbilityTemplate;

	AbilityTree = Unit.GetEarnedSoldierAbilities();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilityTree(SoldierClassAbility)
	{
		AbilityTemplate = X2AbilityTemplate_Dragoon(AbilityTemplateManager.FindAbilityTemplate(SoldierClassAbility.AbilityName));
		if (AbilityTemplate != none)
		{
			Result += AbilityTemplate.GetUIBonusStatMarkup(Stat, InventoryItem);
		}
	}

	return Result;
}

static simulated function int GetUIStatBonusFromInventory(XComGameState_Unit Unit, ECharStatType Stat)
{
	local int Result;
	local array<SoldierClassAbilityType> AbilityTree;
	local SoldierClassAbilityType SoldierClassAbility;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate_Dragoon AbilityTemplate;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	AbilityTree = Unit.GetEarnedSoldierAbilities();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilityTree(SoldierClassAbility)
	{
		AbilityTemplate = X2AbilityTemplate_Dragoon(AbilityTemplateManager.FindAbilityTemplate(SoldierClassAbility.AbilityName));
		CurrentInventory = Unit.GetAllInventoryItems();
		foreach CurrentInventory(InventoryItem)
		{
			if (AbilityTemplate != none)
			{
				Result += AbilityTemplate.GetUIBonusStatMarkup(Stat, InventoryItem);
			}
		}
	}

	return Result;
}



