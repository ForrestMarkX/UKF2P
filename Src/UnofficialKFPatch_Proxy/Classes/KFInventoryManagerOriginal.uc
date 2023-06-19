class KFInventoryManagerOriginal extends Object;

simulated function ThrowMoney();
reliable server function ServerThrowMoney();
simulated event DiscardInventory();
reliable server final private function ServerBuyUpgrade(byte ItemIndex, int CurrentUpgradeLevel);
reliable server final private event ServerAddTransactionUpgrade(int ItemIndex, int NewUpgradeLevel);