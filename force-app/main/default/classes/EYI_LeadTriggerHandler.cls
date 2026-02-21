/**
 * @description       : 
 * @author            : EYI Team
 * @group             : EY Notification Framework
 * @last modified on  : 11-18-2024
 * @last modified by  : EYI Team
**/
public with sharing class EYI_LeadTriggerHandler {
    
    public static void updateProjectOnLead(List<Lead> newLeadList){
        List<Lead> leadList = new List<Lead>();
        List<String> projectVal = new List<String>();
        Set<String> validUTMSources = new Set<String>();
        Map<String,EYI_Project__c> projectDetails = new Map<String, EYI_Project__c>();
        for(Lead ld: newLeadList){
            System.debug('ld : '+ld);
            projectVal.add(ld.EYI_Property__c); 
        }
        
        List<EYI_Project__c> projectList = [SELECT Id,Name,EYI_Project_Property_Type__c FROM EYI_Project__c WHERE Name IN: projectVal];
        for(EYI_Project__c p: projectList){
            projectDetails.put(p.Name, p);
        }
        
        Schema.DescribeFieldResult fieldResult = Lead.EYI_Lead_Sub_Source__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues) {
            validUTMSources.add(entry.getValue());
        }
        
        for(Lead ld: newLeadList){
            if(ld.Company == 'CTI'){
                 ld.Company = 'TBC';
             }
            //ld.EYI_Lead_Generation_Medium__c = 'Manually';
            if(projectDetails.containsKey(ld.EYI_Property__c)){
            ld.EYI_Project_Enquired__c = projectDetails.get(ld.EYI_Property__c).Id;
            ld.EYI_Segment__c = projectDetails.get(ld.EYI_Property__c).EYI_Project_Property_Type__c;
               
                if(ld.EYI_Segment__c =='Residential' && (ld.LeadSource == 'Web' )){
                    if(ld.EYI_Property__c.toLowerCase().contains('villa') && ld.EYI_Property__c != 'Bougain Villa'){
                        ld.EYI_LeadType__c = 'Villa';
                    } 
                    else{
                        ld.EYI_LeadType__c = 'Apartment';
                    }
                }
                if(ld.EYI_Segment__c =='Commercial' && (ld.LeadSource == 'Web' )){
                    ld.EYI_LeadType__c = 'Office Unit';
                }
                
                /*if(ld.LeadSource == 'Web' && ld.EYI_Property__c != null && ld.EYI_UTM_Source__c == null){
                    ld.EYI_Lead_Sub_Source_Type__c = ld.EYI_Property__c + ' Website';
                }*/
                
                if(ld.LeadSource == 'Web' && ld.EYI_UTM_Source__c != null && validUTMSources.contains(ld.EYI_UTM_Source__c)){
                    ld.EYI_Lead_Sub_Source__c = ld.EYI_UTM_Source__c;
                }else if(ld.LeadSource == 'Web' && ld.EYI_UTM_Source__c != null && !validUTMSources.contains(ld.EYI_UTM_Source__c)){
                    ld.EYI_Lead_Sub_Source__c = 'Other';
                }
                if(ld.LeadSource == 'Web' && ld.EYI_UTM_Source__c == null){
                    ld.EYI_Lead_Sub_Source__c ='Organic';
				}
                if( ld.LeadSource == 'Web' && ld.EYI_UTM_Campaign__c != null){
                    ld.EYI_Lead_Sub_Source_Type__c = ld.EYI_UTM_Campaign__c;
                }else if( ld.LeadSource == 'Web' && ld.EYI_UTM_Campaign__c == null){
                   ld.EYI_Lead_Sub_Source_Type__c = 'Direct Website';
                }
            }
        }
            
    }

   
}