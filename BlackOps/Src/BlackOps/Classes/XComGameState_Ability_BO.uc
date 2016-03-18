class XComGameState_Ability_BO extends XComGameState_Ability;

function EventListenerReturn AlwaysReadyTurnEndListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState;
	local UnitValue AttacksThisTurn;
	local bool GotValue;
	local StateObjectReference OverwatchRef;
	local XComGameState_Ability OverwatchState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local EffectAppliedData ApplyData;
	local X2Effect VigilantEffect;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(GameState.GetGameStateForObjectID(OwnerStateObject.ObjectID));
	if (UnitState == none)
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(OwnerStateObject.ObjectID));

	if (UnitState != none && UnitState.NumAllReserveActionPoints() == 0)     //  don't activate overwatch if the unit is potentially doing another reserve action
	{
		GotValue = UnitState.GetUnitValue('AttacksThisTurn', AttacksThisTurn);
		if (!GotValue || AttacksThisTurn.fValue == 0)
		{
			OverwatchRef = UnitState.FindAbility('PistolOverwatch');
			OverwatchState = XComGameState_Ability(History.GetGameStateForObjectID(OverwatchRef.ObjectID));
			if (OverwatchState != none)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
				UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
				//  apply the EverVigilantActivated effect directly to the unit
				ApplyData.EffectRef.LookupType = TELT_AbilityShooterEffects;
				ApplyData.EffectRef.TemplateEffectLookupArrayIndex = 0;
				ApplyData.EffectRef.SourceTemplateName = 'AlwaysReadyTrigger';
				ApplyData.PlayerStateObjectRef = UnitState.ControllingPlayer;
				ApplyData.SourceStateObjectRef = UnitState.GetReference();
				ApplyData.TargetStateObjectRef = UnitState.GetReference();
				VigilantEffect = class'X2Effect'.static.GetX2Effect(ApplyData.EffectRef);
				`assert(VigilantEffect != none);
				VigilantEffect.ApplyEffect(ApplyData, UnitState, NewGameState);

				if (UnitState.NumActionPoints() == 0)
				{
					//  give the unit an action point so they can activate overwatch										
					UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);					
				}
				UnitState.SetUnitFloatValue('AlwaysReadyTriggered', 1, eCleanup_BeginTurn);
				//UnitState.SetUnitFloatValue(class'X2Ability_InfantryAbilitySet'.default.AlwaysReadyEffectName, 1, eCleanup_BeginTurn);
				
				NewGameState.AddStateObject(UnitState);
				`TACTICALRULES.SubmitGameState(NewGameState);
				return OverwatchState.AbilityTriggerEventListener_Self(EventData, EventSource, GameState, EventID);
			}
		}
	}

	return ELR_NoInterrupt;
}