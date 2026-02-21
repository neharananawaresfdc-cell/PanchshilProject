declare module "@salesforce/apex/EYI_DocData.getRecordsId" {
  export default function getRecordsId(param: {accId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DocData.getData" {
  export default function getData(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DocData.createContentVersion" {
  export default function createContentVersion(param: {base64Pdf: any, fileName: any, recordId: any}): Promise<any>;
}
