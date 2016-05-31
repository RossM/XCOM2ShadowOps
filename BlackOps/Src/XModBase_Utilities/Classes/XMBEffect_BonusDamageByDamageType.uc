class XMBEffect_BonusDamageByDamageType extends XMBEffect_Persistent config(GameData_SoldierSkills);

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
	local X2Effect_Persistent PersistentEffect;

	if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
		return 0;

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
		PersistentEffect = X2Effect_Persistent(Effect);
		if (PersistentEffect != none && PersistentEffect.ApplyOnTick.Length > 0)
		{
			ApplyDamageEffect = X2Effect_ApplyWeaponDamage(PersistentEffect.ApplyOnTick[0]);
			if (ApplyDamageEffect != none)
			{ 
				DamageType = ApplyDamageEffect.EffectDamageValue.DamageType;
				if (RequiredDamageTypes.Find(DamageType) != INDEX_NONE && !TargetDamageable.IsImmuneToDamage(DamageType))
					return DamageBonus;
			}
		}
	}

	// Check for effects that actually deal fire damage. This includes the burning on-tick effect.
	ApplyDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
	if (ApplyDamageEffect != none)
	{
		ApplyDamageEffect.GetEffectDamageTypes(NewGameState, AppliedData, AppliedDamageTypes);

		foreach AppliedDamageTypes(DamageType)
		{
			if (RequiredDamageTypes.Find(DamageType) != INDEX_NONE && !TargetDamageable.IsImmuneToDamage(DamageType))
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