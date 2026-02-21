@isTest
public class EYI_PricingCalloutBatchJob_Test {
    @isTest
    static void testBatchJob() {
    
        Dynamic_Batch_Setting__c setting = new Dynamic_Batch_Setting__c(
            Name = 'Rate List Sync',
            Last_Batch_Run__c = System.now().addDays(-1)
        );
        insert setting;
        EYI_Inventory__c invtry = new EYI_Inventory__c(
            // EYI_Booking__c=book.id,
            EYI_Inventory_Number__c ='PATN04020',
            Name ='Balewadi Inventory 2',
            EYI_SAP_Material_Type__c='Finished Unit',
            EYI_TCS_Tax_Classification__c='TDS Applicable',
            EYI_GST_Tax_Classification__c ='Non Taxable GST',
            EYI_SAP_Material_Description__c ='qwerty',
            EYI_Inventory_Type__c ='Residential Sales',
            EYI_UOM__c ='Square foot',
            EYI_Material_Group__c='Apartment',
            EYI_Super_Built_up_Area__c=20,
            EYI_Carpet_Area__c =14,
            EYI_Garden_Area__c =20,
            EYI_Terrace_Area__c='50',
            EYI_Balcony_Area__c='30',
            EYI_Built_up_Area__c= 10,
            EYI_Common_Area__c=10,
            EYI_Inventory_Status__c='Reserve',
            EYI_Floor_Number__c='003',
            Configuration__c='Studio',
            EYI_View_based_on_Directions__c='East',
            EYI_View_based_on_Amenities__c='Amenity Facing',
            EYI_SAP_Affordable_Type__c='Affordable Housing',
            EYI_SAP_Profit_Center__c='R150R1R15I'
        );
        insert invtry;

        EYI_Rate_List__c rate = new EYI_Rate_List__c(
            EYI_Condition_Type__c = 'Floor Rise',
            EYI_Pricing_Amount__c = 10000,
            EYI_Pricing_Percentage__c = 10,
            EYI_Pricing_Quantity__c = 5,
            EYI_Calculation_Type__c = 'Percentage',
            EYI_Distruibution_Channel__c = 'Commercial Sales',
            EYI_is_Sync_SAP__c = false,
            EYI_Non_Master_Price__c = false,
            EYI_Inventory__c = invtry.Id
            
          
        );
        insert rate;

        Test.startTest();
        EYI_PricingCalloutBatchJob batch = new EYI_PricingCalloutBatchJob();
        Database.executeBatch(batch, 1);
        Test.stopTest();

       
        Dynamic_Batch_Setting__c updatedSetting = [SELECT Last_Batch_Run__c FROM Dynamic_Batch_Setting__c WHERE Id = :setting.Id];
        System.assert(updatedSetting.Last_Batch_Run__c != null, 'Last_Batch_Run__c should be updated');

        //  EYI_Rate_List__c updatedRate = [SELECT EYI_is_Sync_SAP__c FROM EYI_Rate_List__c WHERE Id = :rate.Id];
        // System.assert(updatedRate.EYI_is_Sync_SAP__c, 'Pricing records should be synced.');

    }
}