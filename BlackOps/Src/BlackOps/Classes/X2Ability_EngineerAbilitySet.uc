class X2Ability_EngineerAbilitySet extends X2Ability
	config(GameData_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(DeepPockets());
	Templates.AddItem(PurePassive('DenseSmoke', "img:///UILibrary_PerkIcons.UIPerk_densesmoke", true));
	Templates.AddItem(PurePassive('SmokeAndMirrors', "img:///UILibrary_PerkIcons.UIPerk_smokeandmirrors", true));

	return Templates;
}

static function X2AbilityTemplate DeepPockets()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('DeepPockets', "img:///UILibrary_PerkIcons.UIPerk_deeppockets");

	Template.SoldierAbilityPurchasedFn = DeepPocketsPurchased;

	Template.bCrossClassEligible = true;

	return Template;
}

static function DeepPocketsPurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	UnitState.ValidateLoadout(NewGameState);
}

