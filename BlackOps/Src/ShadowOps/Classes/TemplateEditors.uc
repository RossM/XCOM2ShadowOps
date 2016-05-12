// This is an Unreal Script
class TemplateEditors extends Object config(GameCore);

var config array<name> ExtraStartingItems, DisabledItems;
var config array<name> GrenadeAbilities, SuppressionBlockedAbilities;

static function EditTemplates()
{
	local name DataName;

	// Strategy
	AddGtsUnlocks();

	// Tactical
	AddAllDoNotConsumeAllAbilities();
	FixAllSimpleStandardAims();
	ChangeAllToGrenadeActionPoints();
	AddAllSuppressionConditions();

	CreateCompatAbilities();

	// Items
	foreach default.ExtraStartingItems(DataName)
	{
		ChangeToStartingItem(DataName);
	}
	foreach default.DisabledItems(DataName)
	{
		DisableItem(DataName);
	}
	EditPlatedVest('PlatedVest');
	ChangeWeaponTier('Sword_MG', 'magnetic'); // Fixes base game bug
}

// --- Strategy ---

static function AddGtsUnlocks()
{
	local X2StrategyElementTemplateManager StrategyManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2FacilityTemplate Template;

	StrategyManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	StrategyManager.FindDataTemplateAllDifficulties('OfficerTrainingSchool', DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2FacilityTemplate(DataTemplate);

		Template.SoldierUnlockTemplates.AddItem('PackmasterUnlock');
		Template.SoldierUnlockTemplates.AddItem('DamnGoodGroundUnlock');
		Template.SoldierUnlockTemplates.AddItem('AdrenalineSurgeUnlock');
		Template.SoldierUnlockTemplates.AddItem('TacticalSenseUnlock');
	}
}

// --- Items ---

static function ChangeToStartingItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2ItemTemplate				Template;
	
	DisableItem(ItemName);

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2ItemTemplate(DataTemplate);

		Template.StartingItem = true;
	}
}

static function EditPlatedVest(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2EquipmentTemplate			Template;
	local ArtifactCost					Resources, Artifacts;
	
	DisableItem(ItemName);

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2EquipmentTemplate(DataTemplate);

		Template.CanBeBuilt = true;
		Template.TradingPostValue = 15;
		Template.PointsToComplete = 0;
		Template.Tier = 1;

		// Requirements
		Template.Requirements.RequiredTechs.AddItem('HybridMaterials');

		// Cost
		Resources.ItemTemplateName = 'Supplies';
		Resources.Quantity = 30;
		Template.Cost.ResourceCosts.AddItem(Resources);

		Artifacts.ItemTemplateName = 'CorpseAdventTrooper';
		Artifacts.Quantity = 4;
		Template.Cost.ArtifactCosts.AddItem(Artifacts);
	}
}

static function DisableItem(name ItemName)
{
	local X2ItemTemplateManager			ItemManager;
	local array<X2DataTemplate>			DataTemplateAllDifficulties;
	local X2DataTemplate				DataTemplate;
	local X2ItemTemplate				Template, BaseTemplate;
	
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemManager.FindDataTemplateAllDifficulties(ItemName, DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2ItemTemplate(DataTemplate);

		if (Template.BaseItem != '')
			BaseTemplate = ItemManager.FindItemTemplate(Template.BaseItem);

		Template.StartingItem = false;
		Template.CanBeBuilt = false;
		Template.RewardDecks.Length = 0;
		Template.CreatorTemplateName = '';
		Template.BaseItem = '';
		Template.Cost.ResourceCosts.Length = 0;
		Template.Cost.ArtifactCosts.Length = 0;
		Template.Requirements.RequiredTechs.Length = 0;

		if (BaseTemplate != none)
		{
			BaseTemplate.HideIfResearched = '';
		}
	}
}

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
			if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllSoldierAbilities.Find(PassiveAbilityName) == INDEX_NONE)
			{
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem(PassiveAbilityName);
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
			if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllEffects.Find(EffectName) == INDEX_NONE)
			{
				ActionPointCost.DoNotConsumeAllEffects.AddItem(EffectName);
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

	// Entrench
	AddDoNotConsumeAllAbility('HunkerDown', 'ShadowOps_Entrench');
}

static function FixSimpleStandardAim(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2AbilityToHitCalc					ToHitCalc;
	local X2AbilityToHitCalc_StandardAim_BO		NewToHitCalc;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		ToHitCalc = Template.AbilityToHitCalc;
		if (ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim') && !ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim_BO'))
		{
			NewToHitCalc = new class'X2AbilityToHitCalc_StandardAim_BO'(X2AbilityToHitCalc_StandardAim(ToHitCalc));
			Template.AbilityToHitCalc = NewToHitCalc;
		}

		ToHitCalc = Template.AbilityToHitOwnerOnMissCalc;
		if (ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim') && !ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim_BO'))
		{
			NewToHitCalc = new class'X2AbilityToHitCalc_StandardAim_BO'(X2AbilityToHitCalc_StandardAim(ToHitCalc));
			Template.AbilityToHitOwnerOnMissCalc = NewToHitCalc;
		}
	}
}

static function FixAllSimpleStandardAims()
{
	FixSimpleStandardAim('StandardShot');
	FixSimpleStandardAim('PistolStandardShot');
	FixSimpleStandardAim('SniperStandardFire');
	FixSimpleStandardAim('AnimaGate');
	FixSimpleStandardAim('LightningHands');
	
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

// This function creates extra versions of all the ShadowOps_* abilities without the ShadowOps_ prefix,
// unless an ability without the prefix already exists. The extra versions are needed for games saved
// during tactical play with a previous mod version to continue working.
static function CreateCompatAbilities()
{
	local X2AbilityTemplateManager				AbilityManager;
	local Array<name>							TemplateNames;
	local name									OldTemplateName, NewTemplateName;
	local X2AbilityTemplate						OldTemplate, NewTemplate;
	local string								Prefix;
	local int									PrefixLength;

	Prefix = "ShadowOps_";
	PrefixLength = Len(Prefix);

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(OldTemplateName)
	{
		if (Left(OldTemplateName, PrefixLength) == Prefix)
		{
			NewTemplateName = name(Mid(OldTemplateName, PrefixLength));

			if (AbilityManager.FindAbilityTemplate(NewTemplateName) == none)
			{
				OldTemplate = AbilityManager.FindAbilityTemplate(OldTemplateName);
				NewTemplate = new class'X2AbilityTemplate'(OldTemplate);

				NewTemplate.SetTemplateName(NewTemplateName);
				AbilityManager.AddAbilityTemplate(NewTemplate);
			}
		}
	}
}

