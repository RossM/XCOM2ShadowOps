class X2AbilityToHitCalc_FastHacking extends X2AbilityToHitCalc_StatCheck_UnitVsUnit config(GameData);

function int GetAttackValue(XComGameState_Ability kAbility, StateObjectReference TargetRef)
{
	local XComGameState_Unit Hacker;
	local XComGameState_Item SourceWeapon;
	local X2GremlinTemplate GremlinTemplate;
	local int HackAttack;

	Hacker = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

	HackAttack = Hacker.GetCurrentStat(AttackerStat);

	// when the skullmining tech is researched, carrying the skulljack confers a bonus to hacking
	if( Hacker.HasItemOfTemplateType('SKULLJACK') && `XCOMHQ.IsTechResearched('Skullmining') )
	{
		HackAttack += class'X2AbilityToHitCalc_Hacking'.default.SKULLJACK_HACKING_BONUS;
	}

	SourceWeapon = kAbility.GetSourceWeapon();
	if (SourceWeapon != None)
	{
		GremlinTemplate = X2GremlinTemplate(SourceWeapon.GetMyTemplate());
		if (GremlinTemplate != None)
			HackAttack += GremlinTemplate.HackingAttemptBonus;
	}

	return HackAttack;
}

function string GetDefendString() { return class'XLocalizedData'.default.TechStat; }

defaultproperties
{
	AttackerStat = eStat_Hacking;
	DefenderStat = eStat_HackDefense;
}