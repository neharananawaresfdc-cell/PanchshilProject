public class EYI_Esign_VFPageController {
    
     // Constructor
    public EYI_Esign_VFPageController(ApexPages.StandardController controller) {
        EYI_REC__c acc = (EYI_REC__c)controller.getRecord();  // Get the current Account record from the standard controller
        
    }
    
    public static void esignCall(){
        system.debug('Inside E-sign call');
    }

}