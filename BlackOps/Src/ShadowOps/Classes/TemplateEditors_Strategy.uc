class TemplateEditors_Strategy extends UIScreenListener;

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
// X2Item (grenades, weapons, and heavy weapons only) [bugged]
// X2MissionSourceTemplate
// X2SchematicTemplate
// X2SoldierClassTemplate
// X2SoldierUnlockTemplate
// X2SpecialRoomFeatureTemplate
// X2TechTemplate
function EditTemplatesForDifficulty()
{
	AddGtsUnlocks();
}

function EditTemplates()
{
	class'TemplateEditors_Items'.static.EditTemplates();
}

function AddGtsUnlocks()
{
	local X2StrategyElementTemplateManager StrategyManager;
	local X2FacilityTemplate Template;

	StrategyManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Template = X2FacilityTemplate(StrategyManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	Template.SoldierUnlockTemplates.AddItem('PackmasterUnlock');
	Template.SoldierUnlockTemplates.AddItem('DamnGoodGroundUnlock');
	Template.SoldierUnlockTemplates.AddItem('AdrenalineSurgeUnlock');
	Template.SoldierUnlockTemplates.AddItem('TacticalSenseUnlock');
}

defaultproperties
{
	ScreenClass = "UIAvengerHUD";
}