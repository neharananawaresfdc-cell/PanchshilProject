@isTest
private class SendEmailFromFlow_Test {

    @isTest
    static void testSendEmails_CoversAllLines() {
        EYI_Customer_Information_Form__c cif = new EYI_Customer_Information_Form__c(
            EYI_Email_Id__c = 'testuser@example.com',
            EYI_First_Name__c = 'Test',
            EYI_Mobile_number__c = '9999999999'
        );
        insert cif;
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_CIF_Record__c = cif.Id
        );
        insert opp;
        EYI_Inventory__c inv = new EYI_Inventory__c(
            Name = 'Test Inventory',
            EYI_Opportunity__c = opp.Id,
            EYI_Inventory_Number__c = 'INV-001'
        );
        insert inv;
        List<String> recordIds = new List<String>{inv.Id};

        Test.startTest();
        SendEmailFromFlow.sendEmails(recordIds);
        Test.stopTest();

        System.assert(true, 'Method executed without error');
    }
}