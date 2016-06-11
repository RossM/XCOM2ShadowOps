//---------------------------------------------------------------------------------------
//  FILE:    XMBCondition_AbilityCost.uc
//  AUTHOR:  xylthixlm
//
//  A condition that matches based on the action point cost of an ability and/or the
//  actual number of action points spent (including discounts, abilities that consume
//  all remaining points, etc).
//
//  USAGE
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBCondition_AbilityCost extends X2Condition;

var bool bRequireMinimumPointsSpent, bRequireMaximumPointsSpent;
var int MinimumPointsSpent, MaximumPointsSpent;
var bool bRequireMinimumCost, bRequireMaximumCost;
var int MinimumCost, MaximumCost;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState GameState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit, PrevSourceUnit;
	local XComGameStateHistory History;
	local X2AbilityTemplate Ability;
	local X2AbilityCost AbilityCost;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local int PointsSpent, Cost;
	local int i, MovementCost, PathIndex, FarthestTile;

	History = `XCOMHISTORY;

	GameState = kAbility.GetParentGameState();

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return 'AA_ValueCheckFailed';

	SourceUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	if (SourceUnit != none)
	{
		PrevSourceUnit = XComGameState_Unit(History.GetPreviousGameStateForObject(SourceUnit));

		PointsSpent = PrevSourceUnit.ActionPoints.Length - SourceUnit.ActionPoints.Length;

		Ability = kAbility.GetMyTemplate();

		foreach Ability.AbilityCosts(AbilityCost)
		{
			ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
			if (ActionPointCost != none)
			{
				if (ActionPointCost.bAddWeaponTypicalCost && kAbility.GetSourceWeapon() != none)
				{
					Cost = max(Cost, ActionPointCost.iNumPoints + X2WeaponTemplate(kAbility.GetSourceWeapon().GetMyTemplate()).iTypicalActionCost);
				}
				else
				{
					Cost = max(Cost, ActionPointCost.iNumPoints);
				}

				if (ActionPointCost.bMoveCost || ActionPointCost.bConsumeAllPoints)
				{
					Cost = max(Cost, 1);
				}
			}
		}

		// For movement effects, the actual cost depends on the path length.
		if (AbilityContext.InputContext.MovementPaths.Length > 0)
		{
			PathIndex = AbilityContext.GetMovePathIndex(SourceUnit.ObjectID);
			MovementCost = 1;
			
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
					MovementCost++;
			}

			Cost = max(Cost, MovementCost);
		}
	}

	`Log(kAbility.GetMyTemplateName() @ "Cost:" @ Cost @ "Spent:" @ PointsSpent);

	if (bRequireMinimumPointsSpent && PointsSpent < MinimumPointsSpent)
		return 'AA_ValueCheckFailed';
	if (bRequireMaximumPointsSpent && PointsSpent > MaximumPointsSpent)
		return 'AA_ValueCheckFailed';
	if (bRequireMinimumCost && Cost < MinimumCost)
		return 'AA_ValueCheckFailed';
	if (bRequireMaximumCost && Cost > MaximumCost)
		return 'AA_ValueCheckFailed';

	return 'AA_Success';
}