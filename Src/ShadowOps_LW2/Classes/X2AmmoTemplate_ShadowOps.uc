class X2AmmoTemplate_ShadowOps extends X2AmmoTemplate;

var array<name> AllowedWeaponCat;
var array<name> ExcludeWeapon;

function int GetUIStatMarkup(ECharStatType Stat, optional XComGameState_Item Item)
{
	if (Stat == eStat_Mobility && (Item.InventorySlot == eInvSlot_GrenadePocket || Item.InventorySlot == eInvSlot_AmmoPocket))
		return 0;
	return super.GetUIStatMarkup(Stat, Item);
}

function bool IsWeaponValidForAmmo(X2WeaponTemplate WeaponTemplate)
{
	if (AllowedWeaponCat.Length > 0)
	{
		if (AllowedWeaponCat.Find(WeaponTemplate.WeaponCat) == INDEX_NONE)
			return false;
	}
	if (ExcludeWeapon.Length > 0)
	{
		if (ExcludeWeapon.Find(WeaponTemplate.DataName) != INDEX_NONE)
			return false;
	}
	return super.IsWeaponValidForAmmo(WeaponTemplate);
}
