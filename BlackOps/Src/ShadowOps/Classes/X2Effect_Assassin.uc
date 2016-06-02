class X2Effect_Assassin extends X2Effect_Persistent;

var bool bRequireAbilityWeapon, bRequireKill;
var array<EAbilityHitResult> AllowedHitResults;
var name TriggeredEvent;

var array<X2Condition> AbilityTargetConditions;
var array<X2Condition> AbilityShooterConditions;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'Assassin', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);

	ListenerObj = EffectGameState;
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', AssassinListener, ELD_OnStateSubmitted, , UnitState);	
}

function static EventListenerReturn AssassinListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit, TargetUnit;
	local XComGameState_Effect EffectState;
	local X2EventManager EventMgr;
	local X2Effect_Assassin AssassinEffect;

	SourceUnit = XComGameState_Unit(EventSource);
	if (SourceUnit == none)
		return ELR_NoInterrupt;

	EffectState = SourceUnit.GetUnitAffectedByEffectState(default.EffectName);
	if (EffectState == none)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(EventData);
	if (AbilityState == none)
		return ELR_NoInterrupt;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return ELR_NoInterrupt;

	TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if (TargetUnit == none || TargetUnit.ObjectID == SourceUnit.ObjectID)
		return ELR_NoInterrupt;

	AssassinEffect = X2Effect_Assassin(EffectState.GetX2Effect());
	if (AssassinEffect == none)
		return ELR_NoInterrupt;

	if (AssassinEffect.ValidateAttack(EffectState, SourceUnit, TargetUnit, AbilityState) != 'AA_Success')
		return ELR_NoInterrupt;

	EventMgr = `XEVENTMGR;
	EventMgr.TriggerEvent(AssassinEffect.TriggeredEvent, AbilityState, SourceUnit, GameState);

	return ELR_NoInterrupt;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local name AvailableCode;

	if (bRequireAbilityWeapon && AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
		return 'AA_UnknownError';

	if (bRequireKill && (Target == none || !Target.IsDead()))
		return 'AA_UnitIsAlive';

	foreach AbilityTargetConditions(kCondition)
	{
		AvailableCode = kCondition.AbilityMeetsCondition(AbilityState, Target);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;

		AvailableCode = kCondition.MeetsCondition(Target);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
		
		AvailableCode = kCondition.MeetsConditionWithSource(Target, Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	foreach AbilityShooterConditions(kCondition)
	{
		AvailableCode = kCondition.MeetsCondition(Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	return 'AA_Success';
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "Assassin"
	TriggeredEvent = "Assassin"
}