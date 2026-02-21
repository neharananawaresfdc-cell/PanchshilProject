@isTest
public with sharing class EYI_TaskTriggerHandlerTest {
    @IsTest
    static void TaskTriggerHandlerTestMethod
        (){
        List<Task> taskList = EYI_TestDataFactory.createPresalesTask('Follow Up',1,false);
        
        System.debug('taskList===> '+taskList);
        taskList[0].RecordTypeId = System.Label.EYI_Postsales_Record_Type_Id;
        System.debug('taskList[0].RecordTypeId ==> '+taskList[0].RecordTypeId);
        Test.startTest();
		insert taskList;
        Test.stopTest();
    }
    @IsTest
    static void EYI_TaskTriggerHandlerTest1(){
        List<Task> taskList = EYI_TestDataFactory.createPresalesTask('Follow Up',1,true);
        System.debug('taskList===> '+taskList);
        Test.startTest();
            update taskList;
        Test.stopTest();
    }
     @IsTest
    static void EYI_TaskTriggerHandlerTest2(){
        List<Task> taskList = EYI_TestDataFactory.createPresalesTask('Follow Up',1,true);
        System.debug('taskList===> '+taskList);
        Test.startTest();
            EYI_TaskTriggerHelper.updateEscalationDayRM(taskList);
        Test.stopTest();
    }
}