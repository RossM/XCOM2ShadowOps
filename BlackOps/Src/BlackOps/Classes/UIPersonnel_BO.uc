class UIPersonnel_BO extends UIPersonnel;

// Modified to use subclass names
simulated function int SortByClass(StateObjectReference A, StateObjectReference B)
{
	local XComGameState_Unit UnitA, UnitB;
	local string NameA, NameB, SubNameA, SubNameB;

	UnitA = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(A.ObjectID));
	UnitB = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(B.ObjectID));

	NameA = UnitA.GetSoldierClassTemplate().DisplayName;
	NameB = UnitB.GetSoldierClassTemplate().DisplayName;
	
	SubNameA = UnitA.GetSoldierClassDisplayName();
	SubNameB = UnitB.GetSoldierClassDisplayName();

	if( NameA < NameB )
	{
		return m_bFlipSort ? -1 : 1;
	}
	else if( NameA > NameB )
	{
		return m_bFlipSort ? 1 : -1;
	}
	if( SubNameA < SubNameB )
	{
		return m_bFlipSort ? -1 : 1;
	}
	else if( SubNameA > SubNameB )
	{
		return m_bFlipSort ? 1 : -1;
	}
	return 0;
}
