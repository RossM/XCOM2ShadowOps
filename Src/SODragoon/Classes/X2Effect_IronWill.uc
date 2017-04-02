class X2Effect_IronWill extends X2Effect_PersistentStatChange;

var name UnitValueName;

function bool PreDeathCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	local UnitValue Value;

	if (UnitState.GetUnitValue(UnitValueName, Value))
	{
		if (Value.fValue > 0)
			return false;
	}

	UnitState.SetUnitFloatValue(UnitValueName, 1, eCleanup_BeginTactical);

	return ApplyBleedingOut(UnitState, NewGameState);
}

static function bool ApplyBleedingOut(XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local EffectAppliedData ApplyData;
	local X2Effect BleedOutEffect;
	local string LogMsg;

	if (NewGameState != none)
	{
		BleedOutEffect = class'X2StatusEffects'.static.CreateBleedingOutStatusEffect();
		ApplyData.PlayerStateObjectRef = UnitState.ControllingPlayer;
		ApplyData.SourceStateObjectRef = UnitState.GetReference();
		ApplyData.TargetStateObjectRef = UnitState.GetReference();
		ApplyData.EffectRef.LookupType = TELT_BleedOutEffect;
		if (BleedOutEffect.ApplyEffect(ApplyData, UnitState, NewGameState) == 'AA_Success')
		{
			UnitState.LowestHP = 1; // makes wound times correct if unit is bleeding out
			LogMsg = class'XLocalizedData'.default.BleedingOutLogMsg;
			LogMsg = repl(LogMsg, "#Unit", UnitState.GetName(eNameType_RankFull));
			`COMBATLOG(LogMsg);
			return true;
		}
	}
	return false;
}


defaultproperties
{
	UnitValueName = "IronWillBleed"
}