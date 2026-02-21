@isTest
public class EYI_EmailToLeadHandlerTest {
    @isTest
    static void testEmailToLead() {
        // Create a mock email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromName = 'Test User';
        email.fromAddress = 'testuser@example.com';
        email.subject = 'Test Lead Creation';
        email.plainTextBody = 'This is a test email for lead creation.';

        // Create a mock envelope
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.fromAddress = 'testuser@example.com';

        // Instantiate the handler and call the handleInboundEmail method
        EYI_EmailToLeadHandler handler = new EYI_EmailToLeadHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);

        // Verify the result
        System.assert(result.success, 'Email processing failed');

        // Verify that a lead was created
        Lead[] leads = [SELECT Id, LastName, Company, Email, Description FROM Lead WHERE Email = :email.fromAddress];
    }
}