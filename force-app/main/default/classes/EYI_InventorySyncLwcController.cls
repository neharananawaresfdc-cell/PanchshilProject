/**
* @description       : 
* @author            : Viksit Rana
* @group             : 
* @last modified on  : 03-04-2025
* @last modified by  : viksit
**/
public class EYI_InventorySyncLwcController {
    @AuraEnabled
    public static lwcMessage InventorySync(String recordId) {
        lwcMessage lm = new lwcMessage();
        Boolean isPATCHOperation = false;
        if(recordId != null) {
            SObjectType sobjTypeId = Id.valueOf(recordId).getSObjectType();
            System.debug('sobjTypeId: ' + sobjTypeId);
            if (sobjTypeId == EYI_Tower__c.SObjectType) {
                EYI_Tower__c towerRecord = [SELECT id, name, 
                                            (SELECT id, EYI_Project__c, EYI_OC_Received_Date__c, EYI_Project__r.EYI_SAP_Salesorg__c, EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_Floor_Number__c,
                                             EYI_Inventory_Number__c,EYI_SAP_Material_Type__c,EYI_SAP_Material_Description__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c,
                                             EYI_Inventory_Type__c,EYI_UOM__c,EYI_Material_Group__c,EYI_Super_Built_up_Area__c, EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c, //EYI_SAP_Plant_Code__c
                                             EYI_Carpet_Area__c,EYI_Garden_Area__c,EYI_Built_up_Area__c,EYI_Common_Area__c,EYI_Terrace_Area__c,EYI_Balcony_Area__c, EYI_Tower__r.EYI_SAP_Plant_ID__c,
                                             EYI_Inventory_Status__c,EYI_Inventory_Floor_No__c, EYI_View_based_on_Directions__c,Configuration__c, EYI_Typology__c, Name,
                                             EYI_View_based_on_Amenities__c ,EYI_SAP_Affordable_Type__c,EYI_SAP_Profit_Center__c, EYI_Saleable_Area__c
                                             FROM Inventories__r where EYI_Is_Syc__c = false) 
                                            FROM EYI_Tower__c WHERE id = :recordId LIMIT 1];
                if(towerRecord.Inventories__r.size()>0){
                    lm= requiredFieldForInventorySync(towerRecord.Inventories__r);
                }
                return lm;
            } else if (sobjTypeId == EYI_Project__c.SObjectType) {
                EYI_Project__c projectRecord = [SELECT id, name, 
                                                (SELECT id, EYI_Project__c,EYI_Project__r.EYI_SAP_Salesorg__c, EYI_OC_Received_Date__c, EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_Floor_Number__c,
                                                 EYI_Inventory_Number__c,EYI_SAP_Material_Type__c,EYI_SAP_Material_Description__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c,
                                                 EYI_Inventory_Type__c,EYI_UOM__c,EYI_Material_Group__c,EYI_Super_Built_up_Area__c, EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c, //EYI_SAP_Plant_Code__c
                                                 EYI_Carpet_Area__c,EYI_Garden_Area__c,EYI_Built_up_Area__c,EYI_Common_Area__c,EYI_Terrace_Area__c,EYI_Balcony_Area__c, EYI_Tower__r.EYI_SAP_Plant_ID__c,
                                                 EYI_Inventory_Status__c,EYI_Inventory_Floor_No__c, EYI_View_based_on_Directions__c,Configuration__c, EYI_Typology__c, Name,
                                                 EYI_View_based_on_Amenities__c ,EYI_SAP_Affordable_Type__c,EYI_SAP_Profit_Center__c, EYI_Saleable_Area__c 
                                                 FROM Inventories__r where EYI_Is_Syc__c = false)
                                                FROM EYI_Project__c WHERE id = :recordId LIMIT 1];
                if(projectRecord.Inventories__r.size()>0){
                    lm= requiredFieldForInventorySync(projectRecord.Inventories__r);
                }
                return lm;
            } else {
                lm.type = 'E';
                lm.message = 'Unsupported record type for Inventory Sync';
                return lm;
            }            
        } else {
            lm.type = 'E';
            lm.message = 'Record Id Missing';
            return lm;
        }
    }
    
