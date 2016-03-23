class X2Effect_ShieldProtocol extends X2Effect_ModifyStats;

var int ConventionalAmount, MagneticAmount, BeamAmount;

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

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Item SourceItem;
	local X2GremlinTemplate GremlinTemplate;
	local StatChange Change;

	Change.StatType = eStat_ShieldHP;
	Change.StatAmount = default.ConventionalAmount;

	SourceItem = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if (SourceItem == none)
		SourceItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));

	if (SourceItem != none)
	{
		GremlinTemplate = X2GremlinTemplate(SourceItem.GetMyTemplate());
		if (GremlinTemplate != none)
		{
			if (GremlinTemplate.WeaponTech == 'magnetic')
				Change.StatAmount = default.MagneticAmount;
			else if (GremlinTemplate.WeaponTech == 'beam')
				Change.StatAmount = default.BeamAmount;
		}
	}
	NewEffectState.StatChanges.AddItem(Change);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

//simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, name EffectApplyResult)
//{
	//local XComGameStateContext_Ability  Context;
	//local X2Action_PlayAnimation PlayAnimationAction;
//
	//Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
//
	//PlayAnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTrack(BuildTrack, Context));
	//PlayAnimationAction.Params.AnimName = 'HL_EnergyShield';
//}

defaultproperties
{
	EffectName="ShieldProtocol"
	DuplicateResponse=eDupe_Refresh
}