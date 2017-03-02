class UIScreenListener_UIArmory extends UIScreenListener dependson(XComGameState_KillTracker);

var localized string m_strKills, m_strKillsTitle, m_strUnknown;

var UIArmory_MainMenu MainMenuScreen;;

event OnInit(UIScreen Screen)
{
	MainMenuScreen = UIArmory_MainMenu(Screen);
	if (MainMenuScreen == none)
		return;

	AddKillsButton();
}

event OnReceiveFocus(UIScreen Screen)
{
	MainMenuScreen = UIArmory_MainMenu(Screen);
	if (MainMenuScreen == none)
		return;

	AddKillsButton();
}

function AddKillsButton()
{
	local UIListItemString KillsButton;

	KillsButton = MainMenuScreen.Spawn(class'UIListItemString', MainMenuScreen.List.ItemContainer).InitListItem(m_strKills);
	KillsButton.MCName = 'ArmoryMainMenu_KillsButton_BO';
	KillsButton.ButtonBG.OnClickedDelegate = ViewKillStats;

	MainMenuScreen.List.SetSize(MainMenuScreen.List.Width, 60*MainMenuScreen.List.ItemCount);
}

simulated function ViewKillStats(UIButton Button)
{
	local TDialogueBoxData DialogData;
	local XComGameState_Unit UnitState;

	UnitState = MainMenuScreen.GetUnit();

	MainMenuScreen.Movie.Pres.PlayUISound(eSUISound_MenuSelect);

	DialogData.eType = eDialog_Normal;
	DialogData.strTitle = repl(m_strKillsTitle, "#1", UnitState.GetName(eNameType_Full));
	DialogData.strText = GetFormattedKillsText(UnitState);
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericOK;;
	MainMenuScreen.Movie.Pres.UIRaiseDialog(DialogData);
}

simulated function string GetFormattedKillsText(XComGameState_Unit UnitState)
{
	local XComGameState_KillTracker Tracker;
	local int KillerIndex;
	local array<KillListItem> KillList;
	local string Result;
	local KillListItem KLI;
	local KillInfo KI;
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate Template;
	local int TotalKills;

	Tracker = class'XComGameState_KillTracker'.static.GetKillTracker();
	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	KillerIndex = Tracker.KillInfos.Find('ObjectID', UnitState.ObjectID);
	if (KillerIndex == INDEX_NONE)
		return "";

	KI = Tracker.KillInfos[KillerIndex];
	KillList = KI.KillList;

	foreach KillList(KLI)
	{
		TotalKills += KLI.Count;
	}

	if (KI.ProcessedKills > TotalKills)
	{
		KLI.TemplateName = '';
		KLI.Count = KI.ProcessedKills - TotalKills;
		KillList.AddItem(KLI);
	}

	KillList.Sort(KLIComparer);

	foreach KillList(KLI)
	{
		Template = CharMgr.FindCharacterTemplate(KLI.TemplateName);
		if (Template != none)
			Result $= KLI.Count @ Template.strCharacterName;
		else
			Result $= KLI.Count @ m_strUnknown;

		Result $= "\n";
	}

	return Result;
}

static function int KLIComparer(KillListItem a, KillListItem b)
{
	return a.Count - b.Count;
}

defaultProperties
{
    ScreenClass = UIArmory_MainMenu
}
