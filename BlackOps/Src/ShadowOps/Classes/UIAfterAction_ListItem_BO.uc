class UIAfterAction_ListItem_BO extends UIAfterAction_ListItem;

// Modified to display subclass names
simulated function UpdateData(optional StateObjectReference UnitRef)
{
	local int days, woundHours;
	local bool bCanPromote;
	local string statusLabel, statusText, daysLabel, daysText, ClassStr;
	local XComGameState_Unit Unit;

	UnitReference = UnitRef;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	
	if(Unit.bCaptured)
	{
		statusText = m_strMIA;
		statusLabel = "kia"; // corresponds to timeline label on 'AfterActionBG' mc in SquadList.fla
		bShowPortrait = true;
	}
	else if(Unit.IsAlive())
	{
		// TODO: Add support for soldiers MIA (missing in action)

		if(Unit.IsInjured())
		{
			statusText = Caps(Unit.GetWoundStatus(,true));
			statusLabel = "wounded"; // corresponds to timeline label on 'AfterActionBG' mc in SquadList.fla
			
			//After Action Days Wounded Mod fix
			Unit.GetWoundState(woundHours);
			if (woundHours > 0) 
			{
				days = woundHours / 24;
				if( woundHours % 24 > 0 )
					days += 1;

				daysLabel = class'UIUtilities_Text'.static.GetDaysString(days);
				daysText = string(days);
			}
		}
		else
		{
			statusText = m_strActive;
			statusLabel = "active"; // corresponds to timeline label on 'AfterActionBG' mc in SquadList.fla
		}

		if(Unit.HasPsiGift())
			PsiMarkup.Show();
		else
			PsiMarkup.Hide();
	}
	else
	{
		statusText = m_strKIA;
		statusLabel = "kia"; // corresponds to timeline label on 'AfterActionBG' mc in SquadList.fla
		bShowPortrait = true;
	}

	WorldInfo.RemoteEventListeners.AddItem(self); //Listen for the remote event that tells us when we can capture a portrait

	bCanPromote = Unit.ShowPromoteIcon(); 

	// Don't show class label for rookies since their rank is shown which would result in a duplicate string
	if(Unit.GetRank() > 0)
		ClassStr = class'UIUtilities_Text'.static.GetColoredText(Caps(class'UnitUtilities_BO'.static.GetSoldierClassDisplayName(Unit)), eUIState_Faded, 17);
	else
		ClassStr = "";

	AS_SetData( class'UIUtilities_Text'.static.GetColoredText(Caps(class'X2ExperienceConfig'.static.GetRankName(Unit.GetRank(), Unit.GetSoldierClassTemplateName())), eUIState_Faded, 18),
				class'UIUtilities_Text'.static.GetColoredText(Caps(Unit.GetName(eNameType_Last)), eUIState_Normal, 22),
				class'UIUtilities_Text'.static.GetColoredText(Caps(Unit.GetName(eNameType_Nick)), eUIState_Header, 28),
				Unit.GetSoldierClassTemplate().IconImage, class'UIUtilities_Image'.static.GetRankIcon(Unit.GetRank(), Unit.GetSoldierClassTemplateName()),
				(bCanPromote) ? class'UISquadSelect_ListItem'.default.m_strPromote : "",
				statusLabel, statusText, daysLabel, daysText, m_strMissionsLabel, string(Unit.GetNumMissions()),
				m_strKillsLabel, string(Unit.GetNumKills()), false, ClassStr);

	if( bCanPromote )
	{
		EnableNavigation(); 
		if( PromoteButton == none ) //This data will be refreshed several times, so beware not to spawn dupes. 
		{
			PromoteButton = Spawn(class'UIButton', self);
			PromoteButton.InitButton('promoteButtonMC', "", OnClickedPromote, eUIButtonStyle_NONE);
		}
		PromoteButton.Show();
	}
	else
	{
		if( PromoteButton != none )
			PromoteButton.Remove(); 

		DisableNavigation();
		Navigator.SelectFirstAvailable();
	}
}
