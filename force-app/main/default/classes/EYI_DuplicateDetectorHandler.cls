public without sharing class EYI_DuplicateDetectorHandler {
    public EYI_DuplicateDetectorHandler() {

    }
    public static void isDuplicate(string recordAPIName, string nameofMetadata,Map<Id, SObject> newSObjectList, Map<Id,SObject> oldListMap){
        String childEnquiryID = '';
        List<Sobject> customMetadataRecords = getAllCustomMetadata(recordAPIName, nameofMetadata);
        if(customMetadataRecords.size() > 0){
            SObject customMetadataRecord = customMetadataRecords[0];
            // Retrieve and cast the field to String before calling split
            String fieldsToDetectDuplicate = (String) customMetadataRecord.get('EYI_Fields_to_detect_Duplicate__c');
            List<String> duplicateFieldsMDT = fieldsToDetectDuplicate != null ? fieldsToDetectDuplicate.split(',') : new List<String>();
            String masterObjectName = (String) customMetadataRecord.get('EYI_Master_Object_API_Name__c');
            Boolean createChildRecord = (Boolean) customMetadataRecord.get('EYI_Create_Child_Records__c');
            String childObjectName = (String) customMetadataRecord.get('EYI_Child_Object_API_Name__c');
            String duplicateLogicMDT = (String) customMetadataRecord.get('EYI_Duplicate_Logic__c');
            String duplicateErrorMessage = (String) customMetadataRecord.get('EYI_Lead_Duplicate_Error_Message__c');
            String masterObjectFieldToMerge = (String) customMetadataRecord.get('EYI_Master_Object_Field_to_Update__c');
            List<String> masterObjectFieldToMergeList = masterObjectFieldToMerge != null ? masterObjectFieldToMerge.split(',') : new List<String>();
            Boolean IsActive = (Boolean) customMetadataRecord.get('EYI_Active__c');
            String keyFieldsFromMetadata = (String) customMetadataRecord.get('EYI_Key_Field__c');
            List<String> keyFields = keyFieldsFromMetadata != null ? keyFieldsFromMetadata.split(',') : new List<String>();
            List<Id> newParentID = new List<ID>();
            Schema.DescribeSObjectResult objDescribeMaster = Schema.getGlobalDescribe().get(masterObjectName).getDescribe();
            // Get the map of fields for the object
            Map<String, Schema.SObjectField> fieldMapMaster = objDescribeMaster.fields.getMap();
            Schema.DescribeSObjectResult objDescribeChild = Schema.getGlobalDescribe().get(childObjectName).getDescribe();
            // Get the map of fields for the object
            Map<String, Schema.SObjectField> fieldMapChild = objDescribeChild.fields.getMap();
            
           // String duplicateLogicMDT = (String) customMetadataRecord.get('Duplicate_Logic__c');
            Map<String,Set<String>> duplicateCheck = new Map<String,Set<String>>();
            List<SObject> childObjectList = new List<SObject>();
            Map<Id,SObject> mergeMasterRecrod = new Map<Id,SObject>();
            Map<Id,SObject> dupParentEntriesData = new Map<Id,SObject>();
            List<SObject> newBulkObjList = new List<SObject>(); 
                for (SObject parentId : newSObjectList.values()) {
                    newParentID.add(parentId.id);
                    //     //SObject oldParent = oldMap.get(parent.Id);
                    
                    for (String field : duplicateFieldsMDT) {
                        if(parentId.get(field) != null && fieldMapMaster.containsKey(field)){
                            
                            if (!duplicateCheck.containsKey(field)) {
                                duplicateCheck.put(field,  new Set<String>{  (String)parentId.get(field)} );
                            }
                            else {
                                duplicateCheck.get(field).add( (String)parentId.get(field));
                            }
                        }
                    }   
                }
                String duplicateLogic = processDuplicateLogic(duplicateFieldsMDT, duplicateLogicMDT,  duplicateCheck, fieldMapMaster);
                System.debug('duplicateLogic: ' + duplicateLogic);
                List<SObject> duplicateParentRec = getDuplicateParentRecord(duplicateLogic,duplicateFieldsMDT,masterObjectFieldToMergeList, masterObjectName, fieldMapMaster, newParentID);
                List<SObject> duplicateRecords = new List<SObject>();
                system.debug('ParentR'+ duplicateParentRec);
                Set<Id> bulkUploadNewRecID = new Set<Id>();
                Map<String,Map<String,string>> duplicateRecordsMap = new Map<String,Map<String,string>>();
                //this loop code is for that lead which is bulk lead and a new lead so we will not retrieve this lead in query thats why we are adding here only the one lead and other will get delete
               
                for(SObject newLead:newSObjectList.values()){
                    if(!duplicateParentRec.isEmpty()){
                       Boolean dupCheck = false;
                        system.debug('testCheckDupLoop');
                        for(SObject dupLead:duplicateParentRec) {
                            system.debug('testCheckDupLoop2');
                            if(((Lead)newLead).MobilePhone!= null){
                                if (((Lead)newLead).Email != ((Lead)dupLead).Email && ((Lead)newLead).Phone != ((Lead)dupLead).Phone && (((Lead)newLead).MobilePhone != ((Lead)dupLead).MobilePhone )) {
                                    system.debug('testCheckDupLoop3'+(Lead)newLead);
                                    bulkUploadNewRecID.add(newLead.Id);
                                    dupCheck = true;
                                    
                                }else{
                                    system.debug('checkUpdateDup2'+newLead);
                                    bulkUploadNewRecID.remove(newLead.Id);
                                    dupCheck = false;
                                    break;
                                    
                                }
                            }else{
                                if (((Lead)newLead).Email != ((Lead)dupLead).Email && ((Lead)newLead).Phone != ((Lead)dupLead).Phone ) {
                                    system.debug('testCheckDupLoop3'+(Lead)newLead);
                                    bulkUploadNewRecID.add(newLead.Id);
                                    dupCheck = true;
                                    
                                }else{
                                    system.debug('checkUpdateDup2'+newLead);
                                    bulkUploadNewRecID.remove(newLead.Id);
                                    dupCheck = false;
                                    break;
                                    
                                }
                            }
                            
                        } 
                        if(dupCheck){
                            duplicateParentRec.add((SObject)newLead);
                        }
                        
                    }
                    if(duplicateParentRec.isEmpty()){
                        system.debug('checkUpdateDup1'+newLead);
                        duplicateParentRec.add((SObject)newLead);
                            bulkUploadNewRecID.add(newLead.Id);
                    } 
                }
                system.debug('checkUpdateDup'+duplicateParentRec);
                system.debug('checkUpdateDupCount'+duplicateParentRec.size());
                if(duplicateParentRec.size() > 0){
                    //this code is written to add the duplicate record as per the fieldname
                    for(SObject dupParent:duplicateParentRec){
                        for(string field:duplicateFieldsMDT){
                            if (dupParent.get(field) != null ) {
                                if(!duplicateRecordsMap.containsKey(field)){
                                    duplicateRecordsMap.put(field, new Map<String, String>{(String)dupParent.get('Id') => (String)dupParent.get(field)});
                                    //duplicateRecordsMap.put(field,  new List<String>{ (String)(dupLead.get(field) )} );
                                }else{
                                    Map<String, String> innerMap = duplicateRecordsMap.get(field);
                                    innerMap.put((String)dupParent.get('Id'), (String)dupParent.get(field));
                                    //duplicateRecordsMap.get(field).add((String)(dupParent.get(field) ));
                                }
                            }
                        }
                    }
                    for(SObject pObject:newSObjectList.values()){
                        system.debug('checkOldListMapExist---->'+duplicateRecordsMap);
                        system.debug('checkOldListMapdata---->'+oldListMap);
                        if(oldListMap!= null && !oldListMap.isEmpty()){
                            for(String apiName: duplicateFieldsMDT){
                                system.debug('checkOldListMapExistLoop---->'+apiName);
                                if(oldListMap.get(pObject.Id).get(apiName) != pObject.get(apiName)){
                                    system.debug('checkOldListMapExistCondition---->');
                                    if(duplicateRecordsMap!= null){
                                        for(String id: duplicateRecordsMap.get(apiName).keySet()){
                                            Map<string,string> dupRecord2 = duplicateRecordsMap.get(apiName);
                                           // if (duplicateRecordsMap.containsKey(apiName) && pObject.Id != id && (duplicateRecordsMap.get(apiName).values()).contains((String)pObject.get(apiName))) {
                                            if (duplicateRecordsMap.containsKey(apiName) && pObject.Id != id && (dupRecord2.get((String)id) == ((String)pObject.get(apiName)))) {
                                                system.debug('checkOldListMapExistduplicate---->');
                                                pObject.addError('Duplicate found: ' + apiName + ' ' + pObject.get(apiName));
                                            }
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }else{
                            for (SObject duplicateParnt : duplicateParentRec) {
                                system.debug('test1234'+pObject.get('id'));
                                system.debug('test1234'+duplicateParnt.get('id'));
                                //commenting this bcoz its taking apex cpq time a lot and using normal lead instance
                               // SObject childObject = Schema.getGlobalDescribe().get(childObjectName).newSObject();
                               EYI_Lead_Enquiry__c childObject = new EYI_Lead_Enquiry__c();
                                for (String field : duplicateFieldsMDT) {     
                                    system.debug('test123456'+pObject);  
                                    system.debug('test12345'+duplicateParnt);    
                                    system.debug('test12'+pObject.get(field));system.debug('test13'+duplicateParnt.get(field) );
                                    if (pObject.get('Phone') == duplicateParnt.get('Phone') && pObject.get('id') != duplicateParnt.get('id' )) {
                                        system.debug('test121'+duplicateParnt.Id);
                                        childObject.put('EYI_Parent_Record__c', duplicateParnt.Id);
                                        dupParentEntriesData.put(pObject.Id,(SObject)childObject);
                                    
                                    }
                                    else if(!dupParentEntriesData.containsKey((String)pObject.get('id')) && pObject.get('id') != duplicateParnt.get('id') && field!= 'Phone' && pObject.get(field) != null && duplicateParnt.get(field)!= null && pObject.get(field) == duplicateParnt.get(field) ){
                                        system.debug('test212'+duplicateParnt);
                                        system.debug('test313'+duplicateParnt.get(field));
                                        system.debug('test414'+pObject.get(field));
                                        system.debug('test515'+dupParentEntriesData.get(pObject.Id));
                                        childObject.put('EYI_Parent_Record__c', duplicateParnt.Id);
                                        dupParentEntriesData.put(pObject.Id,(SObject)childObject);
                                    system.debug('dupEntryRec'+dupParentEntriesData);
                                    }
                                    
                                    else if(!dupParentEntriesData.containsKey((String)pObject.get('id')) && pObject.get('id') == duplicateParnt.get('id') &&  pObject.get(field) == duplicateParnt.get(field) ){
                                       system.debug('duplicateInitial');
                                        childObject.put('EYI_Parent_Record__c', pObject.Id);
                                        dupParentEntriesData.put(pObject.Id,(SObject)childObject);
                                    
                                    }
                                    //for new creation lead
                                    
                                }
                                if(childObject.get('EYI_Parent_Record__c') == duplicateParnt.Id){
                                  String firstName = pObject.get('FirstName')!=null? (String)pObject.get('FirstName'):'';
                                  String lastName = pObject.get('LastName')!=null?(String)pObject.get('LastName'):'' ;
                                    String fullName = firstName + ' '+ lastName;
                                    childObject.put('name',fullName);
                                    system.debug('test1'+pObject.get('name'));
                                    system.debug('OwnerId'+pObject.get('OwnerId'));
                                    //childObject.put('OwnerId',pObject.get('OwnerId'));
                                    for(String field2 : keyFields){
                                        system.debug('test2'+childObject);
                                            if(field2 == 'EYI_Phone__c'){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('Phone'):'');
                                            } 
                                            if(field2 == 'EYI_Email__c')
                                            {
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('Email'):'');
                                            }
                                             if(field2 == 'EYI_Mobile__c'){
                                                childObject.put(field2,fieldMapChild.containsKey((String)field2)?pObject.get('MobilePhone'):'');
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
                                                
                                            
                                            
                                        
                                        system.debug('test3'+childObject);
                                        
                                    }
                                }
                                if(childObject.get('EYI_Parent_Record__c')!='' && childObject.get('EYI_Parent_Record__c')!= null ){
                                     system.debug('test31'+childObject);
                                    system.debug('test312'+duplicateParnt.Id);
                                    system.debug('test313'+pObject.Id);
                                    dupParentEntriesData.put(pObject.Id,(SObject)childObject); 
                                    
                                    
                                    String typeName = String.valueOf(masterObjectName);
                                     Type sObjectType = Type.forName('Schema.' + typeName);
                                    if (sObjectType != null && duplicateParnt.Id != pObject.Id && childObject.get('EYI_Parent_Record__c')!= pObject.Id)  {
                                        system.debug('enterInmergeLoop');
                                        mergeMasterRecrod.put(pObject.Id,duplicateParnt);
                                   
                                    }
                                system.debug('test4'+dupParentEntriesData);
                                
                                }
                            system.debug('test45'+dupParentEntriesData);
                        }
                        system.debug('test6'+dupParentEntriesData);
                    }
                    system.debug('test7'+dupParentEntriesData);
                }
                
                if(!dupParentEntriesData.isEmpty()){
                    system.debug('test9'+dupParentEntriesData);
                    
                    // try{
                    //     insert dupLeadEntriesData.values();
                    // }catch(DmlException e){
                    //     system.debug('entered'+ e.getMessage());
                    // }
                    if(createChildRecord){
                        List<Database.SaveResult>  sr = Database.insert(dupParentEntriesData.values(), false);
                        for (Database.SaveResult dr : sr) {
                            if (dr.isSuccess()) {
                                //Added by Tushar
                                EYI_Record_Navigation__e event = new EYI_Record_Navigation__e(
                                   EYI_Lead_Enquiry_Record_Id__c = dr.getId()
                                );
                                EventBus.publish(event);
                                System.debug('Successfully deleted account. Account ID: ' + dr.getId());
                            } else {
                                for (Database.Error err : dr.getErrors()) {
                                    System.debug('Error: ' + err.getMessage());
                                }
                            }
                        }
                    }
                    
                    
                }
                if(!mergeMasterRecrod.isEmpty()){
                    system.debug('test10'+mergeMasterRecrod);
                    mergeRecords(newSObjectList.values(),masterObjectName, mergeMasterRecrod,masterObjectFieldToMergeList,bulkUploadNewRecID);
                    // for(sObject ld:newSObjectList){
                    //     // for(String mergeField: masterObjectFieldToMergeList){
                    //     //     if((mergeField != null && mergeField != '') && (mergeMasterRecrod.get(ld.id)).get(mergeField) == null){
                    //     //         //duplicateLeadToMerge.put(mergeField,ld.get(mergeField));
                    //     //         system.debug('test11'+ld.get(mergeField));
                    //     //         (mergeMasterRecrod.get(ld.id)).put(mergeField,ld.get(mergeField));
                    //     //     }
                    //     // }
                    //     sObject leadToMerge = (sObject)mergeMasterRecrod.get(ld.id);
                    //     sObject duplicateLeadToMerge = (sObject)ld;
                    //     //Database.MergeResult results = Database.merge((sObject)leadToMerge, (sObject)duplicateLeadToMerge, false);
                    //     system.debug('masterID' + results.getId());
                    // }
                    
                    
                }
            }
            
        } 
        
        // String redirectUrl = childEnquiryID != null ? 'https://panchshilrealtyorg--devorg.sandbox.lightning.force.com/lightning/page/home/' + childEnquiryID : '/home/home.jsp'; // Default to homepage if null
        // system.debug('redirectUrl'+redirectUrl);
        // PageReference pageRef = new PageReference(redirectUrl);
        // pageRef.setRedirect(true);
        // return pageRef;
        // PageReference pageRef = new PageReference('/' + 'a0ZC4000000nycXMAQ');
        //         pageRef.setRedirect(true);
        //         ApexPages.currentPage().getHeaders().put('Location', pageRef.getUrl());
        
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

    public static String processDuplicateLogic(List<String> duplicateFields, String duplicateLogic, Map<String, Set<String>> duplicateCheck, Map<String, Schema.SObjectField> fieldMapMaster) {
        // Split the logic into parts
        List<String> logicParts = duplicateLogic.split(' ');
        String condition = '';
        Boolean conditionOperator = false;
        String lastOperator = ''; 
    
        // Iterate through the parts and replace placeholders with field names
        for (Integer i = 0; i < logicParts.size(); i++) {
            String part = logicParts[i].trim();
            
            if (part.isNumeric()) {
                Integer index = Integer.valueOf(part) - 1; // Convert to zero-based index
                if (index >= 0 && index < duplicateFields.size()) {
                    logicParts[i] = duplicateFields[index];
                    if (fieldMapMaster.containsKey(duplicateFields[index]) && duplicateCheck.get(duplicateFields[index]) != null) {
                        Set<String> values = duplicateCheck.get(duplicateFields[index]);
    
                        // Convert the values to a string, ensuring they are enclosed in parentheses and properly formatted
                        String valuesString = '';
                        for (String value : values) {
                            if (valuesString != '') {
                                valuesString += ', ';
                            }
                            valuesString += '\'' + value + '\'';  // Add single quotes around each value
                        }
    
                        // Construct the condition with the full list of values
                        condition += duplicateFields[index] + ' IN (' + valuesString + ') ';
                        conditionOperator = true;
                    } else {
                        if (condition != '' && condition != null && condition != '( ') {
                            condition = condition.substring(0, condition.length() - 4);  // Trim trailing spaces or operator
                        }
                    }
                }
            } else {
                lastOperator = part;
                condition += part + ' ';
                conditionOperator = false;
            }
        }
    
        // Clean up the condition by trimming operators at the start (e.g., ( AND, OR, NOT))
        if (condition.startsWith('( AND') || condition.startsWith('( OR') || condition.startsWith('( NOT')) {
            condition = condition.substring(0, 1) + condition.substring(5).trim(); // Remove leading "AND" or "OR"
        }
    
        return condition;
    }
    

    public static List<SObject> getDuplicateParentRecord(String queryCondition, List<String> duplicateFields, List<string> masterObjectFieldToMergeList, String masterObjectName, Map<String, Schema.SObjectField> fieldMapMaster,List<id> newParentID ){
        List<String> allFields = new List<String>();
        List<String> allExistsFields = new List<String>();
        allFields.addAll(duplicateFields);
        allFields.addAll(masterObjectFieldToMergeList);
        for (String field : allFields) {
            if (fieldMapMaster.containsKey(field)) {
                allExistsFields.add(field);
            }
        }
        //duplicateFields.addAll(masterObjectFieldToMergeList);
        String typeOfInsert  = 'Bulk uploads';
        String query = 'SELECT Id, FirstName, LastName,OwnerId,';
        query += String.join(allExistsFields, ', ');
        query += ' FROM '+masterObjectName+' WHERE IsConverted = '+ false ;
        List<String> quotedIds = new List<String>();
        for (String id : newParentID) {
            quotedIds.add('\'' + id + '\'');
        }
       // query += ' And EYI_Lead_Generation_Medium__c != '+ typeOfInsert;
        query += ' AND Id NOT IN (' + String.join(quotedIds, ', ') + ')';
        if(queryCondition != null && queryCondition!= ''){
            query = query + ' AND ( ' + queryCondition + ' )';
        }
        query += ' ORDER BY CreatedDate ASC';
        //adding order by bcoz wanted to retrive record first which is already exist so that new record will get delete if it is duplicate
        //
        
        system.debug('query'+query);
        List<SObject> dupParentObject = new List<SObject>();
        try {
            // Perform the query and cast the results to a list of Lead
            dupParentObject = (List<SObject>)Database.query(query);
            
        } catch (QueryException e) {System.debug('Error executing query: ' + e.getMessage());
        }
        return dupParentObject;
    }

    public static void mergeRecords(List<SObject> newSObjectList, String masterObjectName, Map<Id,SObject> mergeMasterRecrod, List<String> masterObjectFieldToMergeList, Set<Id> bulkUploadNewRecID){
        System.debug('Parent Object List' + newSObjectList);
        System.debug('Parent Object List2' + mergeMasterRecrod);
        List<ID> parentObjectListToDelete = new List<ID>();
        Map<id,SObject> parentObjectListToUpdate = new Map<Id,SObject>();
        for(SObject obj:newSObjectList){
            if(mergeMasterRecrod.containsKey((Id)obj.get('Id')) && mergeMasterRecrod.get((Id)obj.get('Id'))!= null){
                if(!bulkUploadNewRecID.contains(obj.Id)){
                    parentObjectListToDelete.add(obj.Id);
                }
                
                //SObject recordToMerge = Schema.getGlobalDescribe().get(masterObjectName).newSObject();
                Lead recordToMerge = new Lead();
                //SObject recordToMerge = new SObject();
                recordToMerge.put('Id',mergeMasterRecrod.get((Id)obj.get('Id')).Id);
                for(String field:masterObjectFieldToMergeList){
                    
                    if(mergeMasterRecrod.get((Id)obj.get('Id')).get(field) == null){
                        if(field == 'EYI_Lead_Source__c'){
                            recordToMerge.put('LeadSource',obj.get(field));
                        }else if(field == 'EYI_Phone__c'){
                            //recordToMerge.put('Phone',obj.get(field));
                        }
                        else if(field == 'EYI_Email__c'){
                          //  recordToMerge.put('Email',obj.get(field));
                        }
                        else if(field == 'EYI_Mobile__c'){
                           // recordToMerge.put('MobilePhone',obj.get(field));
                        }
                        else{
                            recordToMerge.put(field,obj.get(field));
                        }
                        
                    }
                }
                parentObjectListToUpdate.put(mergeMasterRecrod.get((Id)obj.get('Id')).Id,(SObject)recordToMerge);
            }

        }
        if(!parentObjectListToUpdate.isEmpty()){
            
            system.debug('parentObjectListToUpdate'+parentObjectListToUpdate);
            //update parentObjectListToUpdate.values();
        }
        if(!parentObjectListToDelete.isEmpty()){
            system.debug('parentObjectListToDelete'+parentObjectListToDelete);
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