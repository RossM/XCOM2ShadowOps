class X2Condition_ControlledDetonation extends X2Condition;

// This condition is added to the ThrowGrenade/LaunchGrenade abilities.
// It returns failure if the grenade is thrown by a unit with Controlled
// Detonation, and targeting an ally. Otherwise it returns success.

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameStateHistory History;
	local XComGameState_Unit SourceUnit;
	local XComGameState_Item SourceWeapon, SourceAmmo;
	local X2GrenadeTemplate GrenadeTemplate;
	local array<X2Effect> GrenadeEffects;
	local X2Effect Effect;
	local bool bDamaging;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

	if (SourceUnit == none)
		return 'AA_Success';

	if (!SourceUnit.HasSoldierAbility('ShadowOps_ControlledDetonation'))
		return 'AA_Success';

	if (!SourceUnit.TargetIsAlly(kTarget.ObjectID))
		return 'AA_Success';

	SourceWeapon = kAbility.GetSourceWeapon();
	SourceAmmo = kAbility.GetSourceAmmo();

	if (SourceWeapon != none && SourceWeapon.GetMyTemplate().IsA('X2GrenadeTemplate'))
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());
		GrenadeEffects = GrenadeTemplate.ThrownGrenadeEffects;
	}
	else if (SourceAmmo != none && SourceAmmo.GetMyTemplate().IsA('X2GrenadeTemplate'))
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceAmmo.GetMyTemplate());
		GrenadeEffects = GrenadeTemplate.LaunchedGrenadeEffects;
	}

	if (GrenadeTemplate == none)
		return 'AA_Success';

	foreach GrenadeEffects(Effect)
	{
		if (Effect.IsA('X2Effect_ApplyWeaponDamage'))
		{
			bDamaging = true;
			break;
		}
	}

	if (!bDamaging)
		return 'AA_Success';

	return 'AA_UnitIsImmune';
}
