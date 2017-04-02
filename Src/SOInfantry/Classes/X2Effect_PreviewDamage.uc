class X2Effect_PreviewDamage extends X2Effect;

var X2Effect WrappedEffect;

simulated function GetDamagePreview(StateObjectReference TargetRef, XComGameState_Ability AbilityState, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	WrappedEffect.GetDamagePreview(TargetRef, AbilityState, MinDamagePreview, MaxDamagePreview, AllowsShield);
}