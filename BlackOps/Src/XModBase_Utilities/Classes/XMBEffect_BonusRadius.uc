class XMBEffect_BonusRadius extends X2Effect_Persistent implements(XMBEffectInterface);

var float fBonusRadius;					// Amount to increase the radius, in meters. One tile equals 1.5 meters.
var array<name> AllowedTemplateNames;	// Ammo types (grenades) which the bonus will apply to. If empty, it applies to everything.

// This effect increases the radius of any effect using X2AbilityMultiTarget_SoldierBonusRadius, which in vanilla is only grenades.
//
// Note that the Ability passed in is the ability that the radius is being modified on, and NOT the ability that created this effect.
simulated function float GetRadiusModifier(const XComGameState_Ability Ability, const XComGameState_Unit SourceUnit, float fBaseRadius)
{
	local XComGameState_Item ItemState;

	if (AllowedTemplateNames.Length > 0)
	{
		ItemState = Ability.GetSourceAmmo();
		if (ItemState == none)
			ItemState = Ability.GetSourceWeapon();

		if (ItemState == none)
			return 0;

		if (AllowedTemplateNames.Find(ItemState.GetMyTemplateName()) == INDEX_NONE)
			return 0;
	}

	return fBonusRadius;
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }

function float GetExtValue(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, float fBaseValue)
{
	if (Type == 'BonusRadius')
		return GetRadiusModifier(AbilityState, Attacker, fBaseValue);

	return 0;
}

function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }

defaultproperties
{
	EffectName = "BonusRadius";
}