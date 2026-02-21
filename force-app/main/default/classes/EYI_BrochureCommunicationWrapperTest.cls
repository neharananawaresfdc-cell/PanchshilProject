@isTest
public class EYI_BrochureCommunicationWrapperTest {

    @isTest
    static void testWrapperInitialization() {
		Account acc = new Account();
        acc.Name= 'Test';
        insert acc;
        List<String> fileIds = new List<String>{acc.Id};

        EYI_BrochureCommunicationWrapper wrapper = new EYI_BrochureCommunicationWrapper();

        wrapper.leadId = acc.Id; // sample Lead Id
        wrapper.projectName = 'Test Project';
        wrapper.projectId = acc.Id; // sample Project Id
        wrapper.senderEmail = 'test@example.com';
        wrapper.ccEmails = 'cc1@example.com,cc2@example.com';
        wrapper.senderPhone = '9876543210';
        wrapper.selectedFileIds = fileIds;
        wrapper.messagebody = 'This is a test brochure email.';
        wrapper.emailSubject = 'Test Subject';

        
    }
}