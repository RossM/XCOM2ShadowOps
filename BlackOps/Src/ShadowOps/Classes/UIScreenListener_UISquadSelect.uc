class UIScreenListener_UISquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	RefreshVisuals(Screen);
}

event OnReceiveFocus(UIScreen Screen)
{
	RefreshVisuals(Screen);
}

function RefreshVisuals(UIScreen Screen)
{
	local UISquadSelect_ListItem		ListItem; 
	local UISquadSelect					SquadSelect;
	local int							i;

	SquadSelect = UISquadSelect(Screen);

	for(i = 0; i < SquadSelect.m_kSlotList.ItemCount; i++)
	{
		ListItem = UISquadSelect_ListItem(SquadSelect.m_kSlotList.GetItem(i));

		if (ListItem != none)
		{
			UpdateData(ListItem);
		}
	}
}

function UpdateData(UISquadSelect_ListItem ListItem)
{
	local XComGameState_Unit Unit;
	local string NameStr, ClassStr;
	local XComGameState_Item PrimaryWeapon;
	local X2WeaponTemplate PrimaryWeaponTemplate;

	if (ListItem.bDisabled)
		return;

	if (ListItem.GetUnitRef().ObjectId <= 0)
		return;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.GetUnitRef().ObjectID));

	if(Unit.GetRank() > 0)
		ClassStr = class'UIUtilities_Text'.static.GetColoredText(Caps(class'UnitUtilities_BO'.static.GetSoldierClassDisplayName(Unit)), eUIState_Faded, 17);
	else
		ClassStr = "";

	NameStr = Unit.GetName(eNameType_Last);
	if (NameStr == "") // If the unit has no last name, display their first name instead
	{
		NameStr = Unit.GetName(eNameType_First);
	}

	PrimaryWeapon = Unit.GetItemInSlot(eInvSlot_PrimaryWeapon);
	if(PrimaryWeapon != none)
	{
		PrimaryWeaponTemplate = X2WeaponTemplate(PrimaryWeapon.GetMyTemplate());
	}

	ListItem.AS_SetFilled( class'UIUtilities_Text'.static.GetColoredText(Caps(class'X2ExperienceConfig'.static.GetRankName(Unit.GetRank(), Unit.GetSoldierClassTemplateName())), eUIState_Normal, 18),
					class'UIUtilities_Text'.static.GetColoredText(Caps(NameStr), eUIState_Normal, 22),
					class'UIUtilities_Text'.static.GetColoredText(Caps(Unit.GetName(eNameType_Nick)), eUIState_Header, 28),
					Unit.GetSoldierClassTemplate().IconImage, class'UIUtilities_Image'.static.GetRankIcon(Unit.GetRank(), Unit.GetSoldierClassTemplateName()),
					class'UIUtilities_Text'.static.GetColoredText(ListItem.m_strEdit, ListItem.bDisabledEdit ? eUIState_Disabled : eUIState_Normal),
					class'UIUtilities_Text'.static.GetColoredText(ListItem.m_strDismiss, ListItem.bDisabledDismiss ? eUIState_Disabled : eUIState_Normal),
					class'UIUtilities_Text'.static.GetColoredText(PrimaryWeaponTemplate.GetItemFriendlyName(PrimaryWeapon.ObjectID), ListItem.bDisabledLoadout ? eUIState_Disabled : eUIState_Normal),
					class'UIUtilities_Text'.static.GetColoredText(class'UIArmory_loadout'.default.m_strInventoryLabels[eInvSlot_PrimaryWeapon], ListItem.bDisabledLoadout ? eUIState_Disabled : eUIState_Normal),
					class'UIUtilities_Text'.static.GetColoredText(ListItem.GetHeavyWeaponName(), ListItem.bDisabledLoadout ? eUIState_Disabled : eUIState_Normal),
					class'UIUtilities_Text'.static.GetColoredText(ListItem.GetHeavyWeaponDesc(), ListItem.bDisabledLoadout ? eUIState_Disabled : eUIState_Normal),
					(Unit.ShowPromoteIcon() ? ListItem.m_strPromote : ""), Unit.IsPsiOperative() || (Unit.HasPsiGift() && Unit.GetRank() < 2), ClassStr);

}

defaultproperties
{
	ScreenClass = class'UISquadSelect'
}