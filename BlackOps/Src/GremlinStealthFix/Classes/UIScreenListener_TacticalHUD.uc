class UIScreenListener_TacticalHUD extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	ListenerObj = self;

	EventMgr.RegisterForEvent(ListenerObj, 'UnitConcealmentEntered', UpdateGremlinConcealment, ELD_PreStateSubmitted);
	EventMgr.RegisterForEvent(ListenerObj, 'UnitConcealmentBroken', UpdateGremlinConcealment, ELD_PreStateSubmitted);
}

static function EventListenerReturn UpdateGremlinConcealment(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID)
{
	local array<XComGameState_Unit> AttachedUnits;
	local XComGameState_Unit SourceUnit, AttachedUnit, NewAttachedUnit;
	local bool bConcealed;

	SourceUnit = XComGameState_Unit(EventData);
	if (SourceUnit != none)
	{
		SourceUnit.GetAttachedUnits(AttachedUnits);

		bConcealed = SourceUnit.IsConcealed();
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

	return ELR_NoInterrupt;
}


defaultproperties
{
	ScreenClass = "UITacticalHUD";
}