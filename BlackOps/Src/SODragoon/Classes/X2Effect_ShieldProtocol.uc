class X2Effect_ShieldProtocol extends X2Effect_ModifyStats implements(XMBEffectInterface);

var int ConventionalAmount, MagneticAmount, BeamAmount;
var float AegisDamageReduction;
var array<name> ImmuneTypes;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent(EffectObj, 'ShieldsExpended', EffectGameState.OnShieldsExpended, ELD_OnStateSubmitted, , UnitState);

	// Register for the required events
	// When the Gremlin is recalled to its owner, if aid protocol is in effect, override and return to the unit receiving aid
	// (Priority 49, so this happens after the regular ItemRecalled)
	//EventMgr.RegisterForEvent(EffectObj, 'ItemRecalled', class'X2Effect_ShieldProtocol'.static.OnItemRecalled, ELD_OnStateSubmitted, 49);
}

function bool ProvidesDamageImmunity(XComGameState_Effect EffectState, name DamageType)
{
	return (ImmuneTypes.Find(DamageType) != INDEX_NONE);
}

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect)
{
	local XComGameStateHistory History;
	local XComGameState_Unit SourceUnit;
	local int DamageMod;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (SourceUnit != none && SourceUnit.HasSoldierAbility('ShadowOps_Aegis'))
	{
		DamageMod = -int(float(CurrentDamage) * AegisDamageReduction);
	}

	return DamageMod;
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Item SourceItem;
	local X2GremlinTemplate GremlinTemplate;
	local StatChange Change;

	Change.StatType = eStat_ShieldHP;
	Change.StatAmount = ConventionalAmount;

	SourceItem = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if (SourceItem == none)
		SourceItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));

	if (SourceItem != none)
	{
		GremlinTemplate = X2GremlinTemplate(SourceItem.GetMyTemplate());
		if (GremlinTemplate != none)
		{
			if (GremlinTemplate.WeaponTech == 'magnetic')
				Change.StatAmount = MagneticAmount;
			else if (GremlinTemplate.WeaponTech == 'beam')
				Change.StatAmount = BeamAmount;
		}
	}
	NewEffectState.StatChanges.AddItem(Change);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local XComGameState_Item SourceItem;
	local X2GremlinTemplate GremlinTemplate;

	if (AbilityState != none)
	{
		SourceItem = AbilityState.GetSourceWeapon();
	}

	switch (tag)
	{
	case 'Shield':
		if (SourceItem != none)
		{
			GremlinTemplate = X2GremlinTemplate(SourceItem.GetMyTemplate());
			if (GremlinTemplate != none)
			{
				TagValue = string(ConventionalAmount);
				if (GremlinTemplate.WeaponTech == 'magnetic')
					TagValue = string(MagneticAmount);
				else if (GremlinTemplate.WeaponTech == 'beam')
					TagValue = string(BeamAmount);
				return true;
			}
		}
		TagValue = ConventionalAmount$"/"$MagneticAmount$"/"$BeamAmount;
		return true;
	}

	return false;
}

function bool GetExtValue(LWTuple Tuple) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers) { return false; }

defaultproperties
{
	EffectName="ShieldProtocol"
	DuplicateResponse=eDupe_Refresh
}