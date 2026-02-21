public class EYI_FutureCalloutClass {
    //Sync Price with SAP
    @future(callout=true)
    public static void pricingDataSync(Set<Id> pricingIds){
        List<EYI_Rate_List__c> PricingList = [select id,EYI_Condition_Type__c,EYI_Project__r.EYI_SAP_Salesorg__c, EYI_Non_Master_Price__c, EYI_Project__r.EYI_SAP_Plant_Code__c, EYI_Pricing_Amount__c,EYI_Pricing_Percentage__c,
                                              EYI_Pricing_Quantity__c,EYI_Calculation_Type__c,EYI_Distruibution_Channel__c,EYI_SAP_Error__c,
                                              EYI_Inventory__r.EYI_SAP_Material_Code__c
                                              from EYI_Rate_List__c where EYI_is_Sync_SAP__c=false AND EYI_Non_Master_Price__c=false and 
                                               Id IN:pricingIds order by createddate asc];
        EYI_PricingCallout.processPricingRecords(PricingList, true);
    }
   
    @future(callout=true)
    public static void inventoryDataSync(Set<Id> inventoryIds ,Boolean IS_StatusChange){
        List<EYI_Inventory__c> inventories = [SELECT id, EYI_Project__r.EYI_SAP_Salesorg__c,EYI_OC_Received_Date__c, EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_SAP_Error__c,
                                              EYI_Inventory_Number__c,EYI_SAP_Material_Type__c,EYI_SAP_Material_Description__c,EYI_TCS_Tax_Classification__c,EYI_GST_Tax_Classification__c,
                                              EYI_Inventory_Type__c,EYI_UOM__c,EYI_Material_Group__c,EYI_Super_Built_up_Area__c, EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c, //EYI_SAP_Plant_Code__c
                                              EYI_Carpet_Area__c,EYI_Garden_Area__c,EYI_Built_up_Area__c,EYI_Common_Area__c,EYI_Terrace_Area__c,EYI_Balcony_Area__c,
                                              EYI_Inventory_Status__c,EYI_Inventory_Floor_No__c, EYI_View_based_on_Directions__c,Configuration__c,EYI_Typology__c, Name,
                                              EYI_View_based_on_Amenities__c ,EYI_Saleable_Area__c, EYI_SAP_Affordable_Type__c,EYI_SAP_Profit_Center__c,EYI_Tower__r.EYI_SAP_Plant_ID__c
                                              FROM EYI_Inventory__c Where id IN: inventoryIds  ];
        EYI_InventorySyncLwcController.processInventoryRecords(inventories, true ,IS_StatusChange);
    } 
    @future(callout=true)
    public static void carParkingDataSync(Set<Id> carparkingIds){
        List<EYI_Car_Park_Master__c> PricingList = [SELECT id,Name,EYI_SAP_Material_Type__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Material_Group__c,  EYI_Base_UOM__c,EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,EYI_SAP_Material_Description__c,
                                             EYI_Project__r.EYI_SAP_Salesorg__c, EYI_Status__c,EYI_Parking_Number__c,EYI_Distruibution_Channel__c,EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_External_Material_Group__c,
                                             EYI_Lab_Office__c,EYI_X_Plant_Mat_Status__c,EYI_Built_up_Area__c,EYI_Floor_Number__c,EYI_SAP_Affordable_Type__c,Configuration__c, EYI_SAP_Profit_Center__c,
                                             EYI_Account_Assignment_Group__c,EYI_Sales_Unit__c,EYI_Item_Category__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c
                                              from EYI_Car_Park_Master__c where
                                               Id IN:carparkingIds order by createddate asc];
        EYI_CarParkingSyncLwcController.processCarparkingRecords(PricingList, true);
    }
}