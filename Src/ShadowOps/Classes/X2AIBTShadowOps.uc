class X2AIBTShadowOps extends X2AIBTDefaultActions;

static event bool FindBTActionDelegate(name strName, optional out delegate<BTActionDelegate> dOutFn, optional out name NameParam, optional out name MoveProfile)
{
	switch( strName )
	{
		case 'SetDestinationFromAlertData':
			dOutFn = SetDestinationFromAlertData;
		case 'SetDestinationForSonicBeacon':
			dOutFn = SetDestinationForSonicBeacon;
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

function bt_status SetDestinationForSonicBeacon()
{
	local vector vDest;
	local XComGameState_Effect EffectState;
	local XComGameStateHistory History;
	local int i;

	History = `XCOMHISTORY;

	i = m_kUnitState.AffectedByEffectNames.Find(class'X2Effect_SonicBeacon'.default.EffectName);
	if (i == INDEX_NONE)
		return BTS_FAILURE;

	EffectState = XComGameState_Effect(History.GetGameStateForObjectID(m_kUnitState.AffectedByEffects[i].ObjectID));
	vDest = EffectState.ApplyEffectParameters.AbilityInputContext.TargetLocations[0];

	m_kBehavior.m_vBTDestination = vDest;
	m_kBehavior.m_bBTDestinationSet = true;
	return BTS_SUCCESS;
}