class X2Effect_HeavyArmor extends X2Effect_BonusArmor;

function int GetArmorChance(XComGameState_Effect EffectState, XComGameState_Unit UnitState) { return 100; }

function int GetArmorMitigation(XComGameState_Effect EffectState, XComGameState_Unit UnitState) 
{ 
	local XComGameState_Item RelevantItem;
	local X2ArmorTemplate ArmorTemplate;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_Armor);

	if (RelevantItem != none)
		ArmorTemplate = X2ArmorTemplate(RelevantItem.GetMyTemplate());

	if (ArmorTemplate != none && ArmorTemplate.bHeavyWeapon)
		return 2;

	return 1; 
}
