// This is an Unreal Script
class TemplateEditors extends Object config(GameCore);

var config array<name> GrenadeAbilities, SuppressionBlockedAbilities, OverwatchAbilities, MedikitAbilities;

static function EditTemplates()
{
	// Tactical
	AddAllDoNotConsumeAllAbilities();
	AddAllPostActivationEvents();
	ChangeAllToGrenadeActionPoints();
	AddSwapAmmoAbilities();
	FixHotloadAmmo();

	if (class'ModConfig'.default.bEnableRulesTweaks)
	{
		AddAllSuppressionConditions();
	}

	ChangeWeaponTier('Sword_MG', 'magnetic'); // Fixes base game bug

	UpgradeAbilityVisualization('LaunchGrenade');
}

// --- Items ---

static function ChangeWeaponTier(name ItemName, name WeaponTech)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2WeaponTemplate				Template;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2WeaponTemplate(DataTemplate);

		if (Template == none)
			return;

		Template.WeaponTech = WeaponTech;
	}
}

// --- Tactical ---

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

static function AddDoNotConsumeAllEffect(name AbilityName, name EffectName)
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
			if (ActionPointCost != none && ActionPointCost.bConsumeAllPoints && ActionPointCost.DoNotConsumeAllEffects.Find(EffectName) == INDEX_NONE)
			{
				ActionPointCost.DoNotConsumeAllEffects.AddItem(EffectName);
				if (ActionPointCost.iNumPoints == 0)
					ActionPointCost.iNumPoints = 1;
			}
		}
	}
}

static function AddAllDoNotConsumeAllAbilities()
{
	local name DataName;

	// Bullet Swarm
	AddDoNotConsumeAllAbility('StandardShot', 'ShadowOps_BulletSwarm');

	// Smoke and Mirrors, Fastball
	foreach default.GrenadeAbilities(DataName)
	{
		AddDoNotConsumeAllAbility(DataName, 'ShadowOps_SmokeAndMirrors');
		AddDoNotConsumeAllEffect(DataName, 'Fastball');
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

static function AddAllPostActivationEvents()
{
	local name DataName;

	// Fastball
	foreach default.GrenadeAbilities(DataName)
	{
		AddPostActivationEvent(DataName, 'GrenadeUsed');
	}

	// Fortify
	foreach default.OverwatchAbilities(DataName)
	{
		AddPostActivationEvent(DataName, 'OverwatchUsed');
	}

	// Second Wind
	foreach default.MedikitAbilities(DataName)
	{
		AddPostActivationEvent(DataName, 'MedikitUsed');
	}
}

static function ChangeToGrenadeActionPoints(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2AbilityCost							AbilityCost;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCost_GrenadeActionPoints		GrenadeCost;
	local int									i;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		for (i = 0; i < Template.AbilityCosts.Length; i++)
		{
			AbilityCost = Template.AbilityCosts[i];
			ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
			if (ActionPointCost != none && !ActionPointCost.IsA('X2AbilityCost_GrenadeActionPoints'))
			{
				GrenadeCost = new class 'X2AbilityCost_GrenadeActionPoints'(ActionPointCost);
				GrenadeCost.AllowedTypes.AddItem('grenade');

				Template.AbilityCosts[i] = GrenadeCost;
			}
		}
	}
}

static function ChangeAllToGrenadeActionPoints()
{
	local name DataName;

	foreach default.GrenadeAbilities(DataName)
	{
		ChangeToGrenadeActionPoints(DataName);
	}
}

static function AddSuppressionCondition(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2Condition							Condition;
	local X2Condition_UnitEffects				ExcludeEffectsCondition;
	local bool									bDoEdit;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		bDoEdit = true;
		foreach Template.AbilityShooterConditions(Condition)
		{
			ExcludeEffectsCondition = X2Condition_UnitEffects(Condition);
			if (ExcludeEffectsCondition != none && ExcludeEffectsCondition.ExcludeEffects.Find('EffectName', class'X2Effect_Suppression'.default.EffectName) != INDEX_NONE)
			{
				bDoEdit = false;
				break;
			}
		}

		if (!bDoEdit)
			continue;

		ExcludeEffectsCondition = new class'X2Condition_UnitEffects';
		ExcludeEffectsCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
		Template.AbilityShooterConditions.AddItem(ExcludeEffectsCondition);
	}
}

static function AddAllSuppressionConditions()
{
	local name DataName;

	foreach default.SuppressionBlockedAbilities(DataName)
	{
		AddSuppressionCondition(DataName);
	}
}

static function UpgradeAbilityVisualization(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.BuildVisualizationFn = class'X2Ability_BO'.static.TypicalAbility_BuildVisualization;
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
