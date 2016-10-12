class UIScreenListener_UIArmory_Promotion extends UIScreenListener;

var UIButton RespecButton;
var localized string LocFreeRespec, RespecWarning, RespecWarningTitle;
var UIArmory Armory;
var bool bShowedPopup;

event OnInit(UIScreen Screen)
{
	local TDialogueBoxData kDialogData;
	local XComGameState_Unit Unit;
	local XComGameState_ShadowOpsUnitInfo UnitInfo;
	local bool bAllowRespec;

	Armory = UIArmory(Screen);
	RespecButton = UIButton(Armory.GetChild('respecButton'));

	Unit = Armory.GetUnit();
	UnitInfo = XComGameState_ShadowOpsUnitInfo(Unit.FindComponentObject(class'XComGameState_ShadowOpsUnitInfo'));

	bAllowRespec = UnitInfo != none && UnitInfo.bFreeRespecAllowed && 
		(Unit.GetSoldierRank() <= UnitInfo.iFreeRespecMaxRank || (Unit.GetSoldierRank() == UnitInfo.iFreeRespecMaxRank + 1 && Unit.HasAvailablePerksToAssign()));

	if (bAllowRespec)
	{
		if (RespecButton == none)
		{
			RespecButton = Armory.Spawn(class'UIButton', Armory);
			RespecButton.InitButton('respecButton', LocFreeRespec, OnButtonRespec);
			RespecButton.bAnimateOnInit = false;
			RespecButton.SetText(LocFreeRespec);
			RespecButton.SetResizeToText(true);
			RespecButton.SetFontSize(50);
			RespecButton.SetHeight(60);
			RespecButton.AnchorTopCenter();
			RespecButton.OriginTopCenter();
		}

		RespecButton.Show();

		if (Unit.GetSoldierRank() >= UnitInfo.iFreeRespecMaxRank + 1 && !bShowedPopup)
		{
			bShowedPopup = true;

			kDialogData.eType = eDialog_Normal;
			kDialogData.strTitle = default.RespecWarningTitle;
			kDialogData.strText = default.RespecWarning;
			kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericOK;
			kDialogData.eType = eDialog_Warning;

			`HQPRES.UIRaiseDialog(kDialogData);
		}
	}
	else if (RespecButton != none)
	{
		RespecButton.Hide();
	}
}

simulated public function OnButtonRespec(UIButton ButtonControl)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_ShadowOpsUnitInfo NewUnitInfo;
	local XComGameState NewGameState;
	local int i;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Shadow Ops Respec");

	NewUnitState = Armory.GetUnit();
	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', NewUnitState.ObjectID));

	NewUnitInfo = XComGameState_ShadowOpsUnitInfo(NewUnitState.FindComponentObject(class'XComGameState_ShadowOpsUnitInfo'));
	NewUnitInfo = XComGameState_ShadowOpsUnitInfo(NewGameState.CreateStateObject(class'XComGameState_ShadowOpsUnitInfo', NewUnitInfo.ObjectID));

	if (NewUnitInfo == none || !NewUnitInfo.bFreeRespecAllowed)
		return;

	NewUnitState.ResetSoldierAbilities(); // First clear all of the current abilities
	for (i = 0; i < NewUnitState.GetSoldierClassTemplate().GetAbilityTree(0).Length; ++i) // Then give them their squaddie ability back
	{
		NewUnitState.BuySoldierProgressionAbility(NewGameState, 0, i);
	}

	NewUnitInfo.bFreeRespecAllowed = false;

	NewGameState.AddStateObject(NewUnitState);
	NewGameState.AddStateObject(NewUnitInfo);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	class'UIArmory'.Static.CycleToSoldier(NewUnitState.GetReference());
}

event OnReceiveFocus(UIScreen Screen)
{
	OnInit(Screen);
}


defaultproperties
{
	ScreenClass = class'UIArmory_Promotion'
}