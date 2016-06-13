class X2Effect_AIControl extends X2Effect_Persistent;

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
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', AIControlListener, ELD_OnVisualizationBlockCompleted, 0);	
	EventMgr.RegisterForEvent(ListenerObj, 'UnitMoveFinished', AIControlListener, ELD_OnVisualizationBlockCompleted, 0);	
}

function static UpdateAIControl()
{
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectState;
	local XComGameStateHistory History;
	local X2Effect_AIControl AIControlEffect;
	local XGAIBehavior kBehavior;

	History = `XCOMHISTORY;

    foreach History.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		AIControlEffect = X2Effect_AIControl(EffectState.GetX2Effect());

		if (AIControlEffect != none)
		{
			if (!`BEHAVIORTREEMGR.IsReady())
			{
				`Log("UpdateAiControl: BehaviorTreeMgr not ready, waiting");
				`BATTLE.SetTimer(0.1f, false, nameof(UpdateAIControl), AIControlEffect);
				return;
			}

			UnitState = XComGameState_Unit(History.GetGameStateForObjectId(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

			`Log("UpdateAIControl: Considering" @ UnitState);

			kBehavior = XGUnit(`XCOMHISTORY.GetVisualizer(UnitState.ObjectID)).m_kBehavior;
			if (kBehavior != None && !kBehavior.IsInState('Inactive'))
			{
				`Log("UpdateAIControl: Unit already active");
				continue;
			}

			if (UnitState.ActionPoints.Length == 0)
			{
				`Log("UpdateAIControl: Unit has no actions");
				continue;
			}
			if (UnitState.IsMindControlled())
			{
				`Log("UpdateAIControl: Unit is mind controlled");
				continue;
			}

			`Log("UpdateAIControl: Running behavior tree" @ AIControlEffect.BehaviorTreeName);
			UnitState.AutoRunBehaviorTree(AIControlEffect.BehaviorTreeName);
			return;
		}
	}
}

function static EventListenerReturn AIControlListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	`Log("AIControlListener("$EventID$")");

	UpdateAIControl();

	return ELR_NoInterrupt;
}

function bool AIControlEffectTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	UpdateAIControl();

	return false;
}

defaultproperties
{
	EffectTickedFn = AIControlEffectTicked
}