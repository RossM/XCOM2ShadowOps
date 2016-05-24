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
	local X2WeaponTemplate WeaponTemplate;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;

	Type = name(InString);
	History = `XCOMHISTORY;

	OutString = "";

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

		case 'BreachShred':
			OutString = string(class'X2Effect_Breach'.default.ConventionalDamageValue.Shred);
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
				WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
				if (WeaponTemplate != none)
				{
					if (WeaponTemplate.WeaponTech == 'magnetic')
						OutString = string(class'X2Effect_Breach'.default.MagneticDamageValue.Shred);
					else if (WeaponTemplate.WeaponTech == 'beam')
						OutString = string(class'X2Effect_Breach'.default.BeamDamageValue.Shred);
				}
			}
			break;

		case 'FractureShred':
			OutString = string(class'X2Effect_FractureDamage'.default.ConventionalBonusShred);
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
				WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
				if (WeaponTemplate != none)
				{
					if (WeaponTemplate.WeaponTech == 'magnetic')
						OutString = string(class'X2Effect_FractureDamage'.default.MagneticBonusShred);
					else if (WeaponTemplate.WeaponTech == 'beam')
						OutString = string(class'X2Effect_FractureDamage'.default.BeamBonusShred);
				}
			}
			break;

		case 'RestorationProtocolHealAmount':
			OutString = string(class'X2Ability_DragoonAbilitySet'.default.RestorationHealAmount);
			XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
			if (XComHQ != None && XComHQ.IsTechResearched('BattlefieldMedicine'))
			{
				OutString = string(class'X2Ability_DragoonAbilitySet'.default.RestorationIncreasedHealAmount);
			}
			break;

		case 'RestorationProtocolMaxHealAmount':
			OutString = string(class'X2Ability_DragoonAbilitySet'.default.RestorationMaxHealAmount);
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
					OutString = string(class'X2Ability_DragoonAbilitySet'.default.RestorationMaxHealAmount + 
									   GremlinTemplate.HealingBonus * class'X2Ability_DragoonAbilitySet'.default.RestorationHealingBonusMultiplier);
				}
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

		case 'ShieldsUpValue':
			OutString = string(class'X2Ability_DragoonAbilitySet'.default.ConventionalShieldsUp);
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
						OutString = string(class'X2Ability_DragoonAbilitySet'.default.MagneticShieldsUp);
					else if (GremlinTemplate.WeaponTech == 'beam')
						OutString = string(class'X2Ability_DragoonAbilitySet'.default.BeamShieldsUp);
				}
			}
			break;

		case 'VitalPointDamage':
			OutString = string(class'X2Effect_VitalPoint'.default.ConventionalBonusDamage);
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
				WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
				if (WeaponTemplate != none)
				{
					if (WeaponTemplate.WeaponTech == 'magnetic')
						OutString = string(class'X2Effect_VitalPoint'.default.MagneticBonusDamage);
					else if (WeaponTemplate.WeaponTech == 'beam')
						OutString = string(class'X2Effect_VitalPoint'.default.BeamBonusDamage);
				}
			}
			break;

		case 'VitalPointShred':
			OutString = string(class'X2Effect_VitalPoint'.default.ConventionalBonusShred);
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
				WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
				if (WeaponTemplate != none)
				{
					if (WeaponTemplate.WeaponTech == 'magnetic')
						OutString = string(class'X2Effect_VitalPoint'.default.MagneticBonusShred);
					else if (WeaponTemplate.WeaponTech == 'beam')
						OutString = string(class'X2Effect_VitalPoint'.default.BeamBonusShred);
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