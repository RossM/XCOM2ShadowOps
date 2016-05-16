class X2Effect_DropLoot extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2LootTableManager LootManager;
	local XComGameState_Unit Unit;
	local LootResults Loot;

	`Log("Running DropLoot");

	Unit = XComGameState_Unit(kNewTargetState);
	if (Unit == none)
	{
		`Log("DropLoot targeted a non-unit?");
		return;
	}

	LootManager = class'X2LootTableManager'.static.GetLootTableManager();

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
	if( XComHQ != none && XComHQ.SoldierUnlockTemplates.Find('VultureUnlock') != INDEX_NONE )
	{
		// vulture loot roll
		LootManager.RollForLootCarrier(Unit.GetMyTemplate().VultureLoot, Loot);
	}
	else
	{
		// roll on regular timed loot if vulture is not enabled
		LootManager.RollForLootCarrier(Unit.GetMyTemplate().VultureLoot, Loot);
	}

	`Log("Adding loot:" @ class'X2LootTableManager'.static.LootResultsToString(Loot));
	Unit.SetLoot(Loot);
}