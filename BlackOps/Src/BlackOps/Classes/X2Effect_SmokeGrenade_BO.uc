class X2Effect_SmokeGrenade_BO extends X2Effect_SmokeGrenade;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotMod;
	local XComGameState_Unit SourceUnit;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;

	if (Target.IsInWorldEffectTile(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Class.Name))
	{
		ShotMod.ModType = eHit_Success;
		ShotMod.Value = HitMod;
		ShotMod.Reason = FriendlyName;
		ShotModifiers.AddItem(ShotMod);

		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

		if (SourceUnit.HasSoldierAbility('DenseSmoke'))
		{
			AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('DenseSmoke');

			ShotMod.ModType = eHit_Success;
			ShotMod.Value = -20;
			ShotMod.Reason = AbilityTemplate.LocFriendlyName;
			ShotModifiers.AddItem(ShotMod);
		}
	}
}
