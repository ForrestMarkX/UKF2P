class KFGFxTraderContainer_StoreOriginal extends Object;

function SetItemInfo(out GFxObject ItemDataArray, STraderItem TraderItem, int SlotIndex);
function bool IsItemFiltered(STraderItem Item, optional bool bDebug);
function RefreshWeaponListByPerk(byte FilterIndex, const out array<STraderItem> ItemList);