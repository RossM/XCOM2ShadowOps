class TemplateEditors_Infantry extends Object config(GameCore);

var config array<name> OverwatchAbilities, MedikitAbilities, FixTacticianAbilities;

var X2Effect_ApplyWeaponDamage WeaponUpgradeMissDamage;

static function EditTemplates()
{
	local name DataName;

	`Log("TemplateEditors_Infantry.EditTemplates");

	// Bullet Swarm
	`Log("SOInfantry: Editing" @ 'StandardShot');
	AddDoNotConsumeAllAbility('StandardShot', 'ShadowOps_BulletSwarm');

	// Fortify
	foreach default.OverwatchAbilities(DataName)
	{
		`Log("SOInfantry: Editing" @ DataName);
		AddPostActivationEvent(DataName, 'OverwatchUsed');
	}

	// Second Wind
	foreach default.MedikitAbilities(DataName)
	{
		`Log("SOInfantry: Editing" @ DataName);
		AddPostActivationEvent(DataName, 'MedikitUsed');
	}

	AddSwapAmmoAbilities();
	FixHotloadAmmo();

	// Second Wind
	foreach default.FixTacticianAbilities(DataName)
	{
		`Log("SOInfantry: Editing" @ DataName);
		AddMissDamage(DataName);
	}

	// Fix up Ever Vigilant
	FixEverVigilant();
}

static function AddDoNotConsumeAllAbility(name AbilityName, name PassiveAbilityName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local array<X2AbilityTemplate>		TemplateAllDifficulties;
	local X2AbilityTemplate				Template;
	local X2AbilityCost					AbilityCost;
	local X2AbilityCost_ActionPoints	ActionPointCost;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		foreach Template.AbilityCosts(AbilityCost)
		{
			ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
			if (ActionPointCost != none && ActionPointCost.bConsumeAllPoints && ActionPointCost.DoNotConsumeAllSoldierAbilities.Find(PassiveAbilityName) == INDEX_NONE)
			{
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem(PassiveAbilityName);
				if (ActionPointCost.iNumPoints == 0)
					ActionPointCost.iNumPoints = 1;
			}
		}
	}
}

static function AddPostActivationEvent(name AbilityName, name EventName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local array<X2AbilityTemplate>		TemplateAllDifficulties;
	local X2AbilityTemplate				Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		if (Template.PostActivationEvents.Find(EventName) == INDEX_NONE)
			Template.PostActivationEvents.AddItem(EventName);
	}
}

static function AddMissDamage(name AbilityName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local array<X2AbilityTemplate>		TemplateAllDifficulties;
	local X2AbilityTemplate				Template;
	local X2Effect						Effect;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		foreach Template.AbilityTargetEffects(Effect)
		{
			if (Effect.IsA('X2Effect_ApplyWeaponDamage') && Effect.bApplyOnMiss == true)
				return;
		}
		foreach Template.AbilityMultiTargetEffects(Effect)
		{
			if (Effect.IsA('X2Effect_ApplyWeaponDamage') && Effect.bApplyOnMiss == true)
				return;
		}
		if (Template.AbilityTargetEffects.Length > 0)
			Template.AddTargetEffect(default.WeaponUpgradeMissDamage);
		if (Template.AbilityMultiTargetEffects.Length > 0)
			Template.AddMultiTargetEffect(default.WeaponUpgradeMissDamage);
	}
}

static function AddSwapAmmoAbilities()
{
	local X2ItemTemplateManager			ItemManager;
	local Array<name>					TemplateNames;
	local name							ItemName;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2AmmoTemplate				Template;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(ItemName)
	{
		ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
		foreach DataTemplateAllDifficulties(DataTemplate)
		{
			Template = X2AmmoTemplate(DataTemplate);

			if (Template == none)
				continue;

			if (Template.Abilities.Find('ShadowOps_SwapAmmo') == INDEX_NONE)
				Template.Abilities.AddItem('ShadowOps_SwapAmmo');
		}
	}
}

static function FixHotloadAmmo()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties('HotLoadAmmo', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.BuildNewGameStateFn = HotLoadAmmo_BuildGameState;
	}
}

simulated static function XComGameState HotLoadAmmo_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item AmmoState, WeaponState, NewWeaponState;
	local array<XComGameState_Item> UtilityItems;
	local X2AmmoTemplate AmmoTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local bool FoundAmmo;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	AbilityContext = XComGameStateContext_Ability(Context);
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));
	WeaponState = AbilityState.GetSourceWeapon();
	NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', WeaponState.ObjectID));
	WeaponTemplate = X2WeaponTemplate(WeaponState.GetMyTemplate());

	UtilityItems = UnitState.GetAllItemsInSlot(eInvSlot_AmmoPocket);
	foreach UtilityItems(AmmoState)
	{
		AmmoTemplate = X2AmmoTemplate(AmmoState.GetMyTemplate());
		if (AmmoTemplate != none && AmmoTemplate.IsWeaponValidForAmmo(WeaponTemplate))
		{
			FoundAmmo = true;
			break;
		}
	}
	if (!FoundAmmo)
	{
		UtilityItems = UnitState.GetAllItemsInSlot(eInvSlot_Utility);
		foreach UtilityItems(AmmoState)
		{
			AmmoTemplate = X2AmmoTemplate(AmmoState.GetMyTemplate());
			if (AmmoTemplate != none && AmmoTemplate.IsWeaponValidForAmmo(WeaponTemplate))
			{
				FoundAmmo = true;
				break;
			}
		}
	}

	if (FoundAmmo)
	{
		NewWeaponState.LoadedAmmo = AmmoState.GetReference();
		NewWeaponState.Ammo += AmmoState.GetClipSize();
	}

	NewGameState.AddStateObject(UnitState);
	NewGameState.AddStateObject(NewWeaponState);

	return NewGameState;
}

static function FixEverVigilant()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local XMBAbilityTrigger_EventListener		EventListener;
	local X2Effect_ActivateOverwatch			Effect;
	local X2Condition_UnitValue					Condition;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties('EverVigilant', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.AbilityTriggers.Length = 0;

		EventListener = new class'XMBAbilityTrigger_EventListener';
		EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
		EventListener.ListenerData.EventID = 'PlayerTurnEnded';
		EventListener.ListenerData.Filter = eFilter_Player;
		EventListener.bSelfTarget = true;
		Template.AbilityTriggers.AddItem(EventListener);

		Effect = new class'X2Effect_ActivateOverwatch';
		Effect.UnitValueName = class'X2Ability_SpecialistAbilitySet'.default.EverVigilantEffectName;
		Template.AddTargetEffect(Effect);

		Condition = new class'X2Condition_UnitValue';
		Condition.AddCheckValue('NonMoveActionsThisTurn', 0, eCheck_Exact);
		Template.AbilityShooterConditions.AddItem(Condition);
	}
}

defaultproperties
{
	Begin Object Class=X2Effect_ApplyWeaponDamage Name=DefaultWeaponUpgradeMissDamage
		bApplyOnHit=false
		bApplyOnMiss=true
		bIgnoreBaseDamage=true
		DamageTag="Miss"
		bAllowWeaponUpgrade=true
		bAllowFreeKill=false
	End Object
	WeaponUpgradeMissDamage = DefaultWeaponUpgradeMissDamage;
}