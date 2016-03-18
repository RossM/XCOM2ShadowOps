class X2Ability_DragoonAbilitySet extends X2Ability
	config(GameData_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(ShieldProtocol());
	Templates.AddItem(HeavyArmor());
	Templates.AddItem(Finesse());
	Templates.AddItem(StealthProtocol());
	Templates.AddItem(BurstFire());
	Templates.AddItem(ShieldsUp());
	Templates.AddItem(ECM());
	Templates.AddItem(PurePassive('Rocketeer', "img:///UILibrary_PerkIcons.UIPerk_rocketeer", true));
	Templates.AddItem(Vanish());
	Templates.AddItem(VanishHide());

	return Templates;
}

static function X2AbilityTemplate ShieldProtocol()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2AbilityCharges                      Charges;
	local X2AbilityCost_Charges                 ChargeCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShieldProtocol');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;
	Template.bLimitTargetIcons = true;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = 2;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('ShieldProtocol', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	Template.AddTargetEffect(ShieldProtocolEffect(Template.LocFriendlyName, Template.GetMyLongDescription()));

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.bStationaryWeapon = true;
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
	Template.bSkipPerkActivationActions = true;
	Template.bShowActivation = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');

	Template.CustomSelfFireAnim = 'NO_DefenseProtocolA';

	return Template;
}

static function X2Effect ShieldProtocolEffect(string FriendlyName, string LongDescription)
{
	local X2Effect_ShieldProtocol ShieldedEffect;

	ShieldedEffect = new class'X2Effect_ShieldProtocol';
	ShieldedEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	ShieldedEffect.BaseShield = 3;
	ShieldedEffect.BonusShield = 2;
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);

	return ShieldedEffect;
}

static function X2AbilityTemplate HeavyArmor()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_HeavyArmor                   HeavyArmorEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HeavyArmor');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_willtosurvive";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	HeavyArmorEffect = new class'X2Effect_HeavyArmor';
	HeavyArmorEffect.BuildPersistentEffect(1, true, true, true);
	HeavyArmorEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(HeavyArmorEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, 1);

	return Template;
}

static function X2AbilityTemplate Finesse()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_PersistentStatChange         FinesseEffect;
	local X2Condition_UnitInventory				Condition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Finesse');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sprinter";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	FinesseEffect = new class'X2Effect_PersistentStatChange';
	FinesseEffect.EffectName = 'Finesse';
	FinesseEffect.BuildPersistentEffect(1, true, true, true);
	FinesseEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	FinesseEffect.AddPersistentStatChange(eStat_Offense, 10);
	FinesseEffect.AddPersistentStatChange(eStat_Mobility, 3);
	Template.AddTargetEffect(FinesseEffect);

	Condition = new class'X2Condition_UnitInventory';
	Condition.RelevantSlot = eInvSlot_PrimaryWeapon;
	Condition.RequireWeaponCategory = 'rifle';
	Template.AbilityTargetConditions.AddItem(Condition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.SoldierAbilityPurchasedFn = FinessePurchased;

	Template.bCrossClassEligible = false;

	return Template;
}

static function FinessePurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local XComGameState_Item RelevantItem, ItemState;
	local X2WeaponTemplate WeaponTemplate, NewWeaponTemplate;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	// Grab HQ Object
	History = `XCOMHISTORY;
	
	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if(XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
	}

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if (WeaponTemplate == none || WeaponTemplate.WeaponCat != 'rifle')
	{
		if (RelevantItem != none)
		{
			UnitState.RemoveItemFromInventory(RelevantItem , NewGameState);
			XComHQ.PutItemInInventory(NewGameState, RelevantItem);
		}

		NewWeaponTemplate = X2WeaponTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('AssaultRifle_CV'));

		if (!UnitState.CanAddItemToInventory(NewWeaponTemplate, NewWeaponTemplate.InventorySlot, NewGameState))
		{
			`RedScreen("Unable to add assault rifle to inventory." @ NewWeaponTemplate.DataName);
			return;
		}

		ItemState = NewWeaponTemplate.CreateInstanceFromTemplate(NewGameState);
		ItemState.WeaponAppearance.iWeaponTint = UnitState.kAppearance.iWeaponTint;
		ItemState.WeaponAppearance.nmWeaponPattern = UnitState.kAppearance.nmWeaponPattern;
		UnitState.AddItemToInventory(ItemState, NewWeaponTemplate.InventorySlot, NewGameState);
		NewGameState.AddStateObject(ItemState);
	}
}

static function X2AbilityTemplate StealthProtocol()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2AbilityCharges                      Charges;
	local X2AbilityCost_Charges                 ChargeCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'StealthProtocol');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stealth";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;
	Template.bLimitTargetIcons = true;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = 1;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('RangerStealth', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_Stealth');

	Template.AddTargetEffect(StealthProtocolEffect(Template.LocFriendlyName, Template.GetMyLongDescription()));

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.bStationaryWeapon = true;
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
	Template.bSkipPerkActivationActions = true;
	Template.bShowActivation = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');

	Template.CustomSelfFireAnim = 'NO_DefenseProtocolA';

	return Template;
}

static function X2Effect StealthProtocolEffect(string FriendlyName, string LongDescription)
{
	local X2Effect_RangerStealth Effect;

	Effect = new class'X2Effect_RangerStealth';
	Effect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_stealth", true);
	Effect.bRemoveWhenTargetConcealmentBroken = true;

	return Effect;
}

static function X2AbilityTemplate BurstFire()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCost_Ammo					AmmoCost;
	local X2Effect_ApplyDirectionalWorldDamage  WorldDamage;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BurstFire');

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_demolition";
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bLimitTargetIcons = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 4;
	Template.AbilityCooldown = Cooldown;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 2;
	Template.AbilityCosts.AddItem(AmmoCost);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = 20;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = true;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = true;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
	WorldDamage.PlusNumZTiles = 1;
	WorldDamage.bHitTargetTile = true;
	Template.AddTargetEffect(WorldDamage);

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AssociatedPassives.AddItem('HoloTargeting');
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.AddTargetEffect(class'X2Ability'.default.WeaponUpgradeMissDamage);
	Template.bAllowAmmoEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate ShieldsUp()
{
	local X2AbilityTemplate                     Template;
	//local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShieldsUp');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";
	Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	MultiTargetStyle = new class'X2AbilityMultiTarget_AllAllies';
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('ShieldProtocol', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	Template.AddMultiTargetEffect(ShieldsUpEffect(Template.LocFriendlyName, Template.GetMyLongDescription()));

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2Effect ShieldsUpEffect(string FriendlyName, string LongDescription)
{
	local X2Effect_ShieldProtocol ShieldedEffect;

	ShieldedEffect = new class'X2Effect_ShieldProtocol';
	ShieldedEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	ShieldedEffect.BaseShield = 2;
	ShieldedEffect.BonusShield = 1;
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);

	return ShieldedEffect;
}

static function X2AbilityTemplate ECM()
{
	local X2AbilityTemplate                     Template;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ECM');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bioelectricskin";
	Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	MultiTargetStyle = new class'X2AbilityMultiTarget_AllAllies';
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('ECM', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	Template.AddMultiTargetEffect(ECMEffect(Template.LocFriendlyName, Template.GetMyLongDescription()));

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2Effect ECMEffect(string FriendlyName, string LongDescription)
{
	local X2Effect_PersistentStatChange Effect;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'ECM';
	Effect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	Effect.AddPersistentStatChange(eStat_DetectionModifier, 0.2);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);

	return Effect;
}

static function X2AbilityTemplate Vanish()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('Vanish', "img:///UILibrary_PerkIcons.UIPerk_quadricepshypertrophy", true);
	Template.AdditionalAbilities.AddItem('VanishHide');

	return Template;
}

static function X2AbilityTemplate VanishHide()
{
	local X2AbilityTemplate						Template;
	local X2Effect_RangerStealth                StealthEffect;
	local X2Condition_NotVisibleToEnemies		VisibilityCondition;
	local X2AbilityTrigger_EventListener		EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'VanishHide');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_quadricepshypertrophy";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'PlayerTurnBegun';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');

	VisibilityCondition = new class'X2Condition_NotVisibleToEnemies';
	Template.AbilityShooterConditions.AddItem(VisibilityCondition);

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = true;

	return Template;
}
