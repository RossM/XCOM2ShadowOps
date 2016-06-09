class UIScreenListener_UIArmory_Promotion extends UIScreenListener;

var UIButton RespecButton;
var localized string LocFreeRespec;

event OnInit(UIScreen Screen)
{
	local UIArmory Armory;
	local XComGameState_Unit Unit;
	local XComGameState_ShadowOpsUnitInfo UnitInfo;
	local bool bAllowRespec;

	Armory = UIArmory(Screen);
	RespecButton = UIButton(Armory.GetChild('respecButton'));

	Unit = Armory.GetUnit();
	UnitInfo = XComGameState_ShadowOpsUnitInfo(Unit.FindComponentObject(class'XComGameState_ShadowOpsUnitInfo'));

	bAllowRespec = UnitInfo != none && UnitInfo.bFreeRespecAllowed && Unit.GetSoldierRank() <= UnitInfo.iFreeRespecMaxRank;

	if (bAllowRespec)
	{
		if (RespecButton == none)
		{
			RespecButton = Armory.Spawn(class'UIButton', Armory);
			RespecButton.InitButton('respecButton', LocFreeRespec, OnButtonRespec);
			RespecButton.SetText(LocFreeRespec);
			RespecButton.SetResizeToText(true);
			RespecButton.SetFontSize(50);
			RespecButton.SetHeight(60);
			RespecButton.AnchorTopCenter();
			RespecButton.OriginTopCenter();
		}

		RespecButton.Show();
		RespecButton.NeedsAttention(Unit.CanRankUpSoldier());
	}
	else if (RespecButton != none)
	{
		RespecButton.Hide();
	}
}

simulated public function OnButtonRespec(UIButton ButtonControl)
{
}

event OnReceiveFocus(UIScreen Screen)
{
	OnInit(Screen);
}


defaultproperties
{
	ScreenClass = class'UIArmory_Promotion'
}