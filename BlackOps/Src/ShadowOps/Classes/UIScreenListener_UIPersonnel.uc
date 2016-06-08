class UIScreenListener_UIPersonnel extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local object ListenerObj;

	ListenerObj = self;

	`XEVENTMGR.RegisterForEvent(ListenerObj, 'OnSoldierListItemUpdate_End', OnSoldierListItemUpdate_End, ELD_Immediate);
	`XEVENTMGR.RegisterForEvent(ListenerObj, 'OnSoldierListItemUpdate_Focussed', OnSoldierListItemUpdate_End, ELD_Immediate);

	RefreshVisuals(Screen, true);
}

event OnReceiveFocus(UIScreen Screen)
{
	RefreshVisuals(Screen);
}

function RefreshVisuals(UIScreen Screen, bool bOnInit = false)
{
	local UIPersonnel_SoldierListItem	ListItem; 
	local UIPersonnel					Personnel;
	local int							i;

	Personnel = UIPersonnel(Screen);

	for(i = 0; i < Personnel.m_kList.ItemCount; i++)
	{
		ListItem = UIPersonnel_SoldierListItem(Personnel.m_kList.GetItem(i));

		if (ListItem != none)
		{
			if (ListItem.IsA('UIPersonnel_SoldierListItem_LW'))
			{
				ListItem.UpdateData();
			}
			else
			{
				UpdateData(ListItem);
			}
		}
	}
}

function UpdateData(UIPersonnel_SoldierListItem ListItem)
{
	local XComGameState_Unit Unit;
	local string UnitLoc, status, statusTimeLabel, statusTimeValue, classIcon, rankIcon, flagIcon;	
	local int iRank;
	local X2SoldierClassTemplate SoldierClass;
	
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.UnitRef.ObjectID));

	iRank = Unit.GetRank();

	SoldierClass = Unit.GetSoldierClassTemplate();

	class'UIUtilities_Strategy'.static.GetPersonnelStatusSeparate(Unit, status, statusTimeLabel, statusTimeValue);
	if( statusTimeValue == "" )
		statusTimeValue = "---";

	flagIcon = Unit.GetCountryTemplate().FlagImage;
	rankIcon = class'UIUtilities_Image'.static.GetRankIcon(iRank, SoldierClass.DataName);
	classIcon = SoldierClass.IconImage;

	// if personnel is not staffed, don't show location
	if( class'UIUtilities_Strategy'.static.DisplayLocation(Unit) )
		UnitLoc = class'UIUtilities_Strategy'.static.GetPersonnelLocation(Unit);
	else
		UnitLoc = "";

	ListItem.AS_UpdateDataSoldier(Caps(Unit.GetName(eNameType_Full)),
					Caps(Unit.GetName(eNameType_Nick)),
					Caps(`GET_RANK_ABBRV(Unit.GetRank(), SoldierClass.DataName)),
					rankIcon,
					Caps(SoldierClass != None ? class'UnitUtilities_BO'.static.GetSoldierClassDisplayName(Unit) : ""),
					classIcon,
					status,
					statusTimeValue $"\n" $ Class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(Class'UIUtilities_Text'.static.GetSizedText( statusTimeLabel, 12)),
					UnitLoc,
					flagIcon,
					false, //todo: is disabled 
					Unit.ShowPromoteIcon(),
					false); // psi soldiers can't rank up via missions
}

// For Long War Toolbox compatibility
function EventListenerReturn OnSoldierListItemUpdate_End(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local UIPersonnel_SoldierListItem ListItem;
	local XComGameState_Unit Unit;
	local X2SoldierClassTemplate SoldierClass;
	local array<UIPanel> Children;
	local UIScrollingText ClassNameText;
	local string strClassName;
	local int UIState;
	local bool IsFocussed;

	ListItem = UIPersonnel_SoldierListItem(EventData);

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.UnitRef.ObjectID));
	SoldierClass = Unit.GetSoldierClassTemplate();

	// Grab the soldier class UIScrollingText. This is brittle.
	ListItem.GetChildrenOfType(class'UIScrollingText', Children);
	ClassNameText = UIScrollingText(Children[1]);

	// HORRIBLE HACK
	IsFocussed = InStr(ClassNameText.htmlText, class'UIUtilities_Colors'.const.BLACK_HTML_COLOR $ "'>") != -1;

	if (ListItem.IsDisabled)
		UIState = eUIState_Disabled;
	else if (IsFocussed)
		UIState = -1;
	else
		UIState = eUIState_Normal;

	if (ClassNameText != none)
	{
		strClassName = Caps(SoldierClass != None ? class'UnitUtilities_BO'.static.GetSoldierClassDisplayName(Unit) : "");
		ClassNameText.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(strClassName, UIState));
	}

	return ELR_NoInterrupt;
}

defaultproperties
{
	ScreenClass = class'UIPersonnel'
}