class X2TargetingMethod_Grenade_XModBase extends X2TargetingMethod_Grenade implements(XMBOverrideInterface);

// XModBase version
var int MajorVersion, MinorVersion, PatchVersion;

// This is necessary to get grenade-radius-modifying abilities to work, by giving the terrible
// hack in X2AbilityMultiTarget_SoldierBonusRadius_XModBase a chance to do its thing before the
// target tiles are calculated. Most of the important bits of code are native so this is the
// best I can do.
function Update(float DeltaTime)
{
	Ability.GetAbilityRadius();

	super.Update(DeltaTime);	
}

// XMBOverrideInterace

function class GetOverrideBaseClass() 
{ 
	return class'X2TargetingMethod_Grenade';
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