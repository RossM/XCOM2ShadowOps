class X2Effect_Fade extends X2Effect_RangerStealth_BO;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'ObjectMoved', EffectGameState.GenerateCover_ObjectMoved, ELD_OnStateSubmitted, , UnitState);
}