class X2AbilityCharges_GremlinTech extends X2AbilityCharges;

var int ConventionalCharges, MagneticCharges, BeamCharges;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit)
{
	local X2GremlinTemplate Template;

	Template = X2GremlinTemplate(Ability.GetSourceWeapon().GetMyTemplate());

	switch (Template.WeaponTech)
	{
	case 'conventional':
		return ConventionalCharges;
	case 'magnetic':
		return MagneticCharges;
	case 'beam':
		return BeamCharges;
	}

	return ConventionalCharges;
}