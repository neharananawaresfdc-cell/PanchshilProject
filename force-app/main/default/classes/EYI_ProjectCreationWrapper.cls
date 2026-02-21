/**
 * @Name: EYI_ProjectCreationWrapper
 * @Description: This is a wrapper class for Project creation.
 * @Author: Rishikesh Kale
 * @Creation Date: 21-Jan-2025
 * @Creation Date:21-Jan-2025
 * @Version: 1
 * @Usage: This class should not be instantiated directly. It is called by the EYI_ProjectSyncToMobileApp.
 * @Example: 
 * @See: EYI_ProjectSyncToMobileApp
 * @Related: EYI_ProjectSyncToMobileApp
 * @Notes: 
**/

public class EYI_ProjectCreationWrapper {
    public String Property_Type;	
    public String SFDC_Project_Id;	
    public String Project_Construction_Status;
    public String Configuration_Type;	
    public String Project_Name;	
    public String Location;	
    public String Project_Description;	
    public String Price_Onward;	
    public Decimal Project_Size_Sq_Mtr;	
    public Decimal Project_Size_Sq_Ft;	
    public Decimal Rera_Carpet_Area_Sq_M;	
    public Decimal Rera_Carpet_Area_sqft;
    public String Number_Of_Towers;	
    public Decimal Number_Of_Units;	
    public String Rera_Number;	
    public String Amenities;	
    public String Specifications;	
    public String Land_Area;	
    public String Project_Location;	
    public List<TowerWrapper> towers;
    
    // Constructor to map fields from the EYI_Project__c object
    public EYI_ProjectCreationWrapper(EYI_Project__c projectRecord, List<EYI_Tower__c> towerList) {
        this.Property_Type = projectRecord.EYI_Project_Property_Type__c;
        this.SFDC_Project_Id = String.valueOf(projectRecord.Id); // Assign the Salesforce record ID as a string
        this.Project_Construction_Status = projectRecord.EYI_Project_Status__c;
        this.Configuration_Type = projectRecord.EYI_Configuration_Types__c;
        this.Project_Name = projectRecord.Name;
        this.Project_Location = projectRecord.EYI_Project_Location__c;
        this.Project_Description = projectRecord.EYI_Project_Description__c;
        this.Price_Onward = projectRecord.EYI_Price_Onwards__c;
        this.Project_Size_Sq_Mtr = projectRecord.EYI_Project_Size_In_Sq_Mtr__c;
        this.Project_Size_Sq_Ft = projectRecord.EYI_Project_Size_In_Sq_Ft__c;
        this.Rera_Carpet_Area_Sq_M = projectRecord.EYI_Rera_Carpet_Area_In_Sq_Ft__c;
        this.Rera_Carpet_Area_sqft = projectRecord.EYI_Rera_Carpet_Area_In_Sq_Ft__c;
        this.Number_Of_Towers = String.ValueOf(projectRecord.EYI_Number_Of_Towers__c);
        this.Number_Of_Units = projectRecord.EYI_Number_Of_Units__c;
        this.Rera_Number = projectRecord.EYI_Rera_Number__c;
        this.Land_Area = projectRecord.EYI_Land_Area__c;
        this.towers = new List<TowerWrapper>();
        if (towerList != null && !towerList.isEmpty()) {
            for (EYI_Tower__c tower : towerList) {
                towers.add(new TowerWrapper(tower));
            }
        }
    }
    public class TowerWrapper {
        public String Name;
        public String SFDC_Tower_Id;

        public TowerWrapper(EYI_Tower__c tower) {
            this.Name = tower.Name;
            this.SFDC_Tower_Id = tower.Id;
        }
    }
}

/* Mobile App access token Response
  {
    "user": {
        "id": 2,
        "email": "user9@gmail.com",
        "firstname": "Ankit",
        "lastname": "Gupta",
        "mobile": "7388097282",
        "otp": "57059",
        "token": null,
        "number_verified": true,
        "persistence_token": null,
        "perishable_token": null,
        "last_request_at": null,
        "login": null,
        "authentication_token": null,
        "deleted_at": null,
        "avatar_file_name": null,
        "avatar_content_type": null,
        "avatar_file_size": null,
        "avatar_updated_at": null,
        "supplier_id": null,
        "latitude": 0.0,
        "longitude": 0.0,
        "role_id": null,
        "company_id": null,
        "department_id": null,
        "is_busy_on_call": false,
        "is_online": false,
        "is_available": true,
        "country_code": "91",
        "alternate_email1": null,
        "alternate_email2": null,
        "alternate_address": null,
        "is_admin": false,
        "employee_type": null,
        "profile_type": null,
        "organization_id": null,
        "consent_provided": true,
        "consented_on": null,
        "kyc_status": null,
        "user_title": null,
        "gender": null,
        "birth_date": null,
        "company_cluster_id": null,
        "entity_id": null,
        "blood_group": null,
        "vendor_code": null,
        "company_name": null,
        "created_by_id": null,
        "ext_company_name": null,
        "work_location": null,
        "user_type": null,
        "site_id": null
    },
    "access_token": "EuwqPPUFnUttt9HxeVm5euGOQXm6kT1XXw_Ic7UVj2U",
    "token_type": "bearer"
}
*/