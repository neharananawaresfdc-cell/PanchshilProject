/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class EYI_RECCatClassificationUpdateSchedTest {
   @isTest
    static void testExecute() {
        //EYI_RECCatClassificationUpdateScheduler.isTestMode = true;
        
        Test.startTest();
        EYI_RECCatClassificationUpdateScheduler scheduler = new EYI_RECCatClassificationUpdateScheduler();
        scheduler.execute(null); 
        Test.stopTest();
    }

    @isTest
    static void testScheduleBatch() {
        Test.startTest();
        EYI_RECCatClassificationUpdateScheduler.scheduleBatch();
        Test.stopTest();
    }

}