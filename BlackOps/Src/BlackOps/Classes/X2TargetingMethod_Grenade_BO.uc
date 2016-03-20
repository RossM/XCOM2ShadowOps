class X2TargetingMethod_Grenade_BO extends X2TargetingMethod_Grenade;

// This is necessary to get grenade-radius-modifying abilities to work, by giving the terrible
// hack in X2AbilityMultiTarget_SoldierBonusRadius_BO a chance to do its thing before the
// target tiles are calculated. Most of the important bits of code are native so this is the
// best I can do.
function Update(float DeltaTime)
{
	Ability.GetAbilityRadius();

	super.Update(DeltaTime);	
}