class XComGameState_KillTracker extends XComGameState_BaseObject;

struct KillListItem
{
	var name TemplateName;
	var int Count;
};

struct KillInfo
{
	var int ObjectID;
	var int ProcessedKills;
	var array<KillListItem> KillList;
};

var array<KillInfo> KillInfos;

// Creates the killtracker object if it doesn't exist
static function XComGameState_KillTracker InitializeWithGameState(XComGameState NewGameState)
{
	local XComGameState_KillTracker Tracker;
	local XComGameState_Unit UnitState;

	// Check for an existing kill tracker
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_KillTracker', Tracker)
	{
		break;
	}
	if (Tracker != none)
		return Tracker;

	Tracker = XComGameState_KillTracker(NewGameState.CreateStateObject(class'XComGameState_KillTracker'));
	NewGameState.AddStateObject(Tracker);

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		Tracker.UpdateKills(UnitState);
	}

	return Tracker;
}

// Creates the killtracker object if it doesn't exist
static function XComGameState_KillTracker GetKillTracker()
{
	local XComGameStateHistory History;
	local XComGameState_KillTracker Tracker;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_KillTracker', Tracker)
	{
		break;
	}

	if (Tracker != none)
		return Tracker;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Shadow Ops: Initialize Kill Tracker");
	Tracker = InitializeWithGameState(NewGameState);
	`GAMERULES.SubmitGameState(NewGameState);

	return Tracker;
}

function UpdateKills(XComGameState_Unit UnitState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit KilledUnitState;
	local name TemplateName;
	local KillInfo KI;
	local KillListItem KLI;
	local array<StateObjectReference> Kills;
	local int KillerIndex, KillIndex, i;

	History = `XCOMHISTORY;

	KillerIndex = KillInfos.Find('ObjectID', UnitState.ObjectID);

	if (KillerIndex == INDEX_NONE)
	{
		KillerIndex = KillInfos.Length;
		KI.ObjectID = UnitState.ObjectID;
		KillInfos.AddItem(KI);
	}

	if (!UnitState.GetMyTemplate().bIsSoldier)
		return;

	Kills = UnitState.GetKills();

	for (i = KillInfos[KillerIndex].ProcessedKills; i < Kills.Length; i++)
	{
		KilledUnitState = XComGameState_Unit(History.GetGameStateForObjectID(Kills[i].ObjectID));

		if (KilledUnitState != none)
		{
			TemplateName = KilledUnitState.GetMyTemplateName();
			KillIndex = KillInfos[KillerIndex].KillList.Find('TemplateName', TemplateName);
			if (KillIndex == INDEX_NONE)
			{
				KillIndex = KillInfos[KillerIndex].KillList.Length;
				KLI.TemplateName = TemplateName;
				KLI.Count = 1;
				KillInfos[KillerIndex].KillList.AddItem(KLI);
			}
			else
			{
				KillInfos[KillerIndex].KillList[KillIndex].Count++;
			}
		}
	}

	KillInfos[KillerIndex].ProcessedKills = Kills.Length;
}

static function RefreshListeners()
{
	local XComGameState_KillTracker Tracker;

	Tracker = GetKillTracker();
	Tracker.InitListeners();
}

function InitListeners()
{
	local X2EventManager EventMgr;
	local Object ThisObj;

	ThisObj = self;
	EventMgr = `XEVENTMGR;
	EventMgr.UnregisterFromAllEvents(ThisObj); // clear all old listeners to clear out old stuff before re-registering

	EventMgr.RegisterForEvent(ThisObj, 'KillMail', OnKillMail, ELD_OnStateSubmitted,,, true);
}

function EventListenerReturn OnKillMail(Object EventData, Object EventSource, XComGameState GameState, Name InEventID)
{
	local XComGameState_Unit UnitState;
	local XComGameState_KillTracker Tracker;
	local XComGameState NewGameState;

	// `Log("OnKillMail: EventData =" @ EventData);
	// `Log("OnKillMail: EventSource =" @ EventSource);

	UnitState = XComGameState_Unit(EventSource);
	if (UnitState == none)
		return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Shadow Ops: Update Kill Tracker");
	Tracker = XComGameState_KillTracker(NewGameState.CreateStateObject(class'XComGameState_KillTracker', self.ObjectID));
	NewGameState.AddStateObject(Tracker);
	Tracker.UpdateKills(UnitState);
	`GAMERULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}