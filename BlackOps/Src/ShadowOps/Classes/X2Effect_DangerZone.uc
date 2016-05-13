class X2Effect_DangerZone extends X2Effect_BonusRadius;

var float fBreachBonusRadius;

simulated function float GetRadiusModifier(const XComGameState_Ability Ability, const XComGameState_Unit SourceUnit, float fBaseRadius)
{
	if (Ability.GetMyTemplateName() == 'breach')
		return fBreachBonusRadius;

	return fBonusRadius;
}

defaultproperties
{
	EffectName = "DangerZone";
}