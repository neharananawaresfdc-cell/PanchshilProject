declare module "@salesforce/apex/EYI_DDT_RelatedList_WS.buildFieldJSON" {
  export default function buildFieldJSON(param: {soql: any, objectName: any, whereClause: any, colsJson: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DDT_RelatedList_WS.getRecords" {
  export default function getRecords(param: {soql: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DDT_RelatedList_WS.onSearch" {
  export default function onSearch(param: {searchTerm: any, objectApiName: any, searchFields: any, whereClause: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DDT_RelatedList_WS.countRecords" {
  export default function countRecords(param: {objectName: any, whereClause: any}): Promise<any>;
}
