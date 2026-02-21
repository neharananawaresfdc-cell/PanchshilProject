@isTest
public class EYI_LeadTriggerHandlerTest { 
	@isTest
    public static void updateProjectOnLeadTest(){
        //lead trigger test class
        Test.startTest();
		List<Lead> leadList = EYI_TestDataFactory.createLeads('Test','Golden Bell',1,'983434334','Web','Panchshil.com',true);
        Test.stopTest();
    }
}