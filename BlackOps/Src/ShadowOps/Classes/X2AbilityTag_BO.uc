class X2AbilityTag_BO extends X2AbilityTag;

var X2AbilityTag WrappedTag;

event ExpandHandler(string InString, out string OutString)
{
	local name Type;
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2GremlinTemplate GremlinTemplate;
	local XComGameStateHistory History;

	Type = name(InString);
	History = `XCOMHISTORY;

	switch (Type)
	{
		case 'AssociatedWeapon':
			AbilityState = XComGameState_Ability(ParseObj);
			EffectState = XComGameState_Effect(ParseObj);
			if (EffectState != none)
			{
				AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			}
			if (AbilityState != none)
			{
				ItemState = AbilityState.GetSourceWeapon();
				ItemTemplate = ItemState.GetMyTemplate();

				OutString = ItemTemplate.GetItemFriendlyName();
			}
			else
			{
				OutString = "item";
			}
			break;

		case 'ShieldProtocolValue':
			OutString = string(class'X2Ability_DragoonAbilitySet'.default.ConventionalShieldProtocol);
			EffectState = XComGameState_Effect(ParseObj);
			AbilityState = XComGameState_Ability(ParseObj);
			if (EffectState != none)
			{
				ItemState = XComGameState_Item(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID));				
			}
			else if (AbilityState != none)
			{
				ItemState = AbilityState.GetSourceWeapon();
			}
			if (ItemState != none)
			{
				GremlinTemplate = X2GremlinTemplate(ItemState.GetMyTemplate());
				if (GremlinTemplate != none)
				{
					if (GremlinTemplate.WeaponTech == 'magnetic')
						OutString = string(class'X2Ability_DragoonAbilitySet'.default.MagneticShieldProtocol);
					else if (GremlinTemplate.WeaponTech == 'beam')
						OutString = string(class'X2Ability_DragoonAbilitySet'.default.BeamShieldProtocol);
				}
			}
			break;


		default:
			WrappedTag.ParseObj = ParseObj;
			WrappedTag.StrategyParseObj = StrategyParseObj;
			WrappedTag.GameState = GameState;
			WrappedTag.ExpandHandler(InString, OutString);
			return;
	}

	// no tag found
	if (OutString == "")
	{
		`RedScreenOnce(`location $ ": Unhandled localization tag: '"$Tag$":"$InString$"'");
		OutString = "<Ability:"$InString$"/>";
	}
}