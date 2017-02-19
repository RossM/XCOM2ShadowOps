
class UIMission_GPIntelOptions extends UIMission;

var public localized String m_strLockedHelp;

var localized String m_strFinalAssaultTitle;
var localized String m_strFinalAssaultText;
var localized String IntelAvailableLabel;
var localized String IntelOptionsLabel;
var localized String IntelCostLabel;
var localized String IntelTotalLabel;
var name GPMissionSource;

var UIList List;
var UIText OptionDescText;
var UIText TotalIntelText;

var array<UIPanel> arrOptionsWidgets;

var array<MissionIntelOption> SelectedOptions;

//----------------------------------------------------------------------------
// MEMBERS

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	FindMission(GPMissionSource);
	
	BuildScreen();
}

simulated function Name GetLibraryID()
{
	return 'Alert_GoldenPath';
}

simulated function BindLibraryItem()
{
	local Name AlertLibID;
	local UIPanel IntelPanel;

	AlertLibID = GetLibraryID();
	if( AlertLibID != '' )
	{
		LibraryPanel = Spawn(class'UIPanel', self);
		LibraryPanel.bAnimateOnInit = false;
		LibraryPanel.InitPanel('', AlertLibID);

		List = Spawn(class'UIList', LibraryPanel);
		List.bSelectFirstAvailable = false;
		List.InitList('IntelList');
		List.Navigator.LoopSelection = false; 
		List.Navigator.LoopOnReceiveFocus = true;

		List.OnSelectionChanged = OnSelectionChanged;
		IntelPanel = Spawn(class'UIPanel', LibraryPanel);
		IntelPanel.bAnimateOnInit = false;
		IntelPanel.bCascadeFocus = false;
		IntelPanel.InitPanel('IntelPanel');
		IntelPanel.SetSelectedNavigation();

		ButtonGroup = Spawn(class'UIPanel', IntelPanel);
		ButtonGroup.InitPanel('ButtonGroup', '');

		Button1 = Spawn(class'UIButton', ButtonGroup);

		Button1.InitButton('Button0', "",, eUIButtonStyle_NONE);
		Button1.OnSizeRealized = OnButtonSizeRealized;

		Button2 = Spawn(class'UIButton', ButtonGroup);

		Button2.InitButton('Button1', "",, eUIButtonStyle_NONE);
		Button2.OnSizeRealized = OnButtonSizeRealized;

		Button3 = Spawn(class'UIButton', ButtonGroup);

		Button3.InitButton('Button2', "",, eUIButtonStyle_NONE);
		Button3.OnSizeRealized = OnButtonSizeRealized;

		ConfirmButton = Spawn(class'UIButton', IntelPanel);
		ConfirmButton.SetResizeToText(false);

		ConfirmButton.InitButton('ConfirmButton', "", OnLaunchClicked, eUIButtonStyle_NONE);
		ConfirmButton.OnSizeRealized = OnButtonSizeRealized;

		ShadowChamber = Spawn(class'UIPanel', LibraryPanel);
		ShadowChamber.InitPanel('ShadowChamber');

		if (!CanTakeMission())
		{
			IntelPanel.Hide();
		}

		Navigator.LoopSelection = true;
		Navigator.LoopOnReceiveFocus = true;
	}
}
simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	UpdateGoldenPathButtonMessage(ContainerList.GetSelectedItem(), class'UIUtilities_Input'.const.FXS_L_MOUSE_IN);
}

