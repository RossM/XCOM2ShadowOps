class X2AbilityTemplate_BO extends X2AbilityTemplate;

struct UIAbilityBonusStatMarkup
{
	var int StatModifier;
	var localized string StatLabel;		// The user-friendly label associated with this modifier
	var ECharStatType StatType;			// The stat type of this markup (if applicable)
	var delegate<BonusStatDisplayDelegate> ShouldStatDisplayFn;	// A function to check if the stat should be displayed or not
};

var EInventorySlot ApplyToWeaponSlot;
var array<UIAbilityBonusStatMarkup>	UIBonusStatMarkups;						//  Values to display in the UI to modify soldier stats

delegate bool BonusStatDisplayDelegate(XComGameState_Item Item);

function InitAbilityForUnit(XComGameState_Ability AbilityState, XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	super.InitAbilityForUnit(AbilityState, UnitState, NewGameState);

	if (ApplyToWeaponSlot != eInvSlot_Unknown)
	{
		CurrentInventory = UnitState.GetAllInventoryItems(NewGameState);

		foreach CurrentInventory(InventoryItem)
		{
			if (InventoryItem.bMergedOut)
				continue;
			if (InventoryItem.InventorySlot == ApplyToWeaponSlot)
			{
				AbilityState.SourceWeapon = InventoryItem.GetReference();
				break;
			}
		}
	}
}

function SetUIBonusStatMarkup(String InLabel,
	optional ECharStatType InStatType = eStat_Invalid,
	optional int Amount = 0,
	optional delegate<BonusStatDisplayDelegate> ShowUIStatFn)
{
	local UIAbilityBonusStatMarkup StatMarkup; 

	StatMarkup.StatLabel = InLabel;
	StatMarkup.StatModifier = Amount;
	StatMarkup.StatType = InStatType;
	StatMarkup.ShouldStatDisplayFn = ShowUIStatFn;

	UIBonusStatMarkups.AddItem(StatMarkup);
}

function int GetUIBonusStatMarkup(ECharStatType Stat, XComGameState_Item Item)
{
	local delegate<BonusStatDisplayDelegate> ShouldStatDisplayFn;
	local int Index;

	for (Index = 0; Index < UIBonusStatMarkups.Length; ++Index)
	{
		ShouldStatDisplayFn = UIBonusStatMarkups[Index].ShouldStatDisplayFn;
		if (ShouldStatDisplayFn != None && !ShouldStatDisplayFn(Item))
		{
			continue;
		}

		if (UIBonusStatMarkups[Index].StatType == Stat)
		{
			return UIBonusStatMarkups[Index].StatModifier;
		}
	}

	return 0;
}

// Evil hack
static function SetAbilityTargetEffects(X2AbilityTemplate Template, out array<X2Effect> TargetEffects)
{
	Template.AbilityTargetEffects = TargetEffects;
}

defaultproperties
{
	ApplyToWeaponSlot = eInvSlot_Unknown;
}