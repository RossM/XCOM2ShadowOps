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
	m_kBehavior.m_vBTDestination = m_kBehavior.m_vAlertDataMovementDestination;
	m_kBehavior.m_bBTDestinationSet = m_kBehavior.m_bAlertDataMovementDestinationSet;

	return BTS_SUCCESS;
}
