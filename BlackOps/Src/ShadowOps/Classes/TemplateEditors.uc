class TemplateEditors extends UIScreenListener;

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

function EditTemplatesForDifficulty()
{
}

function EditTemplates()
{
	AddGtsUnlocks();
}

function AddGtsUnlocks()
{
	local X2StrategyElementTemplateManager StrategyManager;
	local X2FacilityTemplate Template;

	StrategyManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Template = X2FacilityTemplate(StrategyManager.FindStrategyElementTemplate('OfficerTrainingSchool'));

	Template.SoldierUnlockTemplates.AddItem('PackmasterUnlock');
	Template.SoldierUnlockTemplates.AddItem('DamnGoodGroundUnlock');
}

defaultproperties
{
	ScreenClass = "UIAvengerHUD";
}