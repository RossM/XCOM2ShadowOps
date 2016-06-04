class XMBEffect_Persistent extends X2Effect_Persistent implements(XMBEffectInterface);

// This class adds some extra methods to X2Effect_Persistent which can be overridden in a
// subclass to create new effects.

// If true, the unit with this effect is immune to critical hits.
function bool CannotBeCrit(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) { return false; }

// If true, the unit with this effect doesn't take penalties to hit and crit chance for using 
// squadsight.
function bool IgnoreSquadsightPenalty(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) { return false; }

// This function can add new hit modifiers after all other hit calculations are done. Importantly,
// it gets access to the complete shot breakdown so far, so it can inspect the chance of a hit, 
// chance of a graze, etc. For example, it could apply a penalty to graze chance based on the total
// hit chance.
//
// Since this applies after all other modifiers, including the modifier that zeroes out critical
// hit chance on shots that can't crit, it can do things like add critical hit chance to reaction 
// shots, or graze chance to shots with a 100% hit chance.
//
// If there are multiple effects with GetFinalToHitModifiers on a unit, they all get the same 
// breakdown, so they won't see the effects of other GetFinalToHitModifiers overrides.
function GetFinalToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers);

////////////////////
// Implementation //
////////////////////

// XMBEffectInterface

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }
function bool GetExtValue(LWTuple Data) { return false; }

function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, ShotBreakdown ShotBreakdown, out array<ShotModifierInfo> ShotModifiers)
{
	switch (Type)
	{
	case 'CannotBeCrit':
		return CannotBeCrit(EffectState, Attacker, Target, AbilityState);

	case 'IgnoreSquadsightPenalty':
		return IgnoreSquadsightPenalty(EffectState, Attacker, Target, AbilityState);

	case 'FinalToHitModifiers':
		GetFinalToHitModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotBreakdown, ShotModifiers);
		return true;
	}
	
	return false;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim ToHitCalc, SubToHitCalc;
	local ShotBreakdown Breakdown;
	local ShotModifierInfo Modifier;
	local AvailableTarget kTarget;
	local int idx;

	AbilityTemplate = AbilityState.GetMyTemplate();
	ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);

	if (ToHitCalc == none)
		return;

	// We want to make sure that other XMBEffect_Persistent's effects are not included in our calculation.
	// Luckily, A2AbilityToHitCalc.HitModifiers is unused, so we use it as a flag to indicate we are in a sub-calculation.
	if (ToHitCalc.IsA('XMBAbilityToHitCalc_StandardAim'))
		return;
	if (ToHitCalc.HitModifiers.Length > 0)
		return;
	ToHitCalc.HitModifiers.Length = 1;

	// We do something very strange and magical here: we do the entire hit calc ahead of time, so we can set up exactly the modifiers we want.

	// We need to allocate a new ToHitCalc to avoid clobbering the breakdown of the one being calculated.
	`Log(`location @ "1");
	SubToHitCalc = new ToHitCalc.Class(ToHitCalc);
	`Log(`location @ "2");

	`Log(`location @ "3");
	kTarget.PrimaryTarget = Target.GetReference();
	`Log(`location @ "4");
	SubToHitCalc.GetShotBreakdown(AbilityState, kTarget, Breakdown);
	`Log(`location @ "5");

	// Recalculate raw shot breakdown table
	for (idx = 0; idx < eHit_MAX; idx++)
		Breakdown.ResultTable[idx] = 0;

	foreach Breakdown.Modifiers(Modifier)
		Breakdown.ResultTable[Modifier.ModType] += Modifier.Value;

	// Add in our own modifiers if this is a call to super.GetToHitModifiers
	foreach ShotModifiers(Modifier)
		Breakdown.ResultTable[Modifier.ModType] += Modifier.Value;

	// If we are supposed to be ignoring squadsight modifiers, find the squadsight modifiers and cancel them
	if (IgnoreSquadsightPenalty(EffectState, Attacker, Target, AbilityState))
	{
		foreach Breakdown.Modifiers(Modifier)
		{
			// Kind of a hacky way to check, since it depends on localization, but nothing should localize some other skill to "squadsight"
			if (Modifier.Reason == class'XLocalizedData'.default.SquadsightMod)
			{
				// Cancel out the modifier and remove it from the result table
				Modifier.Value *= -1;
				Modifier.Reason = FriendlyName;
				ShotModifiers.AddItem(Modifier);
				Breakdown.ResultTable[Modifier.ModType] += Modifier.Value;
			}
		}
	}

	// Apply final to-hit modifiers
	GetFinalToHitModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, Breakdown, ShotModifiers);

	ToHitCalc.HitModifiers.Length = 0;
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim ToHitCalc, SubToHitCalc;
	local ShotBreakdown Breakdown;
	local ShotModifierInfo Modifier;
	local AvailableTarget kTarget;
	local int idx;

	AbilityTemplate = AbilityState.GetMyTemplate();
	ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);

	if (ToHitCalc == none)
		return;

	// We want to make sure that other XMBEffect_Persistent's effects are not included in our calculation.
	// Luckily, A2AbilityToHitCalc.HitModifiers is unused, so we use it as a flag to indicate we are in a sub-calculation.
	if (ToHitCalc.IsA('XMBAbilityToHitCalc_StandardAim'))
		return;
	if (ToHitCalc.HitModifiers.Length > 0)
		return;
	ToHitCalc.HitModifiers.Length = 1;

	// We do something very strange and magical here: we do the entire hit calc ahead of time, so we can set up exactly the modifiers we want.

	// We need to allocate a new ToHitCalc to avoid clobbering the breakdown of the one being calculated.
	SubToHitCalc = new ToHitCalc.Class(ToHitCalc);
	SubToHitCalc.HitModifiers.Length = 1;

	kTarget.PrimaryTarget = Target.GetReference();
	SubToHitCalc.GetShotBreakdown(AbilityState, kTarget, Breakdown);

	// Recalculate raw shot breakdown table
	for (idx = 0; idx < eHit_MAX; idx++)
		Breakdown.ResultTable[idx] = 0;

	foreach Breakdown.Modifiers(Modifier)
		Breakdown.ResultTable[Modifier.ModType] += Modifier.Value;

	// Add in our own modifiers if this is a call to super.GetToHitAsTargetModifiers
	foreach ShotModifiers(Modifier)
		Breakdown.ResultTable[Modifier.ModType] += Modifier.Value;

	if (CannotBeCrit(EffectState, Attacker, Target, AbilityState))
	{
		Modifier.ModType = eHit_Crit;
		Modifier.Value = -max(Breakdown.ResultTable[eHit_Crit], 0);
		Modifier.Reason = FriendlyName;
		ShotModifiers.AddItem(Modifier);
	}

	ToHitCalc.HitModifiers.Length = 0;
}