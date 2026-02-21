/**
* @File Name : QuotationPageController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : January 22, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 22, 2025 |   | Initial Version
**/

public class QuotationPageController {


@AuraEnabled(cacheable=true)
public static List<Object> searchRecords(string searchKey,string objName) {
    list<Object> lstobj ;
    if(objName=='opportunity'){
        if(searchKey!=null){
        lstobj = [SELECT Id, Name FROM Opportunity Where Name LIKE :('%' + searchKey + '%')  ORDER BY CreatedDate DESC LIMIT 5 ];
        }else{
        lstobj = [SELECT Id, Name FROM Opportunity ORDER BY CreatedDate DESC  LIMIT 5];     
        }
    }
        if(objName=='project'){
        if(searchKey!=null){
        lstobj = [select id,name from EYI_Project__c where NAME  LIKE :('%' + searchKey + '%')
        ORDER BY CreatedDate DESC LIMIT 4];
        }  else{
        lstobj = [SELECT Id, Name FROM EYI_Project__c ORDER BY CreatedDate DESC LIMIT 4 ];     
        }
        }

        if(objName=='plantype'){
            if(searchKey!=null){
        lstobj = [select id,name from Payment_Plan__c  where NAME  LIKE :('%' + searchKey + '%')  ORDER BY CreatedDate DESC ];
        }
        else{
        lstobj = [SELECT Id, Name FROM Payment_Plan__c ORDER BY CreatedDate DESC ];     
        }
        }
        system.debug(lstobj);
        return lstobj;
}

@Auraenabled(cacheable=true)
public static list<Payment_Plan__c> getPlanType(String projId,String towerId){
	system.debug('projid' + projId);
      list<Payment_Plan__c>  lstplan = [select id,name from Payment_Plan__c Where Project__c = :projId AND Tower__c = :towerId AND EYI_Is_Extended__c = false AND EYI_Is_Active__c = true
         ORDER BY CreatedDate DESC];
       return lstplan;
    
}

@AuraEnabled
public static string getDummyOpportunity(){
    try {
        Opportunity opp = [SELECT ID FROM opportunity WHERE name LIKE '%Placeholder%' LIMIT 1];
        return opp.Id;
    } catch (Exception e) {
        system.debug('Error retreiving dummy opp' + e);
        return null;
    }
}
@AuraEnabled(cacheable=true)
public static EYI_Inventory__c getInventory(string inventoryId ){

      EYI_Inventory__c inventory = [
            SELECT Id, EYI_Opportunity__c, EYI_Opportunity__r.Name, 
             EYI_Project__c,EYI_Tower__c, EYI_Project__r.Name, Payment_Plan__c,
            Payment_Plan__r.Name, EYI_Built_up_Area__c,EYI_Inventory_Number__c
            FROM EYI_Inventory__c  
            WHERE ID = :inventoryId
            LIMIT 1
        ]; 

        return inventory;
}

@AuraEnabled(cacheable=true)
public static inventoryData getQuoteValues(string inventoryId){

     EYI_Inventory__c inventory;
 try {
         inventory = [
            SELECT Id, EYI_Opportunity__c, EYI_Opportunity__r.Name,
                   EYI_Project__c, EYI_Project__r.Name, Payment_Plan__c, Payment_Plan__r.Name, EYI_Built_up_Area__c,
                   EYI_Parking_Count__c,EYI_Saleable_Area_in_Sq_Mtr__c
            FROM EYI_Inventory__c  
            WHERE ID = :inventoryId
            LIMIT 1
        ]; 

        EYI_Rate_List__c ratelist = [select id,EYI_Rate__c from EYI_Rate_List__c 
        where EYI_Inventory__c=:inventoryId limit 1];
     
     EYI_Project_Unit__c punit;
    //  if(ratelist!=null){
    //      punit = [select id,CGST__c, SGST__c from EYI_Project_Unit__c where 
    //     EYI_Project__c=:ratelist.Id LIMIT 1];
    //  }

        inventoryData inv = new inventoryData();

           if(ratelist.EYI_Rate__c!=null && inventory.EYI_Saleable_Area_in_Sq_Mtr__c!=null){
               inv.unit = ratelist.EYI_Rate__c * inventory.EYI_Saleable_Area_in_Sq_Mtr__c;
           }
        //     if(punit.CGST__c!=null && punit.SGST__c!=null){
        //        inv.centralGst = punit.CGST__c;
        //        inv.stateGst = punit.SGST__c;
        //    }


        if (inventory == null) {
            return null;
        }

     

        // inv.infrastructureCharge ;

        // inv.stateGst;

        // inv.centralGst;

        // inv.stampDuty;

        // inv.registration ;
       

        // inv.mainitenance_deposit;

        // inv.msebc_charges;

        // inv.legal_charges;
        // inv.maintenance_charges ;


 System.debug('inv values : ' + inv);
        return inv;
    } catch (Exception e) {
        System.debug('Error in getQuoteValues: ' + e.getMessage());
        return null;
    }
}

  public class inventoryData {
        @AuraEnabled public Decimal unit { get; set; }
        @AuraEnabled public Decimal infrastructureCharge { get; set; }
        @AuraEnabled public Decimal stateGst { get; set; }
        @AuraEnabled public Decimal centralGst { get; set; }
        @AuraEnabled public Decimal stampDuty { get; set; }
         @AuraEnabled public Decimal registration { get; set; }
        @AuraEnabled public Decimal mainitenance_deposit  { get; set; }
        @AuraEnabled public Decimal msebc_charges  { get; set; }
        @AuraEnabled public Decimal legal_charges  { get; set; }
        @AuraEnabled public Decimal maintenance_charges{ get; set; }
         
    }


}