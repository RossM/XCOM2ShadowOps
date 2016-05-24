class X2Effect_Anatomist extends X2Effect_Persistent config(GameData_SoldierSkills);

var int CritModifier, MaxCritModifier;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local float KilledEnemies;

	KilledEnemies = class'EvilUnitStateHack'.static.NumKillsOfCharacterGroup(Attacker, Target.GetMyTemplate().CharacterGroupName);

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = min(CritModifier * KilledEnemies, MaxCritModifier);
	ShotModifiers.AddItem(ModInfo);
}

