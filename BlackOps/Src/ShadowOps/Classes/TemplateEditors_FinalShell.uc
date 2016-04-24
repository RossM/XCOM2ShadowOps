class TemplateEditors_FinalShell extends UIScreenListener;

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
}

defaultproperties
{
	ScreenClass = "UIFinalShell";
}