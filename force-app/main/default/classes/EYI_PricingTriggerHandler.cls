/* Author: Mrinal Tripathi
* Purpose: Trigger handler for EYI_Rate_List__c
* Created date: 16 February 2025
*/
public class EYI_PricingTriggerHandler {
    
    public static void handleBeforeUpdate() {
        Set<String> fieldSetFields = new Set<String>();
        Set<Id> PricingIds = new Set<Id>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('EYI_Rate_List__c');
        if (objType != null) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // Field Set API Name
            Schema.FieldSet fieldSet = objDescribe.fieldSets.getMap().get('EYI_SAP_Pricing_Field_Set');
            
            if (fieldSet != null) {
                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    fieldSetFields.add(field.getFieldPath());
                }
            }
        }

        for (EYI_Rate_List__c newRecord : (List<EYI_Rate_List__c>)Trigger.new) {
            EYI_Rate_List__c oldRecord = (EYI_Rate_List__c) Trigger.oldMap.get(newRecord.Id);
            
            Boolean hasFieldChanged = false;
            for (String fieldName : fieldSetFields) {
                if (oldRecord.get(fieldName) != newRecord.get(fieldName)) {
                    hasFieldChanged = true;
                    newRecord.EYI_is_Sync_SAP__c = false;
                    break;
                }
            }

            if (hasFieldChanged) {
                PricingIds.add(newRecord.Id);
            }
        }
        
        if (!PricingIds.isEmpty()) {
            if (PricingIds.size() == 1) {
                EYI_FutureCalloutClass.pricingDataSync(PricingIds);
            }
        }
    }

    public static void convert(List<EYI_Rate_List__c> newListQuote) {
        if (newListQuote == null || newListQuote.isEmpty()) return;

        for (EYI_Rate_List__c q : newListQuote) {
            Decimal aggVal = q.Amount__c;
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

        // ❗ Add this to ensure the values are committed to DB
        try {
            update newListQuote;
        } catch (DmlException e) {
            System.debug('DML error in convert(): ' + e.getMessage());
        }
    }
}