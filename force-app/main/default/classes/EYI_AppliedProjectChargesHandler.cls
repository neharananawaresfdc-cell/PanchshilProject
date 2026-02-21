public class EYI_AppliedProjectChargesHandler {
	public static void convert(List<EYI_Applied_Project_Charge__c> newListQuote) {
        for (EYI_Applied_Project_Charge__c q : newListQuote) {
            Decimal aggVal = q.Grand_Total__c;
            if (aggVal != null) {
                Integer intPart = Integer.valueOf(aggVal.setScale(0, RoundingMode.DOWN));
                Integer decimalPart = Integer.valueOf(((aggVal - intPart) * 100).setScale(0, RoundingMode.HALF_UP));

                String words = EYI_ConverAmountToWordHandler.convertToIndianWords(intPart);

                if (decimalPart > 0) {
                    words += ' and ' + EYI_ConverAmountToWordHandler.convertToIndianWords(decimalPart) + ' Paise';
                }

                q.EYI_Grand_Total_Value_in_Words__c = words;
            } else {
                q.EYI_Grand_Total_Value_in_Words__c = null;
            }
        }
    }
}