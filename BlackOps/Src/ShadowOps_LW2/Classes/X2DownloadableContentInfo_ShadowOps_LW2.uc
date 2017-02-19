class X2DownloadableContentInfo_ShadowOps_LW2 extends X2DownloadableContentInfo config(GameCore);

static event OnLoadedSavedGame()
{
	class'XComGameState_SOListenerManager'.static.CreateListenerManager();
}

static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_SOListenerManager'.static.CreateListenerManager(StartState);
}

static event OnLoadedSavedGameToStrategy()
{
	class'XComGameState_SOListenerManager'.static.RefreshListeners();
}

static event OnPostMission()
{
	class'XComGameState_SOListenerManager'.static.RefreshListeners();
}

static event OnPostTemplatesCreated()
{
	SetVariableIconColor('PointBlank');
	SetVariableIconColor('BothBarrels');
}

static function SetVariableIconColor(name AbilityName)
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		Template.AbilityIconColor = "Variable";
	}
}
