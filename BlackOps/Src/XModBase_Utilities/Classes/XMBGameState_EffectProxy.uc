class XMBGameState_EffectProxy extends XComGameState_BaseObject;

var StateObjectReference EffectRef;
var delegate<ProxyOnEventDelegate> OnEvent;

delegate EventListenerReturn ProxyOnEventDelegate(XComGameState_Effect EffectState, Object EventData, Object EventSource, XComGameState GameState, Name EventID);

function EventListenerReturn EventHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Effect EffectState;

	EffectState = XComGameState_Effect(GameState.GetGameStateForObjectID(EffectRef.ObjectID));
	if (EffectState == none)
		EffectState = XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(EffectRef.ObjectID));

	return OnEvent(EffectState, EventData, EventSource, GameState, EventID);
}