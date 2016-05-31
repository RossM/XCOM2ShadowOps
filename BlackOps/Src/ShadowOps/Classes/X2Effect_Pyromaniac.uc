class X2Effect_Pyromaniac extends XMBEffect_Persistent config(GameData_SoldierSkills);

var array<name> RequiredDamageTypes;
var int DamageBonus;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local array<name> AppliedDamageTypes;
	local name DamageType;
	local X2Effect_ApplyWeaponDamage ApplyDamageEffect;
	local XComGameStateHistory History;
	local XComGameState_Item WeaponState, AmmoState;
	local X2AbilityTemplate Ability;
	local array<X2Effect> WeaponEffects;
	local X2Effect Effect;
	local X2Effect_Burning BurningEffect;

	History = `XCOMHISTORY;

	Ability = AbilityState.GetMyTemplate();

	if (Ability.bUseThrownGrenadeEffects)
	{
		WeaponState = XComGameState_Item(History.GetGameStateForObjectID(AppliedData.ItemStateObjectRef.ObjectID));
		if (WeaponState != none)
			WeaponEffects = X2GrenadeTemplate(WeaponState.GetMyTemplate()).ThrownGrenadeEffects;
	}
	else if (Ability.bUseLaunchedGrenadeEffects)
	{
		WeaponState = AbilityState.GetSourceAmmo();
		if (WeaponState != none)
			WeaponEffects = X2GrenadeTemplate(WeaponState.GetMyTemplate()).LaunchedGrenadeEffects;
	}
	else if (Ability.bAllowAmmoEffects)
	{
		WeaponState = XComGameState_Item(History.GetGameStateForObjectID(AppliedData.ItemStateObjectRef.ObjectID));
		if (WeaponState != none && WeaponState.HasLoadedAmmo())
		{
			AmmoState = XComGameState_Item(History.GetGameStateForObjectID(WeaponState.LoadedAmmo.ObjectID));
			WeaponEffects = X2AmmoTemplate(AmmoState.GetMyTemplate()).TargetEffects;
		}
	}

	// Firebombs don't actually deal fire damage, they deal explosive damage. Check for the X2Effect_Burning.
	foreach WeaponEffects(Effect)
	{
		BurningEffect = X2Effect_Burning(Effect);
		if (BurningEffect != none && RequiredDamageTypes.Find(BurningEffect.GetBurnDamage().EffectDamageValue.DamageType) != INDEX_NONE)
			return DamageBonus;
	}

	// Check for effects that actually deal fire damage. This includes the burning on-tick effect.
	ApplyDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
	if (ApplyDamageEffect != none)
	{
		ApplyDamageEffect.GetEffectDamageTypes(NewGameState, AppliedData, AppliedDamageTypes);

		foreach RequiredDamageTypes(DamageType)
		{
			if (AppliedDamageTypes.Find(DamageType) != INDEX_NONE)
			{
				return DamageBonus;
			}
		}
	}

	return 0;
}

defaultproperties
{
	EffectName = "Pyromaniac";
}