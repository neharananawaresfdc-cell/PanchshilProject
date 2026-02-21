public with sharing class EYI_ZSDDemandResponseWrapper {
        public ZSD_DEMAND_FROM_SFResponse n0_ZSD_DEMAND_FROM_SFResponse;
    
        public class ZSD_DEMAND_FROM_SFResponse {
            public EX_OUTPUT EX_OUTPUT;
        }
    
        public class EX_OUTPUT {
            public List<Item> item;
        }
    
        public class Item {
            public String TYPE;
            public String KUNNR;
            public String VBELN;
            public String VBELN_VF;
            public String VKORG;
            public String VTWEG;
            public String MATNR;
            public String POSNR;
            public String FKDAT;
            public String NETWR;
            public String TAX;
            public String PRINCIPAL;
            public String CHARGES;
            public String TIMEBOUND;
            public String MLBEZ;
            public String MLBEZ_DESC;
            public String WAERS;
            public String MLSTN;
            public String CUSTOM1;
            public String CUSTOM2;
            public String CUSTOM3;
            public String MSGTYPE;
            public String ID;
            //public String NUMBER;
            public String MESSAGE;
        }
    
        // Optional: Method to parse JSON into this wrapper
        public static EYI_ZSDDemandResponseWrapper parse(String jsonString) {
            return (EYI_ZSDDemandResponseWrapper) JSON.deserialize(jsonString, EYI_ZSDDemandResponseWrapper.class);
        }
    }