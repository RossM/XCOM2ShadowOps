class UISoldierHeader_BO extends UISoldierHeader;

public function PopulateData(optional XComGameState_Unit Unit, optional StateObjectReference NewItem, optional StateObjectReference ReplacedItem, optional XComGameState NewCheckGameState)
{
	local int iRank, WillBonus, AimBonus, HealthBonus, MobilityBonus, TechBonus, PsiBonus, ArmorBonus, DodgeBonus;
	local string classIcon, rankIcon, flagIcon, Will, Aim, Health, Mobility, Tech, Psi, Armor, Dodge;
	local X2SoldierClassTemplate SoldierClass;
	local X2EquipmentTemplate EquipmentTemplate;
	local XComGameState_Item TmpItem;
	local XComGameStateHistory History;
	local string StatusValue, StatusLabel, StatusDesc, StatusTimeLabel, StatusTimeValue, DaysValue;

	History = `XCOMHISTORY;
	CheckGameState = NewCheckGameState;

	if(Unit == none)
	{
		if(CheckGameState != none)
			Unit = XComGameState_Unit(CheckGameState.GetGameStateForObjectID(UnitRef.ObjectID));
		else
			Unit = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
	}
	
	iRank = Unit.GetRank();

	SoldierClass = Unit.GetSoldierClassTemplate();

	flagIcon  = (Unit.IsSoldier() && !bHideFlag) ? Unit.GetCountryTemplate().FlagImage : "";
	rankIcon  = Unit.IsSoldier() ? class'UIUtilities_Image'.static.GetRankIcon(iRank, Unit.GetSoldierClassTemplateName()) : "";
	classIcon = Unit.IsSoldier() ? SoldierClass.IconImage : Unit.GetMPCharacterTemplate().IconImage;

	if (Unit.IsAlive())
	{
		StatusLabel = m_strStatusLabel;
		class'UIUtilities_Strategy'.static.GetPersonnelStatusSeparate(Unit, StatusDesc, StatusTimeLabel, StatusTimeValue); 
		StatusValue = StatusDesc;
		DaysValue = StatusTimeValue @ StatusTimeLabel;
	}
	else
	{
		StatusLabel = m_strDateKilledLabel;
		StatusValue = class'X2StrategyGameRulesetDataStructures'.static.GetDateString(Unit.GetKIADate());
	}

	if(Unit.IsMPCharacter())
	{
		SetSoldierInfo( Caps(strMPForceName == "" ? Unit.GetName( eNameType_FullNick ) : strMPForceName),
							  StatusLabel, StatusValue,
							  class'XGBuildUI'.default.m_strLabelCost, 
							  string(Unit.GetUnitPointValue()),
							  "", "",
							  classIcon, Caps(SoldierClass != None ? class'UnitUtilities_BO'.static.GetSoldierClassDisplayName(Unit) : ""),
							  rankIcon, Caps(Unit.IsSoldier() ? `GET_RANK_STR(Unit.GetRank(), Unit.GetSoldierClassTemplateName()) : ""),
							  flagIcon, (Unit.ShowPromoteIcon()), DaysValue);
	}
	else
	{
		SetSoldierInfo( Caps(Unit.GetName( eNameType_FullNick )),
							  StatusLabel, StatusValue,
							  m_strMissionsLabel, string(Unit.GetNumMissions()),
							  m_strKillsLabel, string(Unit.GetNumKills()),
							  classIcon, Caps(SoldierClass != None ? class'UnitUtilities_BO'.static.GetSoldierClassDisplayName(Unit) : ""),
							  rankIcon, Caps(`GET_RANK_STR(Unit.GetRank(), Unit.GetSoldierClassTemplateName())),
							  flagIcon, (Unit.ShowPromoteIcon()), DaysValue);
	}

	// Get Unit base stats and any stat modifications from abilities
	Will = string(int(Unit.GetCurrentStat(eStat_Will)) + Unit.GetUIStatFromAbilities(eStat_Will));
	Aim = string(int(Unit.GetCurrentStat(eStat_Offense)) + Unit.GetUIStatFromAbilities(eStat_Offense));
	Health = string(int(Unit.GetCurrentStat(eStat_HP)) + Unit.GetUIStatFromAbilities(eStat_HP));
	Mobility = string(int(Unit.GetCurrentStat(eStat_Mobility)) + Unit.GetUIStatFromAbilities(eStat_Mobility));
	Tech = string(int(Unit.GetCurrentStat(eStat_Hacking)) + Unit.GetUIStatFromAbilities(eStat_Hacking));
	Armor = string(int(Unit.GetCurrentStat(eStat_ArmorMitigation)) + Unit.GetUIStatFromAbilities(eStat_ArmorMitigation));
	Dodge = string(int(Unit.GetCurrentStat(eStat_Dodge)) + Unit.GetUIStatFromAbilities(eStat_Dodge));

	if (Unit.bIsShaken)
	{
		Will = class'UIUtilities_Text'.static.GetColoredText(Will, eUIState_Bad);
	}

	// Get bonus stats for the Unit from items
	WillBonus = GetUIStatFromInventory(Unit, eStat_Will);
	AimBonus = GetUIStatFromInventory(Unit, eStat_Offense);
	HealthBonus = GetUIStatFromInventory(Unit, eStat_HP);
	MobilityBonus = GetUIStatFromInventory(Unit, eStat_Mobility);
	TechBonus = GetUIStatFromInventory(Unit, eStat_Hacking);
	ArmorBonus = GetUIStatFromInventory(Unit, eStat_ArmorMitigation);
	DodgeBonus = GetUIStatFromInventory(Unit, eStat_Dodge);

	if(Unit.IsPsiOperative())
	{
		Psi = string(int(Unit.GetCurrentStat(eStat_PsiOffense)) + Unit.GetUIStatFromAbilities(eStat_PsiOffense));
		PsiBonus = GetUIStatFromInventory(Unit, eStat_PsiOffense);
	}

	// Add bonus stats from an item that is about to be equipped
	if(NewItem.ObjectID > 0)
	{
		if(CheckGameState != None)
			TmpItem = XComGameState_Item(CheckGameState.GetGameStateForObjectID(NewItem.ObjectID));
		else
			TmpItem = XComGameState_Item(History.GetGameStateForObjectID(NewItem.ObjectID));
		EquipmentTemplate = X2EquipmentTemplate(TmpItem.GetMyTemplate());
		
		// Don't include sword boosts or any other equipment in the EquipmentExcludedFromStatBoosts array
		if (EquipmentTemplate != none && EquipmentExcludedFromStatBoosts.Find(EquipmentTemplate.DataName) == INDEX_NONE)
		{
			WillBonus += GetUIStatFromItem(Unit, eStat_Will, TmpItem);
			AimBonus += GetUIStatFromItem(Unit, eStat_Offense, TmpItem);
			HealthBonus += GetUIStatFromItem(Unit, eStat_HP, TmpItem);
			MobilityBonus += GetUIStatFromItem(Unit, eStat_Mobility, TmpItem);
			TechBonus += GetUIStatFromItem(Unit, eStat_Hacking, TmpItem);
			ArmorBonus += GetUIStatFromItem(Unit, eStat_ArmorMitigation, TmpItem);
			DodgeBonus += GetUIStatFromItem(Unit, eStat_Dodge, TmpItem);
					
			if(Unit.IsPsiOperative())
				PsiBonus += GetUIStatFromItem(Unit, eStat_PsiOffense, TmpItem);
		}
	}

	// Subtract stats from an item that is about to be replaced
	if(ReplacedItem.ObjectID > 0)
	{
		if(CheckGameState != None)
			TmpItem = XComGameState_Item(CheckGameState.GetGameStateForObjectID(ReplacedItem.ObjectID));
		else
			TmpItem = XComGameState_Item(History.GetGameStateForObjectID(ReplacedItem.ObjectID));
		EquipmentTemplate = X2EquipmentTemplate(TmpItem.GetMyTemplate());
		
		// Don't include sword boosts or any other equipment in the EquipmentExcludedFromStatBoosts array
		if (EquipmentTemplate != none && EquipmentExcludedFromStatBoosts.Find(EquipmentTemplate.DataName) == INDEX_NONE)
		{
			WillBonus -= GetUIStatFromItem(Unit, eStat_Will, TmpItem);
			AimBonus -= GetUIStatFromItem(Unit, eStat_Offense, TmpItem);
			HealthBonus -= GetUIStatFromItem(Unit, eStat_HP, TmpItem);
			MobilityBonus -= GetUIStatFromItem(Unit, eStat_Mobility, TmpItem);
			TechBonus -= GetUIStatFromItem(Unit, eStat_Hacking, TmpItem);
			ArmorBonus -= GetUIStatFromItem(Unit, eStat_ArmorMitigation, TmpItem);
			DodgeBonus -= GetUIStatFromItem(Unit, eStat_Dodge, TmpItem);
					
			if(Unit.IsPsiOperative())
				PsiBonus -= GetUIStatFromItem(Unit, eStat_PsiOffense, TmpItem);
		}
	}

	if( WillBonus > 0 )
		 Will $= class'UIUtilities_Text'.static.GetColoredText("+"$WillBonus,	eUIState_Good);
	else if (WillBonus < 0)
		Will $= class'UIUtilities_Text'.static.GetColoredText(""$WillBonus,	eUIState_Bad);

	if( AimBonus > 0 )
		Aim $= class'UIUtilities_Text'.static.GetColoredText("+"$AimBonus, eUIState_Good);
	else if (AimBonus < 0)
		Aim $= class'UIUtilities_Text'.static.GetColoredText(""$AimBonus, eUIState_Bad);

	if( HealthBonus > 0 )
		Health $= class'UIUtilities_Text'.static.GetColoredText("+"$HealthBonus, eUIState_Good);
	else if (HealthBonus < 0)
		Health $= class'UIUtilities_Text'.static.GetColoredText(""$HealthBonus, eUIState_Bad);

	if( MobilityBonus > 0 )
		Mobility $= class'UIUtilities_Text'.static.GetColoredText("+"$MobilityBonus, eUIState_Good);
	else if (MobilityBonus < 0)
		Mobility $= class'UIUtilities_Text'.static.GetColoredText(""$MobilityBonus, eUIState_Bad);

	if( TechBonus > 0 )
		Tech $= class'UIUtilities_Text'.static.GetColoredText("+"$TechBonus, eUIState_Good);
	else if (TechBonus < 0)
		Tech $= class'UIUtilities_Text'.static.GetColoredText(""$TechBonus, eUIState_Bad);
	
	if( ArmorBonus > 0 )
		Armor $= class'UIUtilities_Text'.static.GetColoredText("+"$ArmorBonus, eUIState_Good);
	else if (ArmorBonus < 0)
		Armor $= class'UIUtilities_Text'.static.GetColoredText(""$ArmorBonus, eUIState_Bad);

	if( DodgeBonus > 0 )
		Dodge $= class'UIUtilities_Text'.static.GetColoredText("+"$DodgeBonus, eUIState_Good);
	else if (DodgeBonus < 0)
		Dodge $= class'UIUtilities_Text'.static.GetColoredText(""$DodgeBonus, eUIState_Bad);

	if( PsiBonus > 0 )
		Psi $= class'UIUtilities_Text'.static.GetColoredText("+"$PsiBonus, eUIState_Good);
	else if (PsiBonus < 0)
		Psi $= class'UIUtilities_Text'.static.GetColoredText(""$PsiBonus, eUIState_Bad);

	if(Unit.HasPsiGift())
		PsiMarkup.Show();
	else
		PsiMarkup.Hide();

	if(!bSoldierStatsHidden)
	{
		SetSoldierStats(Health, Mobility, Aim, Will, Armor, Dodge, Tech, Psi);
		RefreshCombatSim(Unit);
	}

	Show();
}

simulated function int GetUIStatFromInventory(XComGameState_Unit Unit, ECharStatType Stat)
{
	local int Result;

	Result += Unit.GetUIStatFromInventory(Stat);
	Result += class'UnitUtilities_BO'.static.GetUIStatBonusFromInventory(Unit, Stat);

	return Result;
}

static simulated function int GetUIStatFromItem(XComGameState_Unit Unit, ECharStatType Stat, XComGameState_Item InventoryItem)
{
	local X2EquipmentTemplate EquipmentTemplate;
	EquipmentTemplate = X2EquipmentTemplate(InventoryItem.GetMyTemplate());
	return EquipmentTemplate.GetUIStatMarkup(Stat, InventoryItem) + class'UnitUtilities_BO'.static.GetUIStatBonusFromItem(Unit, Stat, InventoryItem);
}

