class XMGEffect_AIControl extends X2Effect_RunBehaviorTree;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	ListenerObj = self;
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', AIControlListener, ELD_OnVisualizationBlockCompleted);	
	EventMgr.RegisterForEvent(ListenerObj, 'UnitMoveFinished', AIControlListener, ELD_OnVisualizationBlockCompleted);	
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_AIUnitData NewAIUnitData;
	local XComGameState_Unit NewUnitState;
	local bool bDataChanged;
	local AlertAbilityInfo AlertInfo;
	local Vector PingLocation;
	local XComGameState_BattleData BattleData;

	NewUnitState = XComGameState_Unit(kNewTargetState);

	// Create an AI alert for the objective location

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	PingLocation = BattleData.MapData.ObjectiveLocation;
	AlertInfo.AlertTileLocation = `XWORLD.GetTileCoordinatesFromPosition(PingLocation);
	AlertInfo.AlertRadius = 500;
	AlertInfo.AlertUnitSourceID = 0;
	AlertInfo.AnalyzingHistoryIndex = NewGameState.HistoryIndex;

	// Add AI data with the alert

	NewAIUnitData = XComGameState_AIUnitData(NewGameState.CreateStateObject(class'XComGameState_AIUnitData', NewUnitState.GetAIUnitDataID()));
	if( NewAIUnitData.m_iUnitObjectID != NewUnitState.ObjectID )
	{
		NewAIUnitData.Init(NewUnitState.ObjectID);
		bDataChanged = true;
	}
	if( NewAIUnitData.AddAlertData(NewUnitState.ObjectID, eAC_MapwideAlert_Hostile, AlertInfo, NewGameState) )
	{
		bDataChanged = true;
	}

	if( bDataChanged )
	{
		NewGameState.AddStateObject(NewAIUnitData);
	}
	else
	{
		NewGameState.PurgeGameStateForObjectID(NewAIUnitData.ObjectID);
	}
}

function EventListenerReturn AIControlListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
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

function bool AIControlEffectTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
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
	EffectTickedFn = AIControlEffectTicked
	bTickWhenApplied = true
}