public class EYI_ProjectSyncToMobileApp {

    // Metadata config loaded once
    static Project_sync_API_Parameters__mdt authConfig = [
        SELECT Label, API_end_point__c, Auth_API_endpoint__c,
               Client_ID__c, Client_Secret__c, Username__c,
               Password__c, Grant_Type__c
        FROM Project_sync_API_Parameters__mdt
        WHERE MasterLabel = 'Project sync to app'
        LIMIT 1
    ];

    /**
     * Trigger entry point: insert/update handler
     */
	@future(callout=true)
public static void syncTowersToMobileApp(Set<Id> towerIds) {
    List<EYI_Tower__c> towers = [
        SELECT Id, Name, EYI_Project_Name__c
        FROM EYI_Tower__c
        WHERE Id IN :towerIds
    ];

    // Group towers by project
    Map<Id, List<EYI_Tower__c>> projectToTowers = new Map<Id, List<EYI_Tower__c>>();
    for (EYI_Tower__c tower : towers) {
        if (!projectToTowers.containsKey(tower.EYI_Project_Name__c)) {
            projectToTowers.put(tower.EYI_Project_Name__c, new List<EYI_Tower__c>());
        }
        projectToTowers.get(tower.EYI_Project_Name__c).add(tower);
    }

    // Fetch project records
    List<EYI_Project__c> projects = [
        SELECT Id, EYI_Project_Property_Type__c, EYI_Project_Status__c, Name,
               EYI_Project_Location__c, EYI_Configuration_Types__c, EYI_Project_Description__c,
               EYI_Price_Onwards__c, EYI_Project_Size_In_Sq_Mtr__c, EYI_Project_Size_In_Sq_Ft__c,
               EYI_Rera_Carpet_Area_In_Sq_Ft__c, EYI_Number_Of_Towers__c, EYI_Number_Of_Units__c,
               EYI_Rera_Number__c, EYI_Land_Area__c
        FROM EYI_Project__c
        WHERE Id IN :projectToTowers.keySet()
    ];

    String accessToken = getAccessToken();

    for (EYI_Project__c project : projects) {
        List<EYI_Tower__c> associatedTowers = projectToTowers.get(project.Id);
        EYI_ProjectCreationWrapper wrapper = new EYI_ProjectCreationWrapper(project, associatedTowers);
        String payload = JSON.serialize(wrapper);
        System.debug('payload '+payload);
        makeCallout(payload, accessToken, false, project); // Use project for update if needed
    }
}

    public static void handleProjectSync(List<EYI_Project__c> newList, Map<Id, EYI_Project__c> oldMap, Boolean isInsert, Boolean isUpdate) {
        if (Test.isRunningTest()) {
            return; // Skip callouts during tests	
        }

        List<EYI_Project__c> projectList = new List<EYI_Project__c>();

        if (isInsert) {
            projectList = newList;
        } else if (isUpdate) {
            for (EYI_Project__c newRecord : newList) {
                EYI_Project__c oldRecord = oldMap.get(newRecord.Id);
                if (newRecord.EYI_Project_Code__c == oldRecord.EYI_Project_Code__c) {
                    projectList.add(newRecord);
                }
            }
        }

        if (!projectList.isEmpty()) {
            getProjectDetails(projectList, isInsert);
        }
    }

    public static void getProjectDetails(List<EYI_Project__c> projectList, Boolean isInsert) {
        List<Id> projectIds = new List<Id>();
        for (EYI_Project__c project : projectList) {
            projectIds.add(project.Id);
        }
        syncProjectsToMobileApp(projectIds, isInsert);
    }

    @future(callout = true)
    public static void syncProjectsToMobileApp(List<Id> projectIds, Boolean isInsert) {
        List<EYI_Project__c> projects = [
            SELECT Id, EYI_Project_Property_Type__c, EYI_Project_Status__c, Name,
                   EYI_Project_Location__c, EYI_Configuration_Types__c, EYI_Project_Description__c,
                   EYI_Price_Onwards__c, EYI_Project_Size_In_Sq_Mtr__c, EYI_Project_Size_In_Sq_Ft__c,
                   EYI_Rera_Carpet_Area_In_Sq_Ft__c, EYI_Number_Of_Towers__c, EYI_Number_Of_Units__c,
                   EYI_Rera_Number__c, EYI_Land_Area__c
            FROM EYI_Project__c
            WHERE Id IN :projectIds
        ];

        String accessToken = getAccessToken();

        for (EYI_Project__c project : projects) {
            EYI_ProjectCreationWrapper projectPayload = new EYI_ProjectCreationWrapper(project,new List<EYI_Tower__c>());
            String jsonBody = JSON.serialize(projectPayload);
            System.debug('Project Payload : '+jsonBody);
            makeCallout(jsonBody, accessToken, isInsert, project);
        }
    }

    private static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authConfig.Auth_API_endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        String requestBody = JSON.serialize(new Map<String, String>{
            'email'        => authConfig.Username__c,
            'password'     => authConfig.Password__c,
            'client_id'    => authConfig.Client_ID__c,
            'client_secret'=> authConfig.Client_Secret__c,
            'grant_type'   => 'password'
        });
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        return (String) responseMap.get('access_token');
    }

    private static void makeCallout(String jsonBody, String accessToken, Boolean isInsert, EYI_Project__c project) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authConfig.API_end_point__c + '.json');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            EYI_ProjectResponseWrapper projectResponse = (EYI_ProjectResponseWrapper)
                JSON.deserialize(res.getBody(), EYI_ProjectResponseWrapper.class);

            if (projectResponse != null && projectResponse.Id != null) {
                project.EYI_Project_Code__c = projectResponse.Id;
                update project;
            }
        } else {
            System.debug('Error in callout: ' + res.getBody());
        }
    }
}