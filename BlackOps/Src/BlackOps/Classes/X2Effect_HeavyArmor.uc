class X2Effect_HeavyArmor extends X2Effect_BonusArmor;

var int Base, Bonus;

function int GetArmorChance(XComGameState_Effect EffectState, XComGameState_Unit UnitState) { return 100; }

function int GetArmorMitigation(XComGameState_Effect EffectState, XComGameState_Unit UnitState) 
{ 
	local XComGameState_Item RelevantItem;
	local X2ArmorTemplate ArmorTemplate;
	local int Result;

	Result = Base;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_Armor);

	if (RelevantItem != none)
		ArmorTemplate = X2ArmorTemplate(RelevantItem.GetMyTemplate());

	if (ArmorTemplate != none && ArmorTemplate.bHeavyWeapon)
		result += Bonus;

	return Result; 
}