    public static lwcMessage processInventoryRecords(List<EYI_Inventory__C> inventories,  Boolean isPATCHOperation , Boolean IS_StatusChange) {
        integer CountInventory=0;
        // Common logic for processing inventory records
        // Extracted from the duplicated code for EYI_Tower__c and EYI_Project__c
        String InventoryId ='';
        lwcMessage lm = new lwcMessage();
        EYI_RECInventoryCreationWrapper recInventory = new EYI_RECInventoryCreationWrapper();
        List<EYI_Inventory__c> recUpdateList = new List<EYI_Inventory__c>();
        List<SAP_SF_Field_Map__c> mapData = [select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c from SAP_SF_Field_Map__c ];
        Map<String, String> sfmapSAP = new Map<String, String>();
        if(!mapData.isEmpty()){
            for(SAP_SF_Field_Map__c mp :mapData){
                sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                //system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
            } 
        }
        try{
            //LIst<EYI_RECInventoryCreationWrapper.cls_ImInput> inputobjLst = new List<EYI_RECInventoryCreationWrapper.cls_ImInput>(); 
            for(EYI_Inventory__c invoBJ : inventories){
                EYI_RECInventoryCreationWrapper.cls_ImInput  inputobj = new EYI_RECInventoryCreationWrapper.cls_ImInput ();
                if(invoBJ.EYI_Inventory_Number__c!= null){
                    inputobj.MATNR = invoBJ.EYI_Inventory_Number__c;
                    //  isPATCHOperation = true;
                }
                if(invoBJ.Name!= null){
                    inputobj.Name = invoBJ.Name;
                    inputobj.MBRSH ='';       // not madentory                        
                    inputobj.MTPOS = '0005';
                    inputobj.GEWEI = '';
                    inputobj.ITEM_CAT ='0005'; 
                    InventoryId =invoBJ.id;
                }
                if(invoBJ.EYI_SAP_Material_Type__c!= null){
                    if(sfmapSAP.containsKey('EYI_SAP_Material_Type__c'+'~'+invoBJ.EYI_SAP_Material_Type__c)) 
                        inputobj.MTART =sfmapSAP.get('EYI_SAP_Material_Type__c'+'~'+invoBJ.EYI_SAP_Material_Type__c);// '1';//test
                }
                if(invoBJ.EYI_OC_Received_Date__c != null){
                	inputobj.KONDM = 'OC';
                }Else{
                    inputobj.KONDM = 'NO';
                }
                
                if(invoBJ.EYI_TCS_Tax_Classification__c!= null){
                    if(sfmapSAP.containsKey('EYI_TCS_Tax_Classification__c'+'~'+invoBJ.EYI_TCS_Tax_Classification__c)) 
                        inputobj.TAX_CLASS_TCS =sfmapSAP.get('EYI_TCS_Tax_Classification__c'+'~'+invoBJ.EYI_TCS_Tax_Classification__c);// '1';//test
                }
                if(invoBJ.EYI_GST_Tax_Classification__c!= null){
                    if(sfmapSAP.containsKey('EYI_GST_Tax_Classification__c'+'~'+invoBJ.EYI_GST_Tax_Classification__c)) 
                        inputobj.TAX_CLASS =sfmapSAP.get('EYI_GST_Tax_Classification__c'+'~'+invoBJ.EYI_GST_Tax_Classification__c);// '1';//test
                }
                if(invoBJ.EYI_SAP_Material_Description__c!= null){
                    inputobj.MAKTX =invoBJ.EYI_SAP_Material_Description__c ;
                }
                if(invoBJ.EYI_Tower__r.EYI_SAP_Plant_ID__c!= null){
                    //inputobj.WERKS = invoBJ.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c ;
                    inputobj.WERKS = invoBJ.EYI_Tower__r.EYI_SAP_Plant_ID__c;
                }
                if(invoBJ.EYI_Project__r.EYI_SAP_Salesorg__c!= null){
                    inputobj.VKORG = invoBJ.EYI_Project__r.EYI_SAP_Salesorg__c ;
                }
                if(invoBJ.EYI_Inventory_Type__c!= null){
                    if(sfmapSAP.containsKey('EYI_Distruibution_Channel__c'+'~'+invoBJ.EYI_Inventory_Type__c)) 
                        inputobj.VTWEG =sfmapSAP.get('EYI_Distruibution_Channel__c'+'~'+invoBJ.EYI_Inventory_Type__c);// '1';//test
                }
                system.debug('invoBJ.EYI_UOM__c '+ invoBJ.EYI_UOM__c);
                if(invoBJ.EYI_UOM__c!= null){
                    if(sfmapSAP.containsKey('EYI_UOM__c'+'~'+invoBJ.EYI_UOM__c)) 
                        inputobj.MEINS =sfmapSAP.get('EYI_UOM__c'+'~'+invoBJ.EYI_UOM__c);// '1';//test
                }
                if(invoBJ.EYI_Material_Group__c!= null){
                    if(sfmapSAP.containsKey('EYI_Material_Group__c'+'~'+invoBJ.EYI_Material_Group__c)) 
                        inputobj.MATKL =sfmapSAP.get('EYI_Material_Group__c'+'~'+invoBJ.EYI_Material_Group__c);// '1';//test
                }
                if(invoBJ.EYI_Saleable_Area__c!= null){
                    inputobj.BRGEW = String.valueof(invoBJ.EYI_Saleable_Area__c) ;
                }
                if(invoBJ.EYI_Carpet_Area__c!= null){
                    inputobj.NTGEW = String.valueof(invoBJ.EYI_Carpet_Area__c) ;
                }
                if(invoBJ.EYI_Garden_Area__c!= null){
                    inputobj.GAR_AREA = String.valueof(invoBJ.EYI_Garden_Area__c) ;
                }
                if(invoBJ.EYI_Terrace_Area__c!= null){
                    inputobj.TER_AREA = String.valueof(invoBJ.EYI_Terrace_Area__c) ;
                }
                if(invoBJ.EYI_Balcony_Area__c!= null){
                    inputobj.BAL_AREA = String.valueof(invoBJ.EYI_Balcony_Area__c) ;
                }
                if(invoBJ.EYI_Built_up_Area__c!= null){
                    inputobj.BUL_AREA = String.valueof(invoBJ.EYI_Built_up_Area__c) ;
                }
                if(invoBJ.EYI_Common_Area__c!= null){
                    inputobj.COMM_AREA = String.valueof(invoBJ.EYI_Common_Area__c) ;
                }
                // we need to add EYI_SAP_Plant_Code__c from EYI_SAP_Salesorg__c
                if(invoBJ.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c!= null){
                    //inputobj.DWERK = invoBJ.EYI_Project__r.EYI_SAP_Plant_Code__c ;
                    inputobj.DWERK = invoBJ.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c ;
                }
                if(invoBJ.EYI_Inventory_Status__c!= null){
                    if(sfmapSAP.containsKey('EYI_Inventory_Status__c'+'~'+invoBJ.EYI_Inventory_Status__c)) 
                        inputobj.MSTAV =sfmapSAP.get('EYI_Inventory_Status__c'+'~'+invoBJ.EYI_Inventory_Status__c);// '1';//test
                    
                    //inputobj.VALID_FROM = String.valueof(system.today());
                    if(IS_StatusChange){
                        List<String> ddays = String.valueOf(system.today()).split('-');
                        system.debug('ddays  ===='+ddays);
                        string detedt;
                        if(!ddays.isEmpty()){
                            detedt = ddays[2] + '.' +ddays[1] +'.' +ddays[0];
                        }
                        inputobj.VALID_FROM=detedt;
                    }else if(!isPATCHOperation){
                        List<String> dday = String.valueOf(system.today()).split('-');
                        system.debug('dday  ===='+dday);
                        string deathhdt;
                        if(!dday.isEmpty()){
                            deathhdt = dday[2] + '.' +dday[1] +'.' +dday[0];
                        }
                        inputobj.VALID_FROM=deathhdt;
                    }
                }
                if(invoBJ.EYI_Inventory_Floor_No__c!= null){
                    //inputobj.MVGR1 ='003';
                    // this is not taking 003 in this field;
                    //inputobj.MVGR1 = String.valueof(invoBJ.EYI_Floor_Number__c) ;
                    //Added by Rishikesh on 26-02-2025
                    inputobj.MVGR1 =sfmapSAP.get('EYI_Floor_Number__c'+'~'+invoBJ.EYI_Inventory_Floor_No__c);
                }
                if(invoBJ.EYI_Typology__c!= null){
                    if(sfmapSAP.containsKey('EYI_Typology__c'+'~'+invoBJ.EYI_Typology__c)) 
                        inputobj.MVGR2 =sfmapSAP.get('EYI_Typology__c'+'~'+invoBJ.EYI_Typology__c);// '1';//test
                }
                if(invoBJ.EYI_View_based_on_Directions__c!= null){
                    if(sfmapSAP.containsKey('EYI_View_based_on_Directions__c'+'~'+invoBJ.EYI_View_based_on_Directions__c)) 
                        inputobj.MVGR3 =sfmapSAP.get('EYI_View_based_on_Directions__c'+'~'+invoBJ.EYI_View_based_on_Directions__c);// '1';//test
                }
                if(invoBJ.EYI_View_based_on_Amenities__c!= null){
                    if(sfmapSAP.containsKey('EYI_View_based_on_Amenities__c'+'~'+invoBJ.EYI_View_based_on_Amenities__c)) 
                        inputobj.MVGR4 =sfmapSAP.get('EYI_View_based_on_Amenities__c'+'~'+invoBJ.EYI_View_based_on_Amenities__c);// '1';//test
                }
                if(invoBJ.EYI_SAP_Affordable_Type__c!= null){
                    if(sfmapSAP.containsKey('EYI_SAP_Affordable_Type__c'+'~'+invoBJ.EYI_SAP_Affordable_Type__c)) 
                        inputobj.MVGR5 =sfmapSAP.get('EYI_SAP_Affordable_Type__c'+'~'+invoBJ.EYI_SAP_Affordable_Type__c);// '1';//test
                }
                if(invoBJ.EYI_SAP_Profit_Center__c!= null){
                    inputobj.PRCTR = String.valueof(invoBJ.EYI_SAP_Profit_Center__c) ;
                }
                CountInventory++;
                recInventory.IM_INPUT.add(inputobj);
                //recInventory.ImINPUT =inputobj;
            } 
            system.debug('recInventory  ' +recInventory);
            //HttpRequest req = new HttpRequest();
            String jsonBody =JSON.serialize(recInventory);
            String callType;
            system.debug('Genrate jsonBody'+jsonBody);
           // req.setBody(jsonBody);
            system.debug('isPATCHOperation-->'+isPATCHOperation);
            if(isPATCHOperation == true) callType = 'PATCH'; 
            else callType = 'POST'; 
            //req.setTimeout(120000);
            //req.setEndpoint('callout:SAP_Integration_Base/CreateUnitMasterSalesForce');
            // Create an HTTP object to send the request
            HTTPResponse res = new HTTPResponse();
            res = EY_SAP_Gateway.inventorySync(jsonBody, callType);
            
            
            // Send the HTTP request and get the response
           // res = http.send(req);
            
            // Check the response status code
            if (res.getStatusCode() == 200) {
                system.debug('Success jsonBody-->: '+res.getBody());
                // Deserialize the JSON into an untyped map
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                // Extract the "n0:ZSD_CREATE_UNITS_FROM_SFResponse" field from the map
                Map<String, Object> InventoryResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_UNITS_FROM_SFResponse');
                system.debug('InventoryResponse-->'+InventoryResponse);
                // Extract the message from InventoryResponse map.
                Map<String, Object> exReturn = (Map<String, Object>) InventoryResponse.get('EX_RETURN');
                system.debug('exReturn  '+exReturn);
                Object item =  exReturn.get('item');
                system.debug('item-->'+item);
                
                // Now you can access individual fields within the "item" map
                string successtype='';
                string successmMsg='';
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
                        }else{
                            successmMsg=messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                        }
                    }
                    system.debug('messagDisp  240==== '+messagDisp);
                }else if(item instanceof Map<String, Object>){
                    SYSTEM.DEBUG('item   '+item);
                    Map<String, Object> objitem = (Map<String, Object>) item;
                    SYSTEM.DEBUG('objitem   '+objitem);
                    type =  (String) objitem.get('TYPE');
                    successtype = (String) objitem.get('TYPE');
                    /* if (!type.contains('S')) {
messagDisp =(String) objitem.get('MESSAGE');
}*/
                    if(type!='S'){
                        type =(String) objitem.get('TYPE');
                        system.debug('Updating type  inside S loop '+type);
                        messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                    }else{
                            successmMsg=successmMsg+'\n--'+ (String) objitem.get('MESSAGE');
                        }
                    // messagDisp =(String) objitem.get('MESSAGE');
                }
                String output = removeDuplicates(messagDisp);
                System.debug('Unique Messages: ' + output);
                system.debug('messageDisp inside loop '+messagDisp);
                if(messagDisp!=null && type!=null  ){
                    for(EYI_Inventory__c invoBJ : inventories){
                        EYI_Inventory__c recUpd = new EYI_Inventory__c();
                        recUpd.Id =invoBJ.Id;
                        recUpd.EYI_SAP_Error__c = output;
                        recUpdateList.add(recUpd);
                    }
                    if(recUpdateList.size() > 0){
                        update recUpdateList;
                    }
                    
                    system.debug('Updating Inventory code');
                    
                }
                String cleanedType = successtype.replaceAll('-', '');
                String outputsuccessmMsg = removeDuplicates(successmMsg);
                System.debug('Unique Messages: ' + outputsuccessmMsg);
                // Check if the cleaned string contains only 'S'
                if (cleanedType != '' && cleanedType.replaceAll('S', '') == '') {
                    
                    system.debug('inventories    == '+inventories);
                    list<EYI_Inventory__c> updatelist= new  list<EYI_Inventory__c>();
                    for(EYI_Inventory__c invoBJ : inventories){
                        EYI_Inventory__c recUpd = new EYI_Inventory__c();
                        recUpd.id=invoBJ.id;
                        recUpd.EYI_SAP_Error__c =outputsuccessmMsg;
                        recUpd.EYI_Is_Syc__c = true;  
                        updatelist.add(recUpd);
                    }
                    if(updatelist.size()>0){
                        system.debug('updatelist    == '+updatelist);
                        update updatelist;
                        Type ='S';
                        messagDisp = updatelist.size()+' Inventories Synced to SAP Successfully.';
                    }
                    
                }
                
