class X2TacticalGameRuleset_XModBase extends X2TacticalGameRuleset;

// This function is called when setting up a new unit to add bonus item charges from any 
// X2Effect_BonusItemCharges effects the unit has. At this point in setting up a unit, begins-play
// abilities haven't triggered yet (because abilities are still being set up!), so there are no
// actual effects to look through. Instead, we look through the abilities directly to find any
// with the appropriate effects.
simulated function AddBonusItemCharges(XComGameState NewGameState, XComGameState_Unit NewUnit, out array<AbilitySetupData> AbilityData)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2Effect Effect;
	local X2Effect_BonusItemCharges AmmoEffect;
	local XComGameState_Item ItemIter;
	local int i, j;

	// Add bonus item charges from any X2Effect_BonusItemCharges
	for (i = 0; i < AbilityData.Length; ++i)
	{
		AbilityTemplate = AbilityData[i].Template;
		if (!AbilityTemplate.AbilityTargetStyle.IsA('X2AbilityTarget_Self'))
			continue;

		foreach AbilityTemplate.AbilityTargetEffects(Effect)
		{
			AmmoEffect = X2Effect_BonusItemCharges(Effect);

			if (AmmoEffect != none)
			{
				for (j = 0; j < NewUnit.InventoryItems.Length; ++j)
				{
					ItemIter = XComGameState_Item(NewGameState.GetGameStateForObjectID(NewUnit.InventoryItems[j].ObjectID));
					if (ItemIter != none && !ItemIter.bMergedOut)
					{
						ItemIter.Ammo += AmmoEffect.GetItemChargeModifier(NewGameState, NewUnit, ItemIter);
					}
				}
			}
		}
	}
}

// This overrides InitializeUnitAbilities in order to add calls to the two functions above.
simulated function InitializeUnitAbilities(XComGameState NewGameState, XComGameState_Unit NewUnit)
{		
	local XComGameState_Player kPlayer;
	local int i;
	local array<AbilitySetupData> AbilityData;
	local bool bIsMultiplayer;
	local X2AbilityTemplate AbilityTemplate;

	`assert(NewGameState != none);
	`assert(NewUnit != None);

	bIsMultiplayer = class'Engine'.static.GetEngine().IsMultiPlayerGame();

	kPlayer = XComGameState_Player(CachedHistory.GetGameStateForObjectID(NewUnit.ControllingPlayer.ObjectID));			
	AbilityData = NewUnit.GatherUnitAbilitiesForInit(NewGameState, kPlayer);

	AddBonusItemCharges(NewGameState, NewUnit, AbilityData);

	for (i = 0; i < AbilityData.Length; ++i)
	{
		AbilityTemplate = AbilityData[i].Template;

		if( !AbilityTemplate.IsTemplateAvailableToAnyArea(AbilityTemplate.BITFIELD_GAMEAREA_Tactical) )
		{
			`log(`location @ "WARNING!! Ability:"@ AbilityTemplate.DataName@" is not available in tactical!");
		}
		else if( bIsMultiplayer && !AbilityTemplate.IsTemplateAvailableToAnyArea(AbilityTemplate.BITFIELD_GAMEAREA_Multiplayer) )
		{
			`log(`location @ "WARNING!! Ability:"@ AbilityTemplate.DataName@" is not available in multiplayer!");
		}
		else
		{
			InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, AbilityData[i].SourceWeaponRef, AbilityData[i].SourceAmmoRef);
		}
	}
}
