class UIPersonnel_BO extends UIPersonnel;

// Modified to use subclass names
simulated function int SortByClass(StateObjectReference A, StateObjectReference B)
{
	local XComGameState_Unit UnitA, UnitB;
	local string NameA, NameB;

	UnitA = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(A.ObjectID));
	UnitB = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(B.ObjectID));

	NameA = UnitA.GetSoldierClassDisplayName();
	NameB = UnitB.GetSoldierClassDisplayName();

	if( NameA < NameB )
	{
		return m_bFlipSort ? -1 : 1;
	}
	else if( NameA > NameB )
	{
		return m_bFlipSort ? 1 : -1;
	}
	return 0;
}
