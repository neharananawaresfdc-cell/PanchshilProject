@isTest
public class EYI_PaymentScheduleSync_test {
    
   @isTest
    public static void testSyncPaymentSchedules() {
                //As Per Best Practice it is important to instantiate the Rest Context
        
        String jsonString = '{' +
            '   "PaymentScheduleSync": [' +
            '       {' +
            '           "Milestone": "306",' +
            '           "SAPSalesOrg": "R150",' +
            '           "SAPPlantCode": "R15D",' +
            '           "SAPActivityNumber": "3",' +
            '           "Usage": "Z0002",' +
            '           "UsageDescription": "On Booking Changed",' +
            '           "WBSElement": "10609",' +
            '           "BillingDate": "2023-06-30",' +
            '           "ActualDate": "",' +
            '           "InvoicePercentage": "20"' +
            '       },' +
            '       {' +
            '           "Milestone": "312",' +
            '           "SAPSalesOrg": "R150",' +
            '           "SAPPlantCode": "R15D",' +
            '           "SAPActivityNumber": "7",' +
            '           "Usage": "Z0002",' +
            '           "UsageDescription": "On Booking",' +
            '           "WBSElement": "10609",' +
            '           "BillingDate": "2023-06-30",' +
            '           "ActualDate": "",' +
            '           "InvoicePercentage": "20"' +
            '       }' +
            '   ]' +
            '}';
       
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        newTower.EYI_SAP_Delivery_Plant_Code__c = 'R15D';
        insert newTower;
        
        Test.startTest();
        string SAPSalesOrg ='R150' , SAPPlantCode='R15D';
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        EYI_PaymentScheduleSync.syncPaymentSchedules();
        EYI_PaymentScheduleSync.createpaymentPlan(SAPPlantCode,SAPSalesOrg);
        Test.stopTest();
        
    }
    
     @isTest
    public static void testSyncErrorPaymentSchedules() {
                //As Per Best Practice it is important to instantiate the Rest Context
        
        String jsonString = '{' +
            '   "PaymentScheduleSync": [' +
            '       {' +
            '           "Milestone": "306",' +
            '           "SAPSalesOrg": "R152",' +
            '           "SAPPlantCode": "R15D",' +
            '           "SAPActivityNumber": "3",' +
            '           "Usage": "Z0002",' +
            '           "UsageDescription": "On Booking Changed",' +
            '           "WBSElement": "10609",' +
            '           "BillingDate": "2023-06-30",' +
            '           "ActualDate": "",' +
            '           "InvoicePercentage": "20"' +
            '       },' +
            '       {' +
            '           "Milestone": "312",' +
            '           "SAPSalesOrg": "R150",' +
            '           "SAPPlantCode": "R15D",' +
            '           "SAPActivityNumber": "7",' +
            '           "Usage": "Z0002",' +
            '           "UsageDescription": "On Booking",' +
            '           "WBSElement": "10609",' +
            '           "BillingDate": "2023-06-30",' +
            '           "ActualDate": "",' +
            '           "InvoicePercentage": "20"' +
            '       }' +
            '   ]' +
            '}';
       
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        newTower.EYI_SAP_Delivery_Plant_Code__c = 'R15D';
        insert newTower;
        
        Test.startTest();
        string SAPSalesOrg ='R150' , SAPPlantCode='R15D';
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        EYI_PaymentScheduleSync.syncPaymentSchedules();
        EYI_PaymentScheduleSync.createpaymentPlan(SAPPlantCode,SAPSalesOrg);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testSyncPaymentSchedulesElse() {
                //As Per Best Practice it is important to instantiate the Rest Context
        
        String jsonString = '{' +
            '   "PaymentScheduleSync": [' +
            '       {' +
            '           "Milestone": "306",' +
            '           "SAPSalesOrg": "R150",' +
            '           "SAPPlantCode": "R15D",' +
            '           "SAPActivityNumber": "3",' +
            '           "Usage": "Z0002",' +
            '           "UsageDescription": "On Booking",' +
            '           "WBSElement": "10609",' +
            '           "BillingDate": "2023-06-30",' +
            '           "ActualDate": "",' +
            '           "InvoicePercentage": "20"' +
            '       },' +
            '       {' +
            '           "Milestone": "306",' +
            '           "SAPSalesOrg": "R150",' +
            '           "SAPPlantCode": "R15D",' +
            '           "SAPActivityNumber": "3",' +
            '           "Usage": "Z0002",' +
            '           "UsageDescription": "On Booking",' +
            '           "WBSElement": "10609",' +
            '           "BillingDate": "2023-06-30",' +
            '           "ActualDate": "",' +
            '           "InvoicePercentage": "20"' +
            '       }' +
            '   ]' +
            '}';
       
        EYI_Tower__c newTower = new EYI_Tower__c();
        newTower.Name = 'Tower Name';
        newTower.EYI_RERA_Number__c = 'huiqhdugfy7uy';
        newTower.EYI_Stage__c ='Launch';
        newTower.EYI_SAP_Delivery_Plant_Code__c = 'R15D';
        insert newTower;
        
        Test.startTest();
        string SAPSalesOrg ='R150' , SAPPlantCode='R15D';
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonString);
        RestContext.request = req;
        EYI_PaymentScheduleSync.syncPaymentSchedules();
        EYI_PaymentScheduleSync.createpaymentPlan(SAPPlantCode,SAPSalesOrg);
        Test.stopTest();
        
    }

  }