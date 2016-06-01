class X2DownloadableContentInfo_XModBase extends X2DownloadableContentInfo;

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	AddUniversalAbilities();
	FixAllSimpleStandardAims();
	ChainAbilityTag();
}

static function ChainAbilityTag()
{
	local XComEngine Engine;
	local XMBAbilityTag AbilityTag;
	local int idx;

	Engine = `XENGINE;

	AbilityTag = new class'XMBAbilityTag';
	AbilityTag.WrappedTag = Engine.AbilityTag;
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
				foreach class'XModBase_Config'.default.UniversalAbilitySet(AbilityName)
				{
					Template.Abilities.AddItem(AbilityName);
				}
			}
		}
	}
}

static function FixAllSimpleStandardAims()
{
	local X2AbilityTemplateManager				AbilityManager;
	local array<X2AbilityTemplate>				TemplateAllDifficulties;
	local X2AbilityTemplate						Template;
	local X2AbilityToHitCalc					ToHitCalc;
	local X2AbilityToHitCalc_StandardAim_XModBase		NewToHitCalc;
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
			if (ToHitCalc != none && ToHitCalc.Class == class'X2AbilityToHitCalc_StandardAim')
			{
				NewToHitCalc = new class'X2AbilityToHitCalc_StandardAim_XModBase'(X2AbilityToHitCalc_StandardAim(ToHitCalc));
				Template.AbilityToHitCalc = NewToHitCalc;
			}

			ToHitCalc = Template.AbilityToHitOwnerOnMissCalc;
			if (ToHitCalc != none && ToHitCalc.Class == class'X2AbilityToHitCalc_StandardAim')
			{
				NewToHitCalc = new class'X2AbilityToHitCalc_StandardAim_XModBase'(X2AbilityToHitCalc_StandardAim(ToHitCalc));
				Template.AbilityToHitOwnerOnMissCalc = NewToHitCalc;
			}
		}
	}
}

