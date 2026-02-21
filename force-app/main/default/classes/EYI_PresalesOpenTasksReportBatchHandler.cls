public with sharing class EYI_PresalesOpenTasksReportBatchHandler {
    public void sendReportEmail(String reportId,String reportName) {
        // Run the report synchronously
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);
        // Convert report results to CSV
        String csvContent = convertReportResultsToCSV(results,reportName);
        if(csvContent != ''){
            sendEmailWithAttachment(csvContent);
        }
    }

    private String convertReportResultsToCSV(Reports.ReportResults results,String reportName) {
        String csv;
        // Convert the report results to CSV format
        if(reportName == System.Label.EYI_Presales_Incomplete_Task_Report){
            csv = System.Label.EYI_OpenTaskReportColumns; 
        }else if(reportName == System.Label.EYI_DigitalLeadEscalationReport){
            csv = System.Label.EYI_Digital_Lead_No_Activity_Report_Columns;
        }
      // Add your column headers
        
        for (String key : results.getFactMap().keySet()) {
            Reports.ReportFactWithDetails fact = (Reports.ReportFactWithDetails)results.getFactMap().get(key);
            if (fact != null && fact.getRows() != null && !fact.getRows().isEmpty()) {
                // Iterate through the rows if present
                for (Reports.ReportDetailRow row : fact.getRows()) {
                    if(reportName == System.Label.EYI_Presales_Incomplete_Task_Report){
                        csv += row.getDataCells().get(0).getLabel() + ',' + 
                        row.getDataCells().get(1).getLabel() + ',' + 
                        row.getDataCells().get(2).getLabel() + ',' + 
                        row.getDataCells().get(3).getLabel() + ',' + 
                        row.getDataCells().get(4).getLabel() + ',' + 
                        row.getDataCells().get(5).getLabel() + '\n'; 
                    }else if(reportName == System.Label.EYI_DigitalLeadEscalationReport){
                        csv += row.getDataCells().get(0).getLabel() + ',' + 
                        row.getDataCells().get(1).getLabel() + ',' + 
                        row.getDataCells().get(2).getLabel() + ',' + 
                        row.getDataCells().get(3).getLabel() + ',' + 
                        row.getDataCells().get(4).getLabel() + '\n';                     
                    }
                    // Adjust based on your columns
                }
            } else {
                // Handle the case when there are no rows
                csv ='';
            }
        }
        return csv;
    }

    private void sendEmailWithAttachment(String csvContent) {
        List<EYI_Assignment_Group_Member__c> memberList = EYI_AssignmentGroupUtility.getEscalationUsers();
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        List<EYI_Assignment_Group__c> groupAssignedDataList = EYI_AssignmentGroupUtility.getGroupAssignedData(System.Label.EYI_PresalesL3EscalationGroupLabel);
        try {
            if(memberList.size()>0){
                for (EYI_Assignment_Group_Member__c member : memberList) {
                    if (member.EYI_Assignment_Member__r.Email != null) {
                        toAddresses.add(member.EYI_Assignment_Member__r.Email);
                    }
                }
            }
           if(groupAssignedDataList.size()>0){
               for (EYI_Assignment_Group__c groupAssignedData : groupAssignedDataList) {
                    if (groupAssignedData.EYI_Team_Lead_TL__r.Email != null) {
                        ccAddresses.add(groupAssignedData.EYI_Team_Lead_TL__r.Email);
                    }
                    if (groupAssignedData.EYI_Presales_Head__r.Email != null) {
                        ccAddresses.add(groupAssignedData.EYI_Presales_Head__r.Email);
                    }
                }
           }
            // Create the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // Set the recipient
            email.setToAddresses(toAddresses);
            email.setCcAddresses(ccAddresses);
            // Set the subject and body
            email.setSubject('Presales Open Activity Report');
            email.setPlainTextBody('Please find the attached report. The following activities were not completed by the presales advisor:');        // Create the attachment
            Blob reportBlob = Blob.valueOf(csvContent);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Report.csv');
            attachment.setBody(reportBlob);
            // Attach the file to the email
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e) {
                
        }
    }
}