class XMBAbilityTag extends X2AbilityTag implements(XMBOverrideInterface);

var X2AbilityTag WrappedTag;

// XModBase version
var int MajorVersion, MinorVersion, PatchVersion;

event ExpandHandler(string InString, out string OutString)
{
	local name Type;
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim ToHitCalc;
	local X2Effect EffectTemplate;
	local XMBEffectInterface EffectInterface;
	local XComGameStateHistory History;
	local array<string> Split;
	local int idx;

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

		idx = class'XMBConfig'.default.m_aCharStatTags.Find(Type);
		if (idx != INDEX_NONE && FindStatBonus(AbilityTemplate, ECharStatType(idx), OutString))
		{
			return;
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

		case 'ToHit':
		case 'BaseToHit':
			ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);
			if (ToHitCalc != none)
			{
				OutString = string(ToHitCalc.BuiltInHitMod);
			}
			break;

		case 'Crit':
		case 'BaseCrit':
			ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);
			if (ToHitCalc != none)
			{
				OutString = string(ToHitCalc.BuiltInCritMod);
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

function bool FindStatBonus(X2AbilityTemplate AbilityTemplate, ECharStatType StatType, out string OutString)
{
	local X2Effect EffectTemplate;
	local X2Effect_PersistentStatChange StatChangeEffect;
	local int idx;

	if (AbilityTemplate == none)
		return false;

	foreach AbilityTemplate.AbilityTargetEffects(EffectTemplate)
	{
		StatChangeEffect = X2Effect_PersistentStatChange(EffectTemplate);
		if (StatChangeEffect != none)
		{
			idx = StatChangeEffect.m_aStatChanges.Find('StatType', StatType);
			if (idx != INDEX_NONE)
			{
				OutString = string(int(StatChangeEffect.m_aStatChanges[idx].StatAmount));
				return true;
			}
		}
	}
	foreach AbilityTemplate.AbilityMultiTargetEffects(EffectTemplate)
	{
		StatChangeEffect = X2Effect_PersistentStatChange(EffectTemplate);
		if (StatChangeEffect != none)
		{
			idx = StatChangeEffect.m_aStatChanges.Find('StatType', StatType);
			if (idx != INDEX_NONE)
			{
				OutString = string(int(StatChangeEffect.m_aStatChanges[idx].StatAmount));
				return true;
			}
		}
	}
	foreach AbilityTemplate.AbilityShooterEffects(EffectTemplate)
	{
		StatChangeEffect = X2Effect_PersistentStatChange(EffectTemplate);
		if (StatChangeEffect != none)
		{
			idx = StatChangeEffect.m_aStatChanges.Find('StatType', StatType);
			if (idx != INDEX_NONE)
			{
				OutString = string(int(StatChangeEffect.m_aStatChanges[idx].StatAmount));
				return true;
			}
		}
	}

	return false;
}

// XMBOverrideInterace

function class GetOverrideBaseClass() 
{ 
	return class'X2AbilityTag';
}

function GetOverrideVersion(out int Major, out int Minor, out int Patch)
{
	Major = MajorVersion;
	Minor = MinorVersion;
	Patch = PatchVersion;
}

function bool GetExtObjectValue(name Type, out object Value, optional object Data1 = none, optional object Data2 = none) { return false; }
function SetExtObjectValue(name Type, object Value, optional object Data1 = none, optional object Data2 = none);
function bool GetExtFloatValue(name Type, out float Value, optional object Data1 = none, optional object Data2 = none) { return false; }
function SetExtFloatValue(name Type, float Value, optional object Data1 = none, optional object Data2 = none);
function bool GetExtStringValue(name Type, out string Value, optional object Data1 = none, optional object Data2 = none) { return false; }
function SetExtStringValue(name Type, string Value, optional object Data1 = none, optional object Data2 = none);