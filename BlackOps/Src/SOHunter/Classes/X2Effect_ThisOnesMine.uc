class X2Effect_ThisOnesMine extends XMBEffect_ConditionalBonus;

var array<name> RequiredEffects;

function protected name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, bool bAsTarget = false)
{
	local XComGameState_Effect CheckEffectState;
	local XComGameState_Unit UnitState;
	local int i;

	if (bAsTarget)
		UnitState = Attacker;
	else
		UnitState = Target;

	`Log("X2Effect_ThisOnesMine ValidateAttack()");

	for (i = 0; i < UnitState.AffectedByEffects.Length; i++)
	{
		`Log("  EffectName:" @ UnitState.AffectedByEffectNames[i]);
		if (RequiredEffects.Find(UnitState.AffectedByEffectNames[i]) == INDEX_NONE)
			continue;

		CheckEffectState = XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(UnitState.AffectedByEffects[i].ObjectID));
		`Log("  SourceObjectID:" @ CheckEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
		if (CheckEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID == EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID)
			return 'AA_Success';
	}

	return 'AA_Immune';
}
