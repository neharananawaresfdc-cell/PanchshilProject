public class EYI_SAP_OutstandingBatchcheck {
      public static String padLeft(String original, Integer length, String padChar) {
        Integer padLength = length - original.length();
        return (padLength > 0) ? String.valueOf(padChar).repeat(padLength) + original : original;
    }
    public static void processApiResponse(String responseBody) {
        Map<String, Object> responseMap1 = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.debug('responseMap1 -> '+responseMap1);
        Map<String, Decimal> custToOutstanding = new Map<String, Decimal>();
        Set<String> custNumsPadded = new Set<String>();
        for(String key :responseMap1.keySet()){
            Map<String, Object> responseMap2 = (Map<String, Object>) responseMap1.get(key);
            System.debug('responseMap2 -> '+responseMap2);
            Map<String, Object> exOutput = (Map<String, Object>) responseMap2.get('EX_OUTPUT');
            System.debug('exOutput -> '+exOutput);
            if (exOutput == null) {
                return;
            }
            
            List<Object> items = (List<Object>) exOutput.get('item');
            if (items == null || items.isEmpty()) return;
            
            
            
            for (Object obj : items) {
                Map<String, Object> row = (Map<String, Object>) obj;
                String custNo = (String) row.get('KUNNR');
                Decimal outAmt = Decimal.valueof(string.valueof(row.get('OUTSTAND_AMT')));
                if (!String.isBlank(custNo) && outAmt != null) {
                    String paddedCustNo = padLeft(custNo, 10, '0');
                    if(custToOutstanding.containskey(paddedCustNo)){
                        custToOutstanding.put(paddedCustNo,custToOutstanding.get(paddedCustNo)+outAmt);
                    }else {
                        custToOutstanding.put(paddedCustNo,outAmt);
                    }
                    custNumsPadded.add(paddedCustNo);
                }
            }
        }
        
        system.debug('custToOutstanding' + custToOutstanding);
        List<Opportunity> oppsToUpdate = [
            SELECT Id, EYI_SAP_Customer_Number__c, EYI_Outstanding_Amount__c
            FROM Opportunity
            WHERE EYI_SAP_Customer_Number__c IN :custNumsPadded
        ];
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for (Opportunity opp : oppsToUpdate) {
            
            String custNum = padLeft(String.valueOf(opp.EYI_SAP_Customer_Number__c), 10, '0');
            if (custToOutstanding.containsKey(custNum)) {
                opp.EYI_Outstanding_Amount__c = custToOutstanding.get(custNum);
                oppToUpdate.add(opp);
            }
        }
        
        if (!oppToUpdate.isEmpty()) {
            update oppToUpdate;
        }
    }
}