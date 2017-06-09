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
	SetVariableIconColor('VanishingAct');
	SetVariableIconColor('ShadowOps_ThrowSonicBeacon');
	SetVariableIconColor('Deadeye');
	SetVariableIconColor('PrecisionShot');
	SetVariableIconColor('Flush');
	SetVariableIconColor('RapidFire');
	SetVariableIconColor('ShadowOps_Bullseye');
	SetVariableIconColor('ShadowOps_DisablingShot');

	UpdateFleche();

	SetShotHUDPriorities();

	EditSmallItemWeight();

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

// Remove mobility UI stat display on small items in the grenade/ammo slot
static function EditSmallItemWeight()
{
	local X2ItemTemplateManager					ItemManager;
	local array<X2DataTemplate>					TemplateAllDifficulties;
	local X2DataTemplate						Template;
	local X2ItemTemplate						NewTemplate;
	local array<name>							TemplateNames;
	local name									ItemName;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(ItemName)
	{
		ItemManager.FindDataTemplateAllDifficulties(ItemName, TemplateAllDifficulties);
		foreach TemplateAllDifficulties(Template)
		{
			if (Template.IsA('X2GrenadeTemplate'))
			{
				NewTemplate = new class'X2GrenadeTemplate_ShadowOps'(Template);
				ItemManager.AddItemTemplate(NewTemplate, true);
			}
			else if (Template.IsA('X2AmmoTemplate'))
			{
				NewTemplate = new class'X2AmmoTemplate_ShadowOps'(Template);
				ItemManager.AddItemTemplate(NewTemplate, true);
			}
		}
	}
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local XComGameState_Item Item, InnerItem;
	local StateObjectReference ItemRef, InnerItemRef;
	local int i;

	if (StartState == none)
		return;

	// Remove the weight for items in the grenade/ammo slots
	foreach UnitState.InventoryItems(ItemRef)
	{
		Item = XComGameState_Item(StartState.GetGameStateForObjectID(ItemRef.ObjectID));

		if (Item.InventorySlot == eInvSlot_AmmoPocket || Item.InventorySlot == eInvSlot_GrenadePocket)
		{
			// Find the item this was merged into
			foreach UnitState.InventoryItems(InnerItemRef)
			{
				InnerItem = XComGameState_Item(StartState.GetGameStateForObjectID(InnerItemRef.ObjectID));

				if (!InnerItem.bMergedOut && InnerItem.GetMyTemplateName() == Item.GetMyTemplateName())
				{
					`Log("Removing item weight from" @ InnerItem.GetMyTemplateName() @ "in" @ InnerItem.InventorySlot);

					InnerItem = XComGameState_Item(StartState.CreateStateObject(InnerItem.class, InnerItem.ObjectID));
					StartState.AddStateObject(InnerItem);

					// The small item weight depends on the number of merged items, so reduce it 
					// by 1 to remove the weight for the ammo/grenade slot item.
					InnerItem.MergedItemCount--;

					break;
				}
			}
		}
	}

	// Remove squadsight from survivalists not using a sniper rifle
	if (UnitState.GetSoldierClassTemplateName() == 'ShadowOps_Survivalist_LW2' &&
		X2WeaponTemplate(UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon).GetMyTemplate()).WeaponCat != 'sniper_rifle')
	{
		`Log("Removing Squadsight from" @ UnitState.GetFullName());
		for (i = SetupData.Length - 1; i >= 0; --i)
		{
			if (SetupData[i].TemplateName == 'Squadsight')
			{
				SetupData.Remove(i, 1);
			}
		}
	}
}

// Added by LWS. Used to fix up the ammo slot when validating loadout
static function GetMinimumRequiredUtilityItems(out int Value, XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Item EquippedAmmo, EquippedPrimaryWeapon;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	EquippedPrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, NewGameState);

	EquippedAmmo = UnitState.GetItemInSlot(eInvSlot_AmmoPocket, NewGameState);
	if (EquippedAmmo != none)
	{
		if(X2AmmoTemplate(EquippedAmmo.GetMyTemplate()) != none && 
		   !X2AmmoTemplate(EquippedAmmo.GetMyTemplate()).IsWeaponValidForAmmo(X2WeaponTemplate(EquippedPrimaryWeapon.GetMyTemplate())))
		{
			EquippedAmmo = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', EquippedAmmo.ObjectID));
			NewGameState.AddStateObject(EquippedAmmo);
			UnitState.RemoveItemFromInventory(EquippedAmmo, NewGameState);
			XComHQ.PutItemInInventory(NewGameState, EquippedAmmo);
			EquippedAmmo = none;
		}
	}

	if (EquippedAmmo == none && UnitState.HasAmmoPocket())
	{
		EquippedAmmo = GetBestAmmo(UnitState, NewGameState);
		UnitState.AddItemToInventory(EquippedAmmo, eInvSlot_AmmoPocket, NewGameState);
	}	
}

static function XComGameState_Item GetBestAmmo(XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local array<X2AmmoTemplate> AmmoTemplates;
	local XComGameState_Item ItemState;

	AmmoTemplates = GetBestAmmoTemplates(UnitState, NewGameState);

	if(AmmoTemplates.Length == 0)
	{
		return none;
	}

	ItemState = AmmoTemplates[`SYNC_RAND_STATIC(AmmoTemplates.Length)].CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(ItemState);

	return ItemState;
}

static function array<X2AmmoTemplate> GetBestAmmoTemplates(XComGameState_Unit UnitState, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local X2AmmoTemplate AmmoTemplate, BestAmmoTemplate;
	local array<X2AmmoTemplate> BestAmmoTemplates;
	local XComGameState_Item ItemState;
	local XComGameState_Item EquippedPrimaryWeapon;
	local int idx, HighestTier;

	History = `XCOMHISTORY;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	EquippedPrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, NewGameState);

	// First get the default Ammo template
	BestAmmoTemplate = X2AmmoTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(class'X2Ability_InfantryAbilitySet'.default.FreeAmmoForPocket));
	if (BestAmmoTemplate.IsWeaponValidForAmmo(X2WeaponTemplate(EquippedPrimaryWeapon.GetMyTemplate())))
	{
		BestAmmoTemplates.AddItem(BestAmmoTemplate);
		HighestTier = BestAmmoTemplate.Tier;
	}
	else
	{
		BestAmmoTemplate = none;
		HighestTier = 0;
	}

	if( XComHQ != none )
	{
		// Try to find a better Ammo as an infinite item in the inventory
		for (idx = 0; idx < XComHQ.Inventory.Length; idx++)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(XComHQ.Inventory[idx].ObjectID));
			AmmoTemplate = X2AmmoTemplate(ItemState.GetMyTemplate());

			if(AmmoTemplate != none && AmmoTemplate.bInfiniteItem && AmmoTemplate.IsWeaponValidForAmmo(X2WeaponTemplate(EquippedPrimaryWeapon.GetMyTemplate())) &&
				(BestAmmoTemplate == none || (BestAmmoTemplates.Find(AmmoTemplate) == INDEX_NONE && AmmoTemplate.Tier >= BestAmmoTemplate.Tier)))
			{
				BestAmmoTemplate = AmmoTemplate;
				BestAmmoTemplates.AddItem(BestAmmoTemplate);
				HighestTier = BestAmmoTemplate.Tier;
			}
		}
	}

	for(idx = 0; idx < BestAmmoTemplates.Length; idx++)
	{
		if(BestAmmoTemplates[idx].Tier < HighestTier)
		{
			BestAmmoTemplates.Remove(idx, 1);
			idx--;
		}
	}

	return BestAmmoTemplates;
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
	local UnitValue MissionExperienceValue, OfficerBonusKillsValue;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class' XComGameState_HeadquartersXCom'));
	Soldiers = XComHQ.GetSoldiers();

	foreach Soldiers(UnitState)
	{
		UnitState.GetUnitValue('MissionExperience', MissionExperienceValue);
		UnitState.GetUnitValue('OfficerBonusKills', OfficerBonusKillsValue);
		
		`Log("CSV," $
			UnitState.GetName(eNameType_FullNick) $ "," $ 
			UnitState.GetSoldierClassTemplateName() $ "," $ 
			UnitState.GetNumMissions() $ "," $ 
			UnitState.GetNumKills() $ "," $
			UnitState.GetKillAssists().Length $ "," $ 
			MissionExperienceValue.fValue $ "," $
			OfficerBonusKillsValue.fValue);
	}
}

exec function ClearListeners()
{
	class'X2EventManager'.static.GetEventManager().Clear();
}

exec function RerollAWCAbilities(optional name ForceAbility)
{
	local UIArmory Armory;
	local StateObjectReference UnitRef;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_AWC_LW AWCState;
	local int Retries;

	History = `XCOMHISTORY;

	Armory = UIArmory(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory'));
	if (Armory == none)
		return;

	UnitRef = Armory.GetUnitRef();

	Unit = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
	if (Unit == none)
		return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Force AWC Reroll (" $ Unit.GetFullName() $ ")");

	if(Unit.GetRank() > 0) // can't do this for rookies, since they have no class tree for AWC restrictions
	{
		AWCState = class'LWAWCUtilities'.static.GetAWCComponent(Unit);
		if(AWCState == none)
		{
			//create and link it
			Unit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
			NewGameState.AddStateObject(Unit);
			AWCState = XComGameState_Unit_AWC_LW(NewGameState.CreateStateObject(class'XComGameState_Unit_AWC_LW'));
			NewGameState.AddStateObject(AWCState);
			Unit.AddComponentObject(AWCState);
		}
		else
		{
			//UpdatedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
			//NewGameState.AddStateObject(UpdatedUnit);
			AWCState = XComGameState_Unit_AWC_LW(NewGameState.CreateStateObject(class'XComGameState_Unit_AWC_LW', AWCState.ObjectID));
			NewGameState.AddStateObject(AWCState);
		}

		ChooseSoldierAWCoptions(AWCState, Unit, true);

		while (ForceAbility != '' && Retries < 100 && !AWCState.HasAWCAbility(Unit, ForceAbility))
		{
			ChooseSoldierAWCoptions(AWCState, Unit, true);
			Retries++;
		}
	}
	
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

exec function ValidAWCAbilities(const AWCTrainingType Option, const int idx, optional bool bCreateGameState = false, optional bool bCreateAWCState = false)
{
	local UIArmory Armory;
	local StateObjectReference UnitRef;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	local XComGameState_Unit_AWC_LW AWCState;
	local array<ClassAgnosticAbility> PossibleAbilities;
	local ClassAgnosticAbility Ability;
	local string output;
	local XComGameState NewGameState;

	`Log("ValidAWCAbilities" @ Option @ idx @ bCreateGameState @ bCreateAWCState);

	History = `XCOMHISTORY;

	Armory = UIArmory(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory'));
	if (Armory == none)
		return;

	UnitRef = Armory.GetUnitRef();

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
	if (UnitState == none)
		return;

	AWCState = class'LWAWCUtilities'.static.GetAWCComponent(UnitState);

	if (bCreateGameState || AWCState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Force AWC Rerolls");
		if (bCreateAWCState || AWCState == none)
		{
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			NewGameState.AddStateObject(UnitState);
			AWCState = XComGameState_Unit_AWC_LW(NewGameState.CreateStateObject(class'XComGameState_Unit_AWC_LW'));
			NewGameState.AddStateObject(AWCState);
			UnitState.AddComponentObject(AWCState);
		}
		else
		{
			AWCState = XComGameState_Unit_AWC_LW(NewGameState.CreateStateObject(class'XComGameState_Unit_AWC_LW', AWCState.ObjectID));
			NewGameState.AddStateObject(AWCState);
		}

		AWCState.OffenseAbilities.Length = 0;
		AWCState.DefenseAbilities.Length = 0;
		AWCState.PistolAbilities.Length = 0;
	}

	switch (Option)
	{
		case AWCTT_Offense:
			PossibleAbilities = AWCState.GetValidAWCAbilities(class'LWAWCUtilities'.default.AWCAbilityTree_Offense, idx + 1);
			break;
		case AWCTT_Defense:
			PossibleAbilities = AWCState.GetValidAWCAbilities(class'LWAWCUtilities'.default.AWCAbilityTree_Defense, idx + 1);
			break;
		case AWCTT_Pistol:
			PossibleAbilities = AWCState.WeightedSort(class'LWAWCUtilities'.default.AWCAbilityTree_Pistol);
			break;
		default:
			break;
	}

	foreach PossibleAbilities(Ability)
	{
		output $= "\n";
		output $= Ability.AbilityType.AbilityName;
	}

	`Log(output);

	if (bCreateGameState)
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
	}
}

//This uses the config data in LWAWCUtilities to select a set of AWC abilities for a soldier
function ChooseSoldierAWCOptions(XComGameState_Unit_AWC_LW AWCState, XComGameState_Unit UnitState, optional bool bForce=false)
{
	local int idx;
	local array<ClassAgnosticAbility> PossibleAbilities;
	local int NumPistolAbilities;

	//Fill out with randomized abilities
	for(idx = 0; idx < class'LWAWCUtilities'.default.NUM_OFFENSE_ABILITIES; idx++)
	{
		if (AWCState.OffenseAbilities[idx].bUnlocked)
			continue;
		AWCState.OffenseAbilities[idx] = AWCState.ChooseSoldierAWCOption(UnitState, idx, AWCTT_Offense);
	}

	for(idx = 0; idx < class'LWAWCUtilities'.default.NUM_DEFENSE_ABILITIES; idx++)
	{
		if (AWCState.DefenseAbilities[idx].bUnlocked)
			continue;
		AWCState.DefenseAbilities[idx] = AWCState.ChooseSoldierAWCOption(UnitState, idx, AWCTT_Defense);
	}

	if (AWCState.PistolAbilities[0].bUnlocked)
		return;

	PossibleAbilities = AWCState.WeightedSort(class'LWAWCUtilities'.default.AWCAbilityTree_Pistol);
	NumPistolAbilities = Min(class'LWAWCUtilities'.default.AWCAbilityTree_Pistol.Length, class'LWAWCUtilities'.default.NUM_PISTOL_ABILITIES);
	for(idx = 0; idx < NumPistolAbilities; idx++)
	{
		AWCState.PistolAbilities[idx] = PossibleAbilities[idx];
	}
}
