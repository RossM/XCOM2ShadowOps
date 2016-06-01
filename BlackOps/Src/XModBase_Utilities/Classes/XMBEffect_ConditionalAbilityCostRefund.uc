class XMBEffect_ConditionalAbilityCostRefund extends X2Effect_Persistent config(GameData_SoldierSkills);

var bool bRequireMatchingWeapon, bRequireKill;
var array<EAbilityHitResult> AllowedHitResults;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'SlamFire', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	//  match the weapon associated with Serial to the attacking weapon
	if (bRequireMatchingWeapon && kAbility.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
		return false;

	if (AllowedHitResults.Length > 0 && AllowedHitResults.Find(AbilityContext.ResultContext.HitResult) == INDEX_NONE)
		return false;

	if (bRequireKill && (TargetUnit == none || !TargetUnit.IsDead()))
		return false;

	//  restore the pre cost action points to fully refund this action
	if (SourceUnit.ActionPoints.Length != PreCostActionPoints.Length)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			SourceUnit.ActionPoints = PreCostActionPoints;

			EventMgr = `XEVENTMGR;
			EventMgr.TriggerEvent('SlamFire', AbilityState, SourceUnit, NewGameState);

			return true;
		}
	}

	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "SlamFire"
}