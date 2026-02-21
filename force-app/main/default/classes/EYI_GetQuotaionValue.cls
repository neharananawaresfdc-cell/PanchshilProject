public class EYI_GetQuotaionValue {
    public static Decimal MaintenanceChargeAmount = 0;
    @AuraEnabled
    public static EYI_Inventory__c fetchinventoryDetails(Id currentPageRecordId){
        EYI_Inventory__c inv = new EYI_Inventory__c();
        
        if(currentPageRecordId!=null){
            String inventoryid;
            String quoteId;
            String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
            if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                inventoryid = currentPageRecordId;
            }
            else if(sObjName!=null && sObjName =='Quote'){
             quoteId = currentPageRecordId;
                Quote quoteDetails = fetchQuoteDetails(quoteId);
               if(quoteDetails!=null) inventoryid = quoteDetails.EYI_Inventory__c;
            }
            
            List<EYI_Inventory__c> invDetails = [select id ,EYI_Opportunity__c,EYI_Opportunity__r.Name,EYI_Inventory_Number__c,EYI_Tower__r.Name,EYI_Floor_No__c, EYI_Project__c,
                                          EYI_Saleable_Area__c,EYI_Tower__c,EYI_Typology__c,EYI_Carpet_Area__c,EYI_RERA_Carpet_Area__c,EYI_Balcony_Area__c
                                                 from EYI_Inventory__c where id =:inventoryid limit 1];
        system.debug('invdetails' + invDetails);
        if(!invDetails.isEmpty()) return invDetails[0];
        }
        return inv;
    }
    
	@AuraEnabled
    public static boolean getUserRole(String usrId) {
        User currentUser = [SELECT UserRole.Name FROM User WHERE Id = :usrId];
        if(currentUser.UserRole.Name != null && currentUser.UserRole.Name.contains('Manager')) {
            return false;
        }
        else {
            return true;
        }
    }

    @AuraEnabled
    public static List<EYI_Car_Park_Master__c> fetchCarParks(Id currentPageRecordId) {
        system.debug('cpr' + currentPageRecordId);
        if(currentPageRecordId!=null){
            String inventoryid;
            String quoteId;
            String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
            if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                inventoryid = currentPageRecordId;
            }
            else if(sObjName!=null && sObjName =='Quote'){
             quoteId = currentPageRecordId;
                Quote quoteDetails = fetchQuoteDetails(quoteId);
               if(quoteDetails!=null) inventoryid = quoteDetails.EYI_Inventory__c;
            }
            system.debug('invid' + inventoryid);
            return [Select Id, EYI_Parking_Type__c,EYI_Category__c,EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c from EYI_Car_Park_Master__c
                Where EYI_Inventory__c = :inventoryid];
        }
        return null;
    }
    
    @AuraEnabled
    public static quote fetchQuoteDetails(String quoteid){
        quote quote = new quote();
        
        if(quoteid!=null){
            List<quote> quoteDetails = [select id ,	OpportunityId, EYI_Inventory__c, EYI_Inventory__r.EYI_Project__c,EYI_Inventory__r.EYI_Tower__c
                                        ,EYI_Floor_Rate_Discount_L__c,EYI_Floor_Rate_Discount_PSF__c,EYI_Base_Rate_Discount_L__c,EYI_Base_Rate_Discount_PSF__c
                                        from quote where id =:quoteid limit 1];
    
        if(!quoteDetails.isEmpty()) return quoteDetails[0];
        }
        return quote;
    }
    @AuraEnabled
    public static Decimal getBaseRate(Id currentPageRecordId) {
        String inventoryid;
        try{
            if(currentPageRecordId!=null){
                Quote quoteDetails = new Quote();
                String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
                if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                    inventoryid = currentPageRecordId;
                }
                system.debug('Base rate -> InventoryId' + inventoryid);
            }
            List<EYI_Rate_List__c> rteList = [select id ,EYI_Calculation_Type__c,EYI_Rate__c,EYI_Inventory__r.EYI_Floor_No__c,EYI_Condition_Type__c,
                                                   EYI_Inventory__r.EYI_Saleable_Area_in_Sq_Mtr__c ,EYI_Pricing_Quantity__c,EYI_Pricing_Percentage__c,EYI_Pricing_Amount__c
                                                   from EYI_Rate_List__c
                                                  where EYI_Inventory__c=:inventoryid and EYI_Condition_Type__c = 'Base Price'];
            system.debug(rteList[0].EYI_Rate__c);
            return rteList[0].EYI_Rate__c;
        }
        catch(exception e){
            system.debug('Error getting base rate' + e);
            return null;
        }
    }
    
    @AuraEnabled
    public static Decimal getFloorRise(Id currentPageRecordId) {
        String inventoryid;
        try{
            if(currentPageRecordId!=null){
                Quote quoteDetails = new Quote();
                String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
                if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                    inventoryid = currentPageRecordId;
                }
                system.debug('Base rate -> InventoryId' + inventoryid);
            }
            List<EYI_Rate_List__c> rteList = [select id ,EYI_Calculation_Type__c,EYI_Rate__c,EYI_Inventory__r.EYI_Floor_No__c,EYI_Condition_Type__c,
                                                   EYI_Inventory__r.EYI_Saleable_Area_in_Sq_Mtr__c ,EYI_Pricing_Quantity__c,EYI_Pricing_Percentage__c,EYI_Pricing_Amount__c
                                                   from EYI_Rate_List__c
                                                  where EYI_Inventory__c=:inventoryid and EYI_Condition_Type__c = 'Floor Rise'];
            system.debug(rteList[0].EYI_Rate__c);
            return rteList[0].EYI_Rate__c;
        }
        catch(exception e){
            system.debug('Error getting floor rise' + e);
            return null;
        }
    }

    @AuraEnabled
    public static quotationValWrapper fetchQuotationValue(Id currentPageRecordId, Id oppId){
        Decimal totalVal=0;
        Decimal totalOtherAmount = 0;
         quotationValWrapper qw = new quotationValWrapper();
        String inventoryid ;//= 'a0RC4000000UTB3MAO';
        String quoteId ;
        String projectid;
        String towerId;
        if(currentPageRecordId!=null){
            Quote quoteDetails = new Quote();
            //EYI_Inventory__c inv = new EYI_Inventory__c();
            String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
            if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                inventoryid = currentPageRecordId;
            }
            else if(sObjName!=null && sObjName =='Quote'){
             quoteId = currentPageRecordId;
                quoteDetails = fetchQuoteDetails(quoteId);
                if(oppId == null && quoteDetails.OpportunityId != null){
                    oppId = quoteDetails.OpportunityId;
                }
               if(quoteDetails!=null) inventoryid = quoteDetails.EYI_Inventory__c;
            }
            //List<EYI_Inventory__c> inv = [select id , EYI_Project__c,EYI_Saleable_Area__c from EYI_Inventory__c where id =:inventoryid limit 1];
            List<EYI_Inventory__c> inv =new List<EYI_Inventory__c>();
            inv.add(fetchinventoryDetails(inventoryid));
            projectid = inv[0].EYI_Project__c;
            towerId = inv[0].EYI_Tower__c;
            system.debug('projectid' + projectid);
            Decimal saleableArea = inv[0].EYI_Saleable_Area__c;
            Decimal carpetArea = inv[0].EYI_RERA_Carpet_Area__c;
            String propertyType ='Flat';
            String distributionCha = 'Residential';
            List<EYI_Quotation_Section_Setting__mdt> qsList = [select id,Main_Section__c,Property_Type__c,Sub_Section__c,
                                                           Distrubution_Channel__c 
                                                           from EYI_Quotation_Section_Setting__mdt
                                                          where Property_Type__c=:propertyType and Distrubution_Channel__c=:distributionCha];	
            
            List<EYI_Rate_List__c> rateList = [select id ,EYI_Calculation_Type__c,EYI_Calculation_Mode__c,EYI_Rate__c,EYI_Inventory__c,EYI_Inventory__r.EYI_Floor_No__c,EYI_Condition_Type__c,
                                               EYI_Inventory__r.EYI_Saleable_Area_in_Sq_Mtr__c ,EYI_Pricing_Quantity__c,EYI_Pricing_Percentage__c,EYI_Pricing_Amount__c
                                               from EYI_Rate_List__c
                                              where EYI_Inventory__c=:inventoryid];

            List<EYI_Car_Park_Master__c> cpList = [Select Id, EYI_Parking_Type__c,EYI_Category__c,EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c from EYI_Car_Park_Master__c
                                                   Where EYI_Inventory__c = :inventoryid and EYI_Category__c!='Earmarked' and EYI_Category__c != 'Additional'];

            system.debug('cpList' + cpList);

            EYI_Inventory__c invList = [Select Id, EYI_Opportunity__c,EYI_Final_Market_Value__c from EYI_Inventory__c Where Id =:inventoryid Limit 1];
            //String oppId = invList.EYI_Opportunity__c;
            Decimal marketValue = invList.EYI_Final_Market_Value__c;
            //system.debug('oppId' + oppId);
            Map<String ,Decimal > mapVal = new Map<String, Decimal>();
            for(EYI_Rate_List__c rl :rateList){
                if(rl.EYI_Calculation_Type__c!=null && rl.EYI_Calculation_Type__c =='Fixed Amount' && rl.EYI_Pricing_Amount__c!=null){
                    mapVal.put (rl.EYI_Condition_Type__c ,rl.EYI_Pricing_Amount__c);
                }
                else if(rl.EYI_Calculation_Type__c!=null && rl.EYI_Calculation_Type__c =='Quantity' && rl.EYI_Pricing_Quantity__c!=null){
                    mapVal.put (rl.EYI_Condition_Type__c ,  rl.EYI_Rate__c * rl.EYI_Pricing_Quantity__c);
                }
                
            }
            if(!cpList.isEmpty()) {
                for(EYI_Car_Park_Master__c cp : cpList) {
                    Decimal chargeValue = 0;
                    if(mapVal.containsKey(cp.EYI_Category__c +' '+'Car park')) {
                        system.debug('duplicatekeyfound' + cp.EYI_Category__c +' '+'Car park');
                        chargeValue = mapVal.get(cp.EYI_Category__c +' '+'Car park') + cp.EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c;
                        mapVal.put(cp.EYI_Category__c +' '+'Car park', chargeValue);
                    }
                    else {
                        mapVal.put(cp.EYI_Category__c +' '+'Car park', cp.EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c);
                    }
                    
                    
                    
                }
            }
            
            system.debug('mapVal'+ mapVal);
            
            List<section> scList = new List<section>();
            
            /***************Base Val calculte*/
            scList.add(baseMainSection(saleableArea,rateList, carpetArea));
            
            /***************Base Val Discount calculte*/
            if(quoteDetails!=null && (saleableArea!=null || carpetArea != null) && (quoteDetails.EYI_Base_Rate_Discount_L__c!=null || quoteDetails.EYI_Base_Rate_Discount_PSF__c!=null
                                      ||quoteDetails.EYI_Floor_Rate_Discount_PSF__c!=null || quoteDetails.EYI_Floor_Rate_Discount_L__c!=null)){
            scList.add(baseMainDiscountSection(quoteDetails.EYI_Base_Rate_Discount_PSF__c,quoteDetails.EYI_Base_Rate_Discount_L__c,quoteDetails.EYI_Floor_Rate_Discount_PSF__c,quoteDetails.EYI_Floor_Rate_Discount_L__c,saleableArea,carpetArea,Integer.valueof(inv[0].EYI_Floor_No__c)));
            }
            
            /**Infrastructure Value Calcualte****/
            scList.add(infraStructureSection(mapVal,qsList));
           // Referral section
            if(quoteId!=null){
                System.debug('Referral Discount');
                section referralDiscountSection = referralDiscountSection(quoteId);
                System.debug(referralDiscountSection);
                if(referralDiscountSection!=null) scList.add(referralDiscountSection);
                
            }
            /*Agrement Value Calcualte*****/
            
            Decimal agreementVal = 0;
            for(Section sc: scList){
                
                if(sc.mainsectionvalue!=null) agreementVal = agreementVal + sc.mainsectionvalue;
            }
            section scagreemnt = new section();
            scagreemnt.mainsectionName = 'Agreement Value';
            scagreemnt.mainsectionvalue = agreementVal;
            scList.add(scagreemnt);
            system.debug('agreementVal'+ agreementVal);
            /* Other Value ****/
            //scList.add(governmentChargeSection(projectid,agreementVal,saleableArea,mapVal,rateList,qsList,marketValue));

            scList.add(otherSection(projectid,towerId,agreementVal,saleableArea,mapVal,rateList,qsList,marketValue, oppId));
            
            /* offer discount value */
            system.debug('offer---' + quoteId);
            if(quoteId!=null){
                section offerSection = offerSection(quoteId);
                if(offerSection!=null) scList.add(offerSection);
                
               }
           for(Section sc: scList){
                
                if(sc.mainsectionvalue!=null && sc.mainsectionName!=null && sc.mainsectionName=='Other') totalOtherAmount = totalOtherAmount + sc.mainsectionvalue;
                else if(sc.mainsectionvalue!=null && sc.mainsectionName!=null && sc.mainsectionName.contains('Offer')) totalOtherAmount = totalOtherAmount + sc.mainsectionvalue;
            }
            
                        
            /*grant total */
            if(agreementVal!=null){
                totalVal = totalVal + agreementVal;
            }if(totalOtherAmount!=null ){
                totalVal = totalVal+totalOtherAmount;
            }
            if(totalVal!=null){
                section secTotal = new section();
                secTotal.mainsectionName = 'Grand Total';
                secTotal.mainsectionvalue =totalVal; 
                scList.add(secTotal);
            }
            system.debug('scList-->'+scList);
            qw.section = scList;
            system.debug('qw-->'+qw);
            return qw;
            
            
        }
        return qw;
    }
    
    /* Calculate Base Value*/
    public static section baseMainSection(Decimal saleableArea , List<EYI_Rate_List__c> rateList, Decimal carpetArea){
        section sect = new section();
        sect.mainsectionName = 'Base';
        List<Subsection> subSectList = new List<Subsection>();
        Decimal totalBaseVal = 0;
        for(EYI_Rate_List__c rl :rateList){
            Subsection subSect = new Subsection();
                if(rl.EYI_Condition_Type__c!=null && rl.EYI_Condition_Type__c=='Base Price' && rl.EYI_Rate__c!=null){
                    subSect.subsectionName ='Base Price' + '@ ' + rl.EYI_Rate__c.setScale(2);
                    if(rl.EYI_Calculation_Mode__c == 'RERA Carpet Area') {
                        subSect.subsectionvalue = carpetArea * rl.EYI_Rate__c;
                    }
                    else if(rl.EYI_Calculation_Mode__c == 'Saleable Area') {
                        subSect.subsectionvalue = saleableArea * rl.EYI_Rate__c;
                    }
                   //subSect.subsectionvalue = saleableArea * rl.EYI_Rate__c;
                    totalBaseVal = totalBaseVal+ subSect.subsectionvalue;
                    subSectList.add(subSect);
                }else if(rl.EYI_Condition_Type__c!=null && rl.EYI_Condition_Type__c=='Floor Rise' 
                         && rl.EYI_Rate__c!=null && rl.EYI_Inventory__r.EYI_Floor_No__c!=null){
                   subSect.subsectionName ='Floor Price' + '@ ' + (rl.EYI_Rate__c ).setScale(2);
                   if(rl.EYI_Calculation_Mode__c == 'RERA Carpet Area') {
                        subSect.subsectionvalue = carpetArea * rl.EYI_Rate__c ;
                    }
                    else if(rl.EYI_Calculation_Mode__c == 'Saleable Area') {
                        subSect.subsectionvalue = saleableArea * rl.EYI_Rate__c ;
                    }
                   //subSect.subsectionvalue =saleableArea * rl.EYI_Rate__c ;
                   totalBaseVal = totalBaseVal + subSect.subsectionvalue;
                   subSectList.add(subSect);
                }else if(rl.EYI_Condition_Type__c!=null && rl.EYI_Calculation_Type__c!=null &&rl.EYI_Pricing_Amount__c!=null &&
                         rl.EYI_Calculation_Type__c =='Fixed Amount' && (rl.EYI_Condition_Type__c=='Floor Rise' ||rl.EYI_Condition_Type__c== 'Base Price')){
                             subSect.subsectionName =rl.EYI_Condition_Type__c;
                             subSect.subsectionvalue = rl.EYI_Pricing_Amount__c;
                             
                             totalBaseVal = totalBaseVal + subSect.subsectionvalue;
                   subSectList.add(subSect);
                         }
        }
        if(!subSectList.isEmpty()){
             sect.Subsection = subSectList;
            sect.mainsectionvalue = totalBaseVal;
        }
        return sect;
    }
    
    /*caluclate Base Discount value */
    public static section baseMainDiscountSection(Decimal baseRateDiscountPSF,Decimal baseRateDiscountL,Decimal floorRateDiscountPSF,Decimal floorRateDiscountL,Decimal saleableArea,Decimal carpetArea, Decimal floorNo){
                Decimal totalBaseDiscount = 0;
            
                section sctDiscount = new section();
                sctDiscount.mainsectionName = 'Discount Base';
                Subsection subSecDiscountBase = new Subsection();
                Subsection subSecDiscountFloor = new Subsection();
                List<Subsection> subSecDiscountList = new List<Subsection>();
                if(baseRateDiscountPSF!=null){
                    subSecDiscountBase.subsectionName = 'Base Price Discount' + '@ ' + baseRateDiscountPSF;
                    subSecDiscountBase.subsectionvalue = baseRateDiscountPSF *saleableArea;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountBase.subsectionvalue;
                    subSecDiscountList.add(subSecDiscountBase);
                   
                }else if(baseRateDiscountL!=null){
                    subSecDiscountBase.subsectionName = 'Base Price Discount' + '@ ' +(baseRateDiscountL/saleableArea).setScale(2);
                    subSecDiscountBase.subsectionvalue = baseRateDiscountL;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountBase.subsectionvalue;
                    subSecDiscountList.add(subSecDiscountBase);
                   }
                
                if(floorRateDiscountPSF!=null){
                    subSecDiscountFloor.subsectionName = 'Floor Price Discount' + '@ ' + floorRateDiscountPSF;
                    subSecDiscountFloor.subsectionvalue = floorRateDiscountPSF * (saleableArea) ;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountFloor.subsectionvalue;
                   subSecDiscountList.add(subSecDiscountFloor);
                }else if(floorRateDiscountL!=null){
                    subSecDiscountFloor.subsectionName = 'Floor Price Discount' + '@ ' +((floorRateDiscountL)/(saleableArea)).setScale(2);
                    subSecDiscountFloor.subsectionvalue = floorRateDiscountL;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountFloor.subsectionvalue;
                    subSecDiscountList.add(subSecDiscountFloor);
                 }
                sctDiscount.mainsectionvalue = totalBaseDiscount * -1;
                sctDiscount.Subsection = subSecDiscountList;
                //scList.add(sctDiscount);
            return sctDiscount;
    }
    /*Calculate infrastructure charges*/
    public static section infraStructureSection(Map<String ,Decimal > mapVal, List<EYI_Quotation_Section_Setting__mdt> qsList){
        section sect = new section();
        sect.mainsectionName = 'Infrastructure Charges';
        List<Subsection> subSectList = new List<Subsection>();
        Decimal totalInfraVal = 0;
        for(EYI_Quotation_Section_Setting__mdt qs :qsList){
            if(qs.Sub_Section__c!=null && qs.Main_Section__c!=null && qs.Main_Section__c == 'Infrastructure Charges' 
              && mapVal.containsKey(qs.Sub_Section__c)){
               Subsection subSect = new Subsection();
                subSect.subsectionName = qs.Sub_Section__c;
                subSect.subsectionvalue = mapVal.get(qs.Sub_Section__c);
                subSectList.add(subSect);
                totalInfraVal = totalInfraVal + mapVal.get(qs.Sub_Section__c);
            }
        }
        if(!subSectList.isEmpty()){
         sect.mainsectionvalue = totalInfraVal;
            sect.Subsection = subSectList;
        }
        system.debug('sect' + sect);
        return sect;
    }
    
 /*calculate other section****/
  public static section otherSection(String projectId, String towerId, Decimal agreementVal, Decimal saleableArea,Map<String ,Decimal > mapVal,List<EYI_Rate_List__c> rateList,List<EYI_Quotation_Section_Setting__mdt> qsList, decimal marketValue, Id oppId){
   section secOtherDetails = new section();
   List<Subsection> subSecOtherListDet = new List<Subsection>();
    Decimal totalOtherAmount = 0;
    List<EYI_Inventory__c> invList = new List<EYI_Inventory__c>();
    if(!rateList.isEmpty() && rateList[0].EYI_Inventory__c != null){
        invList = [Select Id,EYI_OC_Received__c,EYI_GST_Tax_Classification__c, EYI_Opportunity__c,EYI_Final_Market_Value__c from EYI_Inventory__c Where Id =:rateList[0].EYI_Inventory__c Limit 1];
    }

      Map<String, Project_Charges__c> uniqueRecords = new Map<String, Project_Charges__c>();
      List<Project_Charges__c> pcList = [select Id,Name, EYI_Amount__c, EYI_Applied_at_the_time_of_FCN__c, EYI_Apply_This_Charge_to_FA__c, EYI_Area_Type_Id__c, 
                                           EYI_Brokerage_Applicable_on_this_charge__c, EYI_Global_Charges__c, EYI_Brokerage_Based_on_Basic__c, EYI_Charge_Percentage__c,
                                           EYI_Charge_Bucket__c, EYI_Charge_Calculated_As__c, EYI_Charge_Id__c, EYI_GST_Applicable_on_this_charge__c, EYI_GST_Percentage__c,
                                           EYI_Interest_Applicable_on_this_charge__c, EYI_Lumpsum_Charge_Amount__c, EYI_Payable_At__c, EYI_Payment_Plan_Applicable__c, EYI_Project__c, EYI_Project_Id__c, EYI_Rate__c, EYI_Registration_charge__c,
                                           EYI_Global_Charges__r.Name,EYI_Term__c,EYI_Tower__c
                                           from Project_Charges__c 
                                           where (EYI_Project__c=:projectid or EYI_Tower__c=:towerId) and EYI_Active__c = true and EYI_Apply_This_Charge_to_FA__c = true AND EYI_Charge_Type__c = 'Other Charges'];
		
      system.debug('pcList' + pcList);
		for (Project_Charges__c pcObj : pcList) {
            if(uniqueRecords.containsKey(pcObj.Name)) {
                if(pcObj.EYI_Tower__c != null) {
                    uniqueRecords.put(pcObj.Name, pcObj);
                }
                else if(pcObj.EYI_Project__c != null) {
                    uniqueRecords.put(pcObj.Name, pcObj);
                }
                
            }
            else {
                    //uniqueRecords.put(pcObj.Name, pcObj);
                    if(pcObj.EYI_Tower__c != null) {
                    uniqueRecords.put(pcObj.Name, pcObj);
                    }
                    else if(pcObj.EYI_Project__c != null) {
                        uniqueRecords.put(pcObj.Name, pcObj);
                    }
                }
        }
		
      	List<Project_Charges__c> uniqueProjectChargesList = new List<Project_Charges__c>(uniqueRecords.values());
      system.debug('uniqueRecords' + uniqueProjectChargesList);
        //logic for SD waive
        List<Opportunity> oppList = [SELECT Id, Name, (Select Id, Name, EYI_Gender__c from Applicants__r)
                                    FROM Opportunity WHERE Id = :oppId LIMIT 1];

            Boolean waive = false;
            if(!oppList.isEmpty()) {
                if(oppList[0].Applicants__r.size() == 1) {
                    system.debug('size' + oppList[0].Applicants__r.size());
                    if(oppList[0].Applicants__r[0].EYI_Gender__c == 'F' || oppList[0].Applicants__r[0].EYI_Gender__c == 'Female') {
                        waive = true;
                    }
                }
                else {
                    for(EYI_Applicants__c applicants : oppList[0].Applicants__r) {
                        if(applicants.EYI_Gender__c == 'M') {
                            waive = false;
                            system.debug('waive 388' + waive);
                            break;
                        }
                        else if(applicants.EYI_Gender__c == 'F'){
                            waive = true;
                        }
                    }
                }
            }
            else {
                waive = false;
            }
            Map<String , Decimal> proChargeMap = new Map<String , Decimal>();
            for(Project_Charges__c pc : uniqueRecords.values()){
                if(!invList.isEmpty() && (!invList[0].EYI_OC_Received__c && (invList[0].EYI_GST_Tax_Classification__c == 'Taxable under GST' || invList[0].EYI_GST_Tax_Classification__c == '5% Scheme-New RERA'))){
                    if(pc.EYI_Global_Charges__c!=null && pc.EYI_Global_Charges__r.Name=='Tax'
                   && pc.EYI_GST_Applicable_on_this_charge__c==true && pc.EYI_GST_Percentage__c!=null
                   && pc.EYI_GST_Percentage__c.contains('GST') && agreementVal!=null){
                       Decimal gstSplit = getGSTSpilt(pc.EYI_GST_Percentage__c);
                       proChargeMap.put('SGST',(gstSplit * agreementVal)/100);
                       proChargeMap.put('CGST',(gstSplit * agreementVal)/100);
                   }
                }
                
                if(pc.EYI_Charge_Bucket__c!=null && pc.EYI_Charge_Bucket__c =='Stamp Duty and Registration' && pc.EYI_Registration_charge__c == false && pc.EYI_Charge_Percentage__c!=null &&agreementVal!=null){
                    system.debug('waive' + waive);
                    if(waive == true){
                        Decimal SDCharge = (marketValue > agreementVal) ? marketValue : agreementVal;
                        Decimal stampDutyCharge = ((pc.EYI_Charge_Percentage__c-1) * SDCharge)/100;
                        system.debug('Rounded stampduty' + Math.ceil(stampDutyCharge / 100) * 100);
                        stampDutyCharge = Math.ceil(stampDutyCharge / 100) * 100;
                        proChargeMap.put('Stamp Duty',stampDutyCharge);
                    }
                    else {
                        Decimal SDCharge = (marketValue > agreementVal) ? marketValue : agreementVal;
                        Decimal stampDutyCharge = ((pc.EYI_Charge_Percentage__c) * SDCharge)/100;
                        system.debug('Rounded stampduty' + Math.ceil(stampDutyCharge / 100) * 100);
                        stampDutyCharge = Math.ceil(stampDutyCharge / 100) * 100;
                        proChargeMap.put('Stamp Duty',stampDutyCharge );
                    }                 
                    
                }
                else if(pc.EYI_Charge_Bucket__c!=null && pc.EYI_Charge_Bucket__c =='Stamp Duty and Registration' && pc.EYI_Registration_charge__c == true && pc.EYI_Charge_Percentage__c!=null &&agreementVal!=null ){
                    if(agreementVal < 3000000) {
                        Decimal regCharge = (pc.EYI_Charge_Percentage__c * agreementVal)/100;
                        proChargeMap.put('Registration',regCharge);
                    }
                    else{
                        proChargeMap.put('Registration',30000);
                    }
                    /*if(regCharge!=null && pc.EYI_Lumpsum_Charge_Amount__c!=null && pc.EYI_Lumpsum_Charge_Amount__c < regCharge ) proChargeMap.put('Registration #',pc.EYI_Lumpsum_Charge_Amount__c);
                    else  proChargeMap.put('Registration',regCharge);*/                                                                                   
                }
                  if(pc.EYI_Charge_Bucket__c!=null && pc.EYI_Charge_Bucket__c =='Maintenance Charges'){
                    if(pc.EYI_Charge_Calculated_As__c!=null && pc.EYI_Charge_Calculated_As__c =='Rate List at Unit Level'
                       && pc.EYI_Rate__c!=null && pc.EYI_GST_Applicable_on_this_charge__c==false){
                            if(pc.EYI_Global_Charges__r.Name == 'Maintenance Charges') {
                                if(pc.EYI_Term__c != null){
                                    proChargeMap.put(pc.EYI_Global_Charges__r.Name,pc.EYI_Rate__c * saleableArea * pc.EYI_Term__c);
                                }
                                else{
                                    proChargeMap.put(pc.EYI_Global_Charges__r.Name,pc.EYI_Rate__c * saleableArea);
                                }
                            }
                                
                            else if(pc.EYI_Global_Charges__r.Name == 'Maintenance Deposit') {
                                proChargeMap.put(pc.EYI_Global_Charges__r.Name,pc.EYI_Rate__c * saleableArea);
                            }
                       }
                    if(pc.EYI_GST_Applicable_on_this_charge__c==true){
                        system.debug('Entered');
                        Decimal gstSplit = getGSTSpilt(pc.EYI_GST_Percentage__c) * 2;
                        
                        system.debug('gstSplit' + gstSplit);
                        if(pc.EYI_Term__c != null){
                            Decimal calValue = pc.EYI_Rate__c * saleableArea * pc.EYI_Term__c;
                            calValue += (calValue * gstSplit)/100;
                            proChargeMap.put(pc.EYI_Global_Charges__r.Name + '(including GST)',calValue);
                        }
                            
                        else {
                            Decimal calValue = pc.EYI_Rate__c * saleableArea;
                            calValue += (calValue * gstSplit)/100;                            
                            proChargeMap.put(pc.EYI_Global_Charges__r.Name + '(including GST)' ,calValue);
                        }
                        EYI_GetQuotaionValue.MaintenanceChargeAmount += ((pc.EYI_Rate__c * saleableArea) * 12)/100;
                        system.debug('EYI_GetQuotaionValue.MaintenanceChargeAmount' + EYI_GetQuotaionValue.MaintenanceChargeAmount);
                    }
                }
                system.debug('other-->'+pc.EYI_Charge_Bucket__c + '-' + pc.EYI_Charge_Calculated_As__c + '-'+pc.EYI_Rate__c + saleableArea);
                if(pc.EYI_Charge_Bucket__c!=null && pc.EYI_Charge_Calculated_As__c!=null && saleableArea!=null
                   && pc.EYI_Charge_Bucket__c =='Other Charges' && pc.EYI_GST_Applicable_on_this_charge__c == false){
                       if(pc.EYI_Charge_Calculated_As__c =='Lumpsum at Project Level'){
                         proChargeMap.put(pc.Name,pc.EYI_Amount__c);
                       }else if(pc.EYI_Charge_Calculated_As__c =='Percentage of Agreement Value'){
                            system.debug(pc.Name);
                           proChargeMap.put(pc.Name,(pc.EYI_Charge_Percentage__c *agreementVal)/100 );
                       }else if(pc.EYI_Charge_Calculated_As__c =='Rate List at Unit Level'){
                           proChargeMap.put(pc.Name,(pc.EYI_Rate__c *agreementVal)/100 );
                       }
                       
                       
                   }
                   else if(pc.EYI_Charge_Bucket__c!=null && pc.EYI_Charge_Calculated_As__c!=null && saleableArea!=null
                   && pc.EYI_Charge_Bucket__c =='Other Charges' && pc.EYI_GST_Applicable_on_this_charge__c == true && pc.EYI_Global_Charges__r.Name!='Basic'){
                    Decimal gstAmt;
                    Decimal gstSplit = getGSTSpilt(pc.EYI_GST_Percentage__c) * 2;
                       if(pc.EYI_Charge_Calculated_As__c =='Lumpsum at Project Level'){
                        gstAmt = (pc.EYI_Amount__c * gstSplit)/100;
                         proChargeMap.put(pc.Name + + '(including GST)',pc.EYI_Amount__c + gstAmt);
                       }else if(pc.EYI_Charge_Calculated_As__c =='Percentage of Agreement Value'){
                            system.debug(pc.Name);
                            gstAmt = (((pc.EYI_Charge_Percentage__c *agreementVal)/100) * gstSplit)/100;
                            proChargeMap.put(pc.Name + + '(including GST)',(pc.EYI_Charge_Percentage__c *agreementVal)/100 + gstAmt);
                       }else if(pc.EYI_Charge_Calculated_As__c =='Rate List at Unit Level'){
                        gstAmt = ((pc.EYI_Rate__c *saleableArea) * gstSplit)/100;
                           proChargeMap.put(pc.Name + + '(including GST)',pc.EYI_Rate__c *saleableArea + gstAmt);
                       }
                       
                       
                   }
                   
                  
                
            }
            //Other Charges from rate List
            for(EYI_Rate_List__c rl :rateList){
                if(rl.EYI_Calculation_Type__c!=null && rl.EYI_Calculation_Type__c =='Percentage'){
                    mapVal.put (rl.EYI_Condition_Type__c ,(rl.EYI_Pricing_Percentage__c * agreementVal)/100);
                }
            }
            
            //Map<String , List<subsection>> otherRLSubSection = new Map<String , List<subsection>>();
            List<subsection> otherRLSubSection = new List<subsection>();
            for(EYI_Quotation_Section_Setting__mdt qs:qsList ){
               if(qs.Main_Section__c!=null && qs.Sub_Section__c!=null && (qs.Main_Section__c == 'Other')){
                       Subsection sb = new Subsection();
                       sb.subsectionName =qs.Sub_Section__c;
                       sb.subsectionvalue = mapVal.get(qs.Sub_Section__c);
                       otherRLSubSection.add(sb);
                   
              }
            }
            
            if(!proChargeMap.isEmpty() || !otherRLSubSection.isEmpty()){
                secOtherDetails.mainsectionName = 'Other';
                //secOtherDetails.mainsectionvalue = agreementVal;
                
                totalOtherAmount = 0;
                for(String key : proChargeMap.keySet()){
                    try{
                        Subsection subSecOther = new Subsection();
                    subSecOther.subsectionName = key;
                    subSecOther.subsectionvalue =proChargeMap.get(key);
                    totalOtherAmount = totalOtherAmount + proChargeMap.get(key);
                    system.debug('totalOtherAmount-->'+totalOtherAmount);
                    subSecOtherListDet.add(subSecOther);
                    }
                    catch(exception error){
                        system.debug('ErrorMSg 558');
                        system.debug(error);
                    }
                }
                
                for(Subsection sub : otherRLSubSection){
                    try{
                        totalOtherAmount = totalOtherAmount + sub.subsectionvalue;
                        subSecOtherListDet.add(sub);
                    }
                    catch(exception error){
                        system.debug('ErrorMSg ');
                        system.debug(error);
                    }
                }
            }
      if(!subSecOtherListDet.isEmpty()){
         secOtherDetails.Subsection = subSecOtherListDet;
         secOtherDetails.mainsectionvalue = totalOtherAmount;
      }
    return secOtherDetails;
}

    
public static section offerSection(String quoteId){
        section sect = new section();
        List<EYI_Applied_Offers_To_Quotation__c> appliedOffer = [select id , EYI_Offer__r.EYI_Amount__c,EYI_Discount_for_Agreement_Value__c, EYI_Offer__r.Name
                                                                     from EYI_Applied_Offers_To_Quotation__c
                                                                     where EYI_Quote__c =:quoteId and (EYI_Offer__r.EYI_Amount__c!=null OR EYI_Discount_for_Agreement_Value__c != null)  and EYI_Offer__r.Offer_Active_Status__c='Active' AND EYI_Offer__r.Offer_Type__c != 'Referral Discount'];
         if(!appliedOffer.isEmpty()){
             sect.mainsectionName = 'Offer Discount';
             List<Subsection> subSectList = new List<Subsection>();
             Decimal totalOfferVal = 0;
        
              for(EYI_Applied_Offers_To_Quotation__c ao :appliedOffer){
                Double amountval = ao.EYI_Offer__r.EYI_Amount__c != null ? ao.EYI_Offer__r.EYI_Amount__c : ao.EYI_Discount_for_Agreement_Value__c;
                Subsection subSect = new Subsection();
                subSect.subsectionName = ao.EYI_Offer__r.Name;
                subSect.subsectionvalue = amountval;
                subSectList.add(subSect);
                totalOfferVal = totalOfferVal + amountval;
            
           }
             if(!subSectList.isEmpty()){
                sect.mainsectionvalue = totalOfferVal * -1;
                sect.Subsection = subSectList;
              }
             return sect;
         }
        
        return null;
    }    
    
    public static section referralDiscountSection(String quoteId){
        section sect = new section();
        List<EYI_Applied_Offers_To_Quotation__c> appliedOffer = [select id , EYI_Offer__r.EYI_Amount__c, EYI_Offer__r.Name,EYI_Discount_for_Agreement_Value__c
                                                                     from EYI_Applied_Offers_To_Quotation__c
                                                                     where EYI_Quote__c =:quoteId and (EYI_Offer__r.EYI_Amount__c!=null OR EYI_Discount_for_Agreement_Value__c != null)  and EYI_Offer__r.Offer_Active_Status__c='Active' AND EYI_Offer__r.Offer_Type__c = 'Referral Discount'];
         if(!appliedOffer.isEmpty()){
             sect.mainsectionName = 'Referral Discount';
             List<Subsection> subSectList = new List<Subsection>();
             Decimal totalOfferVal = 0;
        
              for(EYI_Applied_Offers_To_Quotation__c ao :appliedOffer){
                Double amountval = ao.EYI_Offer__r.EYI_Amount__c != null ? ao.EYI_Offer__r.EYI_Amount__c : ao.EYI_Discount_for_Agreement_Value__c;
                Subsection subSect = new Subsection();
                subSect.subsectionName = ao.EYI_Offer__r.Name;
                subSect.subsectionvalue = amountval;
                subSectList.add(subSect);
                totalOfferVal = totalOfferVal + amountval;
            
           }
             if(!subSectList.isEmpty()){
                sect.mainsectionvalue = totalOfferVal * -1;
                sect.Subsection = subSectList;
              }
             return sect;
         }
        
        return null;
    }    
    
    
    public static Decimal getGSTSpilt(string gstDetails){
        if(gstDetails!=null){
            List<String> gstDet = gstDetails.split('-');
            if(!gstDet.isEmpty() && gstDet.size()==2) return Decimal.valueof(gstDet[1])/2;
        }
        return null;
    }

    public class quotationValWrapper{
        @AuraEnabled public  List<section> section;
        
         public void setSection(List<section> sectionList) {
        this.section = sectionList;
    }
        
    }
            public class section{
             @AuraEnabled public string mainsectionName;
              @AuraEnabled public Decimal mainsectionvalue;
              @AuraEnabled public List<Subsection> Subsection;
                
                public void section(String name, Decimal value, List<Subsection> subSections) {
            this.mainsectionName = name;
            this.mainsectionvalue = value;
            this.Subsection = subSections;
        }
                
            }
     public class Subsection{
         @AuraEnabled public string subsectionName;
         @AuraEnabled public Decimal subsectionvalue;
         
          public void setSubsection(String name, Decimal value) {
            this.subsectionName = name;
            this.subsectionvalue = value;
        }
         /*public subsection(String name , String val){
             this.subsectionName = name;
             this.subsectionvalue = val;
         }*/
        
    }
    
    
    @AuraEnabled
    public static quotationDiscountValWrapper fetchQuotationDiscountValue(Id currentPageRecordId ,Decimal baseRatePSF,Decimal baseRateLS,Decimal floorRatePSF,Decimal floorRateLS,Id oppId ){
        quotationDiscountValWrapper qDicsountVal = new quotationDiscountValWrapper();
        quotationValWrapper qw = new quotationValWrapper();
        String inventoryid;// = 'a0RC4000000UTB3MAO';
        String quoteId;
        try{
        if(currentPageRecordId!=null){
            //
           Quote quoteDetails = new Quote();
            //EYI_Inventory__c inv = new EYI_Inventory__c();
            String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
            if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                inventoryid = currentPageRecordId;
            }
            else if(sObjName!=null && sObjName =='Quote'){
             quoteId = currentPageRecordId;
                quoteDetails = fetchQuoteDetails(quoteId);
               if(quoteDetails!=null) inventoryid = quoteDetails.EYI_Inventory__c;
            }
            //
            List<EYI_Inventory__c> inv = [select id ,EYI_Floor_No__c,EYI_Tower__c, EYI_Opportunity__c,EYI_Project__c,EYI_Saleable_Area__c,EYI_RERA_Carpet_Area__c from EYI_Inventory__c where id =:inventoryid limit 1];
            if(!inv.isEmpty()){
            String projectid = inv[0].EYI_Project__c;
            String towerId = inv[0].EYI_Tower__c;
            Decimal saleableArea = inv[0].EYI_Saleable_Area__c;
                Decimal carpetArea = inv[0].EYI_RERA_Carpet_Area__c;
            Integer floorNo= Integer.Valueof(inv[0].EYI_Floor_No__c);
            String propertyType ='Flat';
            String distributionCha = 'Residential';
             
            List<EYI_Quotation_Section_Setting__mdt> qsList = [select id,Main_Section__c,Property_Type__c,Sub_Section__c,
                                                           Distrubution_Channel__c 
                                                           from EYI_Quotation_Section_Setting__mdt
                                                          where Property_Type__c=:propertyType and Distrubution_Channel__c=:distributionCha];	
            
            List<EYI_Rate_List__c> rateList = [select id ,EYI_Calculation_Type__c,EYI_Calculation_Mode__c,EYI_Rate__c,EYI_Inventory__r.EYI_Floor_No__c,EYI_Condition_Type__c,
                                               EYI_Inventory__r.EYI_Saleable_Area_in_Sq_Mtr__c ,EYI_Pricing_Quantity__c,EYI_Pricing_Percentage__c,EYI_Pricing_Amount__c
                                               from EYI_Rate_List__c
                                              where EYI_Inventory__c=:inventoryid];

            List<EYI_Car_Park_Master__c> cpList = [Select Id, EYI_Parking_Type__c,EYI_Category__c,EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c from EYI_Car_Park_Master__c
                                                   Where EYI_Inventory__c = :inventoryid and EYI_Category__c != 'Earmarked' and EYI_Category__c!='Additional'];

            EYI_Inventory__c invList = [Select Id, EYI_Opportunity__c,EYI_Final_Market_Value__c from EYI_Inventory__c Where Id =:inventoryid Limit 1];
            //String oppId = invList.EYI_Opportunity__c;
            Decimal marketValue = invList.EYI_Final_Market_Value__c;
    
            Map<String ,Decimal > mapVal = new Map<String, Decimal>();
            for(EYI_Rate_List__c rl :rateList){
                if(rl.EYI_Calculation_Type__c!=null && rl.EYI_Calculation_Type__c =='Fixed Amount' && rl.EYI_Pricing_Amount__c!=null){
                    mapVal.put (rl.EYI_Condition_Type__c ,rl.EYI_Pricing_Amount__c);
                }
                else if(rl.EYI_Calculation_Type__c!=null && rl.EYI_Calculation_Type__c =='Quantity' && rl.EYI_Pricing_Quantity__c!=null){
                    mapVal.put (rl.EYI_Condition_Type__c ,  rl.EYI_Rate__c * rl.EYI_Pricing_Quantity__c);
                }
                
            }
            Map<String, Decimal> cpMap = new Map<String,Decimal>();
            if(!cpList.isEmpty()) {
                for(EYI_Car_Park_Master__c cp : cpList) {
                    Decimal chargeValue = 0;
                    if(mapVal.containsKey(cp.EYI_Category__c +' '+'Car park')) {
                        system.debug('duplicatekeyfound' + cp.EYI_Category__c +' '+'Car park');
                        chargeValue = mapVal.get(cp.EYI_Category__c +' '+'Car park') + cp.EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c;
                        mapVal.put(cp.EYI_Category__c +' '+'Car park', chargeValue);
                    }
                    else {
                        mapVal.put(cp.EYI_Category__c +' '+'Car park', cp.EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c);
                    }
                    
                    
                    
                }
            }
            List<section> scList = new List<section>();
            
            /***************Base Val calculte*/
            scList.add(baseMainSection(saleableArea,rateList,carpetArea));
            
            /***** Discount Base******/
             Decimal totalBaseDiscount = 0;
            if(baseRatePSF!=null || baseRateLS!=null || floorRatePSF!=null || floorRateLS!=null){
                section sctDiscount = new section();
                sctDiscount.mainsectionName = 'Discount Base';
                Subsection subSecDiscountBase = new Subsection();
                Subsection subSecDiscountFloor = new Subsection();
                List<Subsection> subSecDiscountList = new List<Subsection>();
                if(baseRatePSF!=null){
                    subSecDiscountBase.subsectionName = 'Base Price Discount' + '@ ' + baseRatePSF;
                    subSecDiscountBase.subsectionvalue = baseRatePSF *saleableArea;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountBase.subsectionvalue;
                    subSecDiscountList.add(subSecDiscountBase);
                   
                }else if(baseRateLS!=null){
                    subSecDiscountBase.subsectionName = 'Base Price Discount' + '@ ' +(baseRateLS/saleableArea).setScale(2);
                    subSecDiscountBase.subsectionvalue = baseRateLS;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountBase.subsectionvalue;
                    subSecDiscountList.add(subSecDiscountBase);
                   }
                
                if(floorRatePSF!=null){
                    subSecDiscountFloor.subsectionName = 'Floor Price Discount' + '@ ' + floorRatePSF;
                    subSecDiscountFloor.subsectionvalue = floorRatePSF * (saleableArea) ;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountFloor.subsectionvalue;
                   subSecDiscountList.add(subSecDiscountFloor);
                }else if(floorRateLS!=null){
                    subSecDiscountFloor.subsectionName = 'Floor Price Discount' + '@ ' +((floorRateLS)/(saleableArea)).setScale(2);
                    subSecDiscountFloor.subsectionvalue = floorRateLS;
                    totalBaseDiscount = totalBaseDiscount + subSecDiscountFloor.subsectionvalue;
                    subSecDiscountList.add(subSecDiscountFloor);
                 }
                sctDiscount.mainsectionvalue = totalBaseDiscount * -1;
                sctDiscount.Subsection = subSecDiscountList;
                scList.add(sctDiscount);
            }
               
            /**Infrastructure Value Calcualte****/
            scList.add(infraStructureSection(mapVal,qsList));
               
            Decimal agreementVal = 0;
            for(Section sc: scList){
                if(sc.mainsectionvalue!=null && sc.mainsectionName!=null) {
                    agreementVal = agreementVal + sc.mainsectionvalue;
                }
               /* if(sc.mainsectionvalue!=null && sc.mainsectionName!=null && sc.mainsectionName!='Discount Base') {
                    agreementVal = agreementVal + sc.mainsectionvalue;
                }else if(sc.mainsectionvalue!=null && sc.mainsectionName!=null && sc.mainsectionName=='Discount Base'){
                    agreementVal = agreementVal - sc.mainsectionvalue;
                }*/
            }
            section scagreemnt = new section();
            scagreemnt.mainsectionName = 'Agreement Value';
            scagreemnt.mainsectionvalue = agreementVal;
            scList.add(scagreemnt);
            /* Other Value ****/
                Decimal totalOtherAmount= 0;
                
            //scList.add(governmentChargeSection(projectid,agreementVal,saleableArea,mapVal,rateList,qsList,marketValue));
            scList.add(otherSection(projectid,towerId,agreementVal,saleableArea,mapVal,rateList,qsList,marketValue, oppId));
            
            /* offer discount value */
            system.debug('offer---' + quoteId);
            if(quoteId!=null){
                section offerSection = offerSection(quoteId);
                if(offerSection!=null) scList.add(offerSection);
                
               }    
                
            for(Section sc: scList){
                
                if(sc.mainsectionvalue!=null && sc.mainsectionName!=null && sc.mainsectionName=='Other') totalOtherAmount = totalOtherAmount + sc.mainsectionvalue;
                else if(sc.mainsectionvalue!=null && sc.mainsectionName!=null && sc.mainsectionName.contains('Offer')) totalOtherAmount = totalOtherAmount + sc.mainsectionvalue;
            }
            
            Decimal totalVal = 0;
            if(agreementVal!=null){
                totalVal = totalVal + agreementVal;
            }if(totalOtherAmount!=null ){
                totalVal = totalVal+totalOtherAmount;
            }
            if(totalVal!=null){
                section secTotal = new section();
                secTotal.mainsectionName = 'Grand Total';
                secTotal.mainsectionvalue =totalVal; 
                scList.add(secTotal);
            }
            system.debug('scList-->'+scList);
            qw.section = scList;
            system.debug('qw-->'+qw);
             qDicsountVal.quotationValWrapperVal = qw;    
                
           }
         }
       
        return qDicsountVal;
        }
        catch(Exception e){
            qDicsountVal.errorMesage = e.getMessage();
            return qDicsountVal;
        }
    }
    
    @AuraEnabled
    public static List<Offer__c> fetchOffers(String quoteid){
    List<Offer__c> offerList = new List<Offer__c>(); 
        
        String inventoryid;// = 'a0RC4000000UTB3MAO';
        if(quoteid!=null){
            Quote quoteDetails = fetchQuoteDetails(quoteid);
            inventoryid = quoteDetails.EYI_Inventory__c;
             //EYI_Inventory__c inv = fetchinventoryDetails(inventoryid);
             String projectId = quoteDetails.EYI_Inventory__r.EYI_Project__c;
             String towerId= quoteDetails.EYI_Inventory__r.EYI_Tower__c;
            List<EYI_Applied_Offers_To_Quotation__c> offerToQuoteList = [Select id,EYI_Offer__c from EYI_Applied_Offers_To_Quotation__c 
                                                                         where EYI_Quote__c=:quoteid];
            Set<Id> addedOfferId = new Set<Id>();
            for(EYI_Applied_Offers_To_Quotation__c offer:  offerToQuoteList){
                if(offer.EYI_Offer__c!=null){
                    addedOfferId.add(offer.EYI_Offer__c);
                }
            }
               offerList = [select Id, Name, Offer_Details__c, Start_Date__c, End_Date__c, EYI_Amount__c
                                        from Offer__c
                                        where ID !=:addedOfferId AND (Project__c=:projectId OR Tower__c=:towerId OR Inventory__c=:inventoryid ) and Offer_Active_Status__c='Active' 
                                        and EYI_Do_not_show_on_Quotation__c=false AND End_Date__c  >=:System.today() AND Start_Date__c <= :System.today() ];
                if(!offerList.isEmpty()){
                     return offerList;
                }
            
           }
        return offerList;
    }
    
    @AuraEnabled
    public static string addOfferToQuote(String quoteId, List<Offer__c> OfferList){
        try{
            if(quoteId!=null && !OfferList.isEmpty()){
                List<EYI_Applied_Offers_To_Quotation__c> offerToQuoteList = new List<EYI_Applied_Offers_To_Quotation__c>();
                    for(Offer__c offer: OfferList){
                        EYI_Applied_Offers_To_Quotation__c offerToQuote = new EYI_Applied_Offers_To_Quotation__c();
                        offerToQuote.EYI_Quote__c = quoteId;
                        offerToQuote.EYI_Offer__c = offer.Id;
                        offerToQuoteList.add(offerToQuote);
                    }
                if(!offerToQuoteList.isEmpty()){
                    insert offerToQuoteList;
                    return 'Success';
                }
            }
            return 'Please pass valid Data';
        }
        catch(exception e){
            return e.getMessage();
        }
    }
        
    @AuraEnabled
    public static quoteData createQuoatationRecord(Id currentPageRecordId,String quotationWrapperData, Id paymentPlanId, Id placeholderOpp, Id selectedOppId){
        
        try{
            Decimal sgst = 0;
        	Decimal cgst = 0;
        	Decimal registrationValue = 0;
        	Decimal stampDuty = 0;
            Decimal maintenanceCharges = 0;
            Decimal maintenanceDeposit = 0;
            
            system.debug('SelectedoppId' + selectedOppId);
            Opportunity seloppRec;
            if(selectedOppId != null){
                seloppRec = [Select Id, Name from Opportunity Where Id = :selectedOppId];
            }
            
            quoteData qd = new quoteData();
            if(currentPageRecordId!=null && quotationWrapperData!=null){
                String inventoryid;
                String quoteId;
                Quote quoteDetails = new Quote();
                //EYI_Inventory__c inv = new EYI_Inventory__c();
                String sObjName = currentPageRecordId.getSObjectType().getDescribe().getName();
                if(sObjName!=null && sObjName =='EYI_Inventory__c') {
                    inventoryid = currentPageRecordId;
                }
                else if(sObjName!=null && sObjName =='Quote'){
                    system.debug('entered quote obj');
                 quoteId = currentPageRecordId;
                    quoteDetails = fetchQuoteDetails(quoteId);
                   if(quoteDetails!=null) inventoryid = quoteDetails.EYI_Inventory__c;
                }
                //List<EYI_Inventory__c> inv = [select id , EYI_Project__c,EYI_Saleable_Area__c from EYI_Inventory__c where id =:inventoryid limit 1];
               // List<EYI_Inventory__c> inv =new List<EYI_Inventory__c>();
                //inv.add(fetchinventoryDetails(inventoryid));
                    
                //quotationValWrapper.section quotationData = (quotationValWrapper.section) JSON.deserialize(quotationWrapperData,quotationValWrapper.section.class);
                List<section> quotationData = (List<section>) JSON.deserialize(quotationWrapperData,List<section>.class);
                EYI_Inventory__c Inv = fetchinventoryDetails(inventoryid);
                system.debug('inv det' + Inv.EYI_Opportunity__c);
                List<EYI_Rate_List__c> rateList = [select id ,EYI_Calculation_Type__c,EYI_Rate__c,EYI_Inventory__r.EYI_Floor_No__c,EYI_Condition_Type__c,
                                                  EYI_Inventory__r.EYI_Saleable_Area_in_Sq_Mtr__c ,EYI_Pricing_Quantity__c,EYI_Pricing_Percentage__c,EYI_Pricing_Amount__c
                                                  from EYI_Rate_List__c
                                                  where EYI_Inventory__c=:inventoryid];
                Decimal basePriceL;
                Decimal basePricePSF;
                Decimal floorPriceRisePSF;
                for(EYI_Rate_List__c rl :rateList){
                    if(rl.EYI_Condition_Type__c!=null && rl.EYI_Condition_Type__c=='Base Price' && rl.EYI_Pricing_Amount__c!=null){
                        basePriceL = rl.EYI_Pricing_Amount__c;
                    }else if(rl.EYI_Condition_Type__c!=null && rl.EYI_Condition_Type__c=='Base Price' && rl.EYI_Rate__c!=null){
                        basePricePSF = rl.EYI_Rate__c;
                    }else if(rl.EYI_Condition_Type__c!=null && rl.EYI_Condition_Type__c=='Floor Rise' && rl.EYI_Pricing_Quantity__c!=null){
                        floorPriceRisePSF = rl.EYI_Pricing_Quantity__c;
                    }else if(rl.EYI_Condition_Type__c!=null && rl.EYI_Condition_Type__c=='Floor Rise' && rl.EYI_Rate__c!=null){
                        floorPriceRisePSF = rl.EYI_Rate__c;
                    }
                }
                Decimal base = 0;
                Decimal agreementValue = 0;
                Decimal grandTotal = 0;
                Decimal infrastructureCharges = 0;
                Boolean discountApplied = false;
                List<Subsection> subSectionOtherList = new List<Subsection>();
                List<Subsection> subSectioBaseDiscountList = new List<Subsection>();
                system.debug('quotation Data' + quotationData);
                for(section quoData: quotationData ){
                    if(quoData.mainsectionName == 'Base'){
                        base = quoData.mainsectionvalue;
                    }else if(quoData.mainsectionName =='Agreement Value'){
                        agreementValue = quoData.mainsectionvalue;
                    }else if(quoData.mainsectionName =='Grand Total'){
                        grandTotal =  quoData.mainsectionvalue;
                    }else if(quoData.mainsectionName =='Infrastructure Charges'){
                        infrastructureCharges =  quoData.mainsectionvalue;
                    }else if(quoData.mainsectionName =='Other'){
                        subSectionOtherList = quoData.Subsection;
                    }else if(quoData.mainsectionName.contains('Discount')){
                        discountApplied = true;
                        
                            if(quoData.mainsectionName =='Discount Base'){
                                subSectioBaseDiscountList = quoData.Subsection;
                            }
                     }
                        
                    
                }
                // Storing rateList amounts
                system.debug('checking..');
                Map<String, Subsection> subsectionMap = new Map<String, Subsection>();
                for (section sect : quotationData) {
                    system.debug('checking2..' + sect);
                    if(sect.Subsection!=null){
                        for (Subsection subSect : sect.Subsection) {
                            if(subSect!=null){
                                system.debug('checking3..' + subSect);
                                if(subSect.subsectionName.contains('Base Price')) {
                                    String cleanSubsectionName = subSect.subsectionName.split('@')[0].trim();
                                    
                                    subsectionMap.put(cleanSubsectionName, subSect);
                                }
                                else if(subSect.subsectionName.contains('Floor Price')) {
                                    String cleanSubsectionName = subSect.subsectionName.split('@')[0].trim();
                                    cleanSubsectionName = cleanSubsectionName.replace('Price', 'Rise');
                                    subsectionMap.put(cleanSubsectionName, subSect);
                                }
                                else
                                    subsectionMap.put(subSect.subsectionName, subSect);
                            }
                            
                        }
                    }
                    
                }

                List<EYI_Rate_List__c> rateListToUpdate = new List<EYI_Rate_List__c>();

                // Iterate over RateList records and compare with subsectionMap
                system.debug('subsectionMap'+ subsectionMap);
                
                for (EYI_Rate_List__c rtL : rateList) {
                    system.debug('rtL' + rtL);
                    if (subsectionMap.containsKey(rtL.EYI_Condition_Type__c)) {
                        Subsection matchingSubsection = subsectionMap.get(rtL.EYI_Condition_Type__c);
                        rtL.EYI_Amount__c = matchingSubsection.subsectionvalue;
                        rateListToUpdate.add(rtL);
                    }
                }
                system.debug('RateListUpdate' + rateListToUpdate);
                if (!rateListToUpdate.isEmpty()) {
                    update rateListToUpdate;
                }
                // -- End of logic

                Decimal registrationVal = 0;
                Decimal legalCharge = 0;
                system.debug('subSectionOtherList' + subSectionOtherList);
                for(Subsection subSect:subSectionOtherList){
                    system.debug('checking...' + subsect.subsectionName);
                    if(subSect.subsectionName.contains('Registration')){
                        registrationVal = subSect.subsectionvalue;
                    }
                    else if(subSect.subsectionName.contains('Legal Charges')){
                        legalCharge = subSect.subsectionvalue;
                    }
                    else if(subSect.subsectionName.contains('SGST')) {
                        sgst = subSect.subsectionvalue;
                    }
                    else if (subSect.subsectionName.contains('CGST')) {
                        cgst = subSect.subsectionvalue;
                    }
                    else if (subSect.subsectionName.contains('Stamp Duty')) {
                        stampDuty = subSect.subsectionvalue;
                    }
                    else if(subSect.subsectionName.contains('Maintenance Charges')) {
                        maintenanceCharges = subSect.subsectionValue;
                    }
                    else if(subSect.subsectionName.contains('Maintenance Deposit')) {
                        maintenanceDeposit = subSect.subsectionValue;
                    }
                    
                }
                //system.debug('values checking...' + sgst+cgst+stampDuty+legalCharge+infrastructureCharges);
                Decimal basePriceDiscountL;
                Decimal basePriceDiscountPSF;
                Decimal FloorPriceDiscountL;
                Decimal FloorPriceDiscountPSF;
                for(Subsection subSect:subSectioBaseDiscountList){
                    if(subSect.subsectionName.contains('Base Price')){
                        basePriceDiscountL = subSect.subsectionvalue;
                        basePriceDiscountPSF = (subSect.subsectionvalue) / (Inv.EYI_Saleable_Area__c);
                    }else if(subSect.subsectionName.contains('Floor Price')){
                        FloorPriceDiscountL = subSect.subsectionvalue;
                        FloorPriceDiscountPSF = (subSect.subsectionvalue) / (Inv.EYI_Saleable_Area__c);
                    }
                    
                }
                
                Quote quote = new Quote();
                quote.EYI_Quoatation_Grand_Total__c = grandTotal;
                quote.EYI_Agreement_Value__c =agreementValue;
                quote.EYI_Registration_Charges__c=registrationVal;
                quote.EYI_Legal_Charges__c =legalCharge;
                quote.EYI_Infrastructure_charges__c=infrastructureCharges;
                quote.EYI_Inventory__c = inv.id;
                quote.EYI_Discount_Applied__c = discountApplied;
                if(placeholderOpp != null){
                    quote.OpportunityId = placeholderOpp;
                    quote.Name = 'Quotation Placeholder Opportunity';
                }
                else if(selectedOppId != null){
                    //system.debug('opp' + inv.EYI_Opportunity__c);
                    quote.OpportunityId = seloppRec.Id;
                    quote.Name = 'Quotation' +' '+ seloppRec.Name;
                }
                else {
                    //quote.OpportunityId = quoteDetails.OpportunityId;
                    //quote.Name = 'Quotation' +' '+ Opportunity.Name;
                }
                
                quote.EYI_Floor_Rise_PSF__c =floorPriceRisePSF;
                quote.EYI_Base_Rate_PSF__c=basePricePSF;
                quote.EYI_Base_Rate_Discount_L__c =basePriceDiscountL;
                quote.EYI_Base_Rate_Discount_PSF__c =basePriceDiscountPSF;
                quote.EYI_Floor_Rate_Discount_PSF__c =FloorPriceDiscountPSF;
                quote.EYI_Floor_Rate_Discount_L__c = FloorPriceDiscountL;
                quote.Payment_Plan__c = paymentPlanId;
                quote.Central_GST__c = cgst;
                quote.State_GST__c = sgst;
                quote.Stamp_Duty__c = stampDuty;
               	quote.Maintenance_Deposit__c = maintenanceDeposit;
                quote.Maintenance_Charges__c = maintenanceCharges; 
				quote.Base_Charges__c = base;
                //quote.Name = 'Quotation' + inv.EYI_Opportunity__r.Name;
                
                if(quoteId!=null){
                    quote.Id = quoteId;
                    update quote;
                 }else{
                    insert quote;
                }
                qd.id = quote.Id;
                
                                //Creating project charge Applied records
                EYI_Inventory__c invVar = [Select Id, EYI_Project__c,EYI_Tower__c from EYI_Inventory__c
                                        Where Id =:inventoryid Limit 1];

                system.debug('invVar' + invVar);
                Map<String, Project_Charges__c> uniqueRecords = new Map<String, Project_Charges__c>();
                List<Project_Charges__c> pcList = [Select Name, EYI_GST_Percentage__c 
                                                    from Project_Charges__c 
                                                    where (EYI_Project__c=:invVar.EYI_Project__c or EYI_Tower__c=:invVar.EYI_Tower__c) and EYI_Active__c = true  AND EYI_Charge_Type__c = 'Other Charges'];
                    
                system.debug('pcList' + pcList);
                    for (Project_Charges__c pcObj : pcList) {
                        if(uniqueRecords.containsKey(pcObj.Name)) {
                            if(pcObj.EYI_Tower__c != null) {
                                uniqueRecords.put(pcObj.Name, pcObj);
                            }
                            
                        }
                        else {
                                uniqueRecords.put(pcObj.Name, pcObj);
                            }
                    }
                    
                    List<Project_Charges__c> uniqueProjectChargesList = new List<Project_Charges__c>(uniqueRecords.values());
                
                // List<Project_Charges__c> pcList = [Select Name, EYI_GST_Percentage__c from Project_Charges__c
                //     Where EYI_Project__c=:uniqueProjectChargesList and EYI_Active__c = true AND EYI_Charge_Type__c = 'Other Charges'];

                system.debug('pcList' + pcList);
                //system.debug('MaintenanceChargeAmount' + EYI_GetQuotaionValue.MaintenanceChargeAmount);

                List<EYI_Applied_Project_Charge__c> apcTobeInserted = new List<EYI_Applied_Project_Charge__c>();
                //List<EYI_Applied_Project_Charge__c> apcTobeInserted2 = new List<EYI_Applied_Project_Charge__c>();
                //Decimal maintenancetax;
                //Decimal legalChargetax;
                Decimal tax;
                List<EYI_Applied_Project_Charge__c> existingAPC = [Select Id, name from EYI_Applied_Project_Charge__c Where EYI_Quote__c = :quote.Id];
                system.debug('existingAPC' + existingAPC);
                if(!existingAPC.isEmpty()) {
                    try{
                        delete existingAPC;
                    }
                    catch(exception e) {
                        system.debug('Error deleting records'+ e);
                    }
                }

                for(Project_Charges__c pc : pcList) {
                    if(pc.Name == 'Registration Charges'){
                        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
                        apc.name = pc.Name;
                        apc.EYI_Quote__c = quote.Id;
                        apc.EYI_Project_Charges__c = pc.Id;
                        //apc.EYI_Charged_Amount__c = registrationVal;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc);
                    }
                    else if(pc.Name == 'Stamp Duty') {
                        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
                        apc.name = pc.Name;
                        apc.EYI_Quote__c = quote.Id;
                        apc.EYI_Project_Charges__c = pc.Id;
                        //apc.EYI_Charged_Amount__c = stampDuty;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc);
                    }
                    else if(pc.Name == 'Maintenance Deposit') {
                        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
                        apc.name = pc.Name;
                        apc.EYI_Quote__c = quote.Id;
                        apc.EYI_Project_Charges__c = pc.Id;
                        //apc.EYI_Amount__c = maintenanceDeposit;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc);
                    }
                    else if(pc.name == 'Maintenance Charges') {
                        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
                        apc.name = pc.Name;
                        apc.EYI_Quote__c = quote.Id;
                        apc.EYI_Project_Charges__c = pc.Id;
                        //apc.EYI_Amount__c = maintenanceCharges;
                        //tax = getGSTSpilt(pc.EYI_GST_Percentage__c);
                        //apc.EYI_Charged_Amount__c = (maintenanceCharges * tax)/100;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc);
                    }
                    else if(pc.name == 'Legal Charges') {
                        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
                        apc.name = pc.Name;
                        apc.EYI_Quote__c = quote.Id;
                        apc.EYI_Project_Charges__c = pc.Id;
                        //apc.EYI_Amount__c = legalCharge;
                        //tax = getGSTSpilt(pc.EYI_GST_Percentage__c);
                        //apc.EYI_Charged_Amount__c = (legalCharge * tax)/100;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc);
                    }
                    else if(pc.name == 'Basic' || pc.name == 'Tax') {
                        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
                        apc.name = 'State GST';
                        apc.EYI_Quote__c = quote.Id;
                        apc.EYI_Project_Charges__c = pc.Id;
                        apc.EYI_Charged_Amount__c = sgst;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc);

                        EYI_Applied_Project_Charge__c apc1 = new EYI_Applied_Project_Charge__c();
                        apc1.name = 'Central GST';
                        apc1.EYI_Quote__c = quote.Id;
                        apc1.EYI_Project_Charges__c = pc.Id;
                        apc1.EYI_Charged_Amount__c = cgst;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc1);
                    }
                    else{
                        EYI_Applied_Project_Charge__c apc1 = new EYI_Applied_Project_Charge__c();
                        apc1.name = pc.name;
                        apc1.EYI_Quote__c = quote.Id;
                        apc1.EYI_Project_Charges__c = pc.Id;
                        system.debug('inside pc');
                        apcTobeInserted.add(apc1);
                    }
                }
                try{
                    insert apcTobeInserted;
                    //insert apcTobeInserted2;
                }catch(exception e){
                    system.debug('Error in creating Applied Project Charges' + e);
                }


                List<AggregateResult> gstAmountSum = [Select sum(EYI_GST_Amount__c) GSTAmount from EYI_Applied_Project_Charge__c
                                                        Where EYI_Quote__c = :quote.Id ];
                system.debug((Decimal)gstAmountSum[0].get('GSTAmount'));
                Decimal GSTAmount = (Decimal)gstAmountSum[0].get('GSTAmount');

              
                Quote quoteRecord = new Quote(
                    Id = quote.Id,
                    EYI_Quoatation_Grand_Total__c = grandTotal + GSTAmount
                );
                try{
                    //update quoteRecord;
                }
                 catch(exception e) {
                    system.debug('Error updating quote' + e);
                }   
                
                
                return qd;
                
            }
            
            qd.errorMessage = 'Please Pass valid data';
            return qd;
        }catch(exception e){
            quoteData qdError = new quoteData();
            qdError.errorMessage =e.getMessage();
            system.debug('Message-->'+e.getMessage());
            return qdError;
        }
    }
    
    public static EYI_Applied_Project_Charge__c createRecord(string name, string quoteId, string projectChargeId, decimal value) {
        EYI_Applied_Project_Charge__c apc = new EYI_Applied_Project_Charge__c();
        apc.name = name;
        apc.EYI_Quote__c = quoteId;
        apc.EYI_Project_Charges__c = projectChargeId;
        apc.EYI_Charged_Amount__c = value;
        return apc;
    }

    public class quoteData{
       @AuraEnabled public string Id;
        @AuraEnabled public string errorMessage;
    }
    
    public class quotationDiscountValWrapper{
        @AuraEnabled public quotationValWrapper quotationValWrapperVal;
        @AuraEnabled public Decimal baseRatePSFVal;
        @AuraEnabled public Decimal baseRateLSVal;
        @AuraEnabled public Decimal floorRatePSFVal;
        @AuraEnabled public Decimal floorRateLSVal;
        @AuraEnabled public String errorMesage;
    }
    
}