@isTest
public class EYI_SMSService_Test {
      @isTest
    static void testSendTextSMSMessagToNumber_elsePath() {
        // This test will hit the `else` block (Test.isRunningTest() = true)
        Account acc = new Account();
        acc.Name='test';
        insert acc;
        EYI_SMSService.SendTextSMSMessagToNumber('9988777766', 'Hello', acc.Id);
        // Expect: debug log "Skipping SMS callout in test context"
    }

    @isTest
    static void testSendSMSInternal_methodLogic() {
        Test.startTest();
		Account acc = new Account();
        acc.Name='test';
        insert acc;
        // Call the internal logic directly to get coverage
        EYI_SMSService.sendSMSInternal('9988777766', 'Hello', acc.Id);

        Test.stopTest();

        // Assert if needed (e.g., check messageType)
        System.assertEquals('SMS', tdc_tsw.GlobalSMSSender.messageType);
    }
   
	@isTest
    public static void SendTextSMSMessagToNumberTest(){
        String phNu = '+919949598086';
        String otpMsg = 'Dear Customer, Thanks Panchsil';
        Test.startTest();
		EYI_SMSService.SendTextSMSMessagToNumber(phNU,otpMsg,'');
         EYI_SMSService.SendTextSMSMessagToNumber(null, null, null);

        Test.stopTest();
    }
    
    @isTest
    public static void sendSMSBrochureTest(){
        String phNu = '+919949598086';
        String otpMsg = 'Dear Customer, Thanks Panchsil';
        Test.startTest();
		EYI_SMSService.sendSMSBrochure(phNU,otpMsg,'');
        EYI_SMSService.SendTextSMSMessagToNumber(null, null, null); 
        EYI_SMSService.SendTextSMSMessagToNumber(phNU, null, null); 

        Test.stopTest();
    }
    
    @isTest
    public static void SendSMSTest() {
        Account acc = new Account();
        acc.Name='test';
        insert acc;
        EYI_SMSService.RecipientWrapper wrapper = new EYI_SMSService.RecipientWrapper();
        
        wrapper.recipient = 'AB';
        wrapper.templateId = 'Template123';
        wrapper.recordId = acc.Id;

        String serialized = JSON.serialize(wrapper);
        List<String> bodyList = new List<String>{ serialized };

		EYI_SMSService.RecipientWrapper wrapper1 = new EYI_SMSService.RecipientWrapper();
        wrapper1.recipient = 'Sssss_c';
        wrapper1.templateId = 'Template123';
        wrapper1.recordId = acc.Id;

        String serialized1 = JSON.serialize(wrapper1);
        List<String> bodyList1 = new List<String>{ serialized1 };
        Test.startTest();
        EYI_SMSService.sendSMS(bodyList);
        EYI_SMSService.sendSMS(bodyList1);
        EYI_SMSService.sendSMS(new List<String>());
        EYI_SMSService.sendSMS(new List<String>{'{"invalid": "json"}'});

        Test.stopTest();
    }
     @isTest
    public static void SendSMSTest1() {
        Account acc = new Account();
        acc.Name='test';
        insert acc;
        EYI_SMSService.RecipientWrapper wrapper = new EYI_SMSService.RecipientWrapper();
        wrapper.recipient = 'EYI_Phone__c';
        wrapper.templateId = 'Template123';
        wrapper.recordId = acc.Id;

        String serialized = JSON.serialize(wrapper);
        Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        List<String> valueList = new List<String>();

        for (Object val : dataMap.values()) {
            valueList.add(String.valueOf(val));
        }
        Test.startTest();
        EYI_SMSService.sendSMS(valueList);
       
        Test.stopTest();
    }
   
     @isTest
    static void isStringTest() {
        System.assert(EYI_SMSService.isString('test'));
        System.assert(!EYI_SMSService.isString(123));
        System.assert(!EYI_SMSService.isString(null));
    }
   
}