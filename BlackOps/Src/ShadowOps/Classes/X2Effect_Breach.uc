class X2Effect_Breach extends X2Effect_ApplyWeaponDamage
	config(GameData_SoldierSkills);

var config WeaponDamageValue ConventionalDamageValue, MagneticDamageValue, BeamDamageValue;

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local WeaponDamageValue DamageValue;
	local X2WeaponTemplate WeaponTemplate;
	local XComGameState_Unit SourceUnit;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	DamageValue = default.ConventionalDamageValue;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	if ((SourceWeapon != none) &&
		(SourceUnit != none))
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate != none)
		{
			if (WeaponTemplate.WeaponTech == 'magnetic')
				DamageValue = default.MagneticDamageValue;
			else if (WeaponTemplate.WeaponTech == 'beam')
				DamageValue = default.BeamDamageValue;
		}
	}

	return DamageValue;
}
