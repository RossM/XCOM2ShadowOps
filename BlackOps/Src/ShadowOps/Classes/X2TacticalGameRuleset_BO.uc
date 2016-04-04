class X2TacticalGameRuleset_BO extends X2TacticalGameRuleset;

// Modified for Rocketeer and Packmaster abilities
simulated function InitializeUnitAbilities(XComGameState NewGameState, XComGameState_Unit NewUnit)
{		
	local XComGameState_Player kPlayer;
	local int i;
	local array<AbilitySetupData> AbilityData;
	local bool bIsMultiplayer;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Item ItemIter;
	local bool bRocketeer, bPackmaster;

	`assert(NewGameState != none);
	`assert(NewUnit != None);

	bIsMultiplayer = class'Engine'.static.GetEngine().IsMultiPlayerGame();

	kPlayer = XComGameState_Player(CachedHistory.GetGameStateForObjectID(NewUnit.ControllingPlayer.ObjectID));			
	AbilityData = NewUnit.GatherUnitAbilitiesForInit(NewGameState, kPlayer);

	bRocketeer = NewUnit.HasSoldierAbility('Rocketeer');
	bPackmaster = NewUnit.HasSoldierAbility('Packmaster');

	for (i = 0; i < NewUnit.InventoryItems.Length; ++i)
	{
		ItemIter = XComGameState_Item(NewGameState.GetGameStateForObjectID(NewUnit.InventoryItems[i].ObjectID));
		if (ItemIter != none && !ItemIter.bMergedOut)
		{
			if (bRocketeer && ItemIter.InventorySlot == eInvSlot_HeavyWeapon)
				ItemIter.Ammo += ItemIter.MergedItemCount;
			if (bPackmaster && (ItemIter.InventorySlot == eInvSlot_Utility || ItemIter.InventorySlot == eInvSlot_GrenadePocket))
				ItemIter.Ammo += ItemIter.MergedItemCount;
		}			
	}

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