simulated function BuildScreen()
{
	`XSTRATEGYSOUNDMGR.PlaySoundEvent("GeoscapeFanfares_GoldenPath");
	XComHQPresentationLayer(Movie.Pres).CAMSaveCurrentLocation();

	if (bInstantInterp)
	{
		XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(GetMission().Get2DLocation(), CAMERA_ZOOM, 0);
	}
	else
	{
		XComHQPresentationLayer(Movie.Pres).CAMLookAtEarth(GetMission().Get2DLocation(), CAMERA_ZOOM);
	}

	// Add Interception warning and Shadow Chamber info 
	super.BuildScreen();

	Navigator.Clear();
	Button1.OnLoseFocus();
	Button2.OnLoseFocus();
	Button3.OnLoseFocus();

	Button1.SetResizeToText(true);
	Button2.SetResizeToText(true);
	Button1.SetStyle(eUIButtonStyle_HOTLINK_BUTTON);
	Button1.SetGamepadIcon(class 'UIUtilities_Input'.const.ICON_X_SQUARE);
	Button2.SetStyle(eUIButtonStyle_HOTLINK_BUTTON);
	Button2.SetGamepadIcon(class 'UIUtilities_Input'.static.GetBackButtonIcon());
	RefreshIntelOptionsPanel();

	UpdateData();
	UpdateGPButtonString("");
	Navigator.Clear();
	Navigator.AddControl(List);
	Navigator.SetSelected(List);
	List.SetSelectedIndex(0);
}
simulated function OnButtonSizeRealized()
{
	super.OnButtonSizeRealized();

	Button1.SetX(-Button1.Width / 2.0);
	Button2.SetX(-Button2.Width / 2.0);
	LockedButton.SetX(185 - LockedButton.Width / 2.0);

	Button1.SetY(10.0);
	Button2.SetY(40.0);
	LockedButton.SetY(125.0);
}

simulated function BuildMissionPanel()
{
	// Send over to flash ---------------------------------------------------

	LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathInfoBlade");
	LibraryPanel.MC.QueueString(GetMission().GetMissionSource().MissionPinLabel);
	LibraryPanel.MC.QueueString(GetMissionTitle());
	LibraryPanel.MC.QueueString(GetMissionImage());
	LibraryPanel.MC.QueueString(GetOpName());
	LibraryPanel.MC.QueueString(m_strMissionObjective);
	LibraryPanel.MC.QueueString(GetObjectiveString());
	LibraryPanel.MC.QueueString(GetMissionDescString());
	LibraryPanel.MC.EndOp();
}

simulated function BuildOptionsPanel()
{
	// LWS changes to make GPIntel function properly when it can be locked
	if (CanTakeMission())
	{
		LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathIntelButtonBlade");
		LibraryPanel.MC.QueueString(IntelOptionsLabel);
		LibraryPanel.MC.QueueString(m_strLaunchMission);
		LibraryPanel.MC.QueueString(class'UIUtilities_Text'.default.m_strGenericCancel);
	}
	else
	{
		// use the regular centered locked panel when can't take mission
		LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathButtonBlade");
		LibraryPanel.MC.QueueString(IntelOptionsLabel);
		LibraryPanel.MC.QueueString(m_strLaunchMission);
		LibraryPanel.MC.QueueString(class'UIUtilities_Text'.default.m_strGenericCancel);
		LibraryPanel.MC.QueueString(m_strLocked);
		LibraryPanel.MC.QueueString(m_strLockedHelp);
		LibraryPanel.MC.QueueString(m_strOK); //OnCancelClicked
	}
	LibraryPanel.MC.EndOp();

	// ---------------------

	if (!CanTakeMission())
	{
		// Hook up to the flash assets for locked info.
		LockedPanel = Spawn(class'UIPanel', LibraryPanel);
		LockedPanel.InitPanel('lockedMC', '');

		LockedButton = Spawn(class'UIButton', LockedPanel);
		LockedButton.SetResizeToText(false);
		LockedButton.InitButton('ConfirmButton', "");
		LockedButton.SetResizeToText(true);
		LockedButton.SetStyle(eUIButtonStyle_HOTLINK_BUTTON);
		LockedButton.SetGamepadIcon(class 'UIUtilities_Input'.static.GetAdvanceButtonIcon());
		LockedButton.OnSizeRealized = OnButtonSizeRealized;
		LockedButton.SetText(m_strOK);
		LockedButton.OnClickedDelegate = OnCancelClicked;
		LockedButton.Show();

		LockedButton.DisableNavigation();
	}

	Button1.SetBad(true);
	Button1.OnClickedDelegate = OnLaunchClicked;

	Button2.SetBad(true);
	Button2.OnClickedDelegate = OnCancelClicked;

	Button3.Hide();
	ConfirmButton.Hide();
}

simulated function RefreshIntelOptionsPanel()
{
	if (CanTakeMission())
	{
		LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathIntel");
		LibraryPanel.MC.QueueString(IntelAvailableLabel);
		LibraryPanel.MC.QueueString(String(GetAvailableIntel()));
		LibraryPanel.MC.QueueString(IntelCostLabel);
		LibraryPanel.MC.QueueString(IntelTotalLabel);
		LibraryPanel.MC.QueueString(String(GetTotalIntelCost()));
		LibraryPanel.MC.EndOp();
	}
	else
	{
		//hide the intel options when can't take mission
		LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathIntel");
		LibraryPanel.MC.QueueString("");
		LibraryPanel.MC.QueueString("");
		LibraryPanel.MC.QueueString("");
		LibraryPanel.MC.QueueString("");
		LibraryPanel.MC.QueueString("");
		LibraryPanel.MC.EndOp();
	}
}

simulated function UpdateData()
{
	if (CanTakeMission())
	{
		UpdateDisplay();
	}
}

simulated function UpdateDisplay()
{
	local UIMechaListItem SpawnedItem;
	local int i, NumIntelOptions, OptionIndex;
	local X2HackRewardTemplateManager HackRewardTemplateManager;
	local X2HackRewardTemplate OptionTemplate;
	local array<MissionIntelOption> IntelOptions;
	local array<MissionIntelOption> PurchasedOptions;
	local MissionIntelOption PurchasedOption;

	HackRewardTemplateManager = class'X2HackRewardTemplateManager'.static.GetHackRewardTemplateManager();
	IntelOptions = GetMissionIntelOptions();
	PurchasedOptions = GetPurchasedIntelOptions();

	foreach PurchasedOptions(PurchasedOption)
	{
		// Remove any options which have already been purchased
		OptionIndex = IntelOptions.Find('IntelRewardName', PurchasedOption.IntelRewardName);
		if (OptionIndex != INDEX_NONE)
		{
			IntelOptions.Remove(OptionIndex, 1);
		}
	}

	NumIntelOptions = IntelOptions.length;

	if (List.itemCount > NumIntelOptions)
		List.ClearItems();

	while (List.itemCount < NumIntelOptions)
	{
		SpawnedItem = UIMechaListItem(List.CreateItem(class'UIMechaListItem'));
		SpawnedItem.bAnimateOnInit = false;
		SpawnedItem.InitListItem();
		SpawnedItem.SetWidgetType(EUILineItemType_Checkbox);
		SpawnedItem.OnMouseEventDelegate = UpdateGoldenPathButtonMessage; 
	}

	for (i = 0; i < NumIntelOptions; i++)
	{
		OptionTemplate = HackRewardTemplateManager.FindHackRewardTemplate(IntelOptions[i].IntelRewardName);
		UIMechaListItem(List.GetItem(i)).UpdateDataCheckbox(OptionTemplate.GetFriendlyName() $ ": " $ GetIntelCost(IntelOptions[i]), "", false, SelectIntelCheckbox);
	}

	UpdateTotalIntel();
}

simulated function UpdateGoldenPathButtonMessage(UIPanel Panel, int Cmd)
{
	local X2HackRewardTemplateManager HackRewardTemplateManager;
	local X2HackRewardTemplate OptionTemplate;
	local array<MissionIntelOption> IntelOptions;
	local int Index; 

	if( Cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_IN )
	{
		HackRewardTemplateManager = class'X2HackRewardTemplateManager'.static.GetHackRewardTemplateManager();
		IntelOptions = GetMissionIntelOptions();
		Index = List.GetItemIndex(Panel);
		OptionTemplate = HackRewardTemplateManager.FindHackRewardTemplate(IntelOptions[Index].IntelRewardName);
		
		UpdateGPButtonString(OptionTemplate.GetDescription(none));
	}
}

function UpdateGPButtonString(string Msg)
{
	LibraryPanel.MC.BeginFunctionOp("UpdateGoldenPathButtonMessage");
	LibraryPanel.MC.QueueString(Msg);
	LibraryPanel.MC.EndOp();
}
simulated function SelectIntelItem(UIList ContainerList, int ItemIndex)
{
	local MissionIntelOption SelectedOption;
	local X2HackRewardTemplateManager HackRewardTemplateManager;
	local X2HackRewardTemplate OptionTemplate;
	
	HackRewardTemplateManager = class'X2HackRewardTemplateManager'.static.GetHackRewardTemplateManager();
	SelectedOption = GetMission().IntelOptions[ItemIndex];
	OptionTemplate = HackRewardTemplateManager.FindHackRewardTemplate(SelectedOption.IntelRewardName);

	OptionDescText.SetText(OptionTemplate.GetDescription(none));
}

simulated function SelectIntelCheckbox(UICheckbox CheckBox)
{
	local UIPanel SelectedPanel;
	local MissionIntelOption SelectedOption;
	local int itemIndex;

	SelectedPanel = List.GetSelectedItem();
	itemIndex = List.GetItemIndex(SelectedPanel);
	SelectedOption = GetMission().IntelOptions[itemIndex];

	if (CheckBox.bChecked)
		SelectedOptions.AddItem(SelectedOption);
	else
		SelectedOptions.RemoveItem(SelectedOption);

	UpdateTotalIntel();
}

simulated function UpdateTotalIntel()
{
	RefreshIntelOptionsPanel();

	if (!CanAffordIntelOptions())
	{
		Button1.DisableButton();
		Button1.SetBad(true);
	}
	else
	{
		Button1.EnableButton();
		Button1.MC.FunctionVoid("setBad");
	}
}

//-------------- EVENT HANDLING --------------------------------------------------------

simulated public function OnLaunchClicked(UIButton button)
{
	local XComGameState NewGameState;
	
	if (GetMission().GetMissionSource().DataName == 'MissionSource_Broadcast')
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Confirm Launch Broadcast Mission");
		`XEVENTMGR.TriggerEvent('OnLaunchBroadcastMission', , , NewGameState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		FinalAssaultPopup();
	}
	else
	{
		super.OnLaunchClicked(button);
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	if (List.OnUnrealCommand(cmd, arg))
	{
		return true;
	}

	switch(cmd)
	{
	case class'UIUtilities_Input'.const.FXS_BUTTON_X:
		if (CanTakeMission() && Button1 != none && Button1.bIsVisible && !Button1.IsDisabled)
		{
			Button1.OnClickedDelegate(Button1);
			return true;
		}

		break;
	}

	return super.OnUnrealCommand(cmd, arg);
}
function FinalAssaultPopup()
{
	local TDialogueBoxData DialogData;

	DialogData.eType = eDialog_Warning;
	DialogData.strTitle = m_strFinalAssaultTitle;
	DialogData.strText = m_strFinalAssaultText;

	DialogData.fnCallback = FinalAssaultCB;

	DialogData.strAccept = m_strLaunchMission;
	DialogData.strCancel = m_strCancel;

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("GeoscapeFanfares_AlienFacility");

	`HQPRES.UIRaiseDialog(DialogData);
}

simulated function FinalAssaultCB(EUIAction eAction)
{
	if (eAction == eUIAction_Accept)
	{
		BuyAndSaveIntelOptions();
		super.OnLaunchClicked(ConfirmButton);
	}
	else
	{
		CloseScreen();
	}
}

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function String GetMissionDescString()
{
	return GetMission().GetMissionSource().MissionFlavorText;
}
simulated function bool CanTakeMission()
{
	return !GetMission().bNotAtThreshold;
}
simulated function EUIState GetLabelColor()
{
	return eUIState_Warning2;
}

simulated function array<MissionIntelOption> GetMissionIntelOptions()
{
	return GetMission().IntelOptions;
}

simulated function array<MissionIntelOption> GetPurchasedIntelOptions()
{
	return GetMission().PurchasedIntelOptions;
}

simulated function bool CanAffordIntelOptions()
{
	return (GetTotalIntelCost() <= GetAvailableIntel());
}

simulated function int GetAvailableIntel()
{
	return class'UIUtilities_Strategy'.static.GetXComHQ().GetResourceAmount('Intel');
}

simulated function int GetIntelCost(MissionIntelOption IntelOption)
{
	return class'UIUtilities_Strategy'.static.GetCostQuantity(IntelOption.Cost, 'Intel');
}

simulated function int GetTotalIntelCost()
{
	local MissionIntelOption IntelOption;
	local int TotalCost;

	foreach SelectedOptions(IntelOption)
	{
		TotalCost += class'UIUtilities_Strategy'.static.GetCostQuantity(IntelOption.Cost, 'Intel');
	}

	return TotalCost;
}

simulated function BuyAndSaveIntelOptions()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local MissionIntelOption IntelOption;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Buy and Save Selected Mission Intel Options");
	
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	
	MissionState = GetMission();
	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
	NewGameState.AddStateObject(MissionState);

	// Save and buy the intel options, and add their tactical tags
	foreach SelectedOptions(IntelOption)
	{
		XComHQ.TacticalGameplayTags.AddItem(IntelOption.IntelRewardName);
		XComHQ.PayStrategyCost(NewGameState, IntelOption.Cost, XComHQ.MissionOptionScalars);
		MissionState.PurchasedIntelOptions.AddItem(IntelOption);
	}
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

simulated function AddIgnoreButton()
{
	local UIButton IgnoreButton; 

	if(CanBackOut())
	{
		IgnoreButton = Spawn(class'UIButton', LibraryPanel);
		IgnoreButton.SetResizeToText( false );
		IgnoreButton.InitButton('IgnoreButton', "", OnCancelClicked);
	}
	else
	{
		IgnoreButton.InitButton('IgnoreButton').Hide();
	}
}

//==============================================================================

defaultproperties
{
	Package = "/ package/gfxAlerts/Alerts";
	InputState = eInputState_Consume;
}