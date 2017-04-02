class X2Effect_RestorationProtocol extends X2Effect_Regeneration implements(XMBEffectInterface);

var name IncreasedHealProject;
var int IncreasedAmountToHeal;
var int HealingBonusMultiplier;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	RegenerationTicked(self, ApplyEffectParameters, NewEffectState, NewGameState, true);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	super.AddX2ActionsForVisualization_Tick(VisualizeGameState, BuildTrack, 0, none);
}

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
	local name ModifiedHealthRegeneratedName;
	
	History = `XCOMHISTORY;
	Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (Ability == none)
		Ability = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	OldTargetState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// Don't affect dead units
	if (!OldTargetState.IsAlive())
		return false;

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
		ModifiedHealthRegeneratedName = name(HealthRegeneratedName $ kNewEffectState.ObjectID);

		OldTargetState.GetUnitValue(ModifiedHealthRegeneratedName, HealthRegenerated);

		// If the unit has already been healed the maximum number of times, do not regen
		if (HealthRegenerated.fValue >= ModifiedMaxHealAmount)
		{
			// Remove effect
			return true;
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
			NewTargetState.SetUnitFloatValue(ModifiedHealthRegeneratedName, HealthRegenerated.fValue + Healed, eCleanup_BeginTactical);
		}
	}

	return false;
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local XComGameState_Item SourceItem;
	local X2GremlinTemplate GremlinTemplate;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;

	if (AbilityState != none)
	{
		SourceItem = AbilityState.GetSourceWeapon();
	}

	History = `XCOMHISTORY;

	switch (tag)
	{
	case 'Heal':
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
		if (XComHQ != None && XComHQ.IsTechResearched(IncreasedHealProject))
			TagValue = string(IncreasedAmountToHeal);
		else
			TagValue = string(HealAmount);
		return true;

	case 'MaxHeal':
		if (SourceItem != none)
		{
			GremlinTemplate = X2GremlinTemplate(SourceItem.GetMyTemplate());
			if (GremlinTemplate != none)
			{
				TagValue = string(MaxHealAmount + GremlinTemplate.HealingBonus * HealingBonusMultiplier);
				return true;
			}
		}
		TagValue = MaxHealAmount$"/"$(MaxHealAmount + HealingBonusMultiplier)$"/"$(MaxHealAmount + 2 * HealingBonusMultiplier);
		return true;
	}
	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }

defaultproperties
{
	EffectName = "RestorationProtocol";
	HealthRegeneratedName = "RestorationProtocolHealthRegenerated";
}