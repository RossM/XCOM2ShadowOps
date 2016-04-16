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
	AddAllDoNotConsumeAllAbilities();
	FixAllSimpleStandardAims();
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
		if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllSoldierAbilities.Find(PassiveAbilityName) < 0)
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
		if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllEffects.Find(EffectName) < 0)
		{
			ActionPointCost.DoNotConsumeAllEffects.AddItem(EffectName);
		}
	}
}

function AddAllDoNotConsumeAllAbilities()
{
	// Bullet Swarm
	AddDoNotConsumeAllAbility('StandardShot', 'BulletSwarm');

	// Smoke and Mirrors
	AddDoNotConsumeAllAbility('ThrowGrenade', 'SmokeAndMirrors');
	AddDoNotConsumeAllAbility('LaunchGrenade', 'SmokeAndMirrors');

	// Fastball
	AddDoNotConsumeAllAbility('ThrowGrenade', 'Fastball');
	AddDoNotConsumeAllAbility('LaunchGrenade', 'Fastball');

	// Entrench
	AddDoNotConsumeAllAbility('HunkerDown', 'Entrench');
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

defaultproperties
{
	ScreenClass = "UITacticalHUD";
}