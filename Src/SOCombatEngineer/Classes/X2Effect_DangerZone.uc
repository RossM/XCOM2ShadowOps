class X2Effect_DangerZone extends XMBEffect_Extended;

var name BonusAbilityName;
var array<name> AbilityNames;
var array<int> BonusRadius;

function OnPostTemplatesCreated()
{
	local name Ability;
	local array<X2AbilityTemplate> TemplateAllDifficulties;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;
	local X2AbilityMultiTarget_Radius RadiusTarget;
	local int i;

	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	`Log(EffectName $ ": --DANGERZONE--");

	for (i = 0; i < AbilityNames.Length; i++)
	{
		Ability = AbilityNames[i];

		AbilityMgr.FindAbilityTemplateAllDifficulties(Ability, TemplateAllDifficulties);

		if (TemplateAllDifficulties.Length == 0)
		{
			`Log(EffectName $ ": Could not find ability template '" $ Ability $ "'");
			continue;
		}

		`Log(EffectName $ ": Editing ability template '" $ Ability $ "'");

		foreach TemplateAllDifficulties(AbilityTemplate)
		{
			RadiusTarget = X2AbilityMultiTarget_Radius(AbilityTemplate.AbilityMultiTargetStyle);

			if (RadiusTarget == none)
			{
				`Log(EffectName $ ": No X2AbilityMultiTarget_Radius on ability template '" $ Ability $ "'");
				continue;
			}

			if (RadiusTarget.AbilityBonusRadii.Find('RequiredAbility', EffectName) == INDEX_NONE)
				RadiusTarget.AddAbilityBonusRadius(BonusAbilityName, BonusRadius[i]);
		}
	}
}