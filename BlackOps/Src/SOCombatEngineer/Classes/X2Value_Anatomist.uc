class X2Value_Anatomist extends XMBValue;

function float GetValue(XComGameState_Effect EffectState, XComGameState_Unit UnitState, XComGameState_Unit TargetState, XComGameState_Ability AbilityState)
{
	local XComGameStateHistory History;
	local array<StateObjectReference> Kills;
	local StateObjectReference KillRef;
	local XComGameState_Unit KilledUnit;
	local int KilledEnemies;

	History = `XCOMHISTORY;

	Kills = UnitState.GetKills();
	foreach Kills(KillRef)
	{
		KilledUnit = XComGameState_Unit(History.GetGameStateForObjectID(KillRef.ObjectID));
		if (KilledUnit.GetMyTemplate().CharacterGroupName == TargetState.GetMyTemplate().CharacterGroupName)
			KilledEnemies++;
	}

	return KilledEnemies;
}