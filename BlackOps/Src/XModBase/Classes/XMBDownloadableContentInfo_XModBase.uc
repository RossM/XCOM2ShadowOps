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
	local object OldAbilityTagObj;

	Engine = `XENGINE;

	OldAbilityTag = Engine.AbilityTag;
	Override = XMBOverrideInterface(OldAbilityTag);

	if (Override != none)
	{
		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return;

		if (Override.GetExtObjectValue('WrappedTag', OldAbilityTagObj))
			OldAbilityTag = X2AbilityTag(OldAbilityTagObj);
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
	local XMBAbilityMultiTarget_SoldierBonusRadius NewMultiTarget;

	Override = XMBOverrideInterface(MultiTarget);

	if (Override != none)
	{
		// If the current hit calc isn't overriding the correct class, don't change it
		if (Override.GetOverrideBaseClass() != class'X2AbilityMultiTarget_SoldierBonusRadius')
			return false;

		// If the current hit calc is a newer version, don't change it
		if (IsNewer(Override))
			return false;
	}
	else
	{
		if (MultiTarget.Class != class'X2AbilityMultiTarget_SoldierBonusRadius')
			return false;
	}

	NewMultiTarget = new class'XMBAbilityMultiTarget_SoldierBonusRadius'(MultiTarget);
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

static function UpdateAbilities()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2AbilityToHitCalc					ToHitCalc;
	local X2AbilityMultiTargetStyle				MultiTarget;
	local class<X2TargetingMethod>				TargetingMethod;
	local array<name>							TemplateNames;
	local name									AbilityName;

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
		}
	}
}

defaultproperties
{
	MajorVersion = 0
	MinorVersion = 1
	PatchVersion = 0
}