class X2Effect_ZeroIn extends X2Effect_Persistent;

var int AccuracyBonus;
var name ZeroInUnitValueName;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMan;
	local XComGameState_Unit UnitState;
	local Object ListenerObj;

	ListenerObj = self;

	EventMan = `XEVENTMGR;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMan.RegisterForEvent(ListenerObj, 'AbilityActivated', ZeroInListener, ELD_OnStateSubmitted, , UnitState);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local UnitValue AccuracyUnitValue;
	local ShotModifierInfo AccuracyInfo;
	local XComGameState_Unit SourceUnit;
	
	Attacker.GetUnitValue(ZeroInUnitValueName, AccuracyUnitValue);

	if (AccuracyUnitValue.fValue > 0)
	{
		AccuracyInfo.ModType = eHit_Success;
		AccuracyInfo.Value = AccuracyUnitValue.fValue;
		AccuracyInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(AccuracyInfo);
	}
}

function EventListenerReturn ZeroInListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectState;
	local int i;

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
			if (class'XComGameStateContext_Ability'.static.IsHitResultHit(AbilityContext.ResultContext.HitResult))
			{
				UnitState.SetUnitFloatValue(ZeroInUnitValueName, 0, eCleanup_BeginTactical);
			}
			else
			{
				UnitState.SetUnitFloatValue(ZeroInUnitValueName, AccuracyBonus, eCleanup_BeginTactical);
			}
		}
	}

	return ELR_NoInterrupt;
}

DefaultProperties
{
	EffectName = "ZeroIn";
	ZeroInUnitValueName = 'ZeroInBonus';
}

