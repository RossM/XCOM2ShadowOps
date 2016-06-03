class X2AbilityMultiTarget_SoldierBonusRadius_XModBase extends X2AbilityMultiTarget_SoldierBonusRadius
	implements(XMBOverrideInterface);

// XModBase version
var int MajorVersion, MinorVersion, PatchVersion;

// This is similar to the vanilla X2AbilityMultiTarget_SoldierBonusRadius, but that class only
// allows one radius-boosting effect, which is used by Volatile Mix. This class extends that
// to have multiple radius-boosting effects defined by XMBEffect_BonusRadius.
//
// The native-code bits of the targetting system are kind of funky, and just overriding
// GetTargetRadius doesn't work like you would expect. Instead, we modify fRadius directly.
// We save the modifier we used so we can undo the change before applying a new modifier.

var private float fRadiusModifier;		// The current modifier added into fRadius

// Calculate ability-specific radius modifiers.
simulated function CalculateRadiusModifier(const XComGameState_Ability Ability)
{
	local XComGameState_Unit SourceUnit;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local XMBEffect_BonusRadius BonusRadiusEffect;
	local XComGameStateHistory History;

	fRadiusModifier = 0;

	History = `XCOMHISTORY;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

	foreach SourceUnit.AffectedByEffects(EffectRef)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		BonusRadiusEffect = XMBEffect_BonusRadius(EffectState.GetX2Effect());
		if (BonusRadiusEffect != none)
		{
			fRadiusModifier += BonusRadiusEffect.GetRadiusModifier(Ability, SourceUnit, fTargetRadius);
		}
	}
}

// Modify radius to include ability-specific modifiers. Note that fTargetRadius applies to all uses of the ability
// template (e.g. launch grenade) so we have to restore it correctly. This is a terrible hack.
simulated function float GetTargetRadius(const XComGameState_Ability Ability)
{
	fTargetRadius -= fRadiusModifier;
	CalculateRadiusModifier(Ability);
	fTargetRadius += fRadiusModifier;

	return super.GetTargetRadius(Ability);
}

// XMBOverrideInterface

function class GetOverrideBaseClass() 
{ 
	return class'X2AbilityMultiTarget_SoldierBonusRadius';
}

function GetOverrideVersion(out int Major, out int Minor, out int Patch)
{
	Major = MajorVersion;
	Minor = MinorVersion;
	Patch = PatchVersion;
}

function bool GetExtObjectValue(name Type, out object Value, optional object Data1 = none, optional object Data2 = none) { return false; }
function SetExtObjectValue(name Type, object Value, optional object Data1 = none, optional object Data2 = none);
function bool GetExtFloatValue(name Type, out float Value, optional object Data1 = none, optional object Data2 = none) { return false; }
function SetExtFloatValue(name Type, float Value, optional object Data1 = none, optional object Data2 = none);
function bool GetExtStringValue(name Type, out string Value, optional object Data1 = none, optional object Data2 = none) { return false; }
function SetExtStringValue(name Type, string Value, optional object Data1 = none, optional object Data2 = none);