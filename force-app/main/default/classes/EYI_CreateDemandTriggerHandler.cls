public class EYI_CreateDemandTriggerHandler {
    
    public static void handleAfterUpdate(List<EYI_Booking__c> newList, Map<Id, EYI_Booking__c> oldMap){
        List<EYI_Demand__c> recordsToCreate = new List<EYI_Demand__c>();
        List<EYI_Demand__c> demandToCreateList = new List<EYI_Demand__c>();
        Set<Id> bookingIds = new Set<Id>();
        Set<Id> paymentPlanIds = new Set<Id>();
        Set<Id> approvedQuoteIds = new Set<Id>();
        Map<Id,Id> mapOfOppBookingIds = new Map<Id,Id>();
        Map<Id,Date> mapOfOppBookingDate = new Map<Id,Date>();
        
        for(EYI_Booking__c bkg : newList){
            system.debug('triggeredrec-->'+bkg.Id);
            if (oldMap.get(bkg.Id).EYI_SAP_Sales_Order_Number__c == null && bkg.EYI_SAP_Sales_Order_Number__c != null){
                bookingIds.add(bkg.Id);
            }
        }
        System.debug('bookingIds : '+bookingIds);
        
        if(!bookingIds.isEmpty()){
            List<EYI_Booking__c> bookings = [select id,EYI_Actual_Booking_Date__c, EYI_Opportunity_Name__r.SyncedQuote.Id from EYI_Booking__c where id IN:bookingIds ];
            
            for (EYI_Booking__c bkg : bookings) {
                if (bkg.EYI_Opportunity_Name__r != null &&  bkg.EYI_Opportunity_Name__r.SyncedQuote.Id != null) {
                    mapOfOppBookingIds.put(bkg.EYI_Opportunity_Name__c,bkg.Id);
                    mapOfOppBookingDate.put(bkg.Id, bkg.EYI_Actual_Booking_Date__c);
                    approvedQuoteIds.add(bkg.EYI_Opportunity_Name__r.SyncedQuote.Id);

                    system.debug('paymentPlanIds-->'+approvedQuoteIds);
                    system.debug('paymentPlanIds-->'+approvedQuoteIds.size());
                    system.debug('bookingIds-->'+mapOfOppBookingIds);
                }
            }
            System.debug('approvedQuoteIds : '+approvedQuoteIds);
            if (!approvedQuoteIds.isEmpty()) {
                System.debug('36');
                for (Payment_Plan__c pp : [SELECT Id FROM Payment_Plan__c WHERE EYI_Quote__r.Id IN :approvedQuoteIds]) {
                    paymentPlanIds.add(pp.Id);
                }
                for (EYI_Applied_Project_Charge__c otherCharge : [Select Id, Name,EYI_Quote__r.OpportunityId,EYI_Calculated_Amount__c,
                                                                  EYI_Quote__r.EYI_Inventory__r.EYI_OC_Received_Date__c,
                                                                  EYI_Quote__r.Opportunity.EYI_Relationship_Manager__c,
                                                                  EYI_Quote__r.EYI_Inventory__r.EYI_Project__r.EYI_SAP_Salesorg__c,
                                                                  EYI_Quote__r.EYI_Inventory__r.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,
                                                                  EYI_Quote__r.EYI_Inventory__r.EYI_Tower__r.EYI_RERA_Possesion_Date__c,
                                                                  EYI_Project_Charges__r.EYI_Charge_Type__c,EYI_Quote__r.EYI_Inventory__r.EYI_Project__c,
                                                                  EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Sequence_Number__c, 
                                                                  Grand_Total__c, EYI_Project_Charges__r.Name, 
                                                                  EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c 
                                                            from EYI_Applied_Project_Charge__c where EYI_Quote__c =: approvedQuoteIds And EYI_Project_Charges__r.EYI_Charge_Type__c = 'Other Charges' 
                                                                  AND EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c !=''  AND EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_Demand_Applicable__c = true] ) {
                 	        System.debug('inside for'); 
                EYI_Demand__c demand = new EYI_Demand__c();
                demand.EYI_Booking__c = mapOfOppBookingIds.get(otherCharge.EYI_Quote__r.OpportunityId);
                demand.EYI_Opportunity__c = otherCharge.EYI_Quote__r.OpportunityId;
                //demand.EYI_Activity_No__c = pay.EYI_SAP_Activity_Number__c;
                //demand.EYI_Actual_Date__c = mapOfOppBookingDate.get(demand.EYI_Booking__c);//otherCharge.EYI_Quote__r.EYI_Inventory__r.EYI_OC_Received_Date__c;
                //demand.EYI_Amount_to_be_paid__c = Decimal.valueOf(otherCharge.EYI_Calculated_Amount__c > 0 ? otherCharge.EYI_Calculated_Amount__c : otherCharge.Grand_Total__c);
                demand.EYI_Amount_to_be_paid__c = (otherCharge.EYI_Calculated_Amount__c > 0) 
                        ? otherCharge.EYI_Calculated_Amount__c 
                        : otherCharge.Grand_Total__c;
                                                                      
                demand.EYI_Billing_Date__c =mapOfOppBookingDate.get(demand.EYI_Booking__c);// otherCharge.EYI_Quote__r.EYI_Inventory__r.EYI_Tower__r.EYI_RERA_Possesion_Date__c;
                demand.EYI_Project__c = otherCharge.EYI_Quote__r.EYI_Inventory__r.EYI_Project__c;
                //demand.EYI_SAP_Milestone_Code__c = pay.EYI_SAP_Milestone_Code__c;
                demand.EYI_SAP_Plant_Code__c = otherCharge.EYI_Quote__r.EYI_Inventory__r.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c;
                demand.EYI_SAP_Sales_Org__c = otherCharge.EYI_Quote__r.EYI_Inventory__r.EYI_Project__r.EYI_SAP_Salesorg__c;
                demand.EYI_Tower__c = otherCharge.EYI_Quote__r.EYI_Inventory__r.EYI_Tower__c;
                demand.EYI_Usage__c = 'Z0112';
                demand.EYI_Usage_Description__c = otherCharge.EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c;
                //demand.EYI_WBS_Element__c = pay.EYI_WBS_Element__c;
                //demand.EYI_Payment_Schedule__c = pay.id;
                demand.EYI_Demand_Percentage__c = 100;
                demand.EYI_Demand_Type__c = 'Time Bound';
                demand.EYI_Demand_Status__c = 'Open';
                demand.EYI_IsOtherChargeDemand__c = 'Yes'; 
                demand.OwnerId = otherCharge.EYI_Quote__r.Opportunity.EYI_Relationship_Manager__c;                                                  
                demandToCreateList.add(demand);
                }
            }
            
        }
        
        if (!paymentPlanIds.isEmpty() && paymentPlanIds != null ) {
            // Query related PaymentSchedule for those bookings
            List<EYI_Payment_Schedule__c> relatedpaymentSchedule = [
                SELECT Id, EYI_Actual_Date__c, Payment_Plan__r.EYI_Quote__r.Opportunity.EYI_Booking__c,
                	Payment_Plan__r.EYI_Quote__r.Opportunity.EYI_Relationship_Manager__c,
                	Payment_Plan__r.EYI_Quote__r.OpportunityId,
                    EYI_Amount_to_be_paid__c, EYI_Billing_Date__c, EYI_Due_Amount__c, EYI_GST__c, EYI_Invoice_Percentage__c, EYI_Milestone_Type__c,
                    EYI_Milestone__c, EYI_Milestone_Number__c, EYI_Net_Payable__c, EYI_NPV_Cal__c, EYI_Payable_Amount__c, EYI_Project__c, EYI_SAP_Activity_Number__c,
                    EYI_SAP_Milestone_Code__c, EYI_SAP_Plant_Code__c, EYI_SAP_Sales_Org__c, EYI_Usage__c, EYI_Tower__c, EYI_Usage_Description__c
                FROM EYI_Payment_Schedule__c
                WHERE Payment_Plan__c IN :paymentPlanIds
            ];
            system.debug('relatedpaymentSchedule-->'+relatedpaymentSchedule);
            system.debug('relatedpaymentSchedule-->'+relatedpaymentSchedule.size());
            for(EYI_Payment_Schedule__c pay :relatedpaymentSchedule){
                EYI_Demand__c demand = new EYI_Demand__c();
                
                demand.EYI_Booking__c = mapOfOppBookingIds.get(pay.Payment_Plan__r.EYI_Quote__r.OpportunityId);
                demand.EYI_Opportunity__c = pay.Payment_Plan__r.EYI_Quote__r.OpportunityId;
                demand.EYI_Activity_No__c = pay.EYI_SAP_Activity_Number__c;
                demand.EYI_Demand_Type__c = pay.EYI_Milestone_Type__c;
                if(pay.EYI_Milestone_Type__c == 'Time Bound'){
                    demand.EYI_Actual_Date__c = pay.EYI_Billing_Date__c;
                }else{
                    demand.EYI_Actual_Date__c = pay.EYI_Actual_Date__c;
                }
                demand.EYI_Amount_to_be_paid__c = pay.EYI_Amount_to_be_paid__c;
                 demand.EYI_Billing_Date__c = pay.EYI_Billing_Date__c;
                /*if(demand.EYI_Usage__c == 'Z0112'){
                    demand.EYI_Billing_Date__c = pay.EYI_Billing_Date__c;
                }else{
                  demand.EYI_Billing_Date__c = pay.EYI_Billing_Date__c;  
                }*/
                
                demand.EYI_Project__c = pay.EYI_Project__c;
                demand.EYI_SAP_Milestone_Code__c = pay.EYI_SAP_Milestone_Code__c;
                demand.EYI_SAP_Plant_Code__c = pay.EYI_SAP_Plant_Code__c;
                demand.EYI_SAP_Sales_Org__c = pay.EYI_SAP_Sales_Org__c;
                demand.EYI_Tower__c = pay.EYI_Tower__c;
                demand.EYI_Usage__c = pay.EYI_Usage__c;
                demand.EYI_Usage_Description__c = pay.EYI_Usage_Description__c;
                //demand.EYI_WBS_Element__c = pay.EYI_WBS_Element__c;
                demand.EYI_Payment_Schedule__c = pay.id;
                demand.EYI_Demand_Percentage__c = pay.EYI_Invoice_Percentage__c;
                demand.EYI_Demand_Status__c = 'Open';
                demand.OwnerId = pay.Payment_Plan__r.EYI_Quote__r.Opportunity.EYI_Relationship_Manager__c;
                demand.EYI_GST__c = pay.EYI_GST__c;
                recordsToCreate.add(demand);
            }
        }
        if (!recordsToCreate.isEmpty()) {
            system.debug('Demand records-->'+recordsToCreate);
            insert recordsToCreate;
        }
        System.debug('demandToCreateList : '+demandToCreateList.size());
        if(!demandToCreateList.isEmpty()){
           insert demandToCreateList;
        }
    }
}