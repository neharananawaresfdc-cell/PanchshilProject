public class EYI_QuoteTriggerHandler {
    //class to convert amount into words
    public static void convert(List<Quote> newListQuote) {
        for (Quote q : newListQuote) {
            Decimal aggVal = q.EYI_Agreement_Value__c;
            if (aggVal != null) {
                Integer intPart = Integer.valueOf(aggVal.setScale(0, RoundingMode.DOWN));
                Integer decimalPart = Integer.valueOf(((aggVal - intPart) * 100).setScale(0, RoundingMode.HALF_UP));

                String words = EYI_ConverAmountToWordHandler.convertToIndianWords(intPart);

                if (decimalPart > 0) {
                    words += ' and ' + EYI_ConverAmountToWordHandler.convertToIndianWords(decimalPart) + ' Paise';
                }

                q.EYI_Agreement_Value_in_Words__c = words;
            } else {
                q.EYI_Agreement_Value_in_Words__c = null;
            }
        }
    }

    

    // Call this method with Number to convert
    


}