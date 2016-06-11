class XMBEffect_AIControl extends X2Effect_Persistent;

var name BehaviorTreeName;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;
	local XComGameState_BattleData BattleData;

	// We use BattleData for the listener obj because it is unique and removed at the end of the battle
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	EventMgr = `XEVENTMGR;

	ListenerObj = BattleData;
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', AIControlListener, ELD_OnVisualizationBlockCompleted);	
	EventMgr.RegisterForEvent(ListenerObj, 'UnitMoveFinished', AIControlListener, ELD_OnVisualizationBlockCompleted);	
}

function static EventListenerReturn AIControlListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectState;
	local XComGameStateHistory History;
	local XMBEffect_AIControl AIControlEffect;

	History = `XCOMHISTORY;

    foreach History.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		AIControlEffect = XMBEffect_AIControl(EffectState.GetX2Effect());

		if (AIControlEffect != none)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectId(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

			if (UnitState.ActionPoints.Length > 0 && !UnitState.IsMindControlled() && !`BEHAVIORTREEMGR.IsQueued(UnitState.ObjectID))	
			{
				UnitState.AutoRunBehaviorTree(AIControlEffect.BehaviorTreeName);
			}
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