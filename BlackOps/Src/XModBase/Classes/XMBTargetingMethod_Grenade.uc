class XMBTargetingMethod_Grenade extends X2TargetingMethod_Grenade implements(XMBOverrideInterface);

// XModBase version
var const int MajorVersion, MinorVersion, PatchVersion;

// This is necessary to get grenade-radius-modifying abilities to work, by giving the terrible
// hack in XMBAbilityMultiTarget_SoldierBonusRadius a chance to do its thing before the
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

function bool GetExtValue(LWTuple Data) { return false; }
function bool SetExtValue(LWTuple Data) { return false; }

// Targeting methods are saved as a class reference, not an object, so bake in the version here
defaultproperties
{
	MajorVersion = 0
	MinorVersion = 1
	PatchVersion = 0
}