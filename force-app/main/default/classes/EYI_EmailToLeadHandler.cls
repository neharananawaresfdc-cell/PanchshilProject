global class EYI_EmailToLeadHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        Lead newLead = new Lead();
        newLead.LastName = email.fromName;
        newLead.Company = 'NA';
        newLead.Email = email.fromAddress;
        newLead.Description = email.plainTextBody;
        newLead.LeadSource = 'Email';
        
        Database.insert(newLead);
        
        result.success = true;
        return result;
    }
}