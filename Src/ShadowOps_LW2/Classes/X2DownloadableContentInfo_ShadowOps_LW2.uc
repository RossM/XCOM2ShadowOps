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
	SetVariableIconColor('Deadeye');
	SetVariableIconColor('PrecisionShot');
	SetVariableIconColor('HaywireProtocol');

	UpdateFleche();

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