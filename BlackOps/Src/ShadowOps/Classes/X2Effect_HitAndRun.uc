class X2Effect_HitAndRun extends X2Effect_Persistent config(GameData_SoldierSkills);

var config array<name> ExcludedAbilities;

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

function bool IsDashMovement(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit)
{
	local int i, iPointsToTake, PathIndex, FarthestTile;

	if (AbilityContext.InputContext.MovementPaths.Length == 0)
		return false;

	PathIndex = AbilityContext.GetMovePathIndex(SourceUnit.ObjectID);
	iPointsToTake = 1;
			
	for(i = AbilityContext.InputContext.MovementPaths[PathIndex].MovementTiles.Length - 1; i >= 0; --i)
	{
		if(AbilityContext.InputContext.MovementPaths[PathIndex].MovementTiles[i] == SourceUnit.TileLocation)
		{
			FarthestTile = i;
			break;
		}
	}
	for (i = 0; i < AbilityContext.InputContext.MovementPaths[PathIndex].CostIncreases.Length; ++i)
	{
		if (AbilityContext.InputContext.MovementPaths[PathIndex].CostIncreases[i] <= FarthestTile)
			iPointsToTake++;
	}

	return iPointsToTake >= 2;
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate Ability;
	local X2AbilityCost Cost;
	local X2AbilityCost_ActionPoints ActionPointCost;

	if (PreCostActionPoints.Length >= 2 && SourceUnit.ActionPoints.Length == 0 && SourceUnit.ReserveActionPoints.Length == 0)
	{
		if (IsDashMovement(AbilityContext, kAbility, SourceUnit))
			return false;

		Ability = kAbility.GetMyTemplate();

		// Exclude certain abilities
		if (default.ExcludedAbilities.Find(Ability.DataName) != INDEX_NONE)
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