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
	local UnitValue CountUnitValue;

	AbilityTemplate = AbilityState.GetMyTemplate();
	StandardAim = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);

	if (StandardAim != none && StandardAim.bReactionFire)
	{
		Attacker.GetUnitValue(FocusValueName, CountUnitValue);

		if (CountUnitValue.fValue <= 0)
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
	local XComGameState_Effect EffectState;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim StandardAim;
	local XComGameState NewGameState;
	local UnitValue CountUnitValue;

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

		SourceUnit.GetUnitValue(default.FocusValueName, CountUnitValue);

		SourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(SourceUnit.Class, SourceUnit.ObjectID));
		SourceUnit.SetUnitFloatValue(default.FocusValueName, CountUnitValue.fValue + 1, eCleanup_BeginTurn);
		NewGameState.AddStateObject(SourceUnit);

		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

DefaultProperties
{
	EffectName = "Focus";
	FocusValueName = "FocusAttackCount";
}