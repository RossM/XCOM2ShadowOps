class X2Effect_MadBomber extends XMBEffect_AddUtilityItem;

var array<name> RandomGrenades;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2ItemTemplate ItemTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Unit NewUnit;
	local name TemplateName;

	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	if (class'XMBEffectUtilities'.static.SkipForDirectMissionTransfer(ApplyEffectParameters))
		return;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	TemplateName = RandomGrenades[`SYNC_RAND(RandomGrenades.Length)];
	ItemTemplate = ItemTemplateMgr.FindItemTemplate(TemplateName);
	
	// Use the highest upgraded available version of the item
	if (bUseHighestAvailableUpgrade)
		`XCOMHQ.UpdateItemTemplateToHighestAvailableUpgrade(ItemTemplate);

	AddUtilityItem(NewUnit, ItemTemplate, NewGameState, NewEffectState);
}
