//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_AbilityTriggered.uc
//  AUTHOR:  xylthixlm
//
//  A persistent effect which triggers an event whenever the unit uses an ability
//  meeting certain conditions. This is more flexible than setting an ability trigger on
//  'AbilityActivated' directly because it lets you check the properties of the ability
//  used, such as with XMBCondition_ReactionFire, and lets you check the properties of
//  the target even when the ability to be triggered is self-targeting.
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBEffect_AbilityTriggered extends X2Effect_Persistent;

var bool bRequireAbilityWeapon;
var name TriggeredEvent;

var array<X2Condition> AbilityTargetConditions;
var array<X2Condition> AbilityShooterConditions;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object ListenerObj;
	local XComGameState_Unit UnitState;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	ListenerObj = UnitState;
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', AbilityActivatedListener, ELD_OnStateSubmitted,, UnitState);	
}

function static EventListenerReturn AbilityActivatedListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit, TargetUnit;
	local XComGameState_Effect EffectState;
	local X2EventManager EventMgr;
	local StateObjectReference EffectRef;
	local XComGameStateHistory History;
	local XMBEffect_AbilityTriggered AbilityTriggeredEffect;

	History = `XCOMHISTORY;
	EventMgr = `XEVENTMGR;

	SourceUnit = XComGameState_Unit(EventSource);
	if (SourceUnit == none)
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

	foreach SourceUnit.AffectedByEffects(EffectRef)
	{
		EffectState = XComGameState_Effect(GameState.GetGameStateForObjectId(EffectRef.ObjectID));
		if (EffectState == none)
			EffectState = XComGameState_Effect(History.GetGameStateForObjectId(EffectRef.ObjectID));
		
		AbilityTriggeredEffect = XMBEffect_AbilityTriggered(EffectState.GetX2Effect());

		if (AbilityTriggeredEffect != none)
		{
			if (AbilityTriggeredEffect.ValidateAttack(EffectState, SourceUnit, TargetUnit, AbilityState) == 'AA_Success')
			{
				EventMgr.TriggerEvent(AbilityTriggeredEffect.TriggeredEvent, AbilityState, SourceUnit, GameState);
			}
		}
	}

	return ELR_NoInterrupt;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	if (bRequireAbilityWeapon)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon == none)
			return 'AA_UnknownError';

		ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
		if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
			return 'AA_UnknownError';
	}

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
	TriggeredEvent = "XMBAbilityTrigger"
}