class X2AbilityToHitCalc_UseSavedHitResult extends X2AbilityToHitCalc;

function RollForAbilityHit(XComGameState_Ability kAbility, AvailableTarget kTarget, out AbilityResultContext ResultContext)
{
	local UnitValue HitResultUnitValue, CalculatedHitChanceUnitValue;
	local XComGameState_Unit UnitState, TargetState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	TargetState = XComGameState_Unit(History.GetGameStateForObjectID(kTarget.PrimaryTarget.ObjectID));

	UnitState.GetUnitValue(class'X2Effect_SaveHitResult'.default.HitResultValueName, HitResultUnitValue);
	ResultContext.HitResult = EAbilityHitResult(HitResultUnitValue.fValue);

	UnitState.GetUnitValue(class'X2Effect_SaveHitResult'.default.CalculatedHitChanceValueName, CalculatedHitChanceUnitValue);
	ResultContext.CalculatedHitChance = CalculatedHitChanceUnitValue.fValue;

	class'X2AbilityArmorHitRolls'.static.RollArmorMitigation(m_ShotBreakdown.ArmorMitigation, ResultContext.ArmorMitigation, TargetState);
}