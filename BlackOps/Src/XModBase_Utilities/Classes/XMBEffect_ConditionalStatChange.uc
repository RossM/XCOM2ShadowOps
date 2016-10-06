class XMBEffect_ConditionalStatChange extends X2Effect_PersistentStatChange;

var array<X2Condition> Conditions;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local XComGameState_Unit UnitState;
	local X2EventManager EventMgr;
	local XMBGameState_EffectProxy Proxy;
	local XComGameState NewGameState;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	NewGameState = EffectGameState.GetParentGameState();
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	Proxy = XMBGameState_EffectProxy(NewGameState.CreateStateObject(class'XMBGameState_EffectProxy'));
	EffectGameState = XComGameState_Effect(NewGameState.CreateStateObject(EffectGameState.class, EffectGameState.ObjectID));

	EffectGameState.AddComponentObject(Proxy);

	NewGameState.AddStateObject(EffectGameState);
	NewGameState.AddStateObject(Proxy);

	ListenerObj = Proxy;

	// Register to tick after EVERY action.
	Proxy.OnEvent = EventHandler;
	Proxy.EffectRef = EffectGameState.GetReference();
	EventMgr.RegisterForEvent(ListenerObj, 'OnUnitBeginPlay', class'XMBGameState_EffectProxy'.static.EventHandler, ELD_OnStateSubmitted, 25, UnitState);	
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', class'XMBGameState_EffectProxy'.static.EventHandler, ELD_OnStateSubmitted, 25);	
}

static function EventListenerReturn EventHandler(XComGameState_Effect EffectState, Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Effect NewEffectState;
	local XComGameState NewGameState;
	local XMBEffect_ConditionalStatChange EffectTemplate;
	local bool bOldApplicable, bNewApplicable;

	if (EffectState == none)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	EffectTemplate = XMBEffect_ConditionalStatChange(EffectState.GetX2Effect());

	bOldApplicable = EffectState.StatChanges.Length > 0;
	bNewApplicable = class'XMBEffectUtilities'.static.CheckShooterConditions(EffectTemplate.Conditions, EffectState, UnitState, none, none) == 'AA_Success';

	if (bOldApplicable != bNewApplicable)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Conditional Stat Change");

		NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(class'XComGameState_Effect', EffectState.ObjectID));

		NewGameState.AddStateObject(NewUnitState);
		NewGameState.AddStateObject(NewEffectState);

		if (bNewApplicable)
		{
			NewEffectState.StatChanges = EffectTemplate.m_aStatChanges;

			// Note: ApplyEffectToStats crashes the game if the state objects aren't added to the game state yet
			NewUnitState.ApplyEffectToStats(NewEffectState, NewGameState);
		}
		else
		{
			NewUnitState.UnApplyEffectFromStats(NewEffectState, NewGameState);
			NewEffectState.StatChanges.Length = 0;
		}

		`GAMERULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}


// From X2Effect_Persistent.
function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
	return EffectGameState.StatChanges.Length > 0;
}


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super(X2Effect_Persistent).OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}