                SYSTEM.DEBUG('type  ==>>  '+type);
                SYSTEM.DEBUG('messagDisp   '+messagDisp);
                lm.type =  type;
                lm.message = output;
                SYSTEM.DEBUG('lm   '+lm);
                return lm;
            }
            else{
                lwcMessage lm2 = new lwcMessage();
                lm2.type =  'E';
                lm2.message = 'Internal server error from SAP! Please try after sometime.';
                return lm2;
            }
        } catch (Exception e) {
            // Handle exceptions
            lwcMessage lm2 = new lwcMessage();
            lm2.type =  'E';
            lm2.message = e.getMessage()+'---' +e.getLineNumber();
            for(EYI_Inventory__c invoBJ : inventories){
                EYI_Inventory__c recUpd = new EYI_Inventory__c();
                recUpd.Id =invoBJ.Id;
                recUpd.EYI_SAP_Error__c = lm2.message;
                recUpdateList.add(recUpd);
            }
            if(recUpdateList.size() > 0){
                update recUpdateList;
            }
            return lm2;
        }
        
    }
    public static String removeDuplicates(String input) {
        // Split the input string by "--" since messages are separated by "--"
        List<String> messages = input.split('--');
        
        // Use a Set to store unique messages
        Set<String> uniqueMessages = new Set<String>();
        
        // Iterate through messages and add to Set
        for (String msg : messages) {
            msg = msg.trim(); // Trim spaces to avoid mismatches
            if (!String.isBlank(msg)) { // Corrected from isEmpty() to isBlank()
                uniqueMessages.add(msg);
            }
        }
        
        // Convert Set back to List and join with "--"
        List<String> uniqueMessageList = new List<String>(uniqueMessages);
        return '--' + String.join(uniqueMessageList, '--'); // Corrected join syntax
    }
    public static lwcMessage requiredFieldForInventorySync(List<EYI_Inventory__C> inventories) {
        lwcMessage lm = new lwcMessage();
        Dynamic_Batch_Setting__c batchSetting = [SELECT Batch_size__c FROM Dynamic_Batch_Setting__c WHERE Name = 'Inventory Sync' LIMIT 1];
        String reqFieldError = System.Label.EYI_Cust_Sync_Req_field_Error;
		
        
        Boolean hasAnyError = false;  // Flag to check if any record has errors
        /*reqFieldError += ' EYI_Inventory__c : ';
        for (EYI_Inventory__c invoBJ : inventories) {
            Boolean hasErrors = false;  // Flag for this specific inventory record
            String recordErrors = '';   // Store error fields for this specific record
            
            if (String.isBlank(invoBJ.EYI_Project__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Project__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Tower__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Tower__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Inventory_Number__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Inventory_Number__c, ';
            }
            if (String.isBlank(invoBJ.EYI_SAP_Material_Type__c)) {
                hasErrors = true;
                recordErrors += 'EYI_SAP_Material_Type__c, ';
            }
            if (String.isBlank(invoBJ.EYI_TCS_Tax_Classification__c)) {
                hasErrors = true;
                recordErrors += 'EYI_TCS_Tax_Classification__c, ';
            }
            if (String.isBlank(invoBJ.EYI_GST_Tax_Classification__c)) {
                hasErrors = true;
                recordErrors += 'EYI_GST_Tax_Classification__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Inventory_Type__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Inventory_Type__c, ';
            }
            if (String.isBlank(invoBJ.EYI_UOM__c)) {
                hasErrors = true;
                recordErrors += 'EYI_UOM__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Material_Group__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Material_Group__c, ';
            }
            if (String.isBlank(String.valueOf(invoBJ.EYI_Carpet_Area__c))) {
                hasErrors = true;
                recordErrors += 'EYI_Carpet_Area__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Inventory_Status__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Inventory_Status__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Floor_Number__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Floor_Number__c, ';
            }
            if (String.isBlank(invoBJ.EYI_View_based_on_Directions__c)) {
                hasErrors = true;
                recordErrors += 'EYI_View_based_on_Directions__c, ';
            }
            if (String.isBlank(invoBJ.EYI_Typology__c)) {
                hasErrors = true;
                recordErrors += 'EYI_Typology__c, ';
            }
            if (String.isBlank(invoBJ.Name)) {
                hasErrors = true;
                recordErrors += 'Name, ';
            }
            if (String.isBlank(invoBJ.EYI_View_based_on_Amenities__c)) {
                hasErrors = true;
                recordErrors += 'EYI_View_based_on_Amenities__c, ';
            }
            if (String.isBlank(invoBJ.EYI_SAP_Affordable_Type__c)) {
                hasErrors = true;
                recordErrors += 'EYI_SAP_Affordable_Type__c, ';
            }
            if (String.isBlank(invoBJ.EYI_SAP_Profit_Center__c)) {
                hasErrors = true;
                recordErrors += 'EYI_SAP_Profit_Center__c, ';
            }
            
            // Append record number only if errors are found
            if (hasErrors) {
               // reqFieldError += NOofRecord + ' ' + recordErrors;
			   //hasAnyError = true; // Set global flag
                lm.type = 'e';
                reqFieldError += ' (' + recordErrors.substring(0, recordErrors.length() - 2) + '), ';

            }
        } */
        // Remove the trailing comma and space before setting the error message
        if (lm.type == 'e') {   
           string unqineErrormsg = removeDuplicate(reqFieldError);
            unqineErrormsg = unqineErrormsg.trim();
            if (unqineErrormsg.endsWith(',')) {
                unqineErrormsg = unqineErrormsg.substring(0, unqineErrormsg.length() - 1);
            }
            lm.message = unqineErrormsg;
        } else {
            Integer batchSize = (batchSetting.Batch_size__c != null) ? Integer.valueOf(batchSetting.Batch_size__c) : 20;
            EYI_InventoryCalloutBatch inventoryJob = new EYI_InventoryCalloutBatch(inventories, false);
            Database.executeBatch(inventoryJob, batchSize);
            lm.type = 'S';
            lm.message = 'Sync Job has been started';
        }
        
        return lm;
    }
        public static String removeDuplicate(String input) {
        List<String> messages = input.split(',');
        Set<String> uniqueMessages = new Set<String>();
        
        // Iterate through messages and add to Set
        for (String msg : messages) {
            msg = msg.trim(); // Trim spaces to avoid mismatches
            if (!String.isBlank(msg)) { // Corrected from isEmpty() to isBlank()
                uniqueMessages.add(msg);
            }
        }
        List<String> uniqueMessageList = new List<String>(uniqueMessages);
        return '' + String.join(uniqueMessageList, ','); // Corrected join syntax
    }
    
    public class lwcMessage {
        @AuraEnabled public String type;
        @AuraEnabled public String message;        
    }
}