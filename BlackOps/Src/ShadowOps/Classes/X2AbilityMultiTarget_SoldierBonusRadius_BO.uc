class X2AbilityMultiTarget_SoldierBonusRadius_BO extends X2AbilityMultiTarget_SoldierBonusRadius;

var float fRadiusModifier;

// Calculate ability-specific radius modifiers.
simulated function CalculateRadiusModifier(const XComGameState_Ability Ability)
{
	local XComGameState_Unit SourceUnit;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local X2Effect_BonusRadius BonusRadiusEffect;
	local XComGameStateHistory History;

	fRadiusModifier = 0;

	History = `XCOMHISTORY;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

	foreach SourceUnit.AffectedByEffects(EffectRef)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		BonusRadiusEffect = X2Effect_BonusRadius(EffectState.GetX2Effect());
		if (BonusRadiusEffect != none)
		{
			fRadiusModifier += BonusRadiusEffect.GetRadiusModifier(Ability, SourceUnit, fTargetRadius);
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
