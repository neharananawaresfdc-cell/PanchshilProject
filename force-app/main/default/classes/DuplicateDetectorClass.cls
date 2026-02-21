public without sharing class DuplicateDetectorClass {
    public static List<Sobject> customMetadataRecords;
    public static String fieldsToDetectDuplicate;
    public static List<String> duplicateFieldsMDT;
    public static String masterObjectName = 'Lead';
    public static String childObjectName = 'EYI_Lead_Enquiry__c';
    public static List<String> masterObjectFieldToMergeList ;
    public static Boolean IsActive;
    public static List<String> keyFields;
    public static Schema.DescribeSObjectResult objDescribeMaster;
    public static Map<String, Schema.SObjectField> fieldMapMaster;
    public static Schema.DescribeSObjectResult objDescribeChild;
    public static Map<String, Schema.SObjectField> fieldMapChild;
    
    public DuplicateDetectorClass() {
		customMetadataRecords = getAllCustomMetadata('Lead_Duplicate', 'EY_Lead_Duplicate_Detector_rules__mdt');
        system.debug('customMetadataRecords2'+customMetadataRecords);
        if(customMetadataRecords.size() > 0){
            SObject customMetadataRecord = customMetadataRecords[0];
            // Retrieve and cast the field to String before calling split
            fieldsToDetectDuplicate = (String) customMetadataRecord.get('EYI_Fields_to_detect_Duplicate__c');
            duplicateFieldsMDT = fieldsToDetectDuplicate != null ? fieldsToDetectDuplicate.split(',') : new List<String>();
            String masterObjectFieldToMerge = (String) customMetadataRecord.get('EYI_Master_Object_Field_to_Update__c');
            masterObjectFieldToMergeList = masterObjectFieldToMerge != null ? masterObjectFieldToMerge.split(',') : new List<String>();
            IsActive = (Boolean) customMetadataRecord.get('EYI_Active__c');
            String keyFieldsFromMetadata = (String) customMetadataRecord.get('EYI_Key_Field__c');
            keyFields = keyFieldsFromMetadata != null ? keyFieldsFromMetadata.split(',') : new List<String>();
            objDescribeMaster = Schema.getGlobalDescribe().get(masterObjectName).getDescribe();
            fieldMapMaster = objDescribeMaster.fields.getMap();
            objDescribeChild = Schema.getGlobalDescribe().get(childObjectName).getDescribe();
            // Get the map of fields for the object
            fieldMapChild = objDescribeChild.fields.getMap();    
        }
    }
    public static void  isDuplicate(string recordAPIName, string nameofMetadata,Map<Id, SObject> newSObjectList, Map<Id,SObject> oldListMap){
        system.debug('customMetadataRecords'+customMetadataRecords);
        if(customMetadataRecords.size() > 0){
        	String childEnquiryID = '';
        
            List<String> newParentID = new List<String>();
            List<String> dupPhone = new List<String>();
            List<String> dupMobile = new List<String>();
            List<String> dupEmail = new List<String>();
         
           // String duplicateLogicMDT = (String) customMetadataRecord.get('Duplicate_Logic__c');
            Map<String,Set<String>> duplicateCheck = new Map<String,Set<String>>();
            List<SObject> childObjectList = new List<SObject>();
            Map<Id,SObject> mergeMasterRecrod = new Map<Id,SObject>();
            Map<Id,SObject> dupParentEntriesData = new Map<Id,SObject>();
            List<SObject> newBulkObjList = new List<SObject>(); 
            for (SObject parentId : newSObjectList.values()) {
              //newParentID.add(parentId.id);
              Lead lead = (Lead)parentId;
                newParentID.add('\'' + lead.Id + '\'');
                if(lead.DupMobile__c !=null){
                    dupPhone.add('\'' + lead.DupMobile__c + '\'');
                }
                if(lead.DupPhone__c!=null){
                    dupMobile.add('\'' + lead.DupPhone__c + '\'');
                }
                if(lead.Email!=null){
                    dupEmail.add('\'' + lead.Email + '\'');
                }
                
                
                

            }
                // for (SObject parentId : newSObjectList.values()) {
                //     newParentID.add(parentId.id);
                //     //     //SObject oldParent = oldMap.get(parent.Id);
                    
                //     for (String field : duplicateFieldsMDT) {
                //         if(parentId.get(field) != null && fieldMapMaster.containsKey(field)){
                            
                //             if (!duplicateCheck.containsKey(field)) {
                //                 duplicateCheck.put(field,  new Set<String>{  (String)parentId.get(field)} );
                //             }
                //             else {
                //                 duplicateCheck.get(field).add( (String)parentId.get(field));
                //             }
                //         }
                //     }   
                // }
                //String duplicateLogic = processDuplicateLogic(duplicateFieldsMDT, duplicateLogicMDT,  duplicateCheck, fieldMapMaster);
                //System.debug('duplicateLogic: ' + duplicateLogic);
                List<SObject> duplicateParentRec = getDuplicateParentRecord(dupEmail,dupMobile,dupPhone,masterObjectFieldToMergeList, masterObjectName, fieldMapMaster, newParentID);
                List<SObject> duplicateRecords = new List<SObject>();
                
                Set<Id> bulkUploadNewRecID = new Set<Id>();
                Map<String,Map<String,string>> duplicateRecordsMap = new Map<String,Map<String,string>>();
                system.debug('duplicateRecordsMap'+duplicateRecords.size());
                //this loop code is for that lead which is bulk lead and a new lead so we will not retrieve this lead in query thats why we are adding here only the one lead and other will get delete
               Boolean dupCheck;
                for(SObject newLead:newSObjectList.values()){
                    if(!duplicateParentRec.isEmpty()){
                       dupCheck = false;
                       system.debug('entry1');
                        for(SObject dupLead:duplicateParentRec) {
                            
                       system.debug('entry2'+dupLead);
                            if(((Lead)newLead).DupPhone__c != null){
                                
                       system.debug('entry2'+newLead);
                                if (((Lead)newLead).Email != ((Lead)dupLead).Email && ((Lead)newLead).DupMobile__c != ((Lead)dupLead).DupMobile__c && (((Lead)newLead).DupPhone__c != ((Lead)dupLead).DupPhone__c )) {
                                    system.debug('entry3'+newLead);
                                    bulkUploadNewRecID.add(newLead.Id);
                                    dupCheck = true;
                                    
                                }else{
                                    system.debug('entry4'+newLead);
                                    bulkUploadNewRecID.remove(newLead.Id);
                                    dupCheck = false;break;
                                    
                                    
                                }
                            }else{
                                if (((Lead)newLead).Email != ((Lead)dupLead).Email && ((Lead)newLead).DupMobile__c != ((Lead)dupLead).DupMobile__c ) {
                                    system.debug('entry5'+newLead);
                                    bulkUploadNewRecID.add(newLead.Id);
                                    dupCheck = true;
                                    
                                }else{
                                    system.debug('entry7'+newLead);
                                    bulkUploadNewRecID.remove(newLead.Id);
                                    dupCheck = false;
                                break;
                                    
                                }
                            }
                            
                        } 
                        if(dupCheck){
                            system.debug('entry8');
                            duplicateParentRec.add((SObject)newLead);
                            system.debug('entry8'+duplicateParentRec);
                        }
                        
                    }
                    if(duplicateParentRec.isEmpty()){ 

                        duplicateParentRec.add((SObject)newLead);
                        bulkUploadNewRecID.add(newLead.Id);
                        system.debug('entry9'+bulkUploadNewRecID);
                    } 
                }
                
                if(duplicateParentRec.size() > 0){
                    system.debug('entry10');
                    //this code is written to add the duplicate record as per the fieldname
                    for(SObject dupParent:duplicateParentRec){
                        system.debug('entry10'+dupParent);
                        for(string field:duplicateFieldsMDT){
                            system.debug('entry11'+duplicateFieldsMDT);
                            if (dupParent.get(field) != null ) {
                                system.debug('entry12'+dupParent);
                                if(!duplicateRecordsMap.containsKey(field)){
                                    system.debug('entry13'+duplicateRecordsMap);
                                    duplicateRecordsMap.put(field, new Map<String, String>{(String)dupParent.get('Id') => (String)dupParent.get(field)});
                                    //duplicateRecordsMap.put(field,  new List<String>{ (String)(dupLead.get(field) )} );
                                }else{
                                    system.debug('entry14'+duplicateRecordsMap);
                                    Map<String, String> innerMap = duplicateRecordsMap.get(field);
                                    innerMap.put((String)dupParent.get('Id'), (String)dupParent.get(field));
                                     system.debug('entry15'+innerMap);
                                    //duplicateRecordsMap.get(field).add((String)(dupParent.get(field) ));
                                }
                            }
                        }
                    }
                    for(SObject pObject:newSObjectList.values()){
                        system.debug('entry16'+pObject);
                        if(oldListMap!= null && !oldListMap.isEmpty()){
                             system.debug('entry17'+oldListMap);
                            for(String apiName: duplicateFieldsMDT){ 
                                system.debug('apiName'+apiName);
                                if(oldListMap.get(pObject.Id).get(apiName) != pObject.get(apiName)){
                                    system.debug('oldListMap'+oldListMap);
                                    if(duplicateRecordsMap!= null){
                                        system.debug('duplicateRecordsMap'+duplicateRecordsMap);
                                        if(duplicateRecordsMap.get(apiName) != null){
                                            for(String id: duplicateRecordsMap.get(apiName).keySet()){
                                                Map<string,string> dupRecord2 = duplicateRecordsMap.get(apiName);
                                               // if (duplicateRecordsMap.containsKey(apiName) && pObject.Id != id && (duplicateRecordsMap.get(apiName).values()).contains((String)pObject.get(apiName))) {
                                                if (duplicateRecordsMap.containsKey(apiName) && pObject.Id != id && (dupRecord2.get((String)id) == ((String)pObject.get(apiName)))) {
                                                    
                                                    pObject.addError('Duplicate found: ' + apiName + ' ' + pObject.get(apiName));
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        }else{
                            EYI_Lead_Enquiry__c childObject = new EYI_Lead_Enquiry__c();
                            for (SObject duplicateParnt : duplicateParentRec) {
                                system.debug('duplicateParnt'+duplicateParnt);
                               
                                for (String field : duplicateFieldsMDT) {     
                                    system.debug('field'+field);
                                    if (pObject.get('DupMobile__c') == duplicateParnt.get('DupMobile__c') && pObject.get('id') != duplicateParnt.get('id' )) {
                                        system.debug('pObject11'+pObject);
                                        childObject.put('EYI_Parent_Record__c', duplicateParnt.Id);
                                        dupParentEntriesData.put(pObject.Id,(SObject)childObject);
                                    
                                    }
                                    else if(!dupParentEntriesData.containsKey((String)pObject.get('id')) && pObject.get('id') != duplicateParnt.get('id') && field!= 'DupMobile__c' && pObject.get(field) != null && duplicateParnt.get(field)!= null && pObject.get(field) == duplicateParnt.get(field) ){
                                        system.debug('dupParentEntriesData'+dupParentEntriesData);
                                        childObject.put('EYI_Parent_Record__c', duplicateParnt.Id);
                                        dupParentEntriesData.put(pObject.Id,(SObject)childObject);
                                    
                                    }
                                    
                                    else if(!dupParentEntriesData.containsKey((String)pObject.get('id')) && pObject.get('id') == duplicateParnt.get('id') &&  pObject.get(field) == duplicateParnt.get(field) ){
                                       system.debug('dupParentEntriesData22'+dupParentEntriesData);
                                        childObject.put('EYI_Parent_Record__c', pObject.Id);
                                        dupParentEntriesData.put(pObject.Id,(SObject)childObject);
                                    
                                    }
                                    //for new creation lead
                                    
                                }
                                if(childObject.get('EYI_Parent_Record__c') == duplicateParnt.Id){
                                    system.debug('childObject'+childObject);
                                  String firstName = pObject.get('FirstName')!=null? (String)pObject.get('FirstName'):'';
                                  String lastName = pObject.get('LastName')!=null?(String)pObject.get('LastName'):'' ;
                                    String fullName = firstName + ' '+ lastName;
                                  
                                    childObject.put('name',fullName);
                                    
                                    //childObject.put('OwnerId',pObject.get('OwnerId'));
                                    for(String field2 : keyFields){
                                       system.debug('field2'+field2);
                                            if(field2 == 'EYI_Phone__c'){
                                                String mobile = (String)pObject.get('Phone');
                                                if (mobile != null && !mobile.startsWith('+91')) {
                                                   // mobile = '+91' + mobile;
                                                }
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?mobile :'');
                                            } 
                                            if(field2 == 'EYI_Email__c')
                                            {
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('Email'):'');
                                            }
                                             if(field2 == 'EYI_Mobile__c'){
                                                String phone = (String)pObject.get('MobilePhone');
                                                if (phone != null && !phone.startsWith('+91')) {
                                                   // phone = '+91' + phone;
                                                }
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?phone :'');
                                                //childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('DupPhone__c'):'');
                                            }
                                        	 if(field2 == 'EYI_Rating__c'){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('Rating'):'');
                                            }
                                           if(field2 == 'EYI_Lead_Source__c'){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('LeadSource'):'');
                                            }
                                           if(field2 == 'EYI_Company__c'){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('Company'):'');
                                            }
                                        	if(field2 == 'EYI_Salutation__c'){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('Salutation'):'');
                                            }
                                             if(field2 != 'EYI_Phone__c' && field2 != 'EYI_Salutation__c' &&  field2 != 'EYI_Company__c' && field2 != 'EYI_Lead_Source__c' && field2 != 'EYI_Rating__c' && field2 != 'EYI_Mobile__c' && field2 != 'EYI_Email__c' && field2 != 'name' && field2 != 'OwnerId' ){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get(field2):'');
                                            }
                                                
                                            
                                            
                                        
                                       
                                        
                                    }
                                }
                                if(childObject.get('EYI_Parent_Record__c')!='' && childObject.get('EYI_Parent_Record__c')!= null ){
                                    system.debug('childObject22'+childObject);
                                    dupParentEntriesData.put(pObject.Id,(SObject)childObject); 
                                    
                                    
                                    String typeName = String.valueOf(masterObjectName);
                                     Type sObjectType = Type.forName('Schema.' + typeName);
                                    if (sObjectType != null && duplicateParnt.Id != pObject.Id && childObject.get('EYI_Parent_Record__c')!= pObject.Id)  {
                                        system.debug('childObject23'+childObject);
                                        mergeMasterRecrod.put(pObject.Id,duplicateParnt);
                                   
                                    }
                               
                                
                                }
                            
                        }
                        
                    }
                    
                }
                
                if(!dupParentEntriesData.isEmpty()){
                   
                     system.debug('dupParentEntriesData22'+dupParentEntriesData);
                    // try{
                    //     insert dupLeadEntriesData.values();
                    // }catch(DmlException e){
                    //     system.debug('entered'+ e.getMessage());
                    // }
                    
                        List<Database.SaveResult>  sr = Database.insert(dupParentEntriesData.values(), false);
                        
                    
                    
                    
                }
                if(!mergeMasterRecrod.isEmpty()){
                    
                    mergeRecords(newSObjectList.values(),masterObjectName, mergeMasterRecrod,masterObjectFieldToMergeList,bulkUploadNewRecID);
                    
                    
                    
                }
            }
            
      }  
        
        
    }

    public static List<SObject> getAllCustomMetadata(String recordApiName, string objectName) {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        String query = 'SELECT ';
        for (String fieldName : fieldMap.keySet()) {
            query += fieldName + ', ';
        }
        
        query = query.removeEnd(', ') + ' FROM ' + objectName + ' WHERE DeveloperName = :recordApiName AND EYI_Active__c = true';
        return Database.query(query);
    }

    

    public static List<SObject> getDuplicateParentRecord(List<String> dupEmail,List<String> dupMobile,List<String> dupPhone, List<string> masterObjectFieldToMergeList, String masterObjectName, Map<String, Schema.SObjectField> fieldMapMaster,List<String> newParentID ){
       
        List<String> allFields = new List<String>();
        List<String> allExistsFields = new List<String>();
       
        allFields.addAll(masterObjectFieldToMergeList);
        for (String field : allFields) {
            if (fieldMapMaster.containsKey(field)) {
                allExistsFields.add(field);
            }
        }
        
        //duplicateFields.addAll(masterObjectFieldToMergeList);
        String typeOfInsert  = 'Bulk uploads';
        String query = 'SELECT Id, FirstName, LastName,OwnerId,Email,MobilePhone,Phone,DupMobile__c,DupPhone__c,';
        query += String.join(allExistsFields, ', ');
        query += ' FROM '+masterObjectName+' WHERE IsConverted = '+ false ;
        // List<String> quotedIds = new List<String>();
        // for (String id : newParentID) {
        //     quotedIds.add('\'' + id + '\'');
        // }
       // query += ' And EYI_Lead_Generation_Medium__c != '+ typeOfInsert;
        query += ' AND Id NOT IN (' + String.join(newParentID, ', ') + ')';
        //query += ' AND Id NOT IN (' + String.join(newParentID, ', ') + ')';
        // if(queryCondition != null && queryCondition!= ''){
        if(dupPhone!=null && dupPhone.size() >0){
            query +=  + ' AND (DupMobile__c IN ('+ String.join(dupPhone, ', ')+') OR ';
        }
        if(dupMobile!=null && !dupMobile.isEmpty()){
             query +=  + ' DupPhone__c IN ('+ String.join(dupMobile, ', ')+') OR ';
        }
        if(dupEmail!=null && dupEmail.size() > 0){
           query +=  + ' Email IN ('+ String.join(dupEmail, ', ') +'))';
        }
       // query += ' ORDER BY CreatedDate ASC';
        //adding order by bcoz wanted to retrive record first which is already exist so that new record will get delete if it is duplicate
        //
        system.debug('query'+query);

        
        List<SObject> dupParentObject = new List<SObject>();
        try {
            // Perform the query and cast the results to a list of Lead
            dupParentObject = (List<SObject>)Database.query(query);
            system.debug('dupParentObjectQ'+dupParentObject);
        } catch (QueryException e) {System.debug('Error executing query: ' + e.getMessage());
        }
        system.debug('dupParentObjectQ1'+dupParentObject);
        return dupParentObject;
    }

    public static void mergeRecords(List<SObject> newSObjectList, String masterObjectName, Map<Id,SObject> mergeMasterRecrod, List<String> masterObjectFieldToMergeList, Set<Id> bulkUploadNewRecID){
        
        List<Id> parentObjectListToDelete = new List<Id>();
        Map<id,SObject> parentObjectListToUpdate = new Map<Id,SObject>();
        for(SObject obj:newSObjectList){
            if(mergeMasterRecrod.containsKey((Id)obj.get('Id')) && mergeMasterRecrod.get((Id)obj.get('Id'))!= null){
                if(!bulkUploadNewRecID.contains(obj.Id)){
                    system.debug('bulkUploadNewRecID22'+bulkUploadNewRecID);
                    parentObjectListToDelete.add(obj.Id);
                }
                
                //SObject recordToMerge = Schema.getGlobalDescribe().get(masterObjectName).newSObject();
                Lead recordToMerge = new Lead();
                //SObject recordToMerge = new SObject();
                recordToMerge.put('Id',mergeMasterRecrod.get((Id)obj.get('Id')).Id);
                for(String field:masterObjectFieldToMergeList){
                    system.debug('bulkUplomasterObjectFieldToMergeListadNewRecID22'+masterObjectFieldToMergeList);
                    if(mergeMasterRecrod.get((Id)obj.get('Id')).get(field) == null){
                        if(field == 'EYI_Lead_Source__c'){
                            recordToMerge.put('LeadSource',obj.get(field));
                        }else if(field == 'EYI_Phone__c'){
                            continue;
                        }
                        else if(field == 'EYI_Email__c'){
                          continue;
                        }
                        else if(field == 'EYI_Mobile__c'){
                           continue;
                        }
                        else{
                            recordToMerge.put(field,obj.get(field));
                        }
                        
                    }
                }
                parentObjectListToUpdate.put(mergeMasterRecrod.get((Id)obj.get('Id')).Id,(SObject)recordToMerge);
            }

        }

        if(!parentObjectListToDelete.isEmpty()){
           system.debug('parentObjectListToDelete11'+parentObjectListToDelete);
            // for (SObject lead : parentObjectListToDelete) {
            //     lead.addError('Deletion is not allowed for this lead: ' + lead.Id);
            // }
           // pObject.addError('Duplicate found: ' + apiName + ' ' + pObject.get(apiName));
            //delete parentObjectListToDelete;
            deleteRecords(parentObjectListToDelete,masterObjectName);
        }

        

        
    }  
    
    @future
    public static void deleteRecords(List<ID> parentObjectListToDelete, String masterObjectName) {
        try {
            String pObjectType = masterObjectName; // Replace with the actual object type
            String query = 'SELECT Id FROM ' + pObjectType + ' WHERE Id IN :parentObjectListToDelete';
            List<SObject> recordsToDelete = Database.query(query);
            delete recordsToDelete;
            //apex.region().refresh()
            //List<SObject> recordsToDelete = [SELECT Id FROM SObject WHERE Id IN :parentObjectListToDelete];
            //delete recordsToDelete;
           // return '/home/home.jsp'; 
        } catch (DmlException e) { System.debug('Error deleting records: ' + e.getMessage());
          //  return '/home/home.jsp'; 
        }
    }
}