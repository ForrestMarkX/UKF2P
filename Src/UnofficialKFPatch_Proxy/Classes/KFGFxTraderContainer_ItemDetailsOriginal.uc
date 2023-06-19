class KFGFxTraderContainer_ItemDetailsOriginal extends Object;

function SetPlayerItemDetails(out STraderItem TraderItem, int ItemPrice, optional int UpgradeLevel = INDEX_NONE);
function SetGenericItemDetails(const out STraderItem TraderItem, out GFxObject ItemData, optional int UpgradeLevel = INDEX_NONE);
function SetDetailsText(string DetailName, string NewName);