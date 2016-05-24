class EvilUnitStateHack extends XComGameState_Unit;

function static int NumKillsOfCharacterGroup(XComGameState_Unit Unit, name CharacterGroupName)
{
	local StateObjectReference KillRef;
	local XComGameStateHistory History;
	local XComGameState_Unit KilledUnit;
	local int Result;

	History = `XCOMHISTORY;

	foreach Unit.KilledUnits(KillRef)
	{
		KilledUnit = XComGameState_Unit(History.GetGameStateForObjectID(KillRef.ObjectID));
		if (KilledUnit.GetMyTemplate().CharacterGroupName == CharacterGroupName)
			Result++;
	}

	return Result;
}