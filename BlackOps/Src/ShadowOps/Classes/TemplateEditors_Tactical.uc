class TemplateEditors_Tactical extends UIScreenListener;

var array<bool> bEditedTemplatesForDifficulty;
var bool bEditedTemplates;

event OnInit(UIScreen Screen)
{
	if (!bEditedTemplates)
	{
		EditTemplates();
		bEditedTemplates = true;
	}

	bEditedTemplatesForDifficulty.Length = 4;
	if (!bEditedTemplatesForDifficulty[`DifficultySetting])
	{
		EditTemplatesForDifficulty();
		bEditedTemplatesForDifficulty[`DifficultySetting] = true;
	}
}

// The following template types have per-difficulty variants:
// X2CharacterTemplate (except civilians and characters who never appear in tactical play)
// X2FacilityTemplate
// X2FacilityUpgradeTemplate
// X2MissionSourceTemplate
// X2SchematicTemplate
// X2SoldierClassTemplate
// X2SoldierUnlockTemplate
// X2SpecialRoomFeatureTemplate
// X2TechTemplate
function EditTemplatesForDifficulty()
{
}

function EditTemplates()
{
	class'TemplateEditors_Items'.static.EditTemplates();

	AddAllDoNotConsumeAllAbilities();
	FixAllSimpleStandardAims();
	ChangeAllToGrenadeActionPoints();
	AddAllSuppressionConditions();

	CreateCompatAbilities();
}

function AddDoNotConsumeAllAbility(name AbilityName, name PassiveAbilityName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local X2AbilityTemplate				Template;
	local X2AbilityCost					AbilityCost;
	local X2AbilityCost_ActionPoints	ActionPointCost;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(AbilityName);

	foreach Template.AbilityCosts(AbilityCost)
	{
		ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
		if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllSoldierAbilities.Find(PassiveAbilityName) == INDEX_NONE)
		{
			ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem(PassiveAbilityName);
		}
	}
}

function AddDoNotConsumeAllEffect(name AbilityName, name EffectName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local X2AbilityTemplate				Template;
	local X2AbilityCost					AbilityCost;
	local X2AbilityCost_ActionPoints	ActionPointCost;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(AbilityName);

	foreach Template.AbilityCosts(AbilityCost)
	{
		ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
		if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllEffects.Find(EffectName) == INDEX_NONE)
		{
			ActionPointCost.DoNotConsumeAllEffects.AddItem(EffectName);
		}
	}
}

function AddAllDoNotConsumeAllAbilities()
{
	// Bullet Swarm
	AddDoNotConsumeAllAbility('StandardShot', 'ShadowOps_BulletSwarm');

	// Smoke and Mirrors
	AddDoNotConsumeAllAbility('ThrowGrenade', 'ShadowOps_SmokeAndMirrors');
	AddDoNotConsumeAllAbility('LaunchGrenade', 'ShadowOps_SmokeAndMirrors');

	// Fastball
	AddDoNotConsumeAllEffect('ThrowGrenade', 'Fastball');
	AddDoNotConsumeAllEffect('LaunchGrenade', 'Fastball');

	// Entrench
	AddDoNotConsumeAllAbility('HunkerDown', 'ShadowOps_Entrench');
}

function FixSimpleStandardAim(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local X2AbilityTemplate						Template;
	local X2AbilityToHitCalc					ToHitCalc;
	local X2AbilityToHitCalc_StandardAim_BO		NewToHitCalc;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(AbilityName);

	ToHitCalc = Template.AbilityToHitCalc;
	if (ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim') && !ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim_BO'))
	{
		NewToHitCalc = new class'X2AbilityToHitCalc_StandardAim_BO';
		Template.AbilityToHitCalc = NewToHitCalc;
	}

	ToHitCalc = Template.AbilityToHitOwnerOnMissCalc;
	if (ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim') && !ToHitCalc.IsA('X2AbilityToHitCalc_StandardAim_BO'))
	{
		NewToHitCalc = new class'X2AbilityToHitCalc_StandardAim_BO';
		Template.AbilityToHitOwnerOnMissCalc = NewToHitCalc;
	}
}

function FixAllSimpleStandardAims()
{
	FixSimpleStandardAim('StandardShot');
	FixSimpleStandardAim('PistolStandardShot');
	FixSimpleStandardAim('SniperStandardFire');
	FixSimpleStandardAim('AnimaGate');
	FixSimpleStandardAim('LightningHands');
	
}

function ChangeToGrenadeActionPoints(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local X2AbilityTemplate						Template;
	local X2AbilityCost							AbilityCost;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCost_GrenadeActionPoints		GrenadeCost;
	local int									i;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(AbilityName);

	for (i = 0; i < Template.AbilityCosts.Length; i++)
	{
		AbilityCost = Template.AbilityCosts[i];
		ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
		if (ActionPointCost != none && !ActionPointCost.IsA('X2AbilityCost_GrenadeActionPoints'))
		{
			GrenadeCost = new class 'X2AbilityCost_GrenadeActionPoints';
			GrenadeCost.iNumPoints = ActionPointCost.iNumPoints;
			GrenadeCost.bConsumeAllPoints = ActionPointCost.bConsumeAllPoints;
			GrenadeCost.DoNotConsumeAllSoldierAbilities = ActionPointCost.DoNotConsumeAllSoldierAbilities;
			GrenadeCost.DoNotConsumeAllEffects = ActionPointCost.DoNotConsumeAllEffects;
			GrenadeCost.AllowedTypes = ActionPointCost.AllowedTypes;
			GrenadeCost.AllowedTypes.AddItem('grenade');

			Template.AbilityCosts[i] = GrenadeCost;
		}
	}
}

function ChangeAllToGrenadeActionPoints()
{
	ChangeToGrenadeActionPoints('ThrowGrenade');
	ChangeToGrenadeActionPoints('LaunchGrenade');
}

function AddSuppressionCondition(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local X2AbilityTemplate						Template;
	local X2Condition							Condition;
	local X2Condition_UnitEffects				ExcludeEffectsCondition;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate(AbilityName);

	foreach Template.AbilityShooterConditions(Condition)
	{
		ExcludeEffectsCondition = X2Condition_UnitEffects(Condition);
		if (ExcludeEffectsCondition != none && ExcludeEffectsCondition.ExcludeEffects.Find('EffectName', class'X2Effect_Suppression'.default.EffectName) != INDEX_NONE)
			return;
	}

	ExcludeEffectsCondition = new class'X2Condition_UnitEffects';
	ExcludeEffectsCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(ExcludeEffectsCondition);
}

function AddAllSuppressionConditions()
{
	AddSuppressionCondition('ThrowGrenade');
	AddSuppressionCondition('LaunchGrenade');
	AddSuppressionCondition('MicroMissiles');
}

// This function creates extra versions of all the ShadowOps_* abilities without the ShadowOps_ prefix,
// unless an ability without the prefix already exists. The extra versions are needed for games saved
// during tactical play with a previous mod version to continue working.
function CreateCompatAbilities()
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

defaultproperties
{
	ScreenClass = "UITacticalHUD";
}