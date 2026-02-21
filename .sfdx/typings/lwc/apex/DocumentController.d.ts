declare module "@salesforce/apex/DocumentController.saveDocument" {
  export default function saveDocument(param: {fileContent: any, fileName: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentController.getDocumentTrackerRecords" {
  export default function getDocumentTrackerRecords(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocumentController.deleteDocument" {
  export default function deleteDocument(param: {contentDocumentId: any}): Promise<any>;
}
