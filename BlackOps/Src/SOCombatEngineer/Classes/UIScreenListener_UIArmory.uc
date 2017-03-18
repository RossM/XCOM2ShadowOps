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
	local array<X2CharacterTemplate> Templates;
	local string Result;
	local KillListItem KLI, InnerKLI;
	local KillInfo KI;
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate Template, InnerTemplate;
	local array<name> CharacterGroupNames;
	local array<int> CharacterGroupCounts;
	local int TotalKills;
	local int CharacterGroupIndex, Index;

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

		Template = CharMgr.FindCharacterTemplate(KLI.TemplateName);
		if (Template != none)
		{
			Templates.AddItem(Template);
			CharacterGroupIndex = CharacterGroupNames.Find(Template.CharacterGroupName);
			if (CharacterGroupIndex != INDEX_NONE)
			{
				CharacterGroupCounts[CharacterGroupIndex] += KLI.Count;
			}
			else
			{
				CharacterGroupNames.AddItem(Template.CharacterGroupName);
				CharacterGroupCounts.AddItem(KLI.Count);
			}
		}
	}

	KillList.Sort(KLIComparer);
	Templates.Sort(TemplateComparer);

	foreach Templates(Template)
	{
		CharacterGroupIndex = CharacterGroupNames.Find(Template.CharacterGroupName);
		if (CharacterGroupCounts[CharacterGroupIndex] <= 0)
			continue;

		Index = KillList.Find('TemplateName', Template.DataName);
		KLI = KillList[Index];

		if (CharacterGroupCounts[CharacterGroupIndex] == KLI.Count)
		{
			Result $= CharacterGroupCounts[CharacterGroupIndex] @ Template.strCharacterName $ "\n";
		}
		else
		{
			Result $= CharacterGroupCounts[CharacterGroupIndex] @ GetCharacterGroupNameDescription(Template.CharacterGroupName) $ "\n";
			foreach Templates(InnerTemplate)
			{
				if (InnerTemplate.CharacterGroupName == Template.CharacterGroupName)
				{
					Index = KillList.Find('TemplateName', InnerTemplate.DataName);
					InnerKLI = KillList[Index];
					
					Result $= "  " $ InnerKLI.Count @ InnerTemplate.strCharacterName $ "\n";
				}
			}
		}

		// Set to -1 so we don't do this character group again
		CharacterGroupCounts[CharacterGroupIndex] = -1;
	}

	if (KI.ProcessedKills > TotalKills)
	{
		Result $= KI.ProcessedKills - TotalKills @ m_strUnknown $ "\n";
	}

	return Result;
}

static function string GetCharacterGroupNameDescription(name CharacterGroupName)
{
	local X2CharacterTemplateManager CharMgr;
	local X2DataTemplate DataTemplate;
	local X2CharacterTemplate Template;
	local int ForceLevel, BestForceLevel;
	local string BestName;

	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	BestForceLevel = 99;

	foreach CharMgr.IterateTemplates(DataTemplate, none)
	{
		Template = X2CharacterTemplate(DataTemplate);
		if (Template.CharacterGroupName != CharacterGroupName)
			continue;

		ForceLevel = GetMinimumForceLevel(Template);
		if (ForceLevel < BestForceLevel)
		{
			BestForceLevel = ForceLevel;
			BestName = Template.strCharacterName;
		}
	}

	return BestName;
}

static function int GetMinimumForceLevel(X2CharacterTemplate Template)
{
	local ForceLevelSpawnWeight SpawnWeight;

	foreach Template.FollowerLevelSpawnWeights(SpawnWeight)
	{
		if (SpawnWeight.SpawnWeight > 0)
			return SpawnWeight.MinForceLevel;
	}
	foreach Template.LeaderLevelSpawnWeights(SpawnWeight)
	{
		if (SpawnWeight.SpawnWeight > 0)
			return SpawnWeight.MinForceLevel;
	}

	return 99;
}

static function int TemplateComparer(X2CharacterTemplate a, X2CharacterTemplate b)
{
	return GetMinimumForceLevel(b) - GetMinimumForceLevel(a);
}

static function int KLIComparer(KillListItem a, KillListItem b)
{
	return a.Count - b.Count;
}

defaultProperties
{
    ScreenClass = UIArmory_MainMenu
}
