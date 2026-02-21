@isTest
public class EYI_SAP_ReportController_Test {
	@isTest
    public static void getTDSReportTest(){
        Map<String, List<String>> testFilter = new Map<String, List<String>>();
        testFilter.put('CompanyCode', new List<String>{'1000', '2000'});
        testFilter.put('Vendor', new List<String>{'V001'});
        testFilter.put('FiscalYear', new List<String>{'2024'});
        
        String filterJson = JSON.serialize(testFilter);
        String badJson = '{badJson: [unquotedValue]}';
        Test.startTest();
        String result = EYI_SAP_ReportController.getTDSReport(filterJson);
		//String result1 = EYI_SAP_ReportController.getTDSReport(badJson);
        Test.stopTest();
    }
    
    @isTest
    public static void getAgeingReportTest(){
        
         Map<String, Object> input = new Map<String, Object>{
            'KeyDate' => '2025-05-01',
            'CompanyCode' => new List<String>{'1000', '2000'},
            'CustomerNo' => new List<String>{'C001', 'C002'},
            'DueDays1' => new List<String>{'30'},
            'DueDays2' => new List<String>{'60'}
        };

        String inputJson = JSON.serialize(input);
		String badJson = '{badJson: [unquotedValue]}';
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockApiResponse());
        String result = EYI_SAP_ReportController.getAgeingReport(inputJson);
        //String result1 = EYI_SAP_ReportController.getAgeingReport(badJson);
        Test.stopTest();
    }
    
    @isTest
    public static void getAllProjectTest(){
        EYI_Project__c projctobj = new EYI_Project__c(
            Name = 'Balewadi 23',
            EYI_Sourcing_Manager__c = UserInfo.getUserId(),
            EYI_Condition_Group_1__c = 'PMC',
            EYI_Distribution_Channel__c = '10',
            EYI_Project_Status__c = 'Pre- Launch',
            EYI_Project_Type__c = 'Flat',
            EYI_Zone__c = 'Pune City',
            EYI_Chatbot_Active__c = true,
            EYI_Project_Location__c = 'Kharadi',
            EYI_Project_Site_Location_Link__c = 'https://maps.app.goo.gl/ZzSkyikTyHoDYoKr5',
            EYI_Project_Start_Date__c = System.today() - 10,
            EYI_SAP_Company_Code__c = '1320',
            EYI_SAP_Plant_Code__c = 'R15A',
            EYI_Sales_District__c = 'IN0001',
            EYI_SAP_Salesorg__c = 'R152',
            EYI_Stamp_Duty__c = 5,
            EYI_RDS_State__c = 'Maharashtra',
            EYI_Asset_Class__c = 'Outright',
            EYI_Sub_Asset_Class__c = 'Plot',
            EYI_Total_Budget__c = 1000000,
            EYI_Project_Code__c = '83',
            EYI_Project_Property_Type__c = 'Residential',
            EYI_SAPMaterial_Code__c = 'EYI_SAPMaterial_Code__c'
        );
        insert projctobj;
        Test.startTest();
        EYI_SAP_ReportController.getAllProjects();
        Test.stopTest();
    }
    
    class MockApiResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"EX_MESSAGE":{"Message":""},"EX_OUTPUT":{"item":[{"SalesDocument":"3020000159","SOLineItem":"10","CustomerNo":"20000245","CustomerName":"Yugantara Vishwakaram","TotalConsideration":"27006000","BookingDate":"2023-07-28"}]}}');
            return res;
        }
    }
    
    @isTest
    public static void getApiDataTest(){
        Map<String, List<String>> filterMap = new Map<String, List<String>>();
        filterMap.put('CustomerNo', new List<String>{'20000245'});
        filterMap.put('SalesOrg', new List<String>{'R150'});
        filterMap.put('KeyDate', new List<String>{'2024-12-31'});

        String filterString = JSON.serialize(filterMap);
        
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockApiResponse());
        String response = EYI_SAP_ReportController.getApiData(filterString);
		Test.stopTest();        
    }
}