class X2Effect_DangerZone extends X2Effect_Persistent implements(XMBEffectInterface);

var name BonusAbilityName;
var array<name> AbilityNames;
var array<int> BonusRadius;

var bool HandledOnPostTemplatesCreated;

// From XMBEffectInterface
function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }

// From XMBEffectInterface
function bool GetExtValue(LWTuple Tuple)
{
	local name Ability;
	local array<X2AbilityTemplate> TemplateAllDifficulties;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;
	local X2AbilityMultiTarget_Radius RadiusTarget;
	local int i;

	if (Tuple.id != 'OnPostTemplatesCreated')
		return false;

	if (HandledOnPostTemplatesCreated)
		return false;

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

	HandledOnPostTemplatesCreated = true;
	return true;
}