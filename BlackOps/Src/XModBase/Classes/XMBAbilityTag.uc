class XMBAbilityTag extends X2AbilityTag;

var X2AbilityTag WrappedTag;

event ExpandHandler(string InString, out string OutString)
{
	local name Type;
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2AbilityTemplate AbilityTemplate;
	local X2Effect EffectTemplate;
	local XMBEffectInterface EffectInterface;
	local XComGameStateHistory History;
	local array<string> Split;

	History = `XCOMHISTORY;

	OutString = "";

	Split = SplitString(InString, ":");

	Type = name(Split[0]);

	EffectState = XComGameState_Effect(ParseObj);
	AbilityState = XComGameState_Ability(ParseObj);
	AbilityTemplate = X2AbilityTemplate(ParseObj);
		
	if (EffectState != none)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	}
	if (AbilityState != none)
	{
		AbilityTemplate = AbilityState.GetMyTemplate();
	}

	if (Split.Length == 2)
	{
		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(name(Split[1]));
	}

	if (AbilityTemplate != none)
	{
		foreach AbilityTemplate.AbilityTargetEffects(EffectTemplate)
		{
			EffectInterface = XMBEffectInterface(EffectTemplate);
			if (EffectInterface != none && EffectInterface.GetTagValue(Type, AbilityState, OutString))
			{
				//`RedScreen(AbilityTemplate.DataName @ "'"$InString$"':'"$OutString$"'");
				return;
			}
		}
		foreach AbilityTemplate.AbilityMultiTargetEffects(EffectTemplate)
		{
			EffectInterface = XMBEffectInterface(EffectTemplate);
			if (EffectInterface != none && EffectInterface.GetTagValue(Type, AbilityState, OutString))
			{
				//`RedScreen(AbilityTemplate.DataName @ "'"$InString$"':'"$OutString$"'");
				return;
			}
		}
		foreach AbilityTemplate.AbilityShooterEffects(EffectTemplate)
		{
			EffectInterface = XMBEffectInterface(EffectTemplate);
			if (EffectInterface != none && EffectInterface.GetTagValue(Type, AbilityState, OutString))
			{
				//`RedScreen(AbilityTemplate.DataName @ "'"$InString$"':'"$OutString$"'");
				return;
			}
		}
	}

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
