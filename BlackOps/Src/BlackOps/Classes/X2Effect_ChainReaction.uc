class X2Effect_ChainReaction extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	ListenerObj = self;
	EventMgr.RegisterForEvent(ListenerObj, 'KillMail', ChainReactionListener, ELD_OnVisualizationBlockCompleted, , UnitState);	
}

function EventListenerReturn ChainReactionListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit SourceUnit, TargetUnit;
	local GameRulesCache_Unit UnitCache;
	local XComGameStateHistory History;
	local int i, j;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(EventSource);
	if (SourceUnit == none)
		return ELR_NoInterrupt;

	TargetUnit = XComGameState_Unit(EventData);
	if (TargetUnit == none)
		return ELR_NoInterrupt;

	if (!TargetUnit.bKilledByExplosion)
		return ELR_NoInterrupt;

	if (`TACTICALRULES.GetGameRulesCache_Unit(SourceUnit.GetReference(), UnitCache))
	{
		for (i = 0; i < UnitCache.AvailableActions.Length; ++i)
		{
			AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(UnitCache.AvailableActions[i].AbilityObjectRef.ObjectID));
			if (AbilityState.GetMyTemplateName() == 'ChainReactionFuse')
			{
				for (j = 0; j < UnitCache.AvailableActions[i].AvailableTargets.Length; ++j)
				{
					if (UnitCache.AvailableActions[i].AvailableTargets[j].PrimaryTarget.ObjectID == TargetUnit.ObjectID)
					{
						class'XComGameStateContext_Ability'.static.ActivateAbility(UnitCache.AvailableActions[i], j);
						break;
					}
				}
				break;
			}
		}
	}

	return ELR_NoInterrupt;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "ChainReaction"
}