class X2Effect_ReverseEngineering extends X2Effect;

var array<int> HackBonus;

simulated private function int CalculateBonus(int TotalBonus)
{
	local int Bonus;

	if (TotalBonus <= HackBonus.Length - 1)
		Bonus = HackBonus[TotalBonus];
	else
		Bonus = HackBonus[HackBonus.Length - 1];

	return Bonus;
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetState;
	local UnitValue CountValue;
	local int Bonus;

	TargetState = XComGameState_Unit(kNewTargetState);
	if (TargetState == none)
		return;

	TargetState.GetUnitValue('ReverseEngineeringCount', CountValue);
	Bonus = CalculateBonus(int(CountValue.fValue));

	TargetState = XComGameState_Unit(NewGameState.CreateStateObject(TargetState.class, TargetState.ObjectID));
	NewGameState.AddStateObject(TargetState);

	TargetState.SetBaseMaxStat(eStat_Hacking, TargetState.GetBaseStat(eStat_Hacking) + Bonus);
	TargetState.SetUnitFloatValue('ReverseEngineeringCount', CountValue.fValue + 1, eCleanup_Never);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local string						FlyOverText;
	local XComGameState_Unit			UnitState;
	local UnitValue						CountValue;
	local int Bonus;

	if (EffectApplyResult == 'AA_Success' && XGUnit(BuildTrack.TrackActor).IsAlive())
	{
		Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		AbilityContext = Context.InputContext;
		AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	
		UnitState = XGUnit(BuildTrack.TrackActor).GetVisualizedGameState();
		UnitState.GetUnitValue('ReverseEngineeringCount', CountValue);
		Bonus = CalculateBonus(int(CountValue.fValue));

		FlyOverText = AbilityTemplate.LocFlyOverText $ ": +" $ Bonus @ class'XLocalizedData'.default.TechLabel;

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, FlyOverText, '', eColor_Good, AbilityTemplate.IconImage);
	}
}