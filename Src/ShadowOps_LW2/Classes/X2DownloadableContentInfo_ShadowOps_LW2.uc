class X2DownloadableContentInfo_ShadowOps_LW2 extends X2DownloadableContentInfo config(GameCore);

static event OnLoadedSavedGame()
{
	class'XComGameState_SOListenerManager'.static.CreateListenerManager();
	class'XComGameState_KillTracker'.static.RefreshListeners();
}

static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_SOListenerManager'.static.CreateListenerManager(StartState);
	class'XComGameState_KillTracker'.static.InitializeWithGameState(StartState).InitListeners();
}

static event OnLoadedSavedGameToStrategy()
{
	class'XComGameState_SOListenerManager'.static.RefreshListeners();
	class'XComGameState_KillTracker'.static.RefreshListeners();
}

static event OnPostMission()
{
	class'XComGameState_SOListenerManager'.static.RefreshListeners();
	class'XComGameState_KillTracker'.static.RefreshListeners();
}

static event OnPostTemplatesCreated()
{
	`Log("X2DownloadableContentInfo_ShadowOps_LW2.OnPostTemplatesCreated");

	SetVariableIconColor('PointBlank');
	SetVariableIconColor('BothBarrels');
	SetVariableIconColor('HaywireProtocol');
	SetVariableIconColor('ShadowOps_ThrowSonicBeacon');
	SetVariableIconColor('Deadeye');
	SetVariableIconColor('PrecisionShot');
	SetVariableIconColor('Flush');
	SetVariableIconColor('ShadowOps_Bullseye');
	SetVariableIconColor('ShadowOps_DisablingShot');

	UpdateFleche();

	SetShotHUDPriorities();

	// Hack - call the class template editors (sometimes their DLCContentInfos fail to run OnPostTemplatesCreated, no idea why)
	class'TemplateEditors_CombatEngineer'.static.EditTemplates();
	class'TemplateEditors_Hunter'.static.EditTemplates();
	class'TemplateEditors_Infantry'.static.EditTemplates();

	// Super-hack -- force loading stuff
	// DO NOT REMOVE THIS LINE! We must have a reference to class'X2Ability_InfantryAbilitySet' somewhere or it may get dropped,
	// causing the game to not load the abilities! (Apparently. I am super confused about this.)
	`Log("X2Ability_InfantryAbilitySet:" @ class'X2Ability_InfantryAbilitySet');
}

static function SetVariableIconColor(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.AbilityIconColor = "Variable";
	}
}

static function UpdateFleche()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2Effect								Effect;
	local X2Effect_FlecheBonusDamage			FlecheEffect;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties('Fleche', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		foreach Template.AbilityTargetEffects(Effect)
		{
			FlecheEffect = X2Effect_FlecheBonusDamage(Effect);
			if (FlecheEffect != none)
				break;
		}

		if (FlecheEffect != none)
		{
			if (FlecheEffect.AbilityNames.Find('ShadowOps_SliceAndDice') == INDEX_NONE)
				FlecheEffect.AbilityNames.AddItem('ShadowOps_SliceAndDice');
		}
	}
}

static function SetShotHUDPriorities()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local array<name>							TemplateNames;
	local name									AbilityName;
	local int									ShotHUDPriority;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(AbilityName)
	{
		AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
		foreach TemplateAllDifficulties(Template)
		{
			if (Template.ShotHUDPriority >= class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY &&
				Template.ShotHUDPriority <= class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY)
			{
				ShotHUDPriority = FindShotHUDPriority(Template.DataName);
				if (ShotHUDPriority != class'UIUtilities_Tactical'.const.UNSPECIFIED_PRIORITY)
					Template.ShotHUDPriority = ShotHUDPriority;
			}
		}
	}
}

static function int FindShotHUDPriority(name AbilityName)
{
	local X2SoldierClassTemplateManager SoldierClassManager;
	local array<X2SoldierClassTemplate> AllTemplates;
	local X2SoldierClassTemplate Template;
	local array<SoldierClassAbilityType> AbilityTree;
	local int HighestLevel;
	local int rank;

	SoldierClassManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();

	HighestLevel = -1;

	AllTemplates = SoldierClassManager.GetAllSoldierClassTemplates();
	foreach AllTemplates(Template)
	{
		if (Template.NumInDeck == 0 && Template.NumInForcedDeck == 0)
			continue;

		for (rank = 0; rank < Template.GetMaxConfiguredRank(); rank++)
		{
			if (rank <= HighestLevel)
				continue;

			AbilityTree = Template.GetAbilityTree(rank);
			if (AbilityTree.Find('AbilityName', AbilityName) != INDEX_NONE)
				HighestLevel = rank;
		}
	}

	switch (HighestLevel)
	{
	case -1:	return class'UIUtilities_Tactical'.const.UNSPECIFIED_PRIORITY;
	case 0:		return class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	case 1:		return class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	case 2:		return class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	case 3:		return class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	case 4:		return class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	case 5:		return class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	case 6:		return class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	default:	return 300 + 10 * HighestLevel;
	}
}

exec function Respec()
{
	local UIArmory Armory;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UnitState;
	local XComGameState NewGameState;
	local int i;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	Armory = UIArmory(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory'));
	if (Armory == none)
		return;

	UnitRef = Armory.GetUnitRef();

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
	if (UnitState == none)
		return;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Respec Soldier");

	// Set the soldier status back to active, and rank them up to their new class
	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	UnitState.ResetSoldierAbilities(); // First clear all of the current abilities
	for (i = 0; i < UnitState.GetSoldierClassTemplate().GetAbilityTree(0).Length; ++i) // Then give them their squaddie ability back
	{
		UnitState.BuySoldierProgressionAbility(NewGameState, 0, i);
	}
	NewGameState.AddStateObject(UnitState);

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

	Armory.PopulateData();
}

exec function DumpXPInfo()
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<XComGameState_Unit> Soldiers;
	local UnitValue Value;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class' XComGameState_HeadquartersXCom'));
	Soldiers = XComHQ.GetSoldiers();

	foreach Soldiers(UnitState)
	{
		UnitState.GetUnitValue('MissionExperience', Value);
		
		`Log("CSV," $
			UnitState.GetName(eNameType_FullNick) $ "," $ 
			UnitState.GetSoldierClassTemplateName() $ "," $ 
			UnitState.GetNumMissions() $ "," $ 
			UnitState.GetNumKills() $ "," $
			UnitState.GetKillAssists().Length $ "," $ 
			Value.fValue);
	}
}

exec function ClearListeners()
{
	class'X2EventManager'.static.GetEventManager().Clear();
}