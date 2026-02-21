public class EYI_RECAccountTriggerHandler {
    public static Boolean bypassCallouts = false;
    public static void handleAfterInsert(List<EYI_REC__c> newRECAccounts) {
        for (EYI_REC__c recAcc : newRECAccounts) {
            if(recAcc.EYI_Type_Of_RERA_Registration__c == 'Individual'){
                AccountCalloutHelper.makePANValidateCallout(recAcc.Id);
            }
        }
    }
}