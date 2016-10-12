class UIScreenListener_UIInventory_Implants extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local XComHQPresentationLayer HQPres;

	// Need to do a check here because LW Perk Pack replaces UIInventory_Implants
	if (!Screen.IsA('UIInventory_Implants') || Screen.IsA('UIInventory_Implants_BO'))
		return;

	HQPres = `HQPRES;

	HQPres.ScreenStack.Pop(Screen);
	HQPres.ScreenStack.Push(HQPres.Spawn(class'UIInventory_Implants_BO', HQPres), HQPres.Get3DMovie());
}

defaultproperties
{
	ScreenClass = none
}