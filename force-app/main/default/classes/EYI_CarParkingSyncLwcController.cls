public class EYI_CarParkingSyncLwcController {
    @AuraEnabled
    public static lwcMessage CarParkingSync(String recordId) {
        lwcMessage lm = new lwcMessage();
        Boolean isPATCHOperation = false;
        
        
        if(recordId != null) {
            SObjectType sobjTypeId = Id.valueOf(recordId).getSObjectType();
            System.debug('sobjTypeId: ' + sobjTypeId);
            
            if (sobjTypeId == EYI_Tower__c.SObjectType) {
                EYI_Tower__c towerRecord = [SELECT id, name, 
                                            (SELECT id,Name,EYI_SAP_Material_Type__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Material_Group__c,	EYI_Base_UOM__c,EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,EYI_SAP_Material_Description__c,
                                             EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Status__c,EYI_Parking_Number__c,EYI_Distruibution_Channel__c,EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_External_Material_Group__c,
                                             EYI_Lab_Office__c,EYI_X_Plant_Mat_Status__c,EYI_Built_up_Area__c,EYI_Floor_Number__c,EYI_SAP_Affordable_Type__c,Configuration__c,EYI_SAP_Profit_Center__c,
                                             EYI_Account_Assignment_Group__c,EYI_Sales_Unit__c,EYI_Item_Category__c,EYI_GST_Tax_Classification__c,EYI_TCS_Tax_Classification__c,EYI_Is_Syc__c
                                             FROM Car_Park_Masters__r WHERE EYI_Is_Syc__c=false) 
                                            FROM EYI_Tower__c WHERE id = :recordId  LIMIT 1];
                return processCarparkingRecords(towerRecord.Car_Park_Masters__r, isPATCHOperation);
            } else if (sobjTypeId == EYI_Project__c.SObjectType) {
                EYI_Project__c projectRecord = [SELECT id, name, 
                                                (SELECT id,Name,EYI_SAP_Material_Type__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Material_Group__c,EYI_Base_UOM__c,EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c,EYI_SAP_Material_Description__c,
                                                 EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Status__c,EYI_Parking_Number__c,EYI_Distruibution_Channel__c,EYI_Project__r.EYI_SAP_Plant_Code__c,EYI_External_Material_Group__c,
                                                 EYI_Lab_Office__c,EYI_Built_up_Area__c,EYI_Floor_Number__c,EYI_SAP_Affordable_Type__c,Configuration__c,EYI_SAP_Profit_Center__c,EYI_X_Plant_Mat_Status__c,
                                                 EYI_Account_Assignment_Group__c,EYI_Sales_Unit__c,EYI_Item_Category__c,EYI_TCS_Tax_Classification__c,EYI_GST_Tax_Classification__c,EYI_Is_Syc__c
                                                 FROM Car_Park_Masters__r WHERE EYI_Is_Syc__c=false)
                                                FROM EYI_Project__c WHERE id = :recordId LIMIT 1];
                //return processCarparkingRecords(projectRecord.Car_Park_Masters__r, isPATCHOperation);
                Dynamic_Batch_Setting__c batchSetting = [SELECT Batch_size__c FROM Dynamic_Batch_Setting__c WHERE Name LIKE 'Car Park Sync%' ORDER BY Name LIMIT 1];
                
                // Default batch size if not set
                Integer batchSize = (batchSetting.Batch_size__c != null) ? Integer.valueOf(batchSetting.Batch_size__c) : 20;
                EYI_CarParkCalloutBatch carParkJob = new EYI_CarParkCalloutBatch(projectRecord.Car_Park_Masters__r);
                Database.executeBatch(carParkJob, batchSize);
                lm.type = 'S';
                lm.message = 'Sync Job has been started';
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
    
    public static lwcMessage processCarparkingRecords(List<EYI_Car_Park_Master__c> CarParkies,  Boolean isPATCHOperation) {
        // Common logic for processing inventory records
        // Extracted from the duplicated code for EYI_Tower__c and EYI_Project__c
        String carparkingId ='';
        lwcMessage lm = new lwcMessage();
        EYI_RECInventoryCreationWrapper recInventory = new EYI_RECInventoryCreationWrapper();
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
            for(EYI_Car_Park_Master__c CarprkBJ : CarParkies){
                EYI_RECInventoryCreationWrapper.cls_ImInput  inputobj = new EYI_RECInventoryCreationWrapper.cls_ImInput ();
                if(CarprkBJ.EYI_Parking_Number__c!= null){
                    inputobj.MATNR = CarprkBJ.EYI_Parking_Number__c;
                    //  isPATCHOperation = true;
                }
                if(CarprkBJ.Name!= null){
                    inputobj.Name = CarprkBJ.Name;
                    inputobj.MBRSH ='';       // not madentory                        
                    inputobj.MTPOS = '';
                    inputobj.GEWEI = '';
                    inputobj.ITEM_CAT =''; 
                    carparkingId =CarprkBJ.id;
                }
                if(CarprkBJ.EYI_SAP_Material_Type__c!= null){
                    if(sfmapSAP.containsKey('EYI_SAP_Material_Type__c'+'~'+CarprkBJ.EYI_SAP_Material_Type__c)) 
                        inputobj.MTART =sfmapSAP.get('EYI_SAP_Material_Type__c'+'~'+CarprkBJ.EYI_SAP_Material_Type__c);// '1';//test
                }
                
                if(CarprkBJ.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c!= null){
                    inputobj.WERKS = CarprkBJ.EYI_Tower__r.EYI_SAP_Delivery_Plant_Code__c ;
                }
                if(CarprkBJ.EYI_Project__r.EYI_SAP_Salesorg__c!= null){
                    inputobj.VKORG = CarprkBJ.EYI_Project__r.EYI_SAP_Salesorg__c ;
                }
                if(CarprkBJ.EYI_SAP_Material_Description__c!= null){
                    inputobj.MAKTX =CarprkBJ.EYI_SAP_Material_Description__c ;
                }
                
                if(CarprkBJ.EYI_External_Material_Group__c!= null){
                    inputobj.EXTWG =CarprkBJ.EYI_External_Material_Group__c ;
                }
                if(CarprkBJ.EYI_Lab_Office__c!= null){
                    inputobj.LABOR =CarprkBJ.EYI_Lab_Office__c ;
                }
             
                if(CarprkBJ.EYI_Built_up_Area__c!= null){
                    inputobj.BUL_AREA = String.valueof(CarprkBJ.EYI_Built_up_Area__c) ;
                }
                if(CarprkBJ.EYI_X_Plant_Mat_Status__c!= null){
                    if(sfmapSAP.containsKey('EYI_X_Plant_Mat_Status__c'+'~'+CarprkBJ.EYI_X_Plant_Mat_Status__c)) 
                        inputobj.MSTAE =sfmapSAP.get('EYI_X_Plant_Mat_Status__c'+'~'+CarprkBJ.EYI_X_Plant_Mat_Status__c);// '1';//test
                }
                if(CarprkBJ.EYI_Distruibution_Channel__c!= null){
                    if(sfmapSAP.containsKey('EYI_Distruibution_Channel__c'+'~'+CarprkBJ.EYI_Distruibution_Channel__c)) 
                        inputobj.VTWEG =sfmapSAP.get('EYI_Distruibution_Channel__c'+'~'+CarprkBJ.EYI_Distruibution_Channel__c);// '1';//test
                }
                 if(CarprkBJ.EYI_Item_Category__c!= null){
                    if(sfmapSAP.containsKey('EYI_Item_Category__c'+'~'+CarprkBJ.EYI_Item_Category__c)) 
                        inputobj.MTPOS =sfmapSAP.get('EYI_Item_Category__c'+'~'+CarprkBJ.EYI_Item_Category__c);// '1';//test
                }
                if(CarprkBJ.EYI_Base_UOM__c!= null){
                    if(sfmapSAP.containsKey('EYI_UOM__c'+'~'+CarprkBJ.EYI_Base_UOM__c)) 
                        inputobj.MEINS =sfmapSAP.get('EYI_UOM__c'+'~'+CarprkBJ.EYI_Base_UOM__c);// '1';//test
                }
                if(CarprkBJ.EYI_TCS_Tax_Classification__c!= null){
                    if(sfmapSAP.containsKey('EYI_TCS_Tax_Classification__c'+'~'+CarprkBJ.EYI_TCS_Tax_Classification__c)) 
                        inputobj.TAX_CLASS_TCS =sfmapSAP.get('EYI_TCS_Tax_Classification__c'+'~'+CarprkBJ.EYI_TCS_Tax_Classification__c);// '1';//test
                }
                if(CarprkBJ.EYI_GST_Tax_Classification__c!= null){
                    if(sfmapSAP.containsKey('EYI_GST_Tax_Classification__c'+'~'+CarprkBJ.EYI_GST_Tax_Classification__c)) 
                        inputobj.TAX_CLASS =sfmapSAP.get('EYI_GST_Tax_Classification__c'+'~'+CarprkBJ.EYI_GST_Tax_Classification__c);// '1';//test
                }
                if(CarprkBJ.EYI_Material_Group__c!= null){
                    if(sfmapSAP.containsKey('EYI_Material_Group__c'+'~'+CarprkBJ.EYI_Material_Group__c)) 
                        inputobj.MATKL =sfmapSAP.get('EYI_Material_Group__c'+'~'+CarprkBJ.EYI_Material_Group__c);// '1';//test
                }
                
                // we need to add EYI_SAP_Plant_Code__c from EYI_SAP_Salesorg__c
                if(CarprkBJ.EYI_Tower__r.EYI_SAP_Plant_ID__c!= null){
                    inputobj.DWERK = CarprkBJ.EYI_Tower__r.EYI_SAP_Plant_ID__c ;
                }
                if(CarprkBJ.EYI_Floor_Number__c!= null){
                    inputobj.MVGR1 = String.valueof(CarprkBJ.EYI_Floor_Number__c) ;
                }
                if(CarprkBJ.EYI_Sales_Unit__c!= null){
                    inputobj.VRKME = String.valueof(CarprkBJ.EYI_Sales_Unit__c) ;
                }
                if(CarprkBJ.Configuration__c!= null){
                    if(sfmapSAP.containsKey('Configuration__c'+'~'+CarprkBJ.Configuration__c)) 
                        inputobj.MVGR2 =sfmapSAP.get('Configuration__c'+'~'+CarprkBJ.Configuration__c);// '1';//test
                }
                if(CarprkBJ.EYI_SAP_Affordable_Type__c!= null){
                    if(sfmapSAP.containsKey('EYI_SAP_Affordable_Type__c'+'~'+CarprkBJ.EYI_SAP_Affordable_Type__c)) 
                        inputobj.MVGR5 =sfmapSAP.get('EYI_SAP_Affordable_Type__c'+'~'+CarprkBJ.EYI_SAP_Affordable_Type__c);// '1';//test
                }
                if(CarprkBJ.EYI_SAP_Profit_Center__c!= null){
                    inputobj.PRCTR = String.valueof(CarprkBJ.EYI_SAP_Profit_Center__c) ;
                }
                 if(CarprkBJ.EYI_Account_Assignment_Group__c!= null){
                    if(sfmapSAP.containsKey('EYI_Account_Assignment_Group__c'+'~'+CarprkBJ.EYI_Account_Assignment_Group__c)) 
                        inputobj.KTGRM =sfmapSAP.get('EYI_Account_Assignment_Group__c'+'~'+CarprkBJ.EYI_Account_Assignment_Group__c);// '1';//test
                }
                
                if(CarprkBJ.EYI_Status__c!= null){
                    if(sfmapSAP.containsKey('EYI_Inventory_Status__c'+'~'+CarprkBJ.EYI_Status__c)) 
                        inputobj.MSTAV =sfmapSAP.get('EYI_Inventory_Status__c'+'~'+CarprkBJ.EYI_Status__c);// '1';//test
                    List<String> dday = String.valueOf(system.today()).split('-');
                    system.debug('dday  ===='+dday);
                    string deathhdt;
                    if(!dday.isEmpty()){
                        deathhdt = dday[2] + '.' +dday[1] +'.' +dday[0];
                    }
                    inputobj.VALID_FROM=deathhdt;
                    //inputobj.VALID_FROM = String.valueof(system.today());
                    // if(){
                    
                    //}
                }
                
                recInventory.IM_INPUT.add(inputobj);
                //recInventory.ImINPUT =inputobj;
            } 
            system.debug('recInventory  ' +recInventory);
            //HttpRequest req = new HttpRequest();
            String jsonBody =JSON.serialize(recInventory);
            system.debug('Genrate jsonBody'+jsonBody);
            //req.setBody(jsonBody);
            system.debug('isPATCHOperation-->'+isPATCHOperation);
            /*if(isPATCHOperation == true) req.setMethod('PATCH'); 
            else req.setMethod('POST'); */
            String callType;
            if(isPATCHOperation == true) callType = 'PATCH'; 
            else callType = 'POST';
            
            //req.setTimeout(120000);
            HTTPResponse res = new HTTPResponse();
            res = EY_SAP_Gateway.carParkSync(jsonBody, callType);
            
            /*req.setEndpoint('callout:SAP_Integration_Base/CreateUnitMasterSalesForce');
            req.setEndpoint('callout:CreateUnitMasterSalesForce');
            // Create an HTTP object to send the request
            Http http = new Http();
            HttpResponse res;*/
            
            
            // Send the HTTP request and get the response
           // res = http.send(req);
            
            // Check the response status code
            if (res.getStatusCode() == 200) {
                system.debug('Response -->: '+res.getBody());
                // Deserialize the JSON into an untyped map
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                // Extract the "n0:ZSD_CREATE_UNITS_FROM_SFResponse" field from the map
                Map<String, Object> CarparkingResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_UNITS_FROM_SFResponse');
                system.debug('CarparkingResponse-->'+CarparkingResponse);
                // Extract the message from CarparkingResponse map.
                Map<String, Object> exReturn = (Map<String, Object>) CarparkingResponse.get('EX_RETURN');
                system.debug('exReturn  '+exReturn);
                Object item =  exReturn.get('item');
                system.debug('item-->'+item);
                
                // Now you can access individual fields within the "item" map
                String type = '';
                String messagDisp = '';
                if (item instanceof List<Object>) {
                    List<Object> itemList = (List<Object>) item;
                    
                    for (Object obj : itemList) {
                        Map<String, Object> objitem = (Map<String, Object>) obj;
                        string types =(String) objitem.get('TYPE');
                        //system.debug('Updating type '+type);
                        // if (!type.contains('S')) {
                        if(types!='S'){
                            type =(String) objitem.get('TYPE');
                            system.debug('Updating type  inside S loop '+types);
                            messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                        }
                    }
                }else if(item instanceof Map<String, Object>){
                    SYSTEM.DEBUG('item   '+item);
                    Map<String, Object> objitem = (Map<String, Object>) item;
                    SYSTEM.DEBUG('objitem   '+objitem);
                     type =  (String) objitem.get('TYPE');
                   
                      if(type!='S'){
                              type =(String) objitem.get('TYPE');
                          system.debug('Updating type  inside S loop '+type);
                           messagDisp =messagDisp+'\n--'+ (String) objitem.get('MESSAGE');
                         }
                }
                System.debug('messagDisp : '+messagDisp);
                System.debug('type : '+type);
                System.debug('isPATCHOperation : '+isPATCHOperation);
                if( messagDisp != '' &&  type !='' && isPATCHOperation ==true){
                    List<EYI_Car_Park_Master__c> CarprkBJList = new List<EYI_Car_Park_Master__c>();
                    for(EYI_Car_Park_Master__c CarprkBJ : CarParkies){
                         EYI_Car_Park_Master__c recUpd = new EYI_Car_Park_Master__c();
                        recUpd.Id =CarprkBJ.Id;
                        recUpd.EYI_SAP_Error__c = messagDisp;
                        CarprkBJList.add(recUpd);
                    }
                    if(CarprkBJList.size() > 0){
                        update CarprkBJList;
                    }
                    
                    system.debug('Updating carparking code');
                    
                }else{
                    system.debug('CarParkies    == '+CarParkies);
                     list<EYI_Car_Park_Master__c> updatelist= new  list<EYI_Car_Park_Master__c>();
                    for(EYI_Car_Park_Master__c carpark : CarParkies){
                        carpark.EYI_Is_Syc__c = true;  
                        updatelist.add(carpark);
                    }
                    if(updatelist.size()>0){
                         system.debug('updatelist    == '+updatelist);
                        update updatelist;
                           Type ='S';
                        messagDisp = updatelist.size()+' Car Parking Synced to SAP Successfully.';
                    }
                       
                }
               
                SYSTEM.DEBUG('type   '+type);
                SYSTEM.DEBUG('messagDisp   '+messagDisp);
                lm.type =  type;
                lm.message = messagDisp;
                SYSTEM.DEBUG('lm   '+lm);
                return lm;
                
                
            }
        } catch (Exception e) {
            // Handle exceptions
            lwcMessage lm2 = new lwcMessage();
            lm2.type =  'E';
            lm2.message = e.getMessage()+'---' +e.getLineNumber();
            return lm2;
            
        }
        
        return new lwcMessage(); // Return a new lwcMessage object with appropriate values
    }
    
    public class lwcMessage {
        @AuraEnabled public String type;
        @AuraEnabled public String message;        
    }
}