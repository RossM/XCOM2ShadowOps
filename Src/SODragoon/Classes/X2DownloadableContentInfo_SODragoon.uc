class X2DownloadableContentInfo_SODragoon extends X2DownloadableContentInfo;

/// <summary>
/// Called from X2AbilityTag:ExpandHandler after processing the base game tags. Return true (and fill OutString correctly)
/// to indicate the tag has been expanded properly and no further processing is needed.
/// </summary>
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	switch (locs(InString))
	{
	case "ecmdetectionmodifier":
		OutString = string(int(class'X2Ability_DragoonAbilitySet'.default.ECMDetectionModifier * 100));
		return true;
	case "eatthismaxtiles":
		OutString = string(class'X2Ability_DragoonAbilitySet'.default.EatThisMaxTiles);
		return true;
	}
	return false;
}
