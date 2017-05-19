class X2DownloadableContentInfo_SOInfantry extends X2DownloadableContentInfo;

/// <summary>
/// Called from X2AbilityTag:ExpandHandler after processing the base game tags. Return true (and fill OutString correctly)
/// to indicate the tag has been expanded properly and no further processing is needed.
/// </summary>
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	switch (locs(InString))
	{
	case "zoneofcontrollw2shots":
		OutString = string(class'X2Ability_InfantryAbilitySet'.default.ZoneOfControlLW2Shots);
		return true;
	}
	return false;
}

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	class'TemplateEditors_Infantry'.static.EditTemplates();
}
