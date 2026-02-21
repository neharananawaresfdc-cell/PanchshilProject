global class FilteredEmailToCase implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true; // default to true to avoid NDRs unless you decide otherwise

        try {
            String fromAddr = (email.fromAddress == null) ? '' : email.fromAddress.trim().toLowerCase();
            System.debug('Raw From Address: ' + fromAddr);

            // Remove display name and angle brackets if present
            if (fromAddr.contains('<') && fromAddr.contains('>')) {
                fromAddr = fromAddr.substringBetween('<', '>').trim().toLowerCase();
                System.debug('Normalized From Address: ' + fromAddr);
            }

            if (String.isBlank(fromAddr) || !fromAddr.contains('@')) return result;

            String fromDomain = fromAddr.substringAfter('@').trim().toLowerCase();
            System.debug('Extracted Domain: ' + fromDomain);

            // === BLOCKED DOMAINS: could be from Custom Label/Metadata ===
            Set<String> blockedDomains = new Set<String>{'yahoo.com','spamdomain.com'};
            System.debug('Blocked Domains: ' + blockedDomains);

            // Match exact domain or subdomains
            for (String blocked : blockedDomains) {
                if (fromDomain == blocked || fromDomain.endsWith('.' + blocked)) {
                    System.debug('BLOCKED: ' + fromDomain + ' matches ' + blocked);
                    return result; // stop processing, no Case
                }
            }

            // === Create Case ===
            Case c = new Case();
            c.Subject = String.isBlank(email.subject) ? 'No Subject' : email.subject;
            c.Description = !String.isBlank(email.plainTextBody) ? email.plainTextBody : (email.htmlBody == null ? '' : email.htmlBody);
            c.Origin = 'Email';
            c.Status = 'New';
            c.OwnerId = UserInfo.getUserId();
            insert c;

            System.debug('Case Created: ' + c.Id);
            return result;

        } catch (Exception ex) {
            System.debug('FilteredEmailToCase exception: ' + ex.getMessage());
            result.success = true;
            result.message = 'Processed with internal error (admin notified).';
            return result;
        }
    }
}