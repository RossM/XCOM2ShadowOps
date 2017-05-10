class X2GrenadeTemplate_ShadowOps extends X2GrenadeTemplate;

function int GetUIStatMarkup(ECharStatType Stat, optional XComGameState_Item Item)
{
	if (Stat == eStat_Mobility && (Item.InventorySlot == eInvSlot_GrenadePocket || Item.InventorySlot == eInvSlot_AmmoPocket))
		return 0;
	return super.GetUIStatMarkup(Stat, Item);
}