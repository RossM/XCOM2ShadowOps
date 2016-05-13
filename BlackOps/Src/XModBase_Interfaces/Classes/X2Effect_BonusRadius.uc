class X2Effect_BonusRadius extends X2Effect_Persistent;

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

defaultproperties
{
	EffectName = "BonusRadius";
}