class X2Condition_RapidDeployment extends X2Condition;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local name DataName;
	local XComGameState_Item SourceWeapon;
	local X2ItemTemplate AmmoTemplate;
	local name WeaponName, AmmoName;

	DataName = kAbility.GetMyTemplate().DataName;

	if (class'X2Effect_RapidDeployment'.default.VALID_ABILITIES.Find(DataName) != INDEX_NONE)
		return 'AA_Success';

	if (class'X2Effect_RapidDeployment'.default.VALID_GRENADE_ABILITIES.Find(DataName) != INDEX_NONE)
	{
		SourceWeapon = kAbility.GetSourceWeapon();
		WeaponName = SourceWeapon.GetMyTemplateName();
		AmmoTemplate = SourceWeapon.GetLoadedAmmoTemplate(kAbility);
		if (AmmoTemplate != none)
			AmmoName = AmmoTemplate.DataName;

		if (class'X2Effect_RapidDeployment'.default.VALID_GRENADE_TYPES.Find(WeaponName) != INDEX_NONE || 
			(AmmoName != '' && class'X2Effect_RapidDeployment'.default.VALID_GRENADE_TYPES.Find(AmmoName) != INDEX_NONE))
		{
			return 'AA_Success';
		}
	}


	return 'AA_InvalidAbility';
}