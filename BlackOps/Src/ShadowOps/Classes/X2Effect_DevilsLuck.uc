class X2Effect_DevilsLuck extends XMBEffect_Extended;

function bool ChangeHitResultForTarget(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult) 
{ 
	local UnitValue DevilsLuckUsedValue;
	TargetUnit.GetUnitValue('DevilsLuckUsed', DevilsLuckUsedValue);

	if (DevilsLuckUsedValue.fValue < 1 && class'XComGameStateContext_Ability'.static.IsHitResultHit(CurrentResult))
	{
		NewHitResult = eHit_Untouchable;
		return true;
	}
	return false; 
}
