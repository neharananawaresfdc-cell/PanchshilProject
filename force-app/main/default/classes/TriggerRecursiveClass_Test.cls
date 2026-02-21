@isTest
private class TriggerRecursiveClass_Test {
    @isTest
    static void testStaticSets() {
        Account acc = new Account();
        acc.Name= 'Test Account';
        insert acc;

        TriggerRecursiveClass.InventoryAPISetId.add(acc.Id);
        TriggerRecursiveClass.CarParkingAPISetId.add(acc.Id);
        TriggerRecursiveClass.ParcingAPISetId.add(acc.Id);

        System.assert(TriggerRecursiveClass.InventoryAPISetId.contains(acc.Id));
        System.assert(TriggerRecursiveClass.CarParkingAPISetId.contains(acc.Id));
        System.assert(TriggerRecursiveClass.ParcingAPISetId.contains(acc.Id));
    }
}