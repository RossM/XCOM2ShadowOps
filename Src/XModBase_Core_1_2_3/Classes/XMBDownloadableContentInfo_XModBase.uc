//---------------------------------------------------------------------------------------
//  FILE:    XMBDownloadableContentInfo_XModBase.uc
//  AUTHOR:  xylthixlm
//
//  This file contains internal implementation of XModBase. You don't need to, and
//  shouldn't, use it directly.
//
//  INSTALLATION
//
//  Copy all the files in XModBase_Core_1_2_3/Classes/, XModBase_Interfaces/Classes/,
//  and LW_Tuple/Classes/ into similarly named directories under Src/.
//
//  DO NOT EDIT THIS FILE. This class is shared with other mods that use XModBase. If
//  you change this file, your mod will become incompatible with any other mod using
//  XModBase.
//---------------------------------------------------------------------------------------
class XMBDownloadableContentInfo_XModBase extends X2DownloadableContentInfo;

var const int MajorVersion, MinorVersion, PatchVersion;

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	AddUniversalAbilities();
	UpdateAbilities();
	ChainAbilityTag();
	AddGtsUnlocks();
}

static function bool IsNewer(XMBOverrideInterface Override)
{
	local int Major, Minor, Patch;

	Override.GetOverrideVersion(Major, Minor, Patch);

	return (Major > default.MajorVersion ||
		(Major == default.MajorVersion && Minor > default.MinorVersion) ||
		(Major == default.MajorVersion && Minor == default.MinorVersion && Patch >= default.PatchVersion));
}

static function ChainAbilityTag()
{
	local XComEngine Engine;
	local XMBAbilityTag AbilityTag;
	local X2AbilityTag OldAbilityTag;
	local int idx;
	local XMBOverrideInterface Override;
	local LWTuple Tuple;

	Engine = `XENGINE;

	OldAbilityTag = Engine.AbilityTag;
	Override = XMBOverrideInterface(OldAbilityTag);

	if (Override != none)
	{
		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return;

		Tuple = new class'LWTuple';
		Tuple.id = 'WrappedTag';

		if (Override.GetExtValue(Tuple))
			OldAbilityTag = X2AbilityTag(Tuple.Data[0].o);
	}

	AbilityTag = new class'XMBAbilityTag';
	AbilityTag.WrappedTag = OldAbilityTag;
	AbilityTag.MajorVersion = default.MajorVersion;
	AbilityTag.MinorVersion = default.MinorVersion;
	AbilityTag.PatchVersion = default.PatchVersion;

	idx = Engine.LocalizeContext.LocalizeTags.Find(Engine.AbilityTag);
	Engine.AbilityTag = AbilityTag;
	Engine.LocalizeContext.LocalizeTags[idx] = AbilityTag;
}

static function AddUniversalAbilities()
{
	local X2DataTemplate DataTemplate;
	local X2CharacterTemplate Template;
	local array<X2DataTemplate> DataTemplateAllDifficulties;
	local X2CharacterTemplateManager CharacterMgr;
	local array<name> TemplateNames;
	local name TemplateName, AbilityName;

	CharacterMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	CharacterMgr.GetTemplateNames(TemplateNames);
	foreach TemplateNames(TemplateName)
	{
		CharacterMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplateAllDifficulties);
		foreach DataTemplateAllDifficulties(DataTemplate)
		{
			Template = X2CharacterTemplate(DataTemplate);

			if (!Template.bIsCosmetic)
			{
				foreach class'XMBConfig'.default.UniversalAbilitySet(AbilityName)
				{
					if (Template.Abilities.Find(AbilityName) == INDEX_NONE)
						Template.Abilities.AddItem(AbilityName);
				}

				if (Template.DataName == 'Soldier')
				{
					foreach class'XMBConfig'.default.AllSoldierAbilitySet(AbilityName)
					{
						if (Template.Abilities.Find(AbilityName) == INDEX_NONE)
							Template.Abilities.AddItem(AbilityName);
					}
				}
			}
		}
	}
}

static function AddGtsUnlocks()
{
	local X2StrategyElementTemplateManager StrategyManager;
	local array<X2DataTemplate> DataTemplateAllDifficulties;
	local X2DataTemplate DataTemplate;
	local X2FacilityTemplate Template;
	local name UnlockName;

	StrategyManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	StrategyManager.FindDataTemplateAllDifficulties('OfficerTrainingSchool', DataTemplateAllDifficulties);
	foreach DataTemplateAllDifficulties(DataTemplate)
	{
		Template = X2FacilityTemplate(DataTemplate);

		foreach class'XMBConfig'.default.GtsUnlocks(UnlockName)
		{
			if (StrategyManager.FindStrategyElementTemplate(UnlockName) != none)
				Template.SoldierUnlockTemplates.AddItem(UnlockName);
		}
	}
}

static function bool UpdateAbilityToHitCalc(out X2AbilityToHitCalc ToHitCalc)
{
	local XMBOverrideInterface Override;
	local XMBAbilityToHitCalc_StandardAim NewToHitCalc;

	Override = XMBOverrideInterface(ToHitCalc);

	if (Override != none)
	{
		// If the current hit calc isn't overriding the correct class, don't change it
		if (Override.GetOverrideBaseClass() != class'X2AbilityToHitCalc_StandardAim')
			return false;

		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return false;
	}
	else
	{
		if (ToHitCalc.Class != class'X2AbilityToHitCalc_StandardAim')
			return false;
	}

	NewToHitCalc = new class'XMBAbilityToHitCalc_StandardAim'(ToHitCalc);
	NewToHitCalc.MajorVersion = default.MajorVersion;
	NewToHitCalc.MinorVersion = default.MinorVersion;
	NewToHitCalc.PatchVersion = default.PatchVersion;

	ToHitCalc = NewToHitCalc;
	return true;
}

static function bool UpdateAbilityMultiTarget(out X2AbilityMultiTargetStyle MultiTarget)
{
	local XMBOverrideInterface Override;
	local XMBAbilityMultiTarget_Radius NewMultiTarget;

	Override = XMBOverrideInterface(MultiTarget);

	if (Override != none)
	{
		// If the current hit calc isn't overriding the correct class, don't change it
		if (Override.GetOverrideBaseClass() != class'X2AbilityMultiTarget_Radius')
			return false;

		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return false;
	}
	else
	{
		if (MultiTarget.Class != class'X2AbilityMultiTarget_Radius')
			return false;
	}

	NewMultiTarget = new class'XMBAbilityMultiTarget_Radius'(MultiTarget);
	NewMultiTarget.MajorVersion = default.MajorVersion;
	NewMultiTarget.MinorVersion = default.MinorVersion;
	NewMultiTarget.PatchVersion = default.PatchVersion;

	MultiTarget = NewMultiTarget;
	return true;
}

static function bool UpdateTargetingMethod(out class<X2TargetingMethod> TargetingMethod)
{
	local XMBOverrideInterface Override;

	Override = XMBOverrideInterface(new TargetingMethod);

	if (Override != none)
	{
		// If the current hit calc isn't overriding the correct class, don't change it
		if (Override.GetOverrideBaseClass() != class'X2TargetingMethod_Grenade')
			return false;

		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return false;
	}
	else
	{
		if (TargetingMethod != class'X2TargetingMethod_Grenade')
			return false;
	}

	TargetingMethod = class'XMBTargetingMethod_Grenade';

	return true;
}

static function bool UpdateAbilityCost(out X2AbilityCost AbilityCost)
{
	local XMBOverrideInterface Override;
	local XMBAbilityCost_ActionPoints NewAbilityCost;

	Override = XMBOverrideInterface(AbilityCost);

	if (Override != none)
	{
		// If the current hit calc isn't overriding the correct class, don't change it
		if (Override.GetOverrideBaseClass() != class'X2AbilityCost_ActionPoints')
			return false;

		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return false;
	}

	if (AbilityCost.class == class'X2AbilityCost_ActionPoints')
	{
		NewAbilityCost = new class'XMBAbilityCost_ActionPoints'(AbilityCost);
		NewAbilityCost.MajorVersion = default.MajorVersion;
		NewAbilityCost.MinorVersion = default.MinorVersion;
		NewAbilityCost.PatchVersion = default.PatchVersion;

		AbilityCost = NewAbilityCost;
		return true;
	}

	return false;
}

static function UpdateAbilities()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2AbilityToHitCalc					ToHitCalc;
	local X2AbilityMultiTargetStyle				MultiTarget;
	local class<X2TargetingMethod>				TargetingMethod;
	local X2AbilityCost							AbilityCost;
	local array<name>							TemplateNames;
	local name									AbilityName;
	local int i;
	local int hack;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	AbilityManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(AbilityName)
	{
		AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
		foreach TemplateAllDifficulties(Template)
		{
			ToHitCalc = Template.AbilityToHitCalc;
			if (ToHitCalc != none && UpdateAbilityToHitCalc(ToHitCalc))
			{
				Template.AbilityToHitCalc = ToHitCalc;
			}

			ToHitCalc = Template.AbilityToHitOwnerOnMissCalc;
			if (ToHitCalc != none && UpdateAbilityToHitCalc(ToHitCalc))
			{
				Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;
			}

			MultiTarget = Template.AbilityMultiTargetStyle;
			if (MultiTarget != none && UpdateAbilityMultiTarget(MultiTarget))
			{
				Template.AbilityMultiTargetStyle = MultiTarget;
			}

			TargetingMethod = Template.TargetingMethod;
			if (TargetingMethod != none && UpdateTargetingMethod(TargetingMethod))
			{
				Template.TargetingMethod = TargetingMethod;
			}

			for (i = 0; i < Template.AbilityCosts.Length; i++)
			{
				AbilityCost = Template.AbilityCosts[i];
				if (AbilityCost.bFreeCost)
					continue;
				if (AbilityCost != none && UpdateAbilityCost(AbilityCost))
				{
					Template.AbilityCosts[i] = AbilityCost;
				}
			}

			if (Template.ShotHUDPriority == -1)  // class'XMBAbility'.default.AUTO_PRIORITY
			{
				Template.ShotHUDPriority = FindShotHUDPriority(Template.DataName);
			}

			HandleAbilityEffects(Template);
		}
	}
}

static function int FindShotHUDPriority(name AbilityName)
{
	local X2SoldierClassTemplateManager SoldierClassManager;
	local array<X2SoldierClassTemplate> AllTemplates;
	local X2SoldierClassTemplate Template;
	local array<SoldierClassAbilityType> AbilityTree;
	local int HighestLevel;
	local int rank;

	SoldierClassManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();

	HighestLevel = -1;

	AllTemplates = SoldierClassManager.GetAllSoldierClassTemplates();
	foreach AllTemplates(Template)
	{
		for (rank = 0; rank < Template.GetMaxConfiguredRank(); rank++)
		{
			if (rank <= HighestLevel)
				continue;

			AbilityTree = Template.GetAbilityTree(rank);
			if (AbilityTree.Find('AbilityName', AbilityName) != INDEX_NONE)
				HighestLevel = rank;
		}
	}

	switch (HighestLevel)
	{
	case 0:		return class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	case 1:		return class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	case 2:		return class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	case 3:		return class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	case 4:		return class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	case 5:		return class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	case 6:		return class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	default:	return class'UIUtilities_Tactical'.const.UNSPECIFIED_PRIORITY;
	}
}

static function HandleAbilityEffects(X2AbilityTemplate Template)
{
	local X2Effect Effect;

	foreach Template.AbilityTargetEffects(Effect)
	{
		HandleEffect(Effect);
	}

	foreach Template.AbilityMultiTargetEffects(Effect)
	{
		HandleEffect(Effect);
	}

	foreach Template.AbilityShooterEffects(Effect)
	{
		HandleEffect(Effect);
	}
}

static function HandleEffect(X2Effect Effect)
{
	local XMBEffectInterface XMBEffect;
	local LWTuple Tuple;

	XMBEffect = XMBEffectInterface(Effect);
	if (XMBEffect == none)
		return;

	Tuple = new class'LWTuple';
	Tuple.Id = 'OnPostTemplatesCreated';

	XMBEffect.GetExtValue(Tuple);
}

defaultproperties
{
	MajorVersion = 1
	MinorVersion = 2
	PatchVersion = 3
}