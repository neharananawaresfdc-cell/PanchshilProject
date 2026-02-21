@isTest
public class EYI_WhatsAppService_Test {
    
    @isTest
    public static void sendWhatsAppBrochureTest(){
        String phNu = '+919949598086';
        String otpMsg = 'Dear Customer, Thanks Panchsil';
        Test.startTest();
		EYI_WhatsAppService.sendWhatsAppBrochure(phNU,otpMsg,'');
        Test.stopTest();
    }
    
    @isTest
    public static void SendTextWhatsAppMessagToNumberTest(){
        String phNu = '+919949598086';
        String otpMsg = 'Dear Customer, Thanks Panchsil';
        Test.startTest();
		EYI_WhatsAppService.SendTextWhatsAppMessagToNumber(phNU,otpMsg,'');
        Test.stopTest();
    }
    
    @isTest
    public static void sendWhatsAppTest() {
        Account acc = new Account();
        acc.Name='test';
        insert acc;
        EYI_WhatsAppService.RecipientWrapper wrapper = new EYI_WhatsAppService.RecipientWrapper();
        wrapper.recipient = 'AB';
        wrapper.templateId = 'Template123';
        wrapper.recordId = acc.Id;

        String serialized = JSON.serialize(wrapper);
        List<String> bodyList = new List<String>{ serialized };
		
		EYI_WhatsAppService.RecipientWrapper wrapper1 = new EYI_WhatsAppService.RecipientWrapper();
        wrapper1.recipient = 'S';
        wrapper1.documentId = acc.Id;
        wrapper1.templateId = 'Template123';
        wrapper1.recordId = acc.Id;

        String serialized1 = JSON.serialize(wrapper1);
        List<String> bodyList1 = new List<String>{ serialized1 };
        Test.startTest();
        EYI_WhatsAppService.sendWhatsApp(bodyList);
        EYI_WhatsAppService.sendWhatsApp(bodyList1);
        Test.stopTest();
    }
     @isTest
    public static void sendWhatsAppTest1() {
        Account acc = new Account();
        acc.Name='test';
        insert acc;
        EYI_WhatsAppService.RecipientWrapper wrapper = new EYI_WhatsAppService.RecipientWrapper();
        wrapper.recipient = '+919949598086';
        wrapper.templateId = 'Template123';
        wrapper.recordId = acc.Id;

        String serialized = JSON.serialize(wrapper);
        List<String> bodyList = new List<String>{ serialized };

		
        Test.startTest();
        EYI_WhatsAppService.sendWhatsApp(bodyList);
        Test.stopTest();
    }
    
    @isTest
    public static void sendWhatsAppBrochure_ExceptionTest() {
        Test.startTest();
        // Pass nulls to force a NullPointerException or similar
        EYI_WhatsAppService.sendWhatsAppBrochure(null, null, null);
        EYI_WhatsAppService.sendWhatsAppBrochure('invalid', null, null);
        Test.stopTest();
    }
    
   
}