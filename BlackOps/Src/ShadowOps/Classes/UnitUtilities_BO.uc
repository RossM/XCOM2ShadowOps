class UnitUtilities_BO extends Object config(ShadowOpsOptions);

var config bool bDisplaySubclassNames;

// This class contains functions that augment or replace functions on XComGameState_Unit, since
// those can't be overridden in a mod.

static function string GetSoldierClassDisplayName(XComGameState_Unit Unit)
{
	local X2SoldierClassTemplate SoldierClassTemplate;
	local int iLeftCount, iRightCount, i;

	SoldierClassTemplate = Unit.GetSoldierClassTemplate();

	if (!default.bDisplaySubclassNames)
		return SoldierClassTemplate.DisplayName;

	for (i = 0; i < Unit.m_SoldierProgressionAbilties.Length; i++)
	{
		if (Unit.m_SoldierProgressionAbilties[i].iRank <= 0)
			continue;

		if (Unit.m_SoldierProgressionAbilties[i].iBranch == 0)
		{
			iLeftCount++;
			if (iLeftCount >= 2)
				return SoldierClassTemplate.LeftAbilityTreeTitle;
		}
		else
		{
			iRightCount++;
			if (iRightCount >= 2)
				return SoldierClassTemplate.RightAbilityTreeTitle;
		}
	}

	return SoldierClassTemplate.DisplayName;
}

static simulated function int GetUIStatBonusFromItem(XComGameState_Unit Unit, ECharStatType Stat, XComGameState_Item InventoryItem)
{
	local int Result;
	local array<SoldierClassAbilityType> AbilityTree;
	local SoldierClassAbilityType SoldierClassAbility;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate_BO AbilityTemplate;

	AbilityTree = Unit.GetEarnedSoldierAbilities();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilityTree(SoldierClassAbility)
	{
		AbilityTemplate = X2AbilityTemplate_BO(AbilityTemplateManager.FindAbilityTemplate(SoldierClassAbility.AbilityName));
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
	local X2AbilityTemplate_BO AbilityTemplate;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	AbilityTree = Unit.GetEarnedSoldierAbilities();
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilityTree(SoldierClassAbility)
	{
		AbilityTemplate = X2AbilityTemplate_BO(AbilityTemplateManager.FindAbilityTemplate(SoldierClassAbility.AbilityName));
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



