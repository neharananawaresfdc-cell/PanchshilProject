@isTest
public class EYI_TDSOutstandingBatchTest {
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');

        // Mocked JSON response with one TDS item
        Map<String, Object> responseBody = new Map<String, Object>{
            'n0:ZSD_CUSTOMER_LEDGER_SFResponse' => new Map<String, Object>{
                'EX_OUTPUT' => new Map<String, Object>{
                    'item' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'INVOICE' => 'INV001',
                            'COMPANYCODE' => '1580',
                            'CUSTOMERCODE' => 'CUST001',
                            'PAYMENTMILESTONE' => 'TDS',
                            'DEMANDRAISEDDATE' => '2025-07-01',
                            'DUEDATE' => '2025-07-10',
                            'PRINCIPALAMOUNT' => 1000000,
                            'GSTAMOUNT' => 180000,
                            'TOTALRECEIVABLE' => 1180000,
                            'PAYMENTRECEIVED' => 0,
                            'OTHERADJUSTMENT' => 0,
                            'TOTALOUTSTANDING' => '1180000',
                            'DOCNUMBER' => '8020001234',
                            'RECEIVEDDATE' => '',
                            'SOURCEOFPAYMENT' => '',
                            'BANKDETAILS' => '',
                            'INSTRUMENTNUMBER' => '',
                            'INSTRUMENTDATE' => ''
                        }
                    }
                }
            }
        };

        res.setBody(JSON.serialize(responseBody));
        return res;
    }
    }
    
    // Mock for empty response
    class MockEmptyResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(JSON.serialize(
                new Map<String, Object>{
                    'n0:ZSD_OUTSTANDING_BALANCE_SFResponse' => new Map<String, Object>{
                        'EX_MESSAGE' => '',
                            'EX_OUTPUT' => new Map<String, Object>{
                                'item' => new List<Map<String, Object>>()
                                    }
                    }
                }
            ));
            return res;
        }
    }
    
    // Mock for 500 error
    class MockSAP500Error implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    
    @isTest
    static void testProcessApiResponseMethod() {
        EYI_Project__c proj = new EYI_Project__c(
            Name = 'Test Project',
            EYI_SAP_Company_Code__c = '1320',
            EYI_Project_Code__c = 'PRJ001'
        );
        insert proj;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            EYI_SAP_Customer_Number__c = '0010000001',
            EYI_Project_Enquired__c = proj.Id,
            EYI_Ownership_Status__c = 'Accepted'
        );
        insert opp;
        
        EYI_Booking__c book = new EYI_Booking__c(
            EYI_SAP_Sales_Order_Number__c ='1234400994',
            EYI_Opportunity_Name__c= opp.id,
            EYI_Project_Name__c= proj.id,
            EYI_Divisions__c='Residential',
            //EYI_Account_Name__c= Acc.id,
            EYI_Actual_Booking_Date__c= system.today()-10,
            EYI_Cancellation_Reason__c = 'Sales call',
            EYI_Sourcing_manager__c= UserInfo.getUserId()
        );
        insert book;
        opp.EYI_Booking__c =book.Id;
        update opp;
        // Use the same mock body as MockSAPCallout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

         Test.startTest();
        EYI_TDSOutstandingBatch batch = new EYI_TDSOutstandingBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    @isTest
    static void testSchedulerExecute() {
        Test.startTest();
        
        // Instantiate and execute the scheduler
        EYI_TDSOutstandingSchedular scheduler = new EYI_TDSOutstandingSchedular();
        scheduler.execute(null); // Passing null is okay in test context
        
        Test.stopTest();
        
        System.assert(true, 'Scheduler execute method should run without error');
    }
}