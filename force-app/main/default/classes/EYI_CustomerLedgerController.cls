public class EYI_CustomerLedgerController {
	@AuraEnabled
    public static String fetchCustomerLedger(String customerNumber, String companyCode){
        if (String.isBlank(customerNumber)) {
            throw new AuraHandledException('Customer Number is required.');
        }
		List<Map<String, Object>> responseList = new List<Map<String, Object>>();

        Map<String, String> payload = new Map<String, String>{
            'customerNumber' => customerNumber,
            'companyCode' => companyCode
        };

        String reqBody = JSON.serialize(payload);
		HTTPResponse res = EY_SAP_Gateway.customerLedger(reqBody);
       // HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            //EYI_AbstractHttpServiceConsumer.Logger log = new EYI_AbstractHttpServiceConsumer.Logger();
            //log.addEntry(req, res, DateTime.now());
            //System.enqueueJob(log);
            return res.getBody(); // assuming it's a JSON string
        } else { 
            //EYI_AbstractHttpServiceConsumer.Logger log = new EYI_AbstractHttpServiceConsumer.Logger();
            //log.addEntry(req, res, DateTime.now());
           // System.enqueueJob(log);
            return res.getBody();
        }
    }
    
}