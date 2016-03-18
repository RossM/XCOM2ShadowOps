class UIArmory_Promotion_BO extends UIArmory_Promotion;

// Modified for Deep Pockets and to make AWC retroactive
simulated function array<name> AwardAWCAbilities()
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<name> AWCAbilityNames;
	local X2AbilityTemplate AbilityTemplate;
	local int idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Unlock AWC Abilities");
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitReference.ObjectID));
	NewGameState.AddStateObject(UnitState);

	if(XComHQ.HasFacilityByName('AdvancedWarfareCenter'))
	{
		// if you have the AWC, and have reached the rank for one of your hidden abilities, unlock it
		for(idx = 0; idx < UnitState.AWCAbilities.Length; idx++)
		{
			if(!UnitState.AWCAbilities[idx].bUnlocked && UnitState.AWCAbilities[idx].iRank >= UnitState.GetRank())
			{
				UnitState.AWCAbilities[idx].bUnlocked = true;
				AWCAbilityNames.AddItem(UnitState.AWCAbilities[idx].AbilityType.AbilityName);

				AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(UnitState.AWCAbilities[idx].AbilityType.AbilityName);
				if (AbilityTemplate != none && AbilityTemplate.SoldierAbilityPurchasedFn != none)
					AbilityTemplate.SoldierAbilityPurchasedFn(NewGameState, UnitState);			}
		}
	}
	else
	{
		// if you don't have the AWC, remove any AWC abilities that haven't been unlocked
		for(idx = 0; idx < UnitState.AWCAbilities.Length; idx++)
		{
			if(!UnitState.AWCAbilities[idx].bUnlocked)
			{
				UnitState.AWCAbilities.Remove(idx, 1);
				idx--;
			}
		}

		// if the unit has no AWC abilities, mark them as eligible to roll again if another AWC is built
		if(UnitState.AWCAbilities.Length == 0)
		{
			UnitState.bRolledForAWCAbility = false;
		}
	}

	`GAMERULES.SubmitGameState(NewGameState);

	return AWCAbilityNames;
}
