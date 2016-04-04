class X2AbilityMultiTarget_SoldierBonusRadius_BO extends X2AbilityMultiTarget_SoldierBonusRadius;

var float fRadiusModifier;

// Calculate ability-specific radius modifiers.
simulated function CalculateRadiusModifier(const XComGameState_Ability Ability)
{
	local XComGameState_Item ItemState;
	local X2GrenadeTemplate GrenadeTemplate;
	local XComGameState_Unit SourceUnit;

	fRadiusModifier = 0;

	SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

	if (SourceUnit != none && SourceUnit.HasSoldierAbility('DangerZone'))
	{
		fRadiusModifier += class'X2Ability_EngineerAbilitySet'.default.DangerZoneBonusRadius;
	}		

	if (SourceUnit != none && SourceUnit.HasSoldierAbility('DenseSmoke'))
	{
		ItemState = Ability.GetSourceAmmo();
		if (ItemState == none)
			ItemState = Ability.GetSourceWeapon();

		if (ItemState == none)
			return;

		GrenadeTemplate = X2GrenadeTemplate(ItemState.GetMyTemplate());
		if (GrenadeTemplate == none)
			return;

		if (GrenadeTemplate.DataName == 'SmokeGrenade' ||
			GrenadeTemplate.DataName == 'SmokeGrenadeMk2')
		{
			fRadiusModifier += class'X2Effect_SmokeGrenade_BO'.default.DenseSmokeBonusRadius;
		}
	}
}

// Modify radius to include ability-specific modifiers. Note that fTargetRadius applies to all uses of the ability
// template (e.g. launch grenade) so we have to restore it correctly. This is a terrible hack.
simulated function float GetTargetRadius(const XComGameState_Ability Ability)
{
	fTargetRadius -= fRadiusModifier;
	CalculateRadiusModifier(Ability);
	fTargetRadius += fRadiusModifier;

	return super.GetTargetRadius(Ability);
}
