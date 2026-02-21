@IsTest
private class EYI_CustomerLedgerControllerTest {
    
    // Step 1: Create the mock response class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            
            // Minimal mocked JSON response
            res.setBody(JSON.serialize(new Map<String, Object>{
                'n0:ZSD_CUSTOMER_LEDGER_SFResponse' => new Map<String, Object>{
                    'EX_OUTPUT' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'invoice' => 'INV001',
                            'companyCode' => '1580',
                            'customerCode' => 'CUST001',
                            'paymentMilestone' => 'On Booking',
                            'demandRaisedDate' => '2025-07-01',
                            'dueDate' => '2025-07-10',
                            'principalAmount' => 1000000,
                            'gstAmount' => 180000,
                            'totalReceivable' => 1180000,
                            'paymentReceived' => 0,
                            'otherAdjustment' => 0,
                            'totalOutstanding' => 1180000,
                            'docNumber' => '8020001234',
                            'receivedDate' => '',
                            'sourceofPayment' => '',
                            'bankDetails' => '',
                            'instrumentNumber' => '',
                            'instrumentDate' => ''
                        }
                    }
                }
            }));
            return res;
        }
    }

    @IsTest
    static void testFetchCustomerLedger_SuccessfulMockCallout() {
        // Step 2: Register mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Step 3: Call method inside Test.start/stop
        Test.startTest();
        String response = EYI_CustomerLedgerController.fetchCustomerLedger('CUST001', '1580');
        
        Test.stopTest();

        System.debug('Response: ' + response);
        System.assert(response.contains('On Booking'), 'Expected payment milestone in response');
    }
}