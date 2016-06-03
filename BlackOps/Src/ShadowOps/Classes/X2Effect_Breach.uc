class X2Effect_Breach extends X2Effect_ApplyWeaponDamage implements(XMBEffectInterface)
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

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local XComGameState_Item SourceItem;
	local X2WeaponTemplate WeaponTemplate;

	if (AbilityState != none)
	{
		SourceItem = AbilityState.GetSourceWeapon();
	}

	switch (tag)
	{
	case 'Shred':
		if (SourceItem != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceItem.GetMyTemplate());
			if (WeaponTemplate != none)
			{
				TagValue = string(ConventionalDamageValue.Shred);
				if (WeaponTemplate.WeaponTech == 'magnetic')
					TagValue = string(MagneticDamageValue.Shred);
				else if (WeaponTemplate.WeaponTech == 'beam')
					TagValue = string(BeamDamageValue.Shred);
				return true;
			}
		}
		TagValue = ConventionalDamageValue.Shred$"/"$MagneticDamageValue.Shred$"/"$BeamDamageValue.Shred;
		return true;
	}

	return false;
}

function float GetExtValue(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, float fBaseValue) { return 0; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }
