public class EYI_PricingCallout {
    @AuraEnabled
    public static lwcMessage pricingDataSync(String recordId ){
        lwcMessage lm = new lwcMessage();
        Boolean isPATCHOperation = false;
        
        
        if(recordId!= null){
            SObjectType sobjTypeId = Id.valueOf(recordId).getSObjectType();
            System.debug('sobjTypeId: ' + sobjTypeId);
            
            if (sobjTypeId == EYI_Tower__c.SObjectType) {          
                EYI_Tower__c RecTower= [Select id , name ,
                                        (select id,EYI_Condition_Type__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Non_Master_Price__c, EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Project__r.EYI_SAP_Plant_Code__c, EYI_Pricing_Amount__c,EYI_Pricing_Percentage__c,
                                         EYI_Pricing_Quantity__c,EYI_Calculation_Type__c, EYI_Rate__c, EYI_Inventory__r.EYI_Inventory_Number__c,EYI_Distruibution_Channel__c,EYI_is_Sync_SAP__c,
                                         EYI_Inventory__r.EYI_SAP_Material_Code__c
                                         from Rate_Lists__r where EYI_is_Sync_SAP__c=false AND EYI_Non_Master_Price__c= false order by createddate asc)
                                        from EYI_Tower__c where id=:recordId limit 1];
                
                if(RecTower!= null){
                    return processPricingRecords(RecTower.Rate_Lists__r, isPATCHOperation);
                }
            }Else if(sobjTypeId == EYI_Project__c.SObjectType){
                EYI_Project__c RecProject= [Select id , name ,
                                            (select id,EYI_Condition_Type__c, EYI_Non_Master_Price__c, EYI_Tower__r.EYI_SAP_Plant_ID__c, EYI_Project__r.EYI_SAP_Salesorg__c,EYI_Project__r.EYI_SAP_Plant_Code__c, EYI_Pricing_Amount__c,EYI_Pricing_Percentage__c,
                                             EYI_Pricing_Quantity__c,EYI_Calculation_Type__c, EYI_Rate__c, EYI_Inventory__r.EYI_Inventory_Number__c,EYI_Distruibution_Channel__c,EYI_is_Sync_SAP__c,
                                             EYI_Inventory__r.EYI_SAP_Material_Code__c
                                             from Rate_Lists__r where EYI_is_Sync_SAP__c=false AND EYI_Non_Master_Price__c= false order by createddate asc)
                                            from EYI_Project__c where id=:recordId limit 1];
                if(RecProject!= null){
                    return processPricingRecords(RecProject.Rate_Lists__r, isPATCHOperation);
                    
                }
            }else {
                lm.type = 'E';
                lm.message = 'Unsupported record type for Pricing Sync';
                return lm;
            }   
        }else{
            
            lm.type =  'E';
            lm.message = 'Record Id Missing';
            return lm;
        }
        return null;
    }
    public static lwcMessage processPricingRecords(List<EYI_Rate_List__c> PricingList,  Boolean isPATCHOperation) {
        Map<String, String> sfmapSAP = new Map<String, String>();
        String PricingId ='';
        lwcMessage lm = new lwcMessage();
        EYI_PricingCreationWrapper pc = new EYI_PricingCreationWrapper();
        EYI_PricingCreationWrapper.IMaster imast = new EYI_PricingCreationWrapper.IMaster();
        
        system.debug('PricingList size --> '+ PricingList.size());
        // List<EYI_PricingCreationWrapper.EReturn> pcRetunr =new List<EYI_PricingCreationWrapper.EReturn>();
        // List<EYI_PricingCreationWrapper.item> pcRetunr =new List<EYI_PricingCreationWrapper.item>();
        List<SAP_SF_Field_Map__c> mapData = [select Id, Name, SF_Field_Name__c, SF_Value__c, SAP_Value__c from SAP_SF_Field_Map__c 
                                             where SF_Field_Name__c IN ('EYI_Condition_Type__c','EYI_Distruibution_Channel__c','EYI_Calculation_Type__c')];
        if(!mapData.isEmpty()){
            for(SAP_SF_Field_Map__c mp :mapData){
                sfmapSAP.put(mp.SF_Field_Name__c + '~' + mp.SF_Value__c, mp.SAP_Value__c);
                system.debug('key'+mp.SF_Field_Name__c + '~' + mp.SF_Value__c+'value'+mp.SAP_Value__c);
            } 
        }
        try{
             
            for(EYI_Rate_List__c rl :PricingList){
                PricingId= rl.id;
                // EYI_PricingCreationWrapper.EReturn er = new EYI_PricingCreationWrapper.EReturn();
                EYI_PricingCreationWrapper.cls_item er = new EYI_PricingCreationWrapper.cls_item();
                
                if(rl.EYI_Condition_Type__c !=null && sfmapSAP.containsKey('EYI_Condition_Type__c'+'~'+rl.EYI_Condition_Type__c)) 
                    if(rl.EYI_Condition_Type__c == 'Base Price'){
                        er.KSCHL='ZRCP';
                    }else{
                        er.KSCHL = sfmapSAP.get('EYI_Condition_Type__c'+'~'+rl.EYI_Condition_Type__c);// '1';//test
                    }
                    
                if(rl.EYI_Project__c!=null && rl.EYI_Project__r.EYI_SAP_Salesorg__c!=null)   
                    er.VKORG =rl.EYI_Project__r.EYI_SAP_Salesorg__c ;
                if(rl.EYI_Tower__c!=null && rl.EYI_Tower__r.EYI_SAP_Plant_ID__c!=null)       
                    er.WERKS = rl.EYI_Tower__r.EYI_SAP_Plant_ID__c;
                if(rl.EYI_Distruibution_Channel__c!=null  && sfmapSAP.containsKey('EYI_Distruibution_Channel__c'+'~'+rl.EYI_Distruibution_Channel__c))
                    er.VTWEG = sfmapSAP.get('EYI_Distruibution_Channel__c'+'~'+rl.EYI_Distruibution_Channel__c);
                if(rl.EYI_Inventory__c !=null )   
                    er.MATNR = rl.EYI_Inventory__r.EYI_Inventory_Number__c;
                if(rl.EYI_Calculation_Type__c!=null){
                    if(rl.EYI_Calculation_Type__c =='Percentage' && rl.EYI_Pricing_Percentage__c!=null) 
                        er.KBETR = rl.EYI_Pricing_Percentage__c;
                    else if(rl.EYI_Calculation_Type__c =='Fixed Amount' && rl.EYI_Pricing_Amount__c!=null) 
                        er.KBETR = rl.EYI_Pricing_Amount__c;
                    else if(rl.EYI_Calculation_Type__c =='Quantity' && rl.EYI_Rate__c!=null) 
                        er.KBETR = rl.EYI_Rate__c;
                }
                if(rl.EYI_Calculation_Type__c !=null &&  sfmapSAP.containsKey('EYI_Calculation_Type__c'+'~'+rl.EYI_Calculation_Type__c))   
                    er.KRECH = sfmapSAP.get('EYI_Calculation_Type__c'+'~'+rl.EYI_Calculation_Type__c);
                
                imast.item.add(er);
            }
            // system.debug('Genrate jsonBody'+imast);
            
            //for loop end
            // pc.E_RETURN = pcRetunr;
            //imast.item = pcRetunr;
            pc.I_MASTER = imast;
            HttpRequest req = new HttpRequest();
            String jsonBody =JSON.serialize(pc);
            
           	HTTPResponse res = new HTTPResponse();
            res = EY_SAP_Gateway.pricingSync(jsonBody);
            /*system.debug('Genrate jsonBody'+jsonBody);
            req.setBody(jsonBody);
            req.setMethod('POST'); 
            req.setTimeout(120000);
            
            req.setEndpoint('callout:SAP_Integration_Base' +'/CreatePriceMasterSalesForce' );
            // Create an HTTP object to send the request
            Http http = new Http();
            HttpResponse res;
            
            // Send the HTTP request and get the response
            res = http.send(req);*/
            
            // Check the response status code
            if (res.getStatusCode() == 200) {
                system.debug('Success jsonBody-->: '+res.getBody());
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String typeVal = (String) responseMap.get('TYPE');
                String idVal = (String) responseMap.get('ID');
                Integer numberVal = (Integer) responseMap.get('NUMBER');
                //String type = (String) responseMap.get('MESSAGE');
                // Extract the "n0:ZSD_CREATE_PRICE_FROM_SFResponse" field from the map
                
                Map<String, Object> PricingResponse = (Map<String, Object>) responseMap.get('n0:ZSD_CREATE_PRICE_FROM_SFResponse');
                system.debug('PricingResponse-->'+PricingResponse);
                // Now you can access individual fields within the "item" map
                String type = '';
                String messagDisp = '';
                // Extract the message from vendorResponse map.
                if(PricingResponse.containskey('E_RETURN')){
                    Map<String, Object> E_RETURN = (Map<String, Object>) PricingResponse.get('E_RETURN');
                    system.debug('E_RETURN  '+E_RETURN);
                    Object item =  E_RETURN.get('item');
                    system.debug('item-->'+item);
                    
                    
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
                }else{
                    type= 'E';
                    messagDisp='E_RETURN do not get any value';
                }
                System.debug('messagDisp ::: '+messagDisp);
                System.debug('type ::: '+type);
                System.debug('isPATCHOperation ::: '+isPATCHOperation);
                if(messagDisp!=null && type!=null && isPATCHOperation ==true){
                    EYI_Rate_List__c recUpd = new EYI_Rate_List__c();
                    recUpd.Id =PricingId;
                    recUpd.EYI_SAP_Error__c = messagDisp;
                    //recUpd.EYI_SAP_Request__c = jsonBody;
                    update recUpd;
                    system.debug('Updating Pricing code');
                    
                }else{
                    System.debug('Inside else to Update SF Paricing Data '+PricingList.Size());
                    list<EYI_Rate_List__c> updatelist= new  list<EYI_Rate_List__c>();
                    for(EYI_Rate_List__c invoBJ : PricingList){
                        invoBJ.EYI_is_Sync_SAP__c = true;  
                        updatelist.add(invoBJ);
                    }
                    System.debug('updatelist : '+updatelist.Size());
                    if(updatelist.size()>0){
                        update updatelist;
                        Type ='S';
                        messagDisp = updatelist.size()+' Pricing Synced to SAP Successfully.';
                    }
                }
                SYSTEM.DEBUG('type   '+type);
                SYSTEM.DEBUG('messagDisp   '+messagDisp);
                lm.type =  type;
                lm.message = messagDisp;
                SYSTEM.DEBUG('lm   '+lm);
                return lm;                
            }
            
        }catch(exception e){
            system.debug('error-->'+e.getMessage());
            lwcMessage lm2 = new lwcMessage();
            lm2.type =  'E';
            lm2.message = e.getMessage()+'---' +e.getLineNumber();
            return lm2;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getSyncValue(Id projectId, String lwc){
        Boolean isSynced = true;
        try{
            if(lwc == 'Pricing'){
                List<EYI_Rate_List__c> rateList = [Select Id, EYI_is_Sync_SAP__c from EYI_Rate_List__c where EYI_Project__c = :projectId and EYI_is_Sync_SAP__c = false AND EYI_Non_Master_Price__c= false];
                if(rateList.size() > 0){
                    isSynced = false;
                }
            }
            else if(lwc == 'Inventory'){
                List<EYI_Inventory__c> inventoryList = [Select Id, EYI_Is_Syc__c from EYI_Inventory__c where EYI_Project__c = :projectId and EYI_Is_Syc__c = false];
                if(inventoryList.size() > 0){
                    isSynced = false;
                }
            }
            else{
                List<EYI_Car_Park_Master__c	> carParkList = [Select Id, EYI_Is_Syc__c from EYI_Car_Park_Master__c	 where EYI_Project__c = :projectId and EYI_Is_Syc__c = false];
                if(carParkList.size() > 0){
                    isSynced = false;
                }
            }
        }
        catch(Exception e){
            System.debug('Exception--->'+e);
        }
        return isSynced;
    }
    public class lwcMessage{
        @AuraEnabled  public string type;
        @AuraEnabled  public string message;
    }
}