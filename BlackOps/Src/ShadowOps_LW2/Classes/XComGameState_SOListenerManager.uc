class XComGameState_SOListenerManager extends XComGameState_BaseObject config(ShadowOps);

var config string ICON_COLOR_OBJECTIVE;
var config string ICON_COLOR_PSIONIC_2;
var config string ICON_COLOR_PSIONIC_END;
var config string ICON_COLOR_PSIONIC_1;
var config string ICON_COLOR_PSIONIC_FREE;
var config string ICON_COLOR_COMMANDER_ALL;
var config string ICON_COLOR_2;
var config string ICON_COLOR_END;
var config string ICON_COLOR_1;
var config string ICON_COLOR_FREE;

// This class copied and modified from XComGameState_LWListenerManager in Long War 2

static function XComGameState_SOListenerManager GetListenerManager(optional bool AllowNULL = false)
{
	return XComGameState_SOListenerManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_SOListenerManager', AllowNULL));
}

static function CreateListenerManager(optional XComGameState StartState)
{
	local XComGameState_SOListenerManager ListenerMgr;
	local XComGameState NewGameState;

	//first check that there isn't already a singleton instance of the listener manager
	if(GetListenerManager(true) != none)
		return;

	if(StartState != none)
	{
		ListenerMgr = XComGameState_SOListenerManager(StartState.CreateStateObject(class'XComGameState_SOListenerManager'));
		StartState.AddStateObject(ListenerMgr);
	}
	else
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating LW Listener Manager Singleton");
		ListenerMgr = XComGameState_SOListenerManager(NewGameState.CreateStateObject(class'XComGameState_SOListenerManager'));
		NewGameState.AddStateObject(ListenerMgr);
		`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	}

	ListenerMgr.InitListeners();
}

static function RefreshListeners()
{
	local XComGameState_SOListenerManager ListenerMgr;

	ListenerMgr = GetListenerManager(true);
	if(ListenerMgr == none)
		CreateListenerManager();
	else
		ListenerMgr.InitListeners();
}

function InitListeners()
{
	local X2EventManager EventMgr;
	local Object ThisObj;

	ThisObj = self;
	EventMgr = `XEVENTMGR;
	EventMgr.UnregisterFromAllEvents(ThisObj); // clear all old listeners to clear out old stuff before re-registering

	EventMgr.RegisterForEvent(ThisObj, 'OverrideAbilityIconColor', OnOverrideAbilityIconColor, ELD_Immediate, 40,, true);
}

// This takes on a bunch of exceptions to color ability icons
function EventListenerReturn OnOverrideAbilityIconColor (Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	local XComLWTuple				OverrideTuple;
	local Name						AbilityName;
	local XComGameState_Ability		AbilityState;
	local X2AbilityTemplate			AbilityTemplate;
	local XComGameState_Unit		UnitState;
	local string					IconColor;
	local XComGameState_Item		WeaponState;
	local bool Changed;
	local UnitValue Value;
	local int k;
	local X2AbilityCost_ActionPoints ActionPoints;

	OverrideTuple = XComLWTuple(EventData);
	if(OverrideTuple == none)
	{
		`REDSCREEN("OnOverrideAbilityIconColor event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}
	
	AbilityState = XComGameState_Ability (EventSource);
	//OverrideTuple.Data[0].o;

	if (AbilityState == none)
	{
		return ELR_NoInterrupt;
	}

	Changed = false;
	AbilityTemplate = AbilityState.GetMyTemplate();
	AbilityName = AbilityState.GetMyTemplateName();
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	WeaponState = AbilityState.GetSourceWeapon();

	if (UnitState == none)
	{
		return ELR_NoInterrupt;
	}

	`Log("ShadowOps_LW2 OnOverrideAbilityIconColor :" @ AbilityName);

	switch (AbilityName)
	{
		case 'ThrowGrenade':
		case 'LaunchGrenade':
			if (UnitState.AffectedByEffectNames.Find('Fastball') != INDEX_NONE)
			{
				IconColor = default.ICON_COLOR_FREE;
				Changed = true;
			}
			else
			{
				for (k = 0; k < AbilityTemplate.AbilityCosts.Length; k++)
				{
					ActionPoints = X2AbilityCost_ActionPoints(AbilityTemplate.AbilityCosts[k]);
					if (ActionPoints != none)
					{
						if (ActionPoints.ConsumeAllPoints(AbilityState, UnitState))
							IconColor = default.ICON_COLOR_END;
						else
							IconColor = default.ICON_COLOR_1;
						Changed = true;
						break;
					}
				}
			}
			break;
		case 'PointBlank':
		case 'BothBarrels':
			if (UnitState.HasSoldierAbility('ShadowOps_Hipfire_LW2', true))
			{
				UnitState.GetUnitValue('Hipfire_Count', Value);
				if (Value.fValue < 1)
				{
					IconColor = default.ICON_COLOR_FREE;
					Changed = true;
				}
			}
			break;
		default: break;
	}

	if (Changed)
	{
		OverrideTuple.Data[0].s = IconColor;
	}

	return ELR_NoInterrupt;
}
