@isTest
private class FilteredEmailToCase_Test {

    // Utility method to run the handler
    private static Messaging.InboundEmailResult runHandler(String fromAddress, String subject, String body) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.fromAddress = fromAddress;
        email.subject = subject;
        email.plainTextBody = body;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = fromAddress;

        FilteredEmailToCase handler = new FilteredEmailToCase();
        return handler.handleInboundEmail(email, env);
    }

    @isTest
    static void testBlockedDomainDoesNotCreateCase() {
        // This test will pass if spamdomain.com is in the custom label
        // If not in the label, the case will be created, so we handle both scenarios
        String testDomain = 'spamdomain.com';

        Test.startTest();
        Messaging.InboundEmailResult res = runHandler(
            'badguy@' + testDomain,
            'Blocked domain test',
            'Should not create case'
        );
        Test.stopTest();

        System.assertEquals(true, res.success, 'Handler should always mark success');

        // If label contains spamdomain.com → no case should be created
        // If not in label → case will be created
        List<Case> cases = [SELECT Id FROM Case WHERE Subject = 'Blocked domain test'];
        if (System.Label.Blocked_Domains != null &&
            System.Label.Blocked_Domains.toLowerCase().contains(testDomain)) {
            System.assertEquals(0, cases.size(), 'Case should not be created for blocked domain');
        } else {
            System.assertEquals(1, cases.size(), 'Case should be created if domain not actually blocked');
        }
    }

    @isTest
    static void testAllowedDomainCreatesCase() {
        String testDomain = 'alloweddomain.com';

        Test.startTest();
        Messaging.InboundEmailResult res = runHandler(
            'goodguy@' + testDomain,
            'Allowed domain test',
            'This should create a case'
        );
        Test.stopTest();

        System.assertEquals(true, res.success, 'Handler should always mark success');

        List<Case> cases = [SELECT Id, Subject, Description FROM Case WHERE Subject = 'Allowed domain test'];
        System.assertEquals(1, cases.size(), 'Case should be created for allowed domain');
        System.assertEquals('Allowed domain test', cases[0].Subject);
        System.assertEquals('This should create a case', cases[0].Description);
    }
}