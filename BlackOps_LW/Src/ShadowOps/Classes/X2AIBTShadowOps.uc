class X2AIBTShadowOps extends X2AIBTDefaultActions;

static event bool FindBTActionDelegate(name strName, optional out delegate<BTActionDelegate> dOutFn, optional out name NameParam, optional out name MoveProfile)
{
	switch( strName )
	{
		case 'SetDestinationFromAlertData':
			dOutFn = SetDestinationFromAlertData;
		return true;
		default:
			`WARN("Unresolved behavior tree Action name with no delegate definition:"@strName);
		break;
	}

	return false;
}

function bt_status SetDestinationFromAlertData()
{
	local vector vDest;

	if (m_kBehavior.m_bAlertDataMovementDestinationSet)
	{
		vDest = m_kBehavior.m_vAlertDataMovementDestination;

		// Always use cover
		m_kBehavior.GetClosestCoverLocation(vDest, vDest, false, true);

		m_kBehavior.m_vBTDestination = vDest;
		m_kBehavior.m_bBTDestinationSet = m_kBehavior.m_bAlertDataMovementDestinationSet;
	}

	return BTS_SUCCESS;
}
