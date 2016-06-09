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
	super(X2Effect_Persistent).OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

function EventListenerReturn AIControlListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState;

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if (UnitState.ActionPoints.Length > 0 && UnitState.AffectedByEffectNames.Find(EffectName) != INDEX_NONE && 
			!UnitState.IsMindControlled() && !`BEHAVIORTREEMGR.IsQueued(UnitState.ObjectID))	
		{
			UnitState.AutoRunBehaviorTree(BehaviorTreeName);
		}
	}

	return ELR_NoInterrupt;
}

function bool AIControlEffectTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectId(ApplyEffectParameters.TargetStateObjectRef.ObjectID));	

	if (UnitState.IsMindControlled())
		return false;

	UnitState.AutoRunBehaviorTree(BehaviorTreeName);

	return false;
}

defaultproperties
{
	EffectTickedFn = AIControlEffectTicked
}