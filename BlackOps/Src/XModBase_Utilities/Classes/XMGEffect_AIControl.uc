class XMGEffect_AIControl extends X2Effect_RunBehaviorTree;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	ListenerObj = self;
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', RageListener, ELD_OnVisualizationBlockCompleted);	
	EventMgr.RegisterForEvent(ListenerObj, 'UnitMoveFinished', RageListener, ELD_OnVisualizationBlockCompleted);	
}

function EventListenerReturn RageListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState;
	local XComGameState NewGameState;

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if (UnitState.ActionPoints.Length > 0 && UnitState.AffectedByEffectNames.Find(EffectName) != INDEX_NONE && 
			!UnitState.IsMindControlled() && !`BEHAVIORTREEMGR.IsQueued(UnitState.ObjectID))	
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()), true);
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));

			// Kick off panic behavior tree.
			// Delayed behavior tree kick-off.  Points must be added and game state submitted before the behavior tree can 
			// update, since it requires the ability cache to be refreshed with the new action points.
			UnitState.AutoRunBehaviorTree(BehaviorTreeName, NumActions, `XCOMHISTORY.GetCurrentHistoryIndex() + 1, false, bInitFromPlayer);

			// Mark the last event chain history index when the behavior tree was kicked off, 
			// to prevent multiple BTs from kicking off from a single event chain.
			UnitState.SetUnitFloatValue('LastChainIndexBTStart', `XCOMHISTORY.GetEventChainStartIndex(), eCleanup_BeginTurn);
			NewGameState.AddStateObject(UnitState);

			`TACTICALRULES.SubmitGameState(NewGameState);
		}
	}

	return ELR_NoInterrupt;
}

function bool RageEffectTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));	

	if (UnitState.IsMindControlled())
		return false;

	// Kick off panic behavior tree.
	// Delayed behavior tree kick-off.  Points must be added and game state submitted before the behavior tree can 
	// update, since it requires the ability cache to be refreshed with the new action points.
	UnitState.AutoRunBehaviorTree(BehaviorTreeName, NumActions, `XCOMHISTORY.GetCurrentHistoryIndex() + 1, false, bInitFromPlayer);

	// Mark the last event chain history index when the behavior tree was kicked off, 
	// to prevent multiple BTs from kicking off from a single event chain.
	UnitState.SetUnitFloatValue('LastChainIndexBTStart', `XCOMHISTORY.GetEventChainStartIndex(), eCleanup_BeginTurn);
	NewGameState.AddStateObject(UnitState);

	return false;
}

defaultproperties
{
	EffectName = "Rage"
	EffectTickedFn = RageEffectTicked
	bTickWhenApplied = true
}