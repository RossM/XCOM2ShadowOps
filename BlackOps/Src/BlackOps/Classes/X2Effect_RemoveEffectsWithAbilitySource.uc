class X2Effect_RemoveEffectsWithAbilitySource extends X2Effect_RemoveEffects;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect EffectState;
	local X2Effect_Persistent PersistentEffect;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		if (EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID == ApplyEffectParameters.SourceStateObjectRef.ObjectID &&
			EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == ApplyEffectParameters.TargetStateObjectRef.ObjectID)
		{
			PersistentEffect = EffectState.GetX2Effect();
			if (ShouldRemoveEffect(EffectState, PersistentEffect))
			{
				EffectState.RemoveEffect(NewGameState, NewGameState, bCleanse);
			}
		}
	}
}
