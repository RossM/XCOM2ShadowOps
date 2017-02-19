// LWS : Extending to allow additional weapon techs to be defined via config

class X2Effect_Shredder extends X2Effect_ApplyWeaponDamage
	config(GameData_SoldierSkills);

//LWS : Added new struct and dynamic array to hold new weapon techs
struct TechToShredAmount
{
	var name WeaponTechName;
	var int ShredAmount;
};
var config array<TechToShredAmount> ShredAmounts;

var config int ConventionalShred, MagneticShred, BeamShred;

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local WeaponDamageValue ShredValue;
	local X2WeaponTemplate WeaponTemplate;
	local XComGameState_Unit SourceUnit;
	local XComGameStateHistory History;
	local int idx; // LWS Added

	History = `XCOMHISTORY;

	ShredValue = EffectDamageValue;             //  in case someone has set other fields in here, but not likely

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	if ((SourceWeapon != none) &&
		(SourceUnit != none) &&
		SourceUnit.HasSoldierAbility('Shredder'))
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate != none)
		{
			// LWS: new section that returns if it find a value in the new array, otherwise it uses the base-game 3 values
			idx = default.ShredAmounts.Find('WeaponTechName', WeaponTemplate.WeaponTech);
			if (idx != -1)
			{
				ShredValue.Shred = default.ShredAmounts[idx].ShredAmount;
				return ShredValue;
			}
			ShredValue.Shred = default.ConventionalShred;

			if (WeaponTemplate.WeaponTech == 'magnetic')
				ShredValue.Shred = default.MagneticShred;
			else if (WeaponTemplate.WeaponTech == 'beam')
				ShredValue.Shred = default.BeamShred;
		}
	}

	return ShredValue;
}

DefaultProperties
{
	bAllowFreeKill=true
	bIgnoreBaseDamage=false
}