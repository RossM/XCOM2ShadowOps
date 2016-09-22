class X2Effect_SensorOverlays extends XMBEffect_ConditionalBonus;

function protected name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, bool bAsTarget = false)
{
	local XComGameStateHistory History;
	local XComGameState_Unit SourceUnit;
	local name AvailableCode;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (!bAsTarget)
	{
		AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditions, EffectState, SourceUnit, Target, AbilityState);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
		
		AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditions, EffectState, SourceUnit, Target, AbilityState);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}
	else
	{
		AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditionsAsTarget, EffectState, Attacker, SourceUnit, AbilityState);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
		
		AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditionsAsTarget, EffectState, Attacker, SourceUnit, AbilityState);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}
		
	return 'AA_Success';
}
