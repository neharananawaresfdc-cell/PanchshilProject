public class EYI_ConverAmountToWordHandler {
    Public static String convertToIndianWords(Integer aggVal) {
            if (aggVal == 0) return 'Zero';
        
            List<String> belowTwenty = new List<String>{
                '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
                'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
            };
        
            List<String> tens = new List<String>{
                '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
            };
        
            List<String> parts = new List<String>();
        
            // Crore
            if (aggVal >= 10000000) {  
                Integer crorePart = aggVal / 10000000;
                parts.add(convertToIndianWords(crorePart) + ' crore');
                aggVal = Math.mod(aggVal, 10000000);
            }
        
            // Lakh
            if (aggVal >= 100000) {  
                Integer lakhPart = aggVal / 100000;
                parts.add(convertToIndianWords(lakhPart) + ' lakh');
                aggVal = Math.mod(aggVal, 100000);
            }
        
            // Thousand
            if (aggVal >= 1000) {  
                Integer thousandPart = aggVal / 1000;
                parts.add(convertToIndianWords(thousandPart) + ' thousand');
                aggVal = Math.mod(aggVal, 1000);
            }
        
            // For last part (less than 1000), combine hundreds + tens + units without comma inside
            if (aggVal > 0) {
                String lastPart = '';
        
                if (aggVal >= 100) {
                    Integer hundredPart = aggVal / 100;
                    lastPart += belowTwenty[hundredPart] + ' hundred ';
                    aggVal = Math.mod(aggVal, 100);
                }
        
                if (aggVal >= 20) {
                    lastPart += tens[aggVal / 10] + ' ';
                    aggVal = Math.mod(aggVal, 10);
                }
        
                if (aggVal > 0) {
                    lastPart += belowTwenty[aggVal] + ' ';
                }
        
                parts.add(lastPart.trim());
            }
        
            // Join all major parts with commas
            return String.join(parts, ', ').trim();
        } 
        
}