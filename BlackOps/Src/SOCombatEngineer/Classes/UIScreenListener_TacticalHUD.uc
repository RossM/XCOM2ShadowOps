class UIScreenListener_TacticalHUD extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	class'XComGameState_KillTracker'.static.GetKillTracker().RefreshListeners();
}

defaultProperties
{
    ScreenClass = UITacticalHUD
}
