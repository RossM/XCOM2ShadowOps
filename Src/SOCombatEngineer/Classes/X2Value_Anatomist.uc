class X2Value_Anatomist extends XMBValue dependson(XComGameState_KillTracker);

function float GetValue(XComGameState_Effect EffectState, XComGameState_Unit UnitState, XComGameState_Unit TargetState, XComGameState_Ability AbilityState)
{
	local XComGameState_KillTracker Tracker;
	local int KilledEnemies, KillerIndex;
	local KillListItem KLI;
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate CharTemplate;

	if (TargetState == none)
		return 0;

	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	Tracker = class'XComGameState_KillTracker'.static.GetKillTracker();

	KillerIndex = Tracker.KillInfos.Find('ObjectID', UnitState.ObjectID);
	if (KillerIndex == 0)
		return 0;

	foreach Tracker.KillInfos[KillerIndex].KillList(KLI)
	{
		CharTemplate = CharMgr.FindCharacterTemplate(KLI.TemplateName);
		if (CharTemplate.CharacterGroupName == TargetState.GetMyTemplate().CharacterGroupName)
			KilledEnemies += KLI.Count;
	}

	return KilledEnemies;
}