class X2Effect_Focus extends X2Effect_Persistent;

var name FocusValueName;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	ListenerObj = EffectGameState;
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', FocusListener, ELD_OnStateSubmitted, , UnitState);	
}

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim StandardAim;
	local XComGameState_Effect EffectState;

	EffectState = Attacker.GetUnitAffectedByEffectState(EffectName);
	if (EffectState == none)
		return false;

	AbilityTemplate = AbilityState.GetMyTemplate();
	StandardAim = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);

	if (StandardAim != none && StandardAim.bReactionFire)
	{
		if (EffectState.iStacks <= 0)
		{
			if (class'XComGameStateContext_Ability'.static.IsHitResultMiss(CurrentResult))
			{
				NewHitResult = eHit_Success;
				return true;
			}
		}
	}

	return false;
}

function static EventListenerReturn FocusListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit SourceUnit;
	local XComGameState_Effect EffectState, NewEffectState;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim StandardAim;
	local XComGameState NewGameState;

	SourceUnit = XComGameState_Unit(EventSource);
	if (SourceUnit == none)
		return ELR_NoInterrupt;

	EffectState = SourceUnit.GetUnitAffectedByEffectState(default.EffectName);
	if (EffectState == none)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(EventData);
	if (AbilityState == none)
		return ELR_NoInterrupt;

	AbilityTemplate = AbilityState.GetMyTemplate();
	StandardAim = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);

	if (StandardAim != none && StandardAim.bReactionFire)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));

		NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(EffectState.Class, EffectState.ObjectID));
		NewEffectState.iStacks++;
		NewGameState.AddStateObject(NewEffectState);

		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

DefaultProperties
{
	EffectName = "Focus";
	FocusValueName = "FocusAttackCount";
}