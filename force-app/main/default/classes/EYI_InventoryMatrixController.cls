/**
 * @description       : EYI_InventoryMatrixController is used to get the Inventory Matrix data
 * @author            : Digambar Ganage
 * @group             : Integration
 * @last modified on  : 03-25-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EYI_InventoryMatrixController {
    /**
     * @use: This method is used to get the projects data
     * @param: None
     * @return: List<EYI_Project__c>
     */
    
    @AuraEnabled
    public static String validateDemandDetails(List<Id> recordIds ){
        
        List<EYI_Demand__c> demandList = [select Id,
                                          EYI_Opportunity__r.EYI_Total_Pending_Booking_Amount_in_Per__c,
                                          EYI_Opportunity__r.EYI_Registration_Status__c, EYI_Opportunity__r.Name
                                          from EYI_Demand__c 
                                          where Id IN :recordIds AND 
                                          (EYI_Opportunity__r.EYI_Total_Pending_Booking_Amount_in_Per__c < 9.99  OR
                                          EYI_Opportunity__r.EYI_Total_Pending_Booking_Amount_in_Per__c = null
                                          OR EYI_Opportunity__r.EYI_Registration_Status__c != 'Registration Completed'
                                          OR EYI_Opportunity__r.EYI_Registration_Status__c = null)];
       
        if (demandList.size() > 0) {
        Set<String> oppNames = new Set<String>();
        for (EYI_Demand__c d : demandList) {
            if (d.EYI_Opportunity__r != null && d.EYI_Opportunity__r.Name != null) {
                oppNames.add(d.EYI_Opportunity__r.Name);
            }
        }
        return String.join(new List<String>(oppNames), ', ');
    }
    return ''; 
       
    }
    @AuraEnabled(cacheable=true)
    public static List<EYI_Project__c> getAllProjects(){
        List<EYI_Project__c> projectList = new List<EYI_Project__c>();
        try {
            projectList = [SELECT Id, Name, EYI_Project_Type__c,EYI_Project_Status__c FROM EYI_Project__c where EYI_Project_Status__c NOT IN ('Inactive', 'Complete','Teaser') WITH SECURITY_ENFORCED ORDER BY Name ASC];
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return projectList;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getPicklistValues2() {
        // Create a map to hold the picklist values
        Map<String, List<String>> picklistValuesMap = new Map<String, List<String>>();
    
        // Get picklist values for EYI_Payment_Status__c
        //sObjectField field = EYI_Payment_Receipt__c.Type;
        Schema.SObjectField paymentStatusField = Schema.SObjectType.EYI_Payment_Receipt__c.fields.getMap().get('EYI_Payment_Status__c');
        Schema.DescribeFieldResult describeFieldResult = paymentStatusField.getDescribe();
        // Schema.DescribeFieldResult paymentStatusFieldDesc = Schema.SObjectType.EYI_Payment_Receipt__c.fields.EYI_Payment_Status__c.getDescribe();
        List<Schema.PicklistEntry> paymentStatusPicklist = describeFieldResult.getPicklistValues();
        List<String> paymentStatusValues = new List<String>();
        for (Schema.PicklistEntry entry : paymentStatusPicklist) {
            paymentStatusValues.add(entry.getLabel()); // or entry.getValue() if you need the API name
        }
        picklistValuesMap.put('EYI_Payment_Status__c', paymentStatusValues);
    
        // Get picklist values for EYI_Mode_of_Payment__c
        Schema.SObjectField paymentStatusField1 = Schema.SObjectType.EYI_Payment_Receipt__c.fields.getMap().get('EYI_Mode_of_Payment__c');
        Schema.DescribeFieldResult describeFieldResult1 = paymentStatusField1.getDescribe();
        // Schema.DescribeFieldResult paymentStatusFieldDesc = Schema.SObjectType.EYI_Payment_Receipt__c.fields.EYI_Payment_Status__c.getDescribe();
        List<Schema.PicklistEntry> modeOfPaymentPicklist = describeFieldResult1.getPicklistValues();
        List<String> modeOfPaymentValues = new List<String>();
        for (Schema.PicklistEntry entry : modeOfPaymentPicklist) {
            modeOfPaymentValues.add(entry.getLabel());
        }
        picklistValuesMap.put('EYI_Mode_of_Payment__c', modeOfPaymentValues);

        // Get picklist values for EYI_Mode_of_Payment__c
        Schema.SObjectField paymentStatusField3 = Schema.SObjectType.EYI_Payment_Receipt__c.fields.getMap().get('EYI_Bank_Name__c');
        Schema.DescribeFieldResult describeFieldResult3 = paymentStatusField3.getDescribe();
        // Schema.DescribeFieldResult paymentStatusFieldDesc = Schema.SObjectType.EYI_Payment_Receipt__c.fields.EYI_Payment_Status__c.getDescribe();
        List<Schema.PicklistEntry> bankNamePicklist = describeFieldResult3.getPicklistValues();
        List<String> bankNameValues = new List<String>();
        for (Schema.PicklistEntry entry : bankNamePicklist) {
            bankNameValues.add(entry.getLabel());
        }
        picklistValuesMap.put('EYI_Bank_Name__c', bankNameValues);
    
        // Get picklist values for EYI_Payment_Type__c
        Schema.SObjectField paymentStatusField2 = Schema.SObjectType.EYI_Payment_Receipt__c.fields.getMap().get('EYI_Transaction_Type__c');
        Schema.DescribeFieldResult describeFieldResult2 = paymentStatusField2.getDescribe();
        // Schema.DescribeFieldResult paymentStatusFieldDesc = Schema.SObjectType.EYI_Payment_Receipt__c.fields.EYI_Payment_Status__c.getDescribe();
        List<Schema.PicklistEntry> paymentTypePicklist = describeFieldResult2.getPicklistValues();
        List<String> paymentTypeValues = new List<String>();
        for (Schema.PicklistEntry entry : paymentTypePicklist) {
            paymentTypeValues.add(entry.getLabel());
        }
        picklistValuesMap.put('EYI_Transaction_Type__c', paymentTypeValues);
    
        // Return the map containing picklist values for each field
        return picklistValuesMap;
    }
    
    
    /*
    @AuraEnabled(cacheable=true)
    public static List<EYI_Demand__c> fetchDemands(String project, String tower, String demandType,string demandStatus,Date billingDateFrom, Date billingDateTo) {//
        system.debug('demandType  '+demandType);
        system.debug('demandStatus  '+demandStatus);
        system.debug('billingDateFrom  '+billingDateFrom);
        system.debug('billingDateTo  '+billingDateTo);
        


        List<EYI_Demand__c> demands = [ 
            SELECT Id, name, EYI_Amount_to_be_paid__c,EYI_Demand_Status__c,EYI_Usage__c,EYI_Billing_Date__c,EYI_SAP_Milestone_Code__c,
            EYI_Opportunity__r.EYI_SAP_Customer_Number__c,EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c, EYI_Opportunity__r.StageName,EYI_Opportunity__r.name,
            EYI_Booking__r.EYI_SAP_Sales_Order_Number__c,EYI_SAP_Demand_Number__c
            FROM EYI_Demand__c
            WHERE (EYI_Project__c =:project)
            AND (EYI_Tower__c =:tower)
            AND (EYI_Demand_Type__c =:demandType)
            AND (EYI_Demand_Status__c=: demandStatus)
           AND (EYI_Billing_Date__c >=:billingDateFrom) // Change this to actual date
           AND (EYI_Billing_Date__c <=:billingDateTo)
           //Add demand letter api related fields here
        ];
         system.debug('demands  '+demands);
        return demands;
       
    } */
    @AuraEnabled(cacheable=true)
    public static List<EYI_Demand__c> fetchDemands(
        String project,
        String usageDescription,
        String tower,
        String demandType,
        String demandStatus,
        Date billingDateFrom,
        Date billingDateTo,
        String customerNumber
    ) {
        
        if(customerNumber != null){
        	 List<String> customerList = customerNumber.split(',');
        	Set<String> customerSet = new Set<String>(customerList);
        	  
        }
       
        Set<String> towerName = new Set<String>();
        if(project != 'All'){
            List<EYI_Tower__c> towerNameList = [select id,EYI_Project_Name__c from EYI_Tower__c where EYI_Project_Name__c = :project ];
            for(EYI_Tower__c twName: towerNameList){
                towerName.add(twName.Id);
            }
        }
    
        String baseQuery = 'SELECT Id, Name, EYI_ESIGN_FLAG__c, EYI_Usage_Description__c,EYI_Amount_to_be_paid__c, EYI_Demand_Cancellation_Number__c, EYI_Demand_Status__c, EYI_Usage__c,EYI_Actual_Date__c, EYI_Billing_Date__c, EYI_SAP_Milestone_Code__c, ' +
                           'EYI_Opportunity__r.EYI_SAP_Customer_Number__c, EYI_Opportunity__r.EYI_Billing_Block__c, EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c, ' +
                           'EYI_Opportunity__r.StageName, EYI_Opportunity__r.Name,EYI_Opportunity__r.EYI_Total_Pending_Booking_Amount_in_Per__c, EYI_Opportunity__r.EYI_Registration_Status__c, ' +
                           'EYI_Booking__r.EYI_SAP_Sales_Order_Number__c, EYI_SAP_Demand_Number__c ' +
                           'FROM EYI_Demand__c WHERE EYI_Opportunity__r.EYI_Billing_Block__c != true '; 
                           if (project != 'All') {
                            baseQuery += ' AND EYI_Project__c = :project ';
                            } else {
                                baseQuery += ' AND EYI_Project__c != \'\' ';
                            }
                            if (tower != 'All' ) {
                                baseQuery += ' AND EYI_Tower__c = :tower ';
                            } else if(tower == 'All' && project != 'All') {

                                baseQuery += ' AND EYI_Tower__c IN :towerName ';
                            }else{
                                baseQuery += ' AND EYI_Tower__c != \'\'  ';
                            }
                            
                            if (demandStatus == 'Demand Raised'  ) {
                               baseQuery += 'AND EYI_Demand_Status__c = :demandStatus ' +
                                'AND EYI_ESIGN_FLAG__c = true ';
                            } else{
                                //baseQuery += 'AND EYI_Demand_Type__c = :demandType ' ;
                                baseQuery += 'AND EYI_Demand_Status__c = :demandStatus ';
                            } 
        					if (demandType != 'All') {
                            baseQuery += ' AND EYI_Demand_Type__c = :demandType ';
                            } else {
                                baseQuery += ' AND EYI_Demand_Type__c != \'\' ';
                            }
                            if (usageDescription != 'All') {
                            baseQuery += ' AND EYI_Usage_Description__c = :usageDescription ';
                            } else {
                                baseQuery += ' AND EYI_Usage_Description__c != \'\' ';
                            }
                            baseQuery += 'AND EYI_Demand_Status__c = :demandStatus ' ;
                            //baseQuery += 'AND EYI_Demand_Type__c = :demandType '   ;   
                           
        if(customerNumber != null){
            baseQuery += 'AND EYI_Opportunity__r.EYI_SAP_Customer_Number__c = :customerSet '   ;
        }
        if (billingDateFrom != null && billingDateTo != null) {
            baseQuery += 'AND EYI_Actual_Date__c >= :billingDateFrom ';
            baseQuery += 'AND EYI_Actual_Date__c <= :billingDateTo ';
            //baseQuery += 'AND EYI_Actual_Date__c';

        } else {
            Date today = Date.today();
            baseQuery += 'AND EYI_Actual_Date__c <= :today ';
            
            //system.debug('EYI_Actual_Date__c : '+ EYI_Actual_Date__c);
        }
     
    
        List<EYI_Demand__c> demands = Database.query(baseQuery);
        return demands;
    }


   /**
     * @use: This method is used to get the subprojects data
     * @param: None
     * @return: List<EYI_SubProject__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<EYI_SubProject__c> getAllSubProjects(){
        List<EYI_SubProject__c> subProjectList = new List<EYI_SubProject__c>();
        try{
            subProjectList = [SELECT Id, Name, EYI_Project_Name__c FROM EYI_SubProject__c WITH SECURITY_ENFORCED ORDER BY Name ASC];
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return subProjectList;
    }

    @AuraEnabled(cacheable=true)
    public static String getAllInventoryColorCode(){
         // Retrieve the List Custom Setting using the 'getValues' method
         Inventory_Color_Mapping__c customSetting = Inventory_Color_Mapping__c.getOrgDefaults();// 'default' is an example, use your setting instance name
         return customSetting.StatusWithColor__c;  // Returns the value of the Settings_Field__c
    }
    
    /**
     * @use: This method is used to get the subprojects data
     * @param: None
     * @return: List<EYI_SubProject__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<EYI_Tower__c> getAllTowers(){
        List<EYI_Tower__c> towerList = new List<EYI_Tower__c>();
        try{
            towerList = [SELECT Id, Name,EYI_SubProject_Name__c, EYI_Project_Name__c FROM EYI_Tower__c WITH SECURITY_ENFORCED ORDER BY Name ASC];
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return towerList;
    }
    /**
     * @use: This method is used to get the Inventory data
     * @param: None
     * @return: List<EYI_Inventory__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<EYI_Inventory__c> getAllFloors(){
        List<EYI_Inventory__c> inventoryList = new List<EYI_Inventory__c>();
        try{
            inventoryList = [SELECT Id,EYI_Floor_No__c,EYI_Project__c,EYI_SubProject__c,EYI_Tower__c	 FROM EYI_Inventory__c WITH SECURITY_ENFORCED ORDER BY Name ASC];
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return inventoryList;
    }
   
    public class TokenInfo {
        @AuraEnabled public Decimal totalTokenAmount;
        @AuraEnabled public String sapCustomerNumber;

        public TokenInfo(Decimal totalTokenAmount, String sapCustomerNumber) {
            this.totalTokenAmount = totalTokenAmount;
            this.sapCustomerNumber = sapCustomerNumber;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getTotalTokenAmt(String oppId){
       
        
        List<EYI_Payment_Receipt__c> getAllPR = [
            SELECT Id, EYI_Amount__c 
            FROM EYI_Payment_Receipt__c 
            WHERE EYI_Opportunity__c = :oppId
        ];

        List<Opportunity> getOppData = [
            SELECT EYI_SAP_Customer_Number__c 
            FROM Opportunity 
            WHERE Id = :oppId
        ];

        Decimal totalTokenAmtReceived = 0;
        String sapCustomerNumber = '';

        for (EYI_Payment_Receipt__c pr : getAllPR) {
            totalTokenAmtReceived += pr.EYI_Amount__c;
        }
        return totalTokenAmtReceived;
        //return new TokenInfo(totalTokenAmtReceived, sapCustomerNumber);
        
    }
    /**
     * @use: This method is used to get the Opportunity data
     * @param: None
     * @return: List<Opportunity>
     */  
    @AuraEnabled(cacheable=false)
    public static List<Opportunity> getOpptyProjects(string oppId){
        List<Opportunity> opptyList = new List<Opportunity>();
        try{
            opptyList = [SELECT Name, EYI_Project_Tower_Enquired__c,EYI_SAP_Customer_Number__c, EYI_Project_Enquired__c, EYI_Project_Enquired__r.name
            , EYI_Project_Tower_Enquired__r.name, EYI_Project_Enquired__r.EYI_Project_Type__c, EYI_SubProject_Name__c,EYI_SubProject_Name__r.Name FROM Opportunity WHERE Id=:oppId ];
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return opptyList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EYI_Inventory_Color_Mapping2__mdt> getPicklistConfig() {
        // Query Custom Setting records (replace 'PicklistConfig__c' with your Custom Setting name)
        List<EYI_Inventory_Color_Mapping2__mdt> configs = [
            SELECT EYI_Label__c, EYI_IconName__c, EYI_ClassName__c 
            FROM EYI_Inventory_Color_Mapping2__mdt
        ];
        return configs;
    }
    /**
     * @use: This method is used to get the Inventory data for inventroy matrix page based on Filters
     * @param: None
     * @return: List<EYI_Inventory__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<EYI_Inventory__c> getFilterdInventoryData(String jsonParams) {
        String unitStatusCondition = '';
        String unitViewCondition = '';
        String query ='';
        List<EYI_Inventory__c> inventoryList = new List<EYI_Inventory__c>();
        ProjectDataWrapper params = (ProjectDataWrapper) JSON.deserialize(jsonParams, ProjectDataWrapper.class);

        String selectedProjectType = params.selectedProjectType;
        String selectedProject = params.selectedProject;
        String selectedSubProject = params.selectedSubProject;
        String selectedTower = params.selectedTower;
        String selectedFloor = String.valueOf(params.selectedFloor);
        List<String> selectedUnitStatus = params.selectedUnitStatus;
        List<String> selectedUnitView = params.selectedUnitView;
        
        
        // Add unit status condition
        if (selectedUnitStatus != null && selectedUnitStatus.size() > 0) {
            unitStatusCondition = 'EYI_Inventory_Status__c IN :selectedUnitStatus';
        }
        // Add unit view condition
        if (selectedUnitView != null && selectedUnitView.size() > 0) {
            unitViewCondition = 'EYI_View_based_on_Amenities__c IN :selectedUnitView';
        }
        // Construct a SOQL query based on the parameters
        query = 'SELECT Id, Name, EYI_Opportunity__c ,EYI_Opportunity__r.Owner.Name,EYI_Opportunity__r.Owner.Id,EYI_Opportunity__r.Owner.ManagerId,EYI_Opportunity__r.Name ,EYI_Floor_No__c, EYI_Project__c,EYI_Project__r.EYI_Project_Property_Type__c,EYI_Project__r.EYI_Minimum_Token_Amount__c, EYI_Carpet_Area__c, EYI_SubProject__c, EYI_Tower__c,EYI_Typology__c, '+
        ' EYI_Inventory_Status__c,EYI_Saleable_Area__c,EYI_Two_Wheeler_Count__c,Remarks_for_Block__c,EYI_Car_Park_Count__c, EYI_View_based_on_Amenities__c  FROM EYI_Inventory__c WHERE ';
        
        // Append conditions to query
        if (selectedProjectType != null && selectedProjectType != '') {
            query += 'EYI_Project__r.EYI_Project_Type__c = :selectedProjectType AND ';
        }
        if (selectedProject != null && selectedProject != '') {
            query += 'EYI_Project__c = :selectedProject AND ';
        }
        if (selectedSubProject != null && selectedSubProject != '') {
            query += 'EYI_SubProject__c = :selectedSubProject AND ';
        }
        if (selectedTower != null && selectedTower != '') {
            query += 'EYI_Tower__c = :selectedTower AND ';
        }
        // if (selectedFloor != null && selectedFloor != '') {
        //     Integer floor = Integer.valueOf(selectedFloor);
        //     query += 'EYI_Floor_Number__c = :floor AND ';
        // }
        if (unitStatusCondition != '' && unitViewCondition != '') {
            query += '(' + unitStatusCondition + ' OR ' + unitViewCondition + ') AND ';
        } else if (unitStatusCondition != '') {
            query += unitStatusCondition + ' AND ';
        } else if (unitViewCondition != '') {
            query += unitViewCondition + ' AND ';
        }
        // Remove trailing 'AND '
        if (query.endsWith(' AND ')) {
            query = query.substring(0, query.length() - 5 ) + ' Order By Name';
        }
        
        try{
            inventoryList = Database.query(query);
        } catch (Exception e) {
            System.debug('Error retrieving projects: ' + e.getMessage());
        }
        return inventoryList;
    }
    @AuraEnabled
    public static String savePaymentSchedules(List<EYI_Payment_Receipt__c> paymentSchedules) {
        if (paymentSchedules == null || paymentSchedules.isEmpty()) {
            return 'No payment schedules to save.';
        }

        try {
            // Insert the payment schedules into the database
            insert paymentSchedules;
            return 'Payment schedules saved successfully.';
        } catch (DmlException e) {
            // Handle any exceptions that occur during the insert operation
            return 'Error saving payment schedules: ' + e.getMessage();
        }
    }
    /**
     * @use: This Class is used to desrialise the JSON form Invetory matrix UI 
     * @param: None
     * @return: 
     */
    public class ProjectDataWrapper {
        public String selectedProjectType;
        public String selectedProject;
        public String selectedSubProject;
        public String selectedTower;
        public String selectedFloor;
        public List<String> selectedUnitStatus;
        public List<String> selectedUnitView;
    }
    @AuraEnabled
    public static List<EYI_Demand__c> getDemandDetails(List<Id> recordIds){
       
        List<EYI_Demand__c> demandList = [select Id, EYI_Billing_Date__c,EYI_Demand_Type__c,
                                          EYI_Opportunity__r.Name,EYI_Actual_Date__c,
                                          EYI_SAP_Milestone_Code__c,EYI_Usage_Description__c 
                                          from EYI_Demand__c where Id IN :recordIds ];
       
       return demandList;
    }
    @AuraEnabled
    public static boolean blockInventory(String invId, String blockReason,String status){
        boolean success = false;
        if ((invId != null && invId != '') && (blockReason != null && blockReason != '')) {
            EYI_Inventory__c inv = new EYI_Inventory__c(Id = invId);
            if(status == 'Blocked'){
                inv.Remarks_for_Block__c = blockReason;
            }else{
                inv.Remarks_for_Block__c = '';
            }
            inv.EYI_Inventory_Status__c = status;
            inv.EYI_AutomationBypassDatetime__c = System.now();
            try {
                update inv;
                success = true;
            } catch (DmlException e) {
                success = false;
            }
        }
        return success;
    }
    
    //@Future(callout= true)
    /*
    public static String updateMultipleDemands(Map<Id,Date> demandDataMap , String Action) {
        String response ='';
        ParsedItemWrapper parseItemWrapper =  new ParsedItemWrapper();
        try {
            String apiResponse;
            String type ='';
            List<String> typeList = new List<String>();
            Map<String,Id> denamdIdMap = new Map<String,Id>();
            System.debug('demanSetid===> '+ demandDataMap.keySet());
            System.debug('demandDataMap===> '+ demandDataMap);
            System.debug('Action===>'+Action);

             List<EYI_Demand__c> demandsToUpdate = [SELECT Id, EYI_Billing_Date__c, EYI_Opportunity__r.EYI_Distribution_Channel__c, EYI_IsOtherChargeDemand__c, EYI_SAP_Demand_Number__c,EYI_Demand_Cancellation_Number__c,
                                                   EYI_Opportunity__r.EYI_SAP_Customer_Number__c, EYI_Booking__r.EYI_SAP_Sales_Order_Number__c, EYI_Project__r.EYI_SAP_Salesorg__c,
                                                   EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c, EYI_Actual_Date__c, EYI_Amount_to_be_paid__c, EYI_Usage__c, EYI_Usage_Description__c, EYI_SAP_Milestone_Code__c 
                                                    FROM EYI_Demand__c 
                                                    WHERE Id IN :demandDataMap.keySet()];
            System.debug('demandsToUpdate===>'+demandsToUpdate);
            for(EYI_Demand__c demand : demandsToUpdate){
                String Key = demand.EYI_Opportunity__r.EYI_SAP_Customer_Number__c+demand.EYI_Booking__r.EYI_SAP_Sales_Order_Number__c+demand.EYI_Usage__c;
                denamdIdMap.put(key,demand.Id);
            }
            if (!demandsToUpdate.isEmpty()) { 
                HttpResponse res = EY_SAP_Gateway.blockDemandCall(demandDataMap, demandsToUpdate, Action);
                apiResponse = res.getBody();
                System.debug('apiResponse123===>'+res.getStatusCode());
                System.debug('Response --> '+ res.getBody());
                if(res.getStatusCode() == 200){
                    parseItemWrapper = extractTypesFromResponse(apiResponse,action);
                    system.debug('parseItemWrapper --> '+ parseItemWrapper);
                    if(denamdIdMap!=null && denamdIdMap.size()>0 && demandDataMap != null && demandDataMap.size()>0)
                    {
                        updateDemands(denamdIdMap, demandDataMap,parseItemWrapper.parsedItems);
                    }
                    response = parseItemWrapper.message;   
                }else{
                    response = apiResponse;
                }
                System.debug('apiResponse12===>'+apiResponse);
                System.debug('apiResponse11===>'+response);
                //return 'Success';
               // return response;
            }
            return response;
           //return 'Success';
        } catch (Exception e) {
            system.debug('e.getMessage() ==  '+e.getMessage());
             system.debug('e.getlinenumber() ==  '+e.getlinenumber());
            // throw new AuraHandledException('Error updating demands: ' + e.getMessage());
            response ='Error: '+ e.getMessage();
        }
         System.debug('apiResponse23===>'+response);
        return response;
        //return 'Success';

    }
    */
    public static String updateMultipleDemands(Map<Id, Date> demandDataMap, String Action) {
        String response = '';
        List<String> errorResponses = new List<String>();
        List<String> successMessages = new List<String>();
    
        try {
            // 1. Query Demands
            List<EYI_Demand__c> allDemands = [
                SELECT Id, EYI_Billing_Date__c, EYI_Opportunity__r.EYI_Distribution_Channel__c,
                    EYI_IsOtherChargeDemand__c, EYI_SAP_Demand_Number__c, EYI_Demand_Cancellation_Number__c,
                    EYI_Opportunity__r.EYI_SAP_Customer_Number__c, EYI_Booking__r.EYI_SAP_Sales_Order_Number__c,
                    EYI_Project__r.EYI_SAP_Salesorg__c, EYI_Opportunity__r.EYI_Inventory__r.EYI_Inventory_Number__c,
                    EYI_Actual_Date__c, EYI_Amount_to_be_paid__c, EYI_Usage__c, EYI_Usage_Description__c,
                    EYI_SAP_Milestone_Code__c 
                FROM EYI_Demand__c 
                WHERE Id IN :demandDataMap.keySet()
            ];
            
    
            // 2. Chunk & Process
            Integer chunkSize = 5;
            Integer totalSize = allDemands.size();
            Integer chunkIndex = 0;
    
            while (chunkIndex < totalSize) {
                List<EYI_Demand__c> chunk = new List<EYI_Demand__c>();
                for (Integer j = 0; j < chunkSize && (chunkIndex + j) < totalSize; j++) {
                    chunk.add(allDemands[chunkIndex + j]);
                }
                chunkIndex += chunk.size();
    
                if (chunk.isEmpty()) continue;
    
                Map<String, Id> chunkKeyMap = new Map<String, Id>();
                for (EYI_Demand__c demand : chunk) {
                    String key = (demand.EYI_Opportunity__r != null && demand.EYI_Opportunity__r.EYI_SAP_Customer_Number__c != null
                                    ? demand.EYI_Opportunity__r.EYI_SAP_Customer_Number__c : '') +
                                (demand.EYI_Booking__r != null && demand.EYI_Booking__r.EYI_SAP_Sales_Order_Number__c != null
                                    ? demand.EYI_Booking__r.EYI_SAP_Sales_Order_Number__c : '') +
                                (demand.EYI_Usage__c != null ? demand.EYI_Usage__c : '');
                    chunkKeyMap.put(key, demand.Id);
                }
                HttpResponse res = EY_SAP_Gateway.blockDemandCall(demandDataMap, chunk, Action);
                String apiResponse = res.getBody();
                
    		
                if (res.getStatusCode() == 200) {
                    ParsedItemWrapper parseItemWrapper = extractTypesFromResponse(apiResponse, Action);
                    if (!chunkKeyMap.isEmpty() && !demandDataMap.isEmpty()) {
                        updateDemands(chunkKeyMap, demandDataMap, parseItemWrapper.parsedItems);
                    }
                    successMessages.add(parseItemWrapper.message);
                } else {
                    errorResponses.add('Chunk failed with status ' + res.getStatusCode() + ': ' + apiResponse);
                }
            }
    
            // 3. Final response aggregation
            if (!successMessages.isEmpty()) {
                response = 'SUCCESS: ' + String.join(successMessages, ' | ');
            }
            if (!errorResponses.isEmpty()) {
                response += '\nERRORS: ' + String.join(errorResponses, ' | ');
            }
    
        } catch (Exception e) {
            response = 'Exception: ' + e.getMessage() + ' (Line: ' + e.getLineNumber() + ')';
            System.debug('Exception: ' + e);
        }
    
        
        return response;
    }
    
    @AuraEnabled
    public static String raiseDemandsFromLWC(List<Id> demandIds, String Action) {
        
        String response ='';

        Map<Id, Date> emptyDateMap = new Map<Id, Date>();
        for (Id id : demandIds) {
            emptyDateMap.put(id, Date.today());
        }
        boolean isBatch = false;
        if(demandIds.size()>5){
            // Invoke asynchronous batch class
            Integer chunkSize = 5; 
            DemandCalloutBatch batch = new DemandCalloutBatch(emptyDateMap, Action, chunkSize);
            Database.executeBatch(batch, chunkSize);

            return 'Demand processing has been initiated. You’ll be notified once it completes.';
        }else{
            //Set<Id> demandSet = new Set<Id>(demandIds); 
            response = updateMultipleDemands(emptyDateMap, Action); 
            return response;
        }
    }

    
    @AuraEnabled
    public static String saveDemand(List<EYI_Demand__c> demanddatalist ,String Action) {
        Set<id> Demansetid = new Set<id>();
        Set<id> demandId = new Set<id>();
        Map<Id,Date> demandDateMap = new Map<Id,Date>();
        String response = '';
        String returnValue = '';
        
        //List<EYI_Demand__c> updatedemanddatalist = new List<EYI_Demand__c>();
        try {
            if (!demanddatalist.isEmpty()) {
				/*
                for(EYI_Demand__c dmD: demanddatalist){
                    dmD.EYI_SAP_Milestone_Code__c ='00';
                    updatedemanddatalist.add(dmD);
                }*/
                // Use Database.update with `false` to allow partial success
                for(EYI_Demand__c dmD: demanddatalist){
                    demandId.add(dmD.Id);
                    demandDateMap.put(dmD.Id,dmD.EYI_Actual_Date__c);
                }
               
                response =  updateMultipleDemands(demandDateMap ,Action);
               
                if(response == 'Success'){
                    Database.SaveResult[] results = Database.update(demanddatalist, false);
                
                // Loop through results to check for errors
                    for (Integer i = 0; i < results.size(); i++) {
                        if (!results[i].isSuccess()) {
                            for (Database.Error err : results[i].getErrors()) {
                                System.debug('Error updating record Id: ' + demanddatalist[i].Id + ' - ' + err.getMessage());
                            }
                            returnValue = 'Error while submitting record';
                        }Else{
                            Demansetid.add(results[i].getid());
                            returnValue =  'Record updated successfully';
                        }
                    }
                }else{
                    returnValue = response;
                }
            }
                
        } catch (Exception e) {
             system.debug('e.getMessage() ==  '+e.getMessage());
             system.debug('e.getlinenumber() ==  '+e.getlinenumber());
            returnValue =  'Error while submittin record:' + e.getMessage(); 
           // throw new AuraHandledException(e.getMessage());
             
        }
        return returnValue;
    }
    
    public static void updateDemands(Map<String,Id> demandMap, Map<Id,Date> demandDataMap, List<ParsedItem> parsedItemList) {
        
        List<EYI_Demand__c> demandList =  new List<EYI_Demand__c>();
        for(ParsedItem item: parsedItemList){
            
            EYI_Demand__c demand = new EYI_Demand__c();
            String Key = item.KUNNR+item.VBELN+item.MLBEZ;
            
            String Action = item.Action;
            if(item.TYPE == 'S'){
                if(Action == 'RAISE'){
                    
                    demand.EYI_Demand_Status__c = 'Demand Raised';
                    demand.EYI_Demand_Raise_Date__c = Date.today();
                    demand.EYI_SAP_Demand_Number__c = item.VBELN_VF;
                    if(item.CUSTOM1 == 'X'){
                        demand.EYI_ESIGN_FLAG__c = TRUE;
                    }

                }else if(Action == 'SENT'){
                    demand.EYI_Demand_Status__c = 'Demand Sent';
                    demand.EYI_Demand_Send_Date__c = Date.today();
                }else  if(Action == 'CANCEL'){
                    demand.EYI_Demand_Status__c = 'Demand Cancelled';
                    demand.EYI_Demand_Cancel_date__c = Date.today();
                    demand.EYI_Demand_Cancellation_Number__c = item.CUSTOM1 ;
                }else if(Action == 'BLOCK'){
                    demand.EYI_Demand_Type__c = 'Time Bound';
                    demand.EYI_Milestone_Block_Date__c = Date.today();
                    if(demandMap.containsKey(Key)  && demandDataMap.containsKey(demandMap.get(key))){
                        demand.EYI_Actual_Date__c = demandDataMap.get(demandMap.get(key));
                    }
                }
            }
           
          
            if(demandMap.containsKey(Key)  ){
               
                demand.id = demandMap.get(key);
                demandlist.add(demand);
            }
        }
        
        if(demandList.size()>0){
            try {
               
                update demandList;
            } catch (Exception e) {
                
                System.debug('Error==>'+e.getMessage());
            }             
        }
    }

    public static ParsedItemWrapper extractTypesFromResponse(String jsonResponse,String Action) {
        //List<String> types = new List<String>();
        ParsedItemWrapper itemWrapper = new ParsedItemWrapper();
        List<ParsedItem> parsedItemList = new List<ParsedItem>();
        ParsedItem itemVal;
        String message ='';
        try {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            Map<String, Object> response = (Map<String, Object>) root.get('n0:ZSD_DEMAND_FROM_SFResponse');
            Map<String, Object> exOutput = (Map<String, Object>) response.get('EX_OUTPUT');

            Object itemObj = exOutput.get('item');

            if (itemObj instanceof List<Object>) {
                for (Object entry : (List<Object>) itemObj) {
                    Map<String, Object> itemMap = (Map<String, Object>) entry;
                    itemVal = new ParsedItem();
                    itemVal.Action = Action;
                    /*if(Action == 'CANCEL'){
                        if (itemMap.containsKey('CUSTOM1')) {
                            itemVal.CUSTOM1 = (String)itemMap.get('CUSTOM1');
                        }
                    }*/
                    if (itemMap.containsKey('CUSTOM1')) {
                    	itemVal.CUSTOM1 = (String)itemMap.get('CUSTOM1');
                    }
                    if (itemMap.containsKey('MSGTYPE')) {
                       itemVal.TYPE = (String)itemMap.get('MSGTYPE');
                    }
                    if (itemMap.containsKey('KUNNR')) {
                        itemVal.KUNNR = (String)itemMap.get('KUNNR');
                    }
                    if (itemMap.containsKey('VBELN')) {
                        itemVal.VBELN = (String)itemMap.get('VBELN');
                    }
                    if (itemMap.containsKey('MLBEZ')) {
                        itemVal.MLBEZ = (String)itemMap.get('MLBEZ');
                    }
                    if (itemMap.containsKey('MLBEZ')) {
                        itemVal.MLBEZ = (String)itemMap.get('MLBEZ');
                    }
                    if (itemMap.containsKey('VBELN_VF')) {
                        itemVal.VBELN_VF = (String)itemMap.get('VBELN_VF');
                    }
                    if (itemMap.containsKey('MESSAGE')) {
                        if((String)itemMap.get('MSGTYPE') == 'E'){
                            message = '   Error: ';
                        }
                        message += (itemMap.get('KUNNR') != null ? (String)itemMap.get('KUNNR') : '') 
                            + ':' 
                            + (itemMap.get('MESSAGE') != null ? (String)itemMap.get('MESSAGE') : '') 
                            ;
                    }
                    parsedItemList.add(itemVal);
                }
            } else if (itemObj instanceof Map<String, Object>) {
                Map<String, Object> itemMap = (Map<String, Object>) itemObj;
                itemVal = new ParsedItem();
                itemVal.Action = Action;
                //if(Action == 'CANCEL'){
                    if (itemMap.containsKey('CUSTOM1')) {
                        itemVal.CUSTOM1 = (String)itemMap.get('CUSTOM1');
                    }
               // }
                if (itemMap.containsKey('MSGTYPE')) {
                   itemVal.TYPE = (String)itemMap.get('MSGTYPE');
                }
                if (itemMap.containsKey('KUNNR')) {
                    itemVal.KUNNR = (String)itemMap.get('KUNNR');
                }
                if (itemMap.containsKey('VBELN')) {
                    itemVal.VBELN = (String)itemMap.get('VBELN');
                }
                if (itemMap.containsKey('VBELN_VF')) {
                    itemVal.VBELN_VF = (String)itemMap.get('VBELN_VF');
                }
                if (itemMap.containsKey('MLBEZ')) {
                    itemVal.MLBEZ = (String)itemMap.get('MLBEZ');
                }
                if (itemMap.containsKey('MESSAGE')) {
                    if((String)itemMap.get('MSGTYPE') == 'E'){
                        message = 'Error: ';
                    }
                    message += (itemMap.get('KUNNR') != null ? (String)itemMap.get('KUNNR') : '') 
                    + ' : ' 
                    + (itemMap.get('MESSAGE') != null ? (String)itemMap.get('MESSAGE') : '') 
                    ;
                }
                parsedItemList.add(itemVal);
            }
            itemWrapper.message = message;
            itemWrapper.parsedItems = parsedItemList;
        } catch (Exception e) {
            System.debug('Error parsing JSON: ' + e.getMessage());
        }
        
        return itemWrapper;
    }

    public class ParsedItem {
        public String KUNNR;
        public String VBELN;
        public String MLBEZ;
		public String VBELN_VF;// SapBillingDocNumber
        public String TYPE;
        public String CUSTOM1;
        public String Action; // You can add logic later to populate this
    }
    
    public class ParsedItemWrapper {
        public List<ParsedItem> parsedItems;
        public String message;
    }
}