class X2Effect_Assassin extends X2Effect_Persistent;

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
	local GameRulesCache_VisibilityInfo VisInfo;

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

	// Match the weapon associated with Assassin to the attacking weapon
	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		//  check for a direct kill shot
		TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

		if (TargetUnit != none && TargetUnit.IsDead())
		{
			if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(SourceUnit.ObjectID, TargetUnit.ObjectID, VisInfo))
			{
				if (VisInfo.TargetCover == CT_None)
				{
					EventMgr = `XEVENTMGR;
					EventMgr.TriggerEvent('Assassin', AbilityState, SourceUnit, GameState);
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "Assassin"
}