class XMBEffect_RangeModifier extends X2Effect_Persistent;

var array<int> RangeAccuracy;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local XComGameState_Item SourceWeapon;
	local int Tiles, Modifier;

	SourceWeapon = AbilityState.GetSourceWeapon();
	if (SourceWeapon != none && SourceWeapon.LoadedAmmo.ObjectID == EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
	{
		Tiles = Attacker.TileDistanceBetween(Target);

		if (RangeAccuracy.Length > 0)
		{
			if (Tiles < RangeAccuracy.Length)
				Modifier = RangeAccuracy[Tiles];
			else  //  if this tile is not configured, use the last configured tile					
				Modifier = RangeAccuracy[RangeAccuracy.Length-1];
		}

		ModInfo.ModType = eHit_Success;
		ModInfo.Reason = FriendlyName;
		ModInfo.Value = Modifier;
		ShotModifiers.AddItem(ModInfo);
	}
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
}