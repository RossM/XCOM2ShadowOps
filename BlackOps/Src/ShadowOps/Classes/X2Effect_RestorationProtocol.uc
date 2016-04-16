class X2Effect_RestorationProtocol extends X2Effect_Regeneration;

var name IncreasedHealProject;
var int IncreasedAmountToHeal;
var int HealingBonusMultiplier;

function bool RegenerationTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit OldTargetState, NewTargetState;
	local UnitValue HealthRegenerated;
	local int AmountToHeal, Healed;
	local int ModifiedHealAmount, ModifiedMaxHealAmount;
	local XComGameState_Ability Ability;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState_Item ItemState;
	local X2GremlinTemplate GremlinTemplate;
	
	History = `XCOMHISTORY;
	Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (Ability == none)
		Ability = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	OldTargetState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	ModifiedHealAmount = HealAmount;
	ModifiedMaxHealAmount = MaxHealAmount;

	if (Ability != none)
	{
		if (IncreasedHealProject != '')
		{
			XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
			if (XComHQ != None && XComHQ.IsTechResearched(IncreasedHealProject))
				ModifiedHealAmount = IncreasedAmountToHeal;
		}

		ItemState = Ability.GetSourceWeapon();
		if (ItemState != none)
		{
			GremlinTemplate = X2GremlinTemplate(ItemState.GetMyTemplate());
			if (GremlinTemplate != none)
				ModifiedMaxHealAmount += GremlinTemplate.HealingBonus * HealingBonusMultiplier;
		}
	}

	if (HealthRegeneratedName != '' && MaxHealAmount > 0)
	{
		OldTargetState.GetUnitValue(HealthRegeneratedName, HealthRegenerated);

		// If the unit has already been healed the maximum number of times, do not regen
		if (HealthRegenerated.fValue >= ModifiedMaxHealAmount)
		{
			return false;
		}
		else
		{
			// Ensure the unit is not healed for more than the maximum allowed amount
			AmountToHeal = min(ModifiedHealAmount, (ModifiedMaxHealAmount - HealthRegenerated.fValue));
		}
	}
	else
	{
		// If no value tracking for health regenerated is set, heal for the default amount
		AmountToHeal = ModifiedHealAmount;
	}	

	// Perform the heal
	NewTargetState = XComGameState_Unit(NewGameState.CreateStateObject(OldTargetState.Class, OldTargetState.ObjectID));
	NewTargetState.ModifyCurrentStat(estat_HP, AmountToHeal);
	NewGameState.AddStateObject(NewTargetState);

	if (EventToTriggerOnHeal != '')
	{
		`XEVENTMGR.TriggerEvent(EventToTriggerOnHeal, NewTargetState, NewTargetState, NewGameState);
	}

	// If this health regen is being tracked, save how much the unit was healed
	if (HealthRegeneratedName != '')
	{
		Healed = NewTargetState.GetCurrentStat(eStat_HP) - OldTargetState.GetCurrentStat(eStat_HP);
		if (Healed > 0)
		{
			NewTargetState.SetUnitFloatValue(HealthRegeneratedName, HealthRegenerated.fValue + Healed, eCleanup_BeginTactical);
		}
	}

	return false;
}

defaultproperties
{
	HealthRegeneratedName = "RestorationProtocolHealthRegenerated";
}