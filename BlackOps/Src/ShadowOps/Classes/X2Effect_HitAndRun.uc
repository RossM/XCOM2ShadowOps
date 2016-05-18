class X2Effect_HitAndRun extends X2Effect_Persistent config(GameData_SoldierSkills);

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'HitAndRun', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate Ability;
	local X2AbilityCost Cost;
	local X2AbilityCost_ActionPoints ActionPointCost;

	if (PreCostActionPoints.Length >= 2 && SourceUnit.ActionPoints.Length == 0)
	{
		Ability = kAbility.GetMyTemplate();

		// Hunker is lost on moving, so don't give a move after hunkering
		if (Ability.DataName == 'HunkerDown')
			return false;

		// Don't allow suppressing units to move either
		if (SourceUnit.IsUnitApplyingEffectName('Suppression'))
			return false;

		foreach Ability.AbilityCosts(Cost)
		{
			ActionPointCost = X2AbilityCost_ActionPoints(Cost);
			if (ActionPointCost != none)
			{
				if (ActionPointCost.iNumPoints <= 1)
				{
					SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);

					AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
					`XEVENTMGR.TriggerEvent('HitAndRun', AbilityState, SourceUnit, NewGameState);

					return true;
				}
			}
		}
	}

	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "SlamFire"
}