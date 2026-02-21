/**
* @Name: EYI_SAPBookingsSyncLwcController
* @Description: This class calls SAP sync api to sync booking records with SAP.
* @Author: Mrinal Tripathi
* @Creation Date: 21-Feb-2025
* @Creation Date:21-Feb-2025
* @Version: 1
* @Usage: This class should not be instantiated directly. It is called by the EYI_BookingsSAPSync LWC.
* @Example: 
* @See: EYI_SAPBookingsSyncLwcController
* @Related: EYI_BookingsSAPSync
* @Notes: 
**/
public class EYI_SAPBookingsSyncLwcController {

    public static Id invId;
    public static Id oppId;
    public static Id quoteId;
    public static Id paymentPlanId;

    @AuraEnabled
    public static lwcMessage BookingsSync(Id recordId) {
        lwcMessage lm = new lwcMessage();
        Map<Id, List<EYI_Rate_List__c>> mapOfInvAndPrice = new Map<Id, List<EYI_Rate_List__c>>();
        Map<String, EYI_Applied_Project_Charge__c> mapOfMatAndPrice = new Map<String, EYI_Applied_Project_Charge__c>();
        //cust number from oppty, remove division, oppty auto number field, salesforce group from oppty regional manager, cancellation reason remove, pdf logic ()
        EYI_Booking__c bookingData = [SELECT Id, EYI_SAP_Sales_Order_Number__c, EYI_Opportunity_Name__c,EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Vendor_Code__c, EYI_Opportunity_Name__r.EYI_REC__c, EYI_Opportunity_Name__r.EYI_Walk_in_Source__c, EYI_Opportunity_Name__r.EYI_Inventory__c, EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c,
                                      EYI_Project_Name__r.EYI_SAP_Salesorg__c, EYI_Project_Name__r.EYI_SAP_Plant_Code__c, EYI_Opportunity_Name__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Project_Name__r.EYI_Distribution_Channel__c, 
                                      EYI_Divisions__c, EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Office__c, EYI_Opportunity_Name__r.EYI_Opportunity_Number__c, EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Group__c, 
                                      EYI_Actual_Booking_Date__c, EYI_Cancellation_Reason__c, EYI_Opportunity_Name__r.Name, EYI_Agreement_Execution_Date__c, EYI_Agreement_Handover_Date__c, 
                                      EYI_Agreement_Received_Date__c, EYI_Aggrement_Reg_No__c, EYI_Sales_Deed_No__c, EYI_Registration_Date__c, EYI_Possession_Intimation_Date__c, EYI_Agreement_Possession_Date__c, 
                                      EYI_Actual_Possession_Date__c, EYI_Maintenance_wef_Date__c, Transfer_Swapping_Date__c, EYI_Transfer_Swapping_Remarks__c, EYI_Mortgage_Status__c, EYI_Loaning_Institute__c, 
                                      EYI_Loan_Amount__c, EYI_Loan_File_Number__c, EYI_Agreement_Loan_Percentage__c, EYI_Sanction_Date__c, EYI_NOC_Issue_Date__c, EYI_Cancellation_Date__c, 
                                      EYI_Cancellation_initiated_By__c, EYI_Deed_of_Cancellation_Reg_Date__c, EYI_Name_1__c, EYI_Tab_D_Rate_of_Intrest__c, EYI_Self_Banking_for_VA01__c, EYI_Opportunity_Name__r.SyncedQuote.Payment_Plan__c,
                                      EYI_Banking_Remarks_for_VA01__c,EYI_Source_of_Booking__c,EYI_REC_Account__r.EYI_REC_Vendor_Code__c ,EYI_SAP_request__c,EYI_Opportunity_Name__r.EYI_Segment__c       FROM EYI_Booking__c WHERE Id = :recordId];
        
        EYI_BookingDataWrapper data = new EYI_BookingDataWrapper();
        
        if(bookingData.EYI_Opportunity_Name__c != null){
            oppId = bookingData.EYI_Opportunity_Name__c;
            invId = bookingData.EYI_Opportunity_Name__r.EYI_Inventory__c;
            quoteId = bookingData.EYI_Opportunity_Name__r.SyncedQuoteId;
        }
        Quote currQuote = [Select Id,Name,EYI_Base_Rate_Discount_L__c,EYI_Agreement_Value__c,EYI_Floor_Rate_Discount_L__c FROM Quote WHERE Id =:quoteId LIMIT 1];
        //Get Payment Plan
        Payment_Plan__c paymentPlan = [Select Id, Name From Payment_Plan__c Where EYI_Quote__c = : quoteId Limit 1];
        if(bookingData.EYI_SAP_Sales_Order_Number__c != null){
            system.debug('bookingData.EYI_SAP_Sales_Order_Number__c --> '+bookingData.EYI_SAP_Sales_Order_Number__c);
            data.BookingData.SalesOrderNo = bookingData.EYI_SAP_Sales_Order_Number__c;
        }
        if(bookingData.EYI_Actual_Booking_Date__c != null){
            data.BookingData.BookingDate = String.join(new List<String>{
                (bookingData.EYI_Actual_Booking_Date__c.day() < 10 ? '0' : '') + bookingData.EYI_Actual_Booking_Date__c.day(), 
                    (bookingData.EYI_Actual_Booking_Date__c.month() < 10 ? '0' : '') + bookingData.EYI_Actual_Booking_Date__c.month(), 
                    String.valueOf(bookingData.EYI_Actual_Booking_Date__c.year())}, '.') ;
            
        }
        else{
            data.BookingData.BookingDate = null;
        }
        data.BookingData.ActualBookingDate = data.BookingData.BookingDate;
        //data.BookingData.Division = getSF_FieldMapping('EYI_Divisions__c',bookingData.EYI_Divisions__c);
        data.BookingData.Division = '00';
        data.BookingData.PlantCode = bookingData.EYI_Opportunity_Name__r.EYI_Project_Tower_Enquired__r.EYI_SAP_Plant_ID__c;
        data.BookingData.CancellationReason = bookingData.EYI_Cancellation_Reason__c;
        data.BookingData.OpportunityNumber = bookingData.EYI_Opportunity_Name__r.EYI_Opportunity_number__c;
        data.BookingData.SalesOrg = bookingData.EYI_Project_Name__r.EYI_SAP_Salesorg__c;
        if(bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Office__c == 'Pune Office'){
           data.BookingData.SalesOffice = '1001' ;
        }else if(bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Office__c == 'Mumbai Office'){
           data.BookingData.SalesOffice = '1000' ;
        }else if(bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Office__c == 'WTC Office'){
           data.BookingData.SalesOffice = '1002' ;
        }
       // data.BookingData.SalesOffice = bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Office__c;
        //data.BookingData.SalesGroup = bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Group__c;
        if(bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Group__c == 'Pune Sales Group'){
           data.BookingData.SalesGroup = '101' ;
        }else if(bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Group__c == 'Mumbai Sales Group'){
           data.BookingData.SalesGroup = '100' ;
        }else if(bookingData.EYI_Opportunity_Name__r.EYI_Relationship_Manager__r.EYI_Sales_Group__c == 'Delhi Sales Group'){
           data.BookingData.SalesGroup = '102' ;
        }
        data.BookingData.CustomerNo = bookingData.EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c;
        //data.BookingData.OpportunityNumber = bookingData.EYI_Opportunity_Name__r.EYI_Opportunity_Number__c;
        //data.BookingData.OpportunityNumber = 'OP001';
        Map<String, String> sfmapSAP = new Map<String, String>();
        
        List<SAP_SF_Field_Map__c> mapData = [select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c from SAP_SF_Field_Map__c ];
        if(!mapData.isEmpty()){
            for(SAP_SF_Field_Map__c mp :mapData){
                sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                //system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
            } 
        }
        if(sfmapSAP.containsKey('EYI_Distribution_Channel__c'+'~'+bookingData.EYI_Opportunity_Name__r.EYI_Segment__c)) {
            data.BookingData.DistChannel = sfmapSAP.get('EYI_Distribution_Channel__c'+'~'+bookingData.EYI_Opportunity_Name__r.EYI_Segment__c);
        }
        
        data.BookingData.WarrantyDate = '';
        //merge carpark and inventory in a single list
        mapOfInvAndPrice = getRelatedInventoryAndPricing(invId);
        //mapOfMatAndPrice = getOtherChargesMaterialAndPricing(quoteId);
        List<EYI_Car_Park_Master__c> carparkList = getCarParkMasterList(invId);
        
        List<EYI_Payment_Schedule__c> paymentScheduleList = getPaymentScheduleList( paymentPlan.Id);   
        Integer counter = 10;
        Integer innerCounter = 10;

        // Sync Flat Inventory and Pricings 
        for (EYI_Inventory__c inventory : [Select Id, EYI_Saleable_Area__c, EYI_Inventory_Number__c, EYI_UOM__c from EYI_Inventory__c where Id IN : mapOfInvAndPrice.keySet()] ) {
            EYI_BookingDataWrapper.MaterialDetail material = new EYI_BookingDataWrapper.MaterialDetail();
            material.ItemNumberSD = String.valueOf(counter);
            
            if(inventory.EYI_UOM__c!= null){
                if(sfmapSAP.containsKey('EYI_UOM__c'+'~'+inventory.EYI_UOM__c)) {
                    material.UnitOfMeasure =sfmapSAP.get('EYI_UOM__c'+'~'+inventory.EYI_UOM__c);// '1';//test
                }
            }
            material.MaterialNumber = inventory.EYI_Inventory_Number__c;
            material.Quantity = inventory.EYI_Saleable_Area__c;
            data.BOOKINGDATA.MaterialDetails.add(material);         
            for(EYI_Rate_List__c rateRec: mapOfInvAndPrice.get(inventory.Id)){

                EYI_BookingDataWrapper.Condition con = new EYI_BookingDataWrapper.Condition();
                con.ConditionItemNumber = String.valueOf(counter);
                if(rateRec.EYI_Condition_Type__c !=null && sfmapSAP.containsKey('EYI_Condition_Type__c'+'~'+rateRec.EYI_Condition_Type__c)){ 
                        con.ConditionType = sfmapSAP.get('EYI_Condition_Type__c'+'~'+rateRec.EYI_Condition_Type__c);
                        if(rateRec.EYI_Condition_Type__c == 'Base Price' && rateRec.EYI_Amount__c != null){
                            Decimal baseAmount = rateRec.EYI_Amount__c != null ? rateRec.EYI_Amount__c : 0;
                            Decimal discount = currQuote.EYI_Base_Rate_Discount_L__c != null ? currQuote.EYI_Base_Rate_Discount_L__c : 0;
                            Decimal finalAmount = (baseAmount - discount).setScale(2, RoundingMode.HALF_UP);
                            con.ConditionAmount = String.valueOf(finalAmount);

                            //con.ConditionAmount = String.valueOf(rateRec.EYI_Amount__c - (currQuote.EYI_Base_Rate_Discount_L__c != null? currQuote.EYI_Base_Rate_Discount_L__c : 0));
                        }
                        else if(rateRec.EYI_Condition_Type__c == 'Floor Rise' && rateRec.Amount__c != null){
                            System.debug(currQuote.EYI_Floor_Rate_Discount_L__c != null? currQuote.EYI_Floor_Rate_Discount_L__c : 0);
                            System.debug('F R..... '+ rateRec.EYI_Amount__c);
                            con.ConditionAmount = String.valueOf(rateRec.EYI_Amount__c - (currQuote.EYI_Floor_Rate_Discount_L__c != null? currQuote.EYI_Floor_Rate_Discount_L__c : 0));
                        }
                         else {
                            con.ConditionAmount = String.valueOf(rateRec.EYI_Amount__c);
                        }
                }
                //innerCounter += 10;
                data.BOOKINGDATA.Conditions.add(con);
            }  
            counter +=10;
        }
        //List<String> chargeList = new List<String>();
        List<String> chargeList = new List<String>{'Basic','Registration Charges'};
        // Sync Other Charge Material and Pricings
        for (EYI_Applied_Project_Charge__c otherCharge : [Select Id, Name, EYI_SAP_Final_Amount__c, EYI_Project_Charges__r.EYI_Charge_Type__c, EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Sequence_Number__c, EYI_Calculated_Amount__c, Grand_Total__c, EYI_Project_Charges__r.Name, EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c 
                                                            from EYI_Applied_Project_Charge__c where EYI_Quote__c =: quoteId And EYI_Project_Charges__r.EYI_Charge_Type__c = 'Other Charges' 
                                                                AND EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c !='' ORDER BY EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c  ] ) {

                        EYI_BookingDataWrapper.MaterialDetail material = new EYI_BookingDataWrapper.MaterialDetail();
            //matCounter = 10;
            Integer chargeCounter = 10;
            if(otherCharge.Grand_Total__c != 0){

                //material.ItemNumberSD = String.valueOf(otherCharge.EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Sequence_Number__c);
                material.ItemNumberSD = String.valueOf(counter);
                material.UnitOfMeasure = 'EA';
                /*
                if(inventory.EYI_UOM__c!= null){
                    if(sfmapSAP.containsKey('EYI_UOM__c'+'~'+inventory.EYI_UOM__c)) {
                        material.UnitOfMeasure =sfmapSAP.get('EYI_UOM__c'+'~'+inventory.EYI_UOM__c);// '1';//test
                    }
                }*/
                material.MaterialNumber = otherCharge.EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Material_Name__c;
                material.Quantity = 1;
                data.BOOKINGDATA.MaterialDetails.add(material);         
                EYI_BookingDataWrapper.Condition con = new EYI_BookingDataWrapper.Condition();
                //con.ConditionItemNumber = String.valueOf(otherCharge.EYI_Project_Charges__r.EYI_Global_Charges__r.EYI_SAP_Sequence_Number__c);
                con.ConditionItemNumber = String.valueOf(counter);
                counter +=10;
                con.ConditionType = 'ZBP0' ;
                //if(EYI_Calculated_Amount__c > 0 --> EYI_Calculated_Amount__c else Grand_Total__c )
                //con.ConditionAmount = String.valueOf(otherCharge.Grand_Total__c);
                con.ConditionAmount = String.valueOf(otherCharge.EYI_Calculated_Amount__c > 0 ? otherCharge.EYI_Calculated_Amount__c : otherCharge.Grand_Total__c);

                //innerCounter += 10;
                data.BOOKINGDATA.Conditions.add(con);           
            }                              
        }
        // Sync Car Parks
        for(EYI_Car_Park_Master__c carPark :carparkList){
            EYI_BookingDataWrapper.MaterialDetail material = new EYI_BookingDataWrapper.MaterialDetail();
            material.ItemNumberSD = String.valueOf(counter);
            counter +=10;
            if(sfmapSAP.containsKey('EYI_UOM__c'+'~'+carPark.EYI_Base_UOM__c)) {
                material.UnitOfMeasure =sfmapSAP.get('EYI_UOM__c'+'~'+carPark.EYI_Base_UOM__c);// '1';//test
            }
            material.MaterialNumber = carPark.EYI_Parking_Number__c ;
            material.Quantity = 0;
            data.BOOKINGDATA.MaterialDetails.add(material);
        }

        // Not Needed
        /*
        List<EYI_Rate_List__c> rateList = getPriceList(recordId);
        counter = 10;
        for(EYI_Rate_List__c rateRec: rateList){
            EYI_BookingDataWrapper.Condition con = new EYI_BookingDataWrapper.Condition();
            con.ConditionItemNumber = String.valueOf(counter);
            if(rateRec.EYI_Condition_Type__c !=null && sfmapSAP.containsKey('EYI_Condition_Type__c'+'~'+rateRec.EYI_Condition_Type__c)) 
                    con.ConditionType = sfmapSAP.get('EYI_Condition_Type__c'+'~'+rateRec.EYI_Condition_Type__c);
            
            if(rateRec.EYI_Condition_Type__c == 'Percentage'){
                con.ConditionAmount = String.valueOf(rateRec.EYI_Pricing_Percentage__c);
            }
            else if(rateRec.EYI_Condition_Type__c == 'Fixed Amount'){
                con.ConditionAmount = String.valueOf(rateRec.EYI_Pricing_Amount__c);
            }
            else{
                con.ConditionAmount = String.valueOf(rateRec.EYI_Pricing_Quantity__c);
            }
            counter += 10;
            data.BOOKINGDATA.Conditions.add(con);
        }*/
        for(EYI_Payment_Schedule__c paymentSchedule : paymentScheduleList){
            EYI_BookingDataWrapper.PaymentPlan payplan = new EYI_BookingDataWrapper.PaymentPlan();
            system.debug('String.valueOf(paymentSchedule.EYI_Net_Payable__c) -->'+ paymentSchedule.EYI_Net_Payable__c);
            system.debug('String.valueOf(paymentSchedule.EYI_Net_Payable__c) -->'+ String.valueOf(paymentSchedule.EYI_Net_Payable__c));
            payplan.Usage = paymentSchedule.EYI_Usage__c;
            payPlan.PercentageToBeInvoiced = String.valueOf(paymentSchedule.EYI_Invoice_Percentage__c);
            payPlan.UsageDescription = paymentSchedule.EYI_Usage_Description__c;
            payPlan.BillingDate = String.join(new List<String>{
                (paymentSchedule.EYI_Billing_Date__c.day() < 10 ? '0' : '') + paymentSchedule.EYI_Billing_Date__c.day(), 
                    (paymentSchedule.EYI_Billing_Date__c.month() < 10 ? '0' : '') + paymentSchedule.EYI_Billing_Date__c.month(), 
                    String.valueOf(paymentSchedule.EYI_Billing_Date__c.year())}, '.');
            payPlan.ValueToBeCalculatedOnDate = String.valueOf(paymentSchedule.EYI_Amount_to_be_paid__c); // Removed EYI_Net_Payable__c as per kumar suggestion
            payPlan.MilestoneNumber = String.valueOf(paymentSchedule.EYI_Milestone_Number__c);
            payPlan.CurrencyKey = 'INR';
            data.BOOKINGDATA.PaymentPlan.add(payPlan);
        } 
        //Partner function child json
        
        if(bookingData.EYI_Opportunity_Name__r.EYI_Walk_in_Source__c == 'PREC'){
            EYI_BookingDataWrapper.PartnerFunction partnerFunction = new EYI_BookingDataWrapper.PartnerFunction();
            partnerFunction.PartnerFunction = getSF_FieldMapping('EYI_Source_of_Booking__c',bookingData.EYI_Opportunity_Name__r.EYI_Walk_in_Source__c);
            if( bookingData.EYI_Opportunity_Name__r.EYI_REC__c != null){
                partnerFunction.CustomerNumber = bookingData.EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Vendor_Code__c;
            }
            data.BookingData.partnerFunction.add(partnerFunction);
        }
        else{
            //partnerFunction.PartnerFunction = '';
            //partnerFunction.CustomerNumber = '';
            //partnerFunction = ;
        }
        
        //partnerFunction.CustomerNumber = bookingData.EYI_REC_Account__r.EYI_REC_Vendor_Code__c;
        
        //partnerFunction.CustomerNumber = '0006000273';
        
        
        
        data.BookingData.pdf = getContentVersionPdf(recordId);
        
        //Additional field data
        data.BookingData.Additional.AgrmentExecutionDate = String.valueOf(bookingData.EYI_Agreement_Execution_Date__c);
        
        
        data.BookingData.Additional.AgrmentHandoverDate = String.valueOf(bookingData.EYI_Agreement_Handover_Date__c);
        data.BookingData.Additional.AgrmentRecievedDate = String.valueOf(bookingData.EYI_Agreement_received_date__c);
        data.BookingData.Additional.AgrmentRegNo = String.valueOf(bookingData.EYI_Aggrement_Reg_no__c);
        data.BookingData.Additional.SalesDeedNo = String.valueOf(bookingData.EYI_Sales_Deed_No__c);
        data.BookingData.Additional.RegistrationDate = String.valueOf(bookingData.EYI_Registration_Date__c);
        data.BookingData.Additional.PossesionIntiDate = String.valueOf(bookingData.EYI_Possession_Intimation_Date__c);
        data.BookingData.Additional.RERAPossesionDate = String.valueOf(bookingData.EYI_Agreement_Possession_Date__c);
        data.BookingData.Additional.ActualPossesionDate = String.valueOf(bookingData.EYI_Actual_Possession_Date__c);
        data.BookingData.Additional.MaintenanceDate = String.valueOf(bookingData.EYI_Maintenance_wef_Date__c);
        data.BookingData.Additional.TransferDate = String.valueOf(bookingData.Transfer_Swapping_Date__c);
        data.BookingData.Additional.TransferRemarks = String.valueOf(bookingData.EYI_Transfer_Swapping_Remarks__c);
        data.BookingData.Additional.MortgageStatus = String.valueOf(bookingData.EYI_Mortgage_Status__c);
        data.BookingData.Additional.LoaningInstitue = String.valueOf(bookingData.EYI_Loaning_Institute__c);
        data.BookingData.Additional.LoanAmount = String.valueOf(bookingData.EYI_Loan_Amount__c);
        data.BookingData.Additional.LoanFileNo = String.valueOf(bookingData.EYI_Loan_File_number__c);
        data.BookingData.Additional.LoanPercentage = String.valueOf(bookingData.EYI_Agreement_loan_percentage__c);
        data.BookingData.Additional.SanctionDate = String.valueOf(bookingData.EYI_Sanction_date__c);
        data.BookingData.Additional.NOCIssueDate = String.valueOf(bookingData.EYI_NOC_Issue_Date__c);
        data.BookingData.Additional.CancellationDate = String.valueOf(bookingData.EYI_Cancellation_Date__c);
        data.BookingData.Additional.CancellationInitiatedBy = String.valueOf(bookingData.EYI_Cancellation_initiated_By__c);
        data.BookingData.Additional.DeedOfCancellationRegDate = String.valueOf(bookingData.EYI_Deed_of_Cancellation_Reg_Date__c);
        data.BookingData.Additional.Name1 = String.valueOf(bookingData.EYI_Name_1__c);
        data.BookingData.Additional.RateOfIntrstForTabD = String.valueOf(bookingData.EYI_Tab_D_Rate_of_Intrest__c);
        data.BookingData.Additional.SelfBankingForVA01 = String.valueOf(bookingData.EYI_Self_banking_for_VA01__c);
        data.BookingData.Additional.BankingRemarksForVA01 = String.valueOf(bookingData.EYI_Banking_Remarks_for_VA01__c);
        data.BookingData.Additional.LoanBranchForVA01 = String.valueOf('');
        data.BookingData.Additional.Reference1 = String.valueOf('');
        data.BookingData.Additional.Reference2 = String.valueOf('');
        data.BookingData.Additional.SalesDetails = String.valueOf('');
        data.BookingData.Additional.MsebConsumerNo = String.valueOf('');
        data.BookingData.Additional.PipeGasConsumerNo = String.valueOf('');
        data.BookingData.Additional.PropertyTaxNo = String.valueOf('');
        data.BookingData.Additional.FrankingDate = String.valueOf('');
        data.BookingData.Additional.StampDutyAmount = String.valueOf('');
        data.BookingData.Additional.ParkingIssueLetter = String.valueOf('');
        data.BookingData.Additional.ResaleNOC = String.valueOf('');
        data.BookingData.Additional.ROCDate = String.valueOf('');
        data.BookingData.Additional.PrevBankNOCDate = String.valueOf('');
        data.BookingData.Additional.PaymentProject = String.valueOf('');
        System.debug('conditions :::'+data.BookingData.Conditions);
        System.debug('materials :::'+data.BookingData.MaterialDetails);
        System.debug('payment plan:::'+data.BookingData.PaymentPlan);
        System.debug('payment plan size:::'+data.BookingData.PaymentPlan.size());
        
        String jsonBody =JSON.serialize(data);
        system.debug('Genrate jsonBody --> '+ jsonBody);
        //bookingData.EYI_SAP_request__c = jsonBody.substring(0, 131070);
        
        Integer chunkSize = 200; // Keep buffer within limits
        Integer jsonLength = jsonBody.length();
        for (Integer i = 0; i < jsonLength; i += chunkSize) {
            Integer endIndex = i + chunkSize;
            if (endIndex > jsonLength) {
                endIndex = jsonLength; // Ensure we don't go out of bounds
            }
            System.debug(jsonBody.substring(i, endIndex));
        }
        //update bookingData;
        HttpRequest req = new HttpRequest();
        req.setBody(jsonBody);
        //system.debug('isPATCHOperation-->'+isPATCHOperation);
        //if(isPATCHOperation == true) req.setMethod('PATCH'); 
        req.setMethod('POST'); 
        req.setTimeout(120000);
        req.setEndpoint('callout:Booking_Sync');
        Http http = new Http();
        HttpResponse res;
        
        
        // Send the HTTP request and get the response
        res = http.send(req);
        System.debug('res::'+res.getStatusCode());
        System.debug('res body::'+res.getBody());
        
        // Check the response status code
        if(res.getStatusCode() == 200) {
            try{
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                // Extract the "n0:ZSD_CREATE_UNITS_FROM_SFResponse" field from the map
                Map<String, Object> paymentReceiptResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_SO_FROM_SFResponse');
                // Extract the message from CarparkingResponse map.
                system.debug('Success jsonBody-->: '+res.getBody());
                Map<String, Object> exReturn = (Map<String, Object>) paymentReceiptResponse.get('EX_RETURN');
                system.debug('exReturn  '+exReturn);
                String soNumber = String.valueOf((paymentReceiptResponse.get('EX_SALESDOCUMENT')));
                System.debug('soNumber-->: ' + soNumber);
                Object typeJson =  exReturn.get('TYPE');
                System.debug('type json::'+typeJson);
                Object message = exReturn.get('MESSAGE');
                System.debug('message::'+message);
                if(typeJson != null ){
                    if(String.valueOf(typeJson).toLowerCase() == 's'){
                        bookingData.EYI_Is_Syc__c = true;
                        bookingData.EYI_SAP_Sales_Order_Number__c = soNumber;
                        bookingData.EYI_Opportunity_Name__r.EYI_SalesOrder_Number__c= soNumber;
                        bookingData.EYI_SAP_Error__c = null;
                        lm.type = String.valueOf(typeJson);
                        lm.message = soNumber + ' Sales Order Created Successfully.';
                        update bookingData;
                        EYI_CustomerMasterSyncLwcController.customerMasterSync(oppId,'');
                    }
                    else{
                        
                        lm.type = 'e';
                        lm.message = message!= null ? String.valueOf(message) : 'Internal server error';
                        bookingData.EYI_SAP_Error__c = lm.message;
                        update bookingData;
                    }
                }
                else{
                    Object item =  exReturn.get('item');
                    
                    // Now you can access individual fields within the "item" map
                    string successtype='';
                    String type = '';
                    String messagDisp = '';
                    if (item instanceof List<Object>) {
                        List<Object> itemList = (List<Object>) item;
                        
                        for (Object obj : itemList) { 
                            
                            Map<String, Object> objitem = (Map<String, Object>) obj;
                            //type = type +'-'+ (String) objitem.get('TYPE');
                            successtype = successtype +'-'+ (String) objitem.get('TYPE');
                            string types =(String) objitem.get('TYPE');
                            //system.debug('Updating type '+type);
                            // if (!type.contains('S')) {
                            if(types!='S'){
                                type =(String) objitem.get('TYPE');
                                system.debug('Updating type  inside S loop '+types);
                                messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                            }
                        }
                        system.debug('messagDisp  240==== '+messagDisp);
                    }else if(item instanceof Map<String, Object>){
                        SYSTEM.DEBUG('item   '+item);
                        Map<String, Object> objitem = (Map<String, Object>) item;
                        SYSTEM.DEBUG('objitem   '+objitem);
                        type =  (String) objitem.get('TYPE');
                        successtype = (String) objitem.get('TYPE');
                        if(type!='S'){
                            type =(String) objitem.get('TYPE');
                            system.debug('Updating type  inside S loop '+type);
                            messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                        }
                        // messagDisp =(String) objitem.get('MESSAGE');
                    }
                    system.debug('messageDisp inside loop '+messagDisp);
                    if(messagDisp!=null && type!=null ){
                        bookingData.EYI_SAP_Error__c = messagDisp;
                        update bookingData;
                        system.debug('Updating error on booking data');
                        
                    }
                    String cleanedType = successtype.replaceAll('-', '');
                    
                    // Check if the cleaned string contains only 'S'
                    if (cleanedType != '' && cleanedType.replaceAll('S', '') == '') {
                        bookingData.EYI_Is_Syc__c = true;  
                        Type ='S';
                        messagDisp = 'Booking Synced to SAP Successfully.';
                        update bookingData;
                    }
                    
                    SYSTEM.DEBUG('type  ==>>  '+type);
                    SYSTEM.DEBUG('messagDisp   '+messagDisp);
                    lm.type =  type;
                    lm.message = messagDisp;
                    SYSTEM.DEBUG('lm   '+lm);
                    return lm;
                }
            }
            
            catch(Exception e){ lm.type =  'E';lm.message = 'Internal Server Error!';return lm;
            }
        }
        else{
            lm.type =  'E';
            lm.message = 'Internal Server Error!';
        }
        return lm;
    }
    private static string getContentVersionPdf(Id recordId){
        String pdf = '';
        try{
            List<ContentDocumentLink> cd =  [ SELECT ContentDocumentId,  ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
                                             FROM ContentDocumentLink WHERE LinkedEntityId = :recordId and ContentDocument.Title ='REC_Merged_PDF.pdf' order by ContentDocument.createddate desc limit 1];
            if(!cd.isEmpty()){
                string ContentDocumentId = cd[0].ContentDocumentId;
                List<ContentVersion> cv = [select Id, Title, VersionData, FileExtension , ContentDocumentId from ContentVersion where ContentDocumentId=:ContentDocumentId limit 1];
                
                pdf= EncodingUtil.base64Encode(cv[0].VersionData);
            }
        }
        catch(Exception e){
            System.debug('exception-->'+e);
        }
        
        return pdf;
    }
    private static Map<Id, List<EYI_Rate_List__c>> getRelatedInventoryAndPricing(Id invId){
        Map<Id, List<EYI_Rate_List__c>> mapOfInvAndPrice = new Map<Id, List<EYI_Rate_List__c>>();
        List<EYI_Rate_List__c> rateList = new List<EYI_Rate_List__c>();
        try{
            //EYI_Inventory__c invObj = [Select Id,Name, EYI_Inventory_Number__c, EYI_UOM__c  from EYI_Inventory__c where Id = :invId];
            for(EYI_Rate_List__c rateRec:[Select Id,EYI_Pricing_Percentage__c,EYI_Condition_Type__c,Amount__c,EYI_Amount__c,EYI_Pricing_Quantity__c 
                                            from EYI_Rate_List__c where EYI_Inventory__c =: invId]){
                rateList.add(rateRec); 

            }
            mapOfInvAndPrice.put(invId,rateList);  
            system.debug('mapOfMatAndPrice-->'+mapOfInvAndPrice); 
        }
        catch(Exception e){
            System.debug('Exception---->'+e);
        }
        return mapOfInvAndPrice;
        //return invObj;
    }
    // not using......
    /*
    private static Map<String, EYI_Applied_Project_Charge__c> getOtherChargesMaterialAndPricing(Id quoteId){
        Map<String, EYI_Applied_Project_Charge__c> mapOfMatAndPrice = new Map<String, EYI_Applied_Project_Charge__c>();
        List<EYI_Applied_Project_Charge__c> otherChargeList = new List<EYI_Applied_Project_Charge__c>();
        try{
            //EYI_Inventory__c invObj = [Select Id,Name, EYI_Inventory_Number__c, EYI_UOM__c  from EYI_Inventory__c where Id = :invId];
            for(EYI_Applied_Project_Charge__c otherCharge:[Select Id, Name, EYI_SAP_Final_Amount__c, EYI_Project_Charges__r.Name, EYI_Project_Charges__r.EYI_Global_Charges__r.Name
                                            from EYI_Applied_Project_Charge__c where EYI_Quote__c =: quoteId]){
                //otherChargeList.add(otherCharge); 
                mapOfMatAndPrice.put(otherCharge.EYI_Project_Charges__r.EYI_Global_Charges__r.Name,otherCharge);  
            }
            //mapOfMatAndPrice.put(invId,rateList); 
            system.debug('mapOfMatAndPrice-->'+mapOfMatAndPrice); 
        }
        catch(Exception e){
            System.debug('Exception---->'+e);
        }
        return mapOfMatAndPrice;
        //return invObj;
    }*/
    public static List<EYI_Car_Park_Master__c> getCarParkMasterList(Id invId){
        List<EYI_Car_Park_Master__c> carParkList = new List<EYI_Car_Park_Master__c>();
        try{
            for(EYI_Car_Park_Master__c carPark:[Select Id,Name, EYI_Parking_Number__c, EYI_Base_UOM__c from EYI_Car_Park_Master__c where EYI_Inventory__c =: invId]){
                carParkList.add(carPark);           
            }
        }
        catch(exception e){
            System.debug('Exception---->'+e);
        }
        return carParkList;
    }
    
    @TestVisible
    private static List<EYI_Rate_List__c> getPriceList(Id recordId){
        List<EYI_Rate_List__c> rateList = new List<EYI_Rate_List__c>();
        try{
            List<EYI_Inventory__c> inventoryList = [Select Id from EYI_Inventory__c where EYI_Booking__c = :recordId];
            for(EYI_Rate_List__c rateRec:[Select Id,EYI_Pricing_Percentage__c,EYI_Condition_Type__c,Amount__c,EYI_Pricing_Quantity__c from EYI_Rate_List__c where EYI_Inventory__c In: inventoryList]){
                rateList.add(rateRec);           
            }
        }
        catch(exception e){
            System.debug('Exception---->'+e);
        }
        return rateList;
    } 
    private static List<EYI_Payment_Schedule__c> getPaymentScheduleList(Id paymentPlanId){
        List<EYI_Payment_Schedule__c> paymentScheduleList = new List<EYI_Payment_Schedule__c>();
        try{
            paymentScheduleList = [Select id, EYI_Usage__c,EYI_Amount_to_be_paid__c,EYI_Usage_Description__c,EYI_Billing_Date__c,EYI_Invoice_Percentage__c,EYI_Net_Payable__c,EYI_Milestone_Number__c 
                                    from EYI_Payment_Schedule__c where Payment_Plan__c = :paymentPlanId ];
            
        }
        catch(Exception e){
            
        }
        system.debug('paymentScheduleList'+paymentScheduleList.size());
        return paymentScheduleList;
    }
    //Todo: Modify the metadata to accept object name as well
    public static String getSF_FieldMapping (String fieldName, String sfValue){
        String sapValue = '';
        SAP_SF_Field_Data_Map__mdt fieldMap;
        try{
            fieldMap = [Select Id,SAP_Value__c from SAP_SF_Field_Data_Map__mdt where SF_Field_Name__c = :fieldName and SF_Value__c = :sfValue];
            system.debug('fieldMap -->'+ fieldMap);
        }
        catch(Exception e){
            System.debug('Exception :::'+e);
        }
        if(fieldMap != null){
            sapValue = fieldMap.SAP_Value__c;
            system.debug('sapValue -->'+ sapValue);
        }
        return sapValue;
    }
    public class lwcMessage {
        @AuraEnabled public String type;
        @AuraEnabled public String message;        
    }

    @AuraEnabled
    public static checkData validateBookingDetails(Id recordId){
        String message;
        checkData cd = new checkData();
        if(recordId!=null){
            List<EYI_Booking__c> bookingDetails= [select id,EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c,EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Vendor_Code__c,
                                                  EYI_Opportunity_Name__r.EYI_NCF_Status__c, EYI_Opportunity_Name__r.EYI_Walk_in_Source__c,
                                                  EYI_Opportunity_Name__r.SyncedQuoteId, EYI_Actual_Booking_Date__c,EYI_Booking_Date__c 
                                                  from EYI_Booking__c 
                                                  where Id=:recordId];
            
            String reqFieldError = System.Label.EYI_Cust_Sync_Req_field_Error;
            reqFieldError+=' Booking : ';
            if(bookingDetails[0].EYI_Opportunity_Name__r.EYI_SAP_Customer_Number__c ==null){
                cd.type = 'ERROR';
                cd.projectMapMsg ='Customer is not synced yet.';
               	return cd; 
            }else if(bookingDetails[0].EYI_Opportunity_Name__r.EYI_NCF_Status__c != 'Received'){
                cd.type = 'ERROR';
                cd.projectMapMsg = 'NCF Form has not yet been recieved.';
               	return cd;  
            }else if(bookingDetails[0].EYI_Opportunity_Name__r.SyncedQuoteId == null){
                cd.type = 'ERROR';
                cd.projectMapMsg = 'No Approved Quote Found.';
               	return cd; 
            }else if(bookingDetails[0].EYI_Opportunity_Name__r.EYI_Walk_in_Source__c =='PREC' && bookingDetails[0].EYI_Opportunity_Name__r.EYI_REC__r.EYI_REC_Vendor_Code__c == null ){
                cd.type = 'ERROR';
                cd.projectMapMsg = 'SAP sync pending for REC/Vendor. Complete sync before proceeding.';
               	return cd; 
            }else{
            	if(bookingDetails[0].EYI_Actual_Booking_Date__c ==null){
                cd.type = 'ERROR';
                reqFieldError +='Actual Booking Date, ';
            } 
			if(bookingDetails[0].EYI_Booking_Date__c ==null){
                cd.type = 'ERROR';
                reqFieldError +='Booking Date,';
            }
            
            if (cd.type == 'ERROR' ) {
                    reqFieldError = reqFieldError.trim();
                    if (reqFieldError.endsWith(',')) {
                        reqFieldError = reqFieldError.substring(0, reqFieldError.length() - 1);
                    }
                    cd.projectMapMsg = reqFieldError;
                }    
            }             
        }
        return cd;
    }
    
    public class checkData{
        @AuraEnabled public String type;
        @AuraEnabled public String projectMapMsg;
        //@AuraEnabled public String bankMapMsg;
    }
}