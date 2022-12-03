class KFGFxObject_TraderItemsProxy extends Object;

stripped final function context(KFGFxObject_TraderItems.GetItemIndicesFromArche) bool GetItemIndicesFromArche( out byte ItemIndex, name WeaponClassName )
{
    ItemIndex = SaleItems.Find('ClassName', WeaponClassName);
    return ItemIndex != INDEX_NONE;
}