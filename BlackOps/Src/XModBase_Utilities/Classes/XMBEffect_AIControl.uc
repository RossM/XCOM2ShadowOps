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
	EventMgr.RegisterForEvent(ListenerObj, 'PlayerTurnBegun', AIControlListener, ELD_OnVisualizationBlockCompleted);	
}

function static UpdateAIControl()
{
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectState;
	local XComGameStateHistory History;
	local XMBEffect_AIControl AIControlEffect;
	local XGAIBehavior kBehavior;

	History = `XCOMHISTORY;

    foreach History.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		AIControlEffect = XMBEffect_AIControl(EffectState.GetX2Effect());

		if (AIControlEffect != none)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectId(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

			kBehavior = XGUnit(`XCOMHISTORY.GetVisualizer(UnitState.ObjectID)).m_kBehavior;
			if (kBehavior != None && !kBehavior.IsInState('Inactive'))
			{
				`BATTLE.SetTimer(0.1f, false, nameof(UpdateAIControl));
				continue;
			}

			if (UnitState.ActionPoints.Length > 0 && !UnitState.IsMindControlled() && !`BEHAVIORTREEMGR.IsQueued(UnitState.ObjectID))	
			{
				UnitState.AutoRunBehaviorTree(AIControlEffect.BehaviorTreeName);
			}
		}
	}
}

function static EventListenerReturn AIControlListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	UpdateAIControl();

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