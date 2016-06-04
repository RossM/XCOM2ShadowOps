class X2Effect_ZeroIn extends X2Effect_Persistent implements(XMBEffectInterface);

var int AccuracyBonus;
var name ZeroInUnitValueName;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMan;
	local XComGameState_Unit UnitState;
	local Object ListenerObj;

	ListenerObj = EffectGameState;

	EventMan = `XEVENTMGR;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMan.RegisterForEvent(ListenerObj, 'AbilityActivated', ZeroInListener, ELD_OnStateSubmitted, , UnitState);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo AccuracyInfo;
	
	if (AbilityState != none && AbilityState.IsAbilityInputTriggered() && AbilityState.GetMyTemplate().Hostility == eHostility_Offensive)
	{
		// We (ab)use iStacks to indicate whether the last attack hit or missed.
		if (EffectState.iStacks > 0)
		{
			AccuracyInfo.ModType = eHit_Success;
			AccuracyInfo.Value = AccuracyBonus * EffectState.iStacks;
			AccuracyInfo.Reason = FriendlyName;
			ShotModifiers.AddItem(AccuracyInfo);
		}
	}
}

function static EventListenerReturn ZeroInListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectState, NewEffectState;
	local XComGameState NewGameState;

	UnitState = XComGameState_Unit(EventSource);
	if (UnitState == none)
		return ELR_NoInterrupt;

	EffectState = UnitState.GetUnitApplyingEffectState(default.EffectName);
	if (EffectState == none)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(EventData);
	if (AbilityState != none && AbilityState.IsAbilityInputTriggered() && AbilityState.GetMyTemplate().Hostility == eHostility_Offensive)
	{
		AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
		if (AbilityContext != none)
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
			NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(class'XComGameState_Effect', EffectState.ObjectID));
			if (class'XComGameStateContext_Ability'.static.IsHitResultHit(AbilityContext.ResultContext.HitResult))
				NewEffectState.iStacks = 0;
			else
				NewEffectState.iStacks = 1;
			NewGameState.AddStateObject(NewEffectState);
			`GAMERULES.SubmitGameState(NewGameState);
		}
	}

	return ELR_NoInterrupt;
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	switch (tag)
	{
	case 'ToHit':
		TagValue = string(AccuracyBonus);
		return true;
	}

	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }

DefaultProperties
{
	EffectName = "ZeroIn";
	ZeroInUnitValueName = "ZeroInBonus";
}

