class UIScreenListener_TacticalHUD extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	ListenerObj = self;

	EventMgr.RegisterForEvent(ListenerObj, 'SquadConcealmentBroken', UpdateGremlinConcealment_Player, ELD_OnStateSubmitted);
	EventMgr.RegisterForEvent(ListenerObj, 'UnitConcealmentEntered', UpdateGremlinConcealment_Unit, ELD_PreStateSubmitted);
	EventMgr.RegisterForEvent(ListenerObj, 'UnitConcealmentBroken', UpdateGremlinConcealment_Unit, ELD_PreStateSubmitted);
}

static function UpdateGremlinConcealment(XComGameState_Unit SourceUnit, XComGameState NewGameState, Name EventID)
{
	local array<XComGameState_Unit> AttachedUnits;
	local XComGameState_Unit AttachedUnit, NewAttachedUnit;
	local bool bConcealed;

	SourceUnit.GetAttachedUnits(AttachedUnits);

	bConcealed = SourceUnit.IsIndividuallyConcealed();
	if (EventID == 'UnitConcealmentEntered')
		bConcealed = true;
	else if (EventID == 'UnitConcealmentBroken')
		bConcealed = false;

	foreach AttachedUnits(AttachedUnit)
	{
		NewAttachedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AttachedUnit.ObjectID));
		NewAttachedUnit.SetIndividualConcealment(bConcealed, NewGameState);
		NewGameState.AddStateObject(NewAttachedUnit);
	}
}

static function EventListenerReturn UpdateGremlinConcealment_Unit(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState NewGameState;
	local XComGameState_Unit SourceUnit;
	local bool bSubmitState;

	if (GameState.bReadOnly)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("UpdateGremlinConcealment_Unit");
		bSubmitState = true;
	}
	else
	{
		NewGameState = GameState;
	}

	SourceUnit = XComGameState_Unit(EventData);
	if (SourceUnit != none)
	{
		UpdateGremlinConcealment(SourceUnit, NewGameState, EventID);
	}

	if (bSubmitState)
	{
		if( NewGameState.GetNumGameStateObjects() > 0 )
		{
			`TACTICALRULES.SubmitGameState(NewGameState);
		}
		else
		{
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn UpdateGremlinConcealment_Player(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState NewGameState;
	local XComGameState_Unit SourceUnit;
	local bool bSubmitState;

	if (GameState.bReadOnly)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("UpdateGremlinConcealment_Player");
		bSubmitState = true;
	}
	else
	{
		NewGameState = GameState;
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', SourceUnit)
	{
		UpdateGremlinConcealment(SourceUnit, NewGameState, EventID);
	}

	if (bSubmitState)
	{
		if( NewGameState.GetNumGameStateObjects() > 0 )
		{
			`TACTICALRULES.SubmitGameState(NewGameState);
		}
		else
		{
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}
	}

	return ELR_NoInterrupt;
}


defaultproperties
{
	ScreenClass = "UITacticalHUD";
}