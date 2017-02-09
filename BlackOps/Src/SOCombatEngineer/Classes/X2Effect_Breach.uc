class X2Effect_Breach extends X2Effect_ApplyWeaponDamage implements(XMBEffectInterface)
	config(GameData_SoldierSkills);

struct ExtWeaponDamageValue
{
	var WeaponDamageValue DamageValue;
	var name WeaponTech;
};

var config array<ExtWeaponDamageValue> DamageModifiers;

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local WeaponDamageValue DamageValue;
	local X2WeaponTemplate WeaponTemplate;
	local XComGameState_Unit SourceUnit;
	local XComGameStateHistory History;
	local int index;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	if ((SourceWeapon != none) &&
		(SourceUnit != none))
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate != none)
		{
			index = DamageModifiers.Find('WeaponTech', WeaponTemplate.WeaponTech);
			if (index != INDEX_NONE)
				DamageValue = DamageModifiers[index].DamageValue;
		}
	}

	return DamageValue;
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local XComGameState_Item SourceItem;
	local X2WeaponTemplate WeaponTemplate;
	local int index;

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
				index = DamageModifiers.Find('WeaponTech', WeaponTemplate.WeaponTech);
				if (index != INDEX_NONE)
					TagValue = string(DamageModifiers[index].DamageValue.Shred);
				return true;
			}
		}
		TagValue = string(DamageModifiers[0].DamageValue.Shred);
		return true;
	}

	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }
