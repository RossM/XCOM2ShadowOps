class UISoldierHeader_BO extends UISoldierHeader;

public function PopulateData(optional XComGameState_Unit Unit, optional StateObjectReference NewItem, optional StateObjectReference ReplacedItem, optional XComGameState NewCheckGameState)
{
	local int iRank, WillBonus, AimBonus, HealthBonus, MobilityBonus, TechBonus, PsiBonus, ArmorBonus, DodgeBonus, DefenseBonus;
	local string classIcon, rankIcon, flagIcon, Will, Aim, Health, Mobility, Tech, Psi, Armor, Dodge, Defense;
	local X2SoldierClassTemplate SoldierClass;
	local X2EquipmentTemplate EquipmentTemplate;
	local XComGameState_Item TmpItem;
	local XComGameStateHistory History;
	local string StatusValue, StatusLabel, StatusDesc, StatusTimeLabel, StatusTimeValue, DaysValue;
	local UIArmory_Loadout LoadoutScreen;
	local EInventorySlot EquipmentSlot;

	History = `XCOMHISTORY;
	CheckGameState = NewCheckGameState;

	LoadoutScreen = UIArmory_Loadout(Screen);
	// Ignore mobility change on grenade/ammo slot items (we remove their weight penalty)
	if (LoadoutScreen != none)
	{
		EquipmentSlot = UIArmory_LoadoutItem(LoadoutScreen.EquippedList.GetSelectedItem()).EquipmentSlot;
	}


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
							  classIcon, Caps(SoldierClass != None ? SoldierClass.DisplayName : ""),
							  rankIcon, Caps(Unit.IsSoldier() ? `GET_RANK_STR(Unit.GetRank(), Unit.GetSoldierClassTemplateName()) : ""),
							  flagIcon, (Unit.ShowPromoteIcon()), DaysValue);
	}
	else
	{
		SetSoldierInfo( Caps(Unit.GetName( eNameType_FullNick )),
							  StatusLabel, StatusValue,
							  m_strMissionsLabel, string(Unit.GetNumMissions()),
							  m_strKillsLabel, string(Unit.GetNumKills()),
							  classIcon, Caps(SoldierClass != None ? SoldierClass.DisplayName : ""),
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
	Defense = string(int(Unit.GetCurrentStat(eStat_Defense)) + Unit.GetUIStatFromAbilities(eStat_Defense));

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
	DefenseBonus = GetUIStatFromInventory(Unit, eStat_Defense);

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
			if (EquipmentSlot != eInvSlot_GrenadePocket && EquipmentSlot != eInvSlot_AmmoPocket)
				MobilityBonus += GetUIStatFromItem(Unit, eStat_Mobility, TmpItem);
			TechBonus += GetUIStatFromItem(Unit, eStat_Hacking, TmpItem);
			ArmorBonus += GetUIStatFromItem(Unit, eStat_ArmorMitigation, TmpItem);
			DodgeBonus += GetUIStatFromItem(Unit, eStat_Dodge, TmpItem);
			DefenseBonus += GetUIStatFromItem(Unit, eStat_Defense, TmpItem);
					
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
			if (EquipmentSlot != eInvSlot_GrenadePocket && EquipmentSlot != eInvSlot_AmmoPocket)
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

	if( DefenseBonus > 0 )
		Defense $= class'UIUtilities_Text'.static.GetColoredText("+"$DefenseBonus, eUIState_Good);
	else if (DefenseBonus < 0)
		Defense $= class'UIUtilities_Text'.static.GetColoredText(""$DefenseBonus, eUIState_Bad);

	if(Unit.HasPsiGift())
		PsiMarkup.Show();
	else
		PsiMarkup.Hide();

	if(!bSoldierStatsHidden)
	{
		SetSoldierStatsExt(Health, Mobility, Aim, Will, Armor, Dodge, Tech, Psi, Defense);
		RefreshCombatSim(Unit);
	}

	Show();
}

// Added Defense
public function SetSoldierStatsExt(optional string Health	 = "", 
								optional string Mobility = "", 
								optional string Aim	     = "", 
								optional string Will     = "", 
								optional string Armor	 = "", 
								optional string Dodge	 = "", 
								optional string Tech	 = "", 
								optional string Psi		 = "",
								optional string Defense  = "")
{
	//Stats will stack to the right, and clear out any unused stats 

	mc.BeginFunctionOp("SetSoldierStats");
	
	if( Health != "" )
	{
		mc.QueueString(m_strHealthLabel);
		mc.QueueString(Health);
	}
	if( Mobility != "" )
	{
		mc.QueueString(m_strMobilityLabel);
		mc.QueueString(Mobility);
	}
	if( Aim != "" )
	{
		mc.QueueString(m_strAimLabel);
		mc.QueueString(Aim);
	}
	if( Will != "" )
	{
		mc.QueueString(m_strWillLabel);
		mc.QueueString(Will);
	}
	if( Armor != "" )
	{
		mc.QueueString(m_strArmorLabel);
		mc.QueueString(Armor);
	}
	if( Defense != "" )
	{
		mc.QueueString(class'XLocalizedData'.default.DefenseLabel);
		mc.QueueString(Defense);
	}
	if( Dodge != "" )
	{
		mc.QueueString(m_strDodgeLabel);
		mc.QueueString(Dodge);
	}
	if( Psi != "" )
	{
		mc.QueueString( class'UIUtilities_Text'.static.GetColoredText(m_strPsiLabel, eUIState_Psyonic) );
		mc.QueueString( class'UIUtilities_Text'.static.GetColoredText(Psi, eUIState_Psyonic) );
	}
	else if( Tech != "" )
	{
		mc.QueueString(m_strTechLabel);
		mc.QueueString(Tech);
	}

	mc.EndOp();
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

public function RefreshCombatSim(XComGameState_Unit Unit)
{
	local string Label, IconPath, BorderColor;
	local int i, AvailableSlots;
	local XComGameState_Item ImplantItem;
	local array<XComGameState_Item> EquippedImplants;
	
	EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);
	AvailableSlots = Unit.GetCurrentStat(eStat_CombatSims);

	MC.BeginFunctionOp("SetSoldierCombatSim");
	for(i = 0; i < max(class'UIArmory_Implants'.default.MaxImplantSlots, AvailableSlots); ++i)
	{
		if(i < AvailableSlots && i < EquippedImplants.Length)
		{
			ImplantItem = EquippedImplants[i];
			Label = class'UIUtilities_Text'.static.GetColoredText(ImplantItem.GetMyTemplate().GetItemFriendlyName(ImplantItem.ObjectID), eUIState_Normal);
			IconPath = class'UIUtilities_Image'.static.GetPCSImage(ImplantItem);
			BorderColor = class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR;
		}
		else if(i < AvailableSlots)
		{
			Label = m_strPCSLabelOpen;
			BorderColor = class'UIUtilities_Colors'.const.GOOD_HTML_COLOR;
		}
		else
		{
			Label = m_strPCSLabelLocked;
			BorderColor = class'UIUtilities_Colors'.const.DISABLED_HTML_COLOR;
		}

		MC.QueueString(Label);
		MC.QueueString(IconPath);
		MC.QueueString(BorderColor);
	}

	MC.EndOp();
}
