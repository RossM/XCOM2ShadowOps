class XComGameState_SOListenerManager extends XComGameState_BaseObject config(ShadowOps);

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

	EventMgr.RegisterForEvent(ThisObj, 'AbilityActivated', OnAbilityActivated, ELD_PreStateSubmitted,,, true);
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

	switch (AbilityName)
	{
		case 'ThrowGrenade':
			if (UnitState.AffectedByEffectNames.Find('Fastball') != INDEX_NONE)
			{
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_FREE;
				Changed = true;
			}
			else if (UnitState.AffectedByEffectNames.Find('RapidDeploymentEffect') != -1 &&
				class'X2Effect_RapidDeployment'.default.VALID_GRENADE_TYPES.Find(WeaponState.GetMyTemplateName()) != -1)
			{
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_FREE;
				Changed = true;
			}
			else
			{
				IconColor = GetIconColorByActionPointCost(AbilityTemplate, AbilityState, UnitState);
				Changed = true;
				break;
			}
			break;

		case 'LaunchGrenade':
			if (UnitState.AffectedByEffectNames.Find('Fastball') != INDEX_NONE)
			{
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_FREE;
				Changed = true;
			}
			else if (UnitState.AffectedByEffectNames.Find('RapidDeploymentEffect') != -1 &&
				class'X2Effect_RapidDeployment'.default.VALID_GRENADE_TYPES.Find(WeaponState.GetLoadedAmmoTemplate(AbilityState).DataName) != -1)
			{
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_FREE;
				Changed = true;
			}
			else
			{
				IconColor = GetIconColorByActionPointCost(AbilityTemplate, AbilityState, UnitState);
				Changed = true;
				break;
			}
			break;

		case 'VanishingAct':
		case 'ShadowOps_ThrowSonicBeacon':
			if (UnitState.AffectedByEffectNames.Find('RapidDeploymentEffect') != -1)
			{
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_FREE;
				Changed = true;
			}
			else
			{
				IconColor = GetIconColorByActionPointCost(AbilityTemplate, AbilityState, UnitState);
				Changed = true;
				break;
			}
			break;

		case 'PointBlank':
		case 'BothBarrels':
			if (UnitState.HasSoldierAbility('ShadowOps_Hipfire_LW2', true))
			{
				UnitState.GetUnitValue('Hipfire_Count', Value);
				if (Value.fValue < 1)
				{
					IconColor = class'LWTemplateMods'.default.ICON_COLOR_FREE;
					Changed = true;
				}
			}
			break;

		case 'Deadeye':
		case 'PrecisionShot':
		case 'Flush':
		case 'ShadowOps_Bullseye':
		case 'ShadowOps_DisablingShot':
			IconColor = GetIconColorByActionPointCost(AbilityTemplate, AbilityState, UnitState);
			Changed = true;
			break;
		
		case 'HaywireProtocol':
			if (UnitState.HasSoldierAbility('ShadowOps_Puppeteer', true))
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_1;
			else
				IconColor = class'LWTemplateMods'.default.ICON_COLOR_END;
			Changed = true;
			break;

		default: break;
	}

	if (Changed)
	{
		OverrideTuple.Data[0].s = IconColor;
	}

	return ELR_NoInterrupt;
}

function string GetIconColorByActionPointCost(X2AbilityTemplate AbilityTemplate, XComGameState_Ability AbilityState, XComGameState_Unit UnitState)
{
	local int k, cost;
	local X2AbilityCost_ActionPoints ActionPoints;
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate SourceWeaponTemplate;

	SourceWeapon = AbilityState.GetSourceWeapon();
	if (SourceWeapon != none)
		SourceWeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());

	for (k = 0; k < AbilityTemplate.AbilityCosts.Length; k++)
	{
		ActionPoints = X2AbilityCost_ActionPoints(AbilityTemplate.AbilityCosts[k]);
		if (ActionPoints != none)
		{
			cost = ActionPoints.iNumPoints;
			if (ActionPoints.bAddWeaponTypicalCost && SourceWeaponTemplate != none)
				cost += SourceWeaponTemplate.iTypicalActionCost;

			if (cost >= 2)
				return class'LWTemplateMods'.default.ICON_COLOR_2;
			else if (ActionPoints.ConsumeAllPoints(AbilityState, UnitState))
				return class'LWTemplateMods'.default.ICON_COLOR_END;
			else
				return class'LWTemplateMods'.default.ICON_COLOR_1;
		}
	}

	return class'LWTemplateMods'.default.ICON_COLOR_FREE;
}

// This function is called on PreGameStateSubmitted and gives us a chance to modify arbitrary game state.
function EventListenerReturn OnAbilityActivated (Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameStateHistory History;
	local XComGameState_EnvironmentDamage DamageEvent;
	local XComGameState_Unit SourceStateObject;
	local XComGameState_Item SourceAmmo, SourceWeapon;
	local name AbilityName;

	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());

	AbilityState = XComGameState_Ability(EventData);
	if (AbilityState == none && AbilityContext != none)
	{
		AbilityState = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		if (AbilityState == none)
			AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	}

	if (AbilityState == none)
		return ELR_NoInterrupt;

	AbilityName = AbilityState.GetMyTemplateName();
	SourceStateObject = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	SourceAmmo = AbilityState.GetSourceAmmo();
	SourceWeapon = AbilityState.GetSourceWeapon();

	if (SourceAmmo == none)
	{
		if (SourceWeapon != none && SourceWeapon.HasLoadedAmmo())
			SourceAmmo = XComGameState_Item(History.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));
	}

	switch (AbilityName)
	{
	case 'ThrowGrenade':
	case 'LaunchGrenade':
		if (SourceStateObject.HasSoldierAbility('ShadowOps_DemoGrenades'))
		{
			//`Log("ShadowOps_DemoGrenades");
			foreach NewGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', DamageEvent)
			{
				if (SourceAmmo != none && SourceAmmo.GetItemEnvironmentDamage() > 0)
				{
					DamageEvent.DamageAmount += class'X2Ability_EngineerAbilitySet'.default.DemoGrenadesEnvironmentDamageBonus;
				}
			}
		}
		break;
	}

	return ELR_NoInterrupt;
}