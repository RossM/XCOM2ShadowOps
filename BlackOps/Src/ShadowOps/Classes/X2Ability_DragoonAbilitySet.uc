class X2Ability_DragoonAbilitySet extends X2Ability
	config(GameData_SoldierSkills);

var config array<name> ShieldProtocolImmunities;
var config int ConventionalShieldProtocol, MagneticShieldProtocol, BeamShieldProtocol;
var config int ConventionalShieldsUp, MagneticShieldsUp, BeamShieldsUp;
var config int HeavyArmorBase, HeavyArmorBonus;
var config int FinesseMobilityBonus, FinesseOffenseBonus;
var config int BurstFireHitMod, BurstFireEnvironmentalDamage;
var config float ECMDetectionModifier;
var config int TacticalSenseDodgeBonus, TacticalSenseMaxDodgeBonus;
var config int RestorationHealAmount, RestorationMaxHealAmount, RestorationIncreasedHealAmount, RestorationHealingBonusMultiplier;
var config name RestorationIncreasedHealProject;

var config int ShieldProtocolCharges, StealthProtocolCharges, RestoratonProtocolCharges;
var config int BurstFireCooldown, StasisFieldCooldown, PuppetProtocolCooldown;
var config int BurstFireAmmo;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(ShieldProtocol());
	Templates.AddItem(HeavyArmor());
	Templates.AddItem(Finesse());
	Templates.AddItem(StealthProtocol());
	Templates.AddItem(BurstFire());
	Templates.AddItem(ShieldsUp());
	Templates.AddItem(ShieldsUpTrigger());
	Templates.AddItem(ECM());
	Templates.AddItem(ECMTrigger());
	Templates.AddItem(Rocketeer());
	Templates.AddItem(Vanish());
	Templates.AddItem(VanishTrigger());
	Templates.AddItem(RestorationProtocol());
	Templates.AddItem(StasisField());
	Templates.AddItem(PuppetProtocol());
	Templates.AddItem(TacticalSense());

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

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ShieldProtocol');

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
	Charges.InitialCharges = default.ShieldProtocolCharges;
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

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2Effect ShieldProtocolEffect(string FriendlyName, string LongDescription)
{
	local X2Effect_ShieldProtocol ShieldedEffect;

	ShieldedEffect = new class'X2Effect_ShieldProtocol';
	ShieldedEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	ShieldedEffect.ConventionalAmount = default.ConventionalShieldProtocol;
	ShieldedEffect.MagneticAmount = default.MagneticShieldProtocol;
	ShieldedEffect.BeamAmount = default.BeamShieldProtocol;
	ShieldedEffect.ImmuneTypes = default.ShieldProtocolImmunities;
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);

	return ShieldedEffect;
}

static function X2AbilityTemplate HeavyArmor()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_HeavyArmor                   HeavyArmorEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_HeavyArmor');

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
	HeavyArmorEffect.Base = default.HeavyArmorBase;
	HeavyArmorEffect.Bonus = default.HeavyArmorBonus;
	HeavyArmorEffect.BuildPersistentEffect(1, true, true, true);
	HeavyArmorEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(HeavyArmorEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, default.HeavyArmorBase);

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate Finesse()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_PersistentStatChange         FinesseEffect;
	local X2Condition_UnitInventory				Condition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Finesse');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stickandmove";

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
	FinesseEffect.AddPersistentStatChange(eStat_Offense, default.FinesseOffenseBonus);
	FinesseEffect.AddPersistentStatChange(eStat_Mobility, default.FinesseMobilityBonus);
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
	local X2WeaponTemplate WeaponTemplate, BestWeaponTemplate;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local int idx;

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

		for (idx = 0; idx < XComHQ.Inventory.Length; idx++)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(XComHQ.Inventory[idx].ObjectID));
			WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());

			if (WeaponTemplate != none && WeaponTemplate.bInfiniteItem && WeaponTemplate.WeaponCat == 'rifle' && (BestWeaponTemplate == none || (WeaponTemplate.Tier >= BestWeaponTemplate.Tier)))
			{
				BestWeaponTemplate = WeaponTemplate;
			}
		}

		if (!UnitState.CanAddItemToInventory(BestWeaponTemplate, BestWeaponTemplate.InventorySlot, NewGameState))
		{
			`RedScreen("Unable to add assault rifle to inventory." @ BestWeaponTemplate.DataName);
			return;
		}

		ItemState = BestWeaponTemplate.CreateInstanceFromTemplate(NewGameState);
		ItemState.WeaponAppearance.iWeaponTint = UnitState.kAppearance.iWeaponTint;
		ItemState.WeaponAppearance.nmWeaponPattern = UnitState.kAppearance.nmWeaponPattern;
		UnitState.AddItemToInventory(ItemState, BestWeaponTemplate.InventorySlot, NewGameState);
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

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_StealthProtocol');

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

	Charges = new class 'X2AbilityCharges_RevivalProtocol';
	Charges.InitialCharges = default.StealthProtocolCharges;
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
	TargetProperty.ExcludeCivilian = true;
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

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2Effect StealthProtocolEffect(string FriendlyName, string LongDescription)
{
	local X2Effect_RangerStealth Effect;

	Effect = new class'X2Effect_RangerStealth_BO';
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
	local X2Effect_ApplyWeaponDamage			WeaponDamageEffect;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityToHitCalc_StandardAim		ToHitCalc;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2AbilityMultiTarget_Line				LineMultiTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_BurstFire');

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_barage";
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bLimitTargetIcons = true;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	LineMultiTarget = new class'X2AbilityMultiTarget_Line';
	Template.AbilityMultiTargetStyle = LineMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Line';

	Template.CinescriptCameraType = "StandardGunFiring";	

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 0; //Uses typical action points of weapon:
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.BurstFireCooldown;
	Template.AbilityCooldown = Cooldown;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.BurstFireAmmo;
	Template.AbilityCosts.AddItem(AmmoCost);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = default.BurstFireHitMod;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	//Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	//Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	//Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	WeaponDamageEffect = class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect();
	WeaponDamageEffect.EnvironmentalDamageAmount = default.BurstFireEnvironmentalDamage;
	WeaponDamageEffect.bApplyToWorldOnHit = true;
	WeaponDamageEffect.bApplyToWorldOnMiss = true;
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	Template.AddMultiTargetEffect(class'X2Ability'.default.WeaponUpgradeMissDamage);
	Template.bAllowAmmoEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate ShieldsUp()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('ShadowOps_ShieldsUp', "img:///UILibrary_PerkIcons.UIPerk_absorption_fields", false);
	Template.AdditionalAbilities.AddItem('ShadowOps_ShieldsUpTrigger');

	return Template;
}

static function X2AbilityTemplate ShieldsUpTrigger()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ShieldsUpTrigger');

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
	ShieldedEffect.EffectName = 'ShieldsUpEffect';
	ShieldedEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	ShieldedEffect.ConventionalAmount = default.ConventionalShieldsUp;
	ShieldedEffect.MagneticAmount = default.MagneticShieldsUp;
	ShieldedEffect.BeamAmount = default.BeamShieldsUp;
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_absorption_fields", true);

	return ShieldedEffect;
}

static function X2AbilityTemplate ECM()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('ShadowOps_ECM', "img:///UILibrary_PerkIcons.UIPerk_jamthesignal", false);
	Template.AdditionalAbilities.AddItem('ShadowOps_ECMTrigger');

	return Template;
}

static function X2AbilityTemplate ECMTrigger()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityMultiTarget_AllUnits			MultiTargetStyle;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_ECMTrigger');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_jamthesignal";
	Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	MultiTargetStyle = new class'X2AbilityMultiTarget_AllAllies';
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

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
	Effect.EffectName = 'ECMEffect';
	Effect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	Effect.AddPersistentStatChange(eStat_DetectionModifier, default.ECMDetectionModifier);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, FriendlyName, LongDescription, "img:///UILibrary_PerkIcons.UIPerk_jamthesignal", true);

	return Effect;
}

static function X2AbilityTemplate Vanish()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('ShadowOps_Vanish', "img:///UILibrary_PerkIcons.UIPerk_quadricepshypertrophy", true);
	Template.AdditionalAbilities.AddItem('ShadowOps_VanishTrigger');

	return Template;
}

static function X2AbilityTemplate VanishTrigger()
{
	local X2AbilityTemplate						Template;
	local X2Effect_RangerStealth                StealthEffect;
	local X2Condition_NotVisibleToEnemies		VisibilityCondition;
	local X2AbilityTrigger_EventListener		EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_VanishTrigger');

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

	StealthEffect = new class'X2Effect_RangerStealth_BO';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate RestorationProtocol()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitStatCheck             UnitStatCheckCondition;
	local X2AbilityCharges                      Charges;
	local X2AbilityCost_Charges                 ChargeCost;
	local X2Effect_RestorationProtocol			RestorationEffect;			
	local X2Effect_RemoveEffects				RemoveEffects;
	local X2Effect_Persistent					StandUpEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_RestorationProtocol');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_regeneration";
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

	Charges = new class 'X2AbilityCharges_RevivalProtocol';
	Charges.InitialCharges = default.RestoratonProtocolCharges;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = false;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	//Hack: Do this instead of ExcludeDead, to only exclude properly-dead or bleeding-out units.
	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);
	Template.AbilityTargetConditions.AddItem(UnitStatCheckCondition);

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_RestorationProtocol');

	RestorationEffect = new class'X2Effect_RestorationProtocol';
	RestorationEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	RestorationEffect.HealAmount = default.RestorationHealAmount;
	RestorationEffect.MaxHealAmount = default.RestorationMaxHealAmount;
	RestorationEffect.IncreasedHealProject = default.RestorationIncreasedHealProject;
	RestorationEffect.IncreasedAmountToHeal = default.RestorationIncreasedHealAmount;
	RestorationEffect.HealingBonusMultiplier = default.RestorationHealingBonusMultiplier;
	RestorationEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true);
	Template.AddTargetEffect(RestorationEffect);

	Template.AddTargetEffect(class'X2Ability_SpecialistAbilitySet'.static.RemoveAllEffectsByDamageType());

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);
	Template.AddTargetEffect(RemoveEffects);

	StandUpEffect = new class'X2Effect_Persistent';
	StandUpEffect.BuildPersistentEffect(1);
	StandUpEffect.VisualizationFn = UnconsciousVisualizationRemoved;
	Template.AddTargetEffect(StandUpEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.bStationaryWeapon = true;
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
	Template.bSkipPerkActivationActions = true;
	Template.bShowActivation = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');

	Template.CustomSelfFireAnim = 'NO_RevivalProtocol';

	Template.bCrossClassEligible = false;

	return Template;
}

static function UnconsciousVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);

	if( UnitState == none)
		return;

	if (!XGUnit(UnitState.GetVisualizer()).GetPawn().bFinalRagdoll)
		return;

	class 'X2StatusEffects'.static.UnconsciousVisualizationRemoved(VisualizeGameState, BuildTrack, EffectApplyResult);
}

static function X2AbilityTemplate StasisField()
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2AbilityCooldown                     Cooldown;
	local X2Effect_Stasis						StasisEffect;
	local X2AbilityMultiTarget_Radius			RadiusMultiTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_StasisField');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stasis";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.bLimitTargetIcons = true;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.StasisFieldCooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = 6;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	StasisEffect = new class'X2Effect_Stasis';
	StasisEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	StasisEffect.bUseSourcePlayerState = true;
	StasisEffect.bRemoveWhenTargetDies = true;          //  probably shouldn't be possible for them to die while in stasis, but just in case
	StasisEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage);
	Template.AddMultiTargetEffect(StasisEffect);
	Template.AddTargetEffect(StasisEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate PuppetProtocol()
{
	local X2AbilityTemplate             Template;
	local X2AbilityCost_ActionPoints    ActionPointCost;
	local X2Condition_UnitProperty      UnitPropertyCondition;
	local X2Effect_MindControl          MindControlEffect;
	local X2Condition_UnitEffects       EffectCondition;
	local X2AbilityCharges              Charges;
	local X2AbilityCost_Charges         ChargeCost;
	local X2AbilityCooldown             Cooldown;
	local X2Effect_BreakUnitConcealment	BreakConcealmentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_PuppetProtocol');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_domination";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.Hostility = eHostility_Neutral;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = 1;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	ChargeCost.bOnlyOnHit = true;
	Template.AbilityCosts.AddItem(ChargeCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.PuppetProtocolCooldown;
	Cooldown.bDoNotApplyOnHit = true;
	Template.AbilityCooldown = Cooldown;
	
	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_FastHacking';

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeOrganic = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);	
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	EffectCondition = new class'X2Condition_UnitEffects';
	EffectCondition.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsMindControlled');
	Template.AbilityTargetConditions.AddItem(EffectCondition);

	//  mind control target
	MindControlEffect = class'X2StatusEffects'.static.CreateMindControlStatusEffect(1, true, true);
	Template.AddTargetEffect(MindControlEffect);

	// On failure, break concealment
	BreakConcealmentEffect = new class'X2Effect_BreakUnitConcealment';
	BreakConcealmentEffect.bApplyOnHit = false;
	BreakConcealmentEffect.bApplyOnMiss = true;
	Template.AddShooterEffect(BreakConcealmentEffect);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.ActivationSpeech = 'Domination';
	Template.SourceMissSpeech = 'SoldierFailsControl';

	Template.bStationaryWeapon = true;
	Template.PostActivationEvents.AddItem('ItemRecalled');
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
	
	return Template;
}

static function X2AbilityTemplate Rocketeer()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_BonusItemCharges             ItemChargesEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_Rocketeer');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_rocketeer";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	ItemChargesEffect = new class'X2Effect_BonusItemCharges';
	ItemChargesEffect.EffectName = 'Rocketeer';
	ItemChargesEffect.ApplyToSlots.AddItem(eInvSlot_HeavyWeapon);
	ItemChargesEffect.BuildPersistentEffect(1, true, true, true);
	ItemChargesEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(ItemChargesEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

static function X2AbilityTemplate TacticalSense()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_TacticalSense				Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShadowOps_TacticalSense');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_tacticalsense";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	Effect = new class'X2Effect_TacticalSense';
	Effect.DodgeModifier = default.TacticalSenseDodgeBonus;
	Effect.MaxDodgeModifier = default.TacticalSenseMaxDodgeBonus;
	Effect.BuildPersistentEffect(1, true, true, true);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

