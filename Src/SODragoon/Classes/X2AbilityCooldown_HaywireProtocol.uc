class X2AbilityCooldown_HaywireProtocol extends X2AbilityCooldown;

simulated function int GetNumTurns(XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	if (XComGameState_Unit(AffectState).HasSoldierAbility('ShadowOps_Puppeteer'))
		return 0;	

	return iNumTurns;
}
