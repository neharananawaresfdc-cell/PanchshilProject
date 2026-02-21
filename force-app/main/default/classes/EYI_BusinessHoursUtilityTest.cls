/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@istest
public with sharing class EYI_BusinessHoursUtilityTest {
    @IsTest
    static void BusnesHrsUtlityTest(){
        Test.startTest();
            EYI_BusinessHoursUtility util = new EYI_BusinessHoursUtility();
        Test.stopTest();
        System.assertEquals(true, util.isBusinessDay(Date.newInstance(2013, 1, 7)));
    }
    @IsTest
    static void BusnesHrsUtlityTest1(){
        Test.startTest();
            EYI_BusinessHoursUtility util = new EYI_BusinessHoursUtility();
            util.getStartTime(Date.newInstance(2013, 1, 7));
            util.getEndTime(Date.newInstance(2013, 1, 7));
        Test.stopTest();
        System.assertEquals(true, util.isBusinessDay(Date.newInstance(2013, 1, 7)));
    }
    @IsTest
    static void BusnesHrsUtlityTest2(){
        Test.startTest();
            EYI_BusinessHoursUtility util = new EYI_BusinessHoursUtility();
            util.addBusinessHours(Datetime.newInstance(Date.newInstance(2013, 1, 7), Time.newInstance(0,0,0,0)),10);
            EYI_BusinessHoursUtility.addBusinessMinutes(Date.newInstance(2013, 1, 7),10);
        Test.stopTest();
        System.assertEquals(true, util.isBusinessDay(Date.newInstance(2013, 1, 7)));
    }
    // @IsTest
    // static void BusnesHrsUtlityTest3(){
    //     Test.startTest();
    //         EYI_BusinessHoursUtility util = new EYI_BusinessHoursUtility();
    //         util.getBuinessDaysDiffInHrs(DateTime.newInstance(2024, 11, 28, 10, 30, 0),DateTime.newInstance(2024, 11, 27, 10, 30, 0));
    //         util.getBuinessDaysDiffInDays(DateTime.newInstance(2024, 11, 28, 10, 30, 0),DateTime.newInstance(2024, 11, 27, 10, 30, 0));
    //         util.getDateDiffInDays(DateTime.newInstance(2024, 11, 28, 10, 30, 0),DateTime.newInstance(2024, 11, 27, 10, 30, 0));
    //     Test.stopTest();
    //     System.assertEquals(true, util.isBusinessDay(Date.newInstance(2013, 1, 7)));
    // }
   
    @IsTest
static void BusnesHrsUtlityTest3() {
    Test.startTest();
    EYI_BusinessHoursUtility util = new EYI_BusinessHoursUtility();
    Long hoursDiff = EYI_BusinessHoursUtility.getBuinessDaysDiffInHrs(
        DateTime.newInstance(2024, 11, 28, 10, 30, 0),
        DateTime.newInstance(2024, 11, 27, 10, 30, 0)
    );
    Long daysDiff = EYI_BusinessHoursUtility.getBuinessDaysDiffInDays(
        DateTime.newInstance(2024, 11, 28, 10, 30, 0),
        DateTime.newInstance(2024, 11, 27, 10, 30, 0)
    );
    Integer dateDiff = EYI_BusinessHoursUtility.getDateDiffInDays(
        DateTime.newInstance(2024, 11, 28, 10, 30, 0),
        DateTime.newInstance(2024, 11, 27, 10, 30, 0)
    );
    Test.stopTest();
    System.assertEquals(true, util.isBusinessDay(Date.newInstance(2013, 1, 7)));
}

}