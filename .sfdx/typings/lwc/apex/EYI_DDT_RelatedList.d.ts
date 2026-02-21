declare module "@salesforce/apex/EYI_DDT_RelatedList.buildFieldJSON" {
  export default function buildFieldJSON(param: {soql: any, objectName: any, whereClause: any, colsJson: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DDT_RelatedList.getRecords" {
  export default function getRecords(param: {soql: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DDT_RelatedList.onSearch" {
  export default function onSearch(param: {searchTerm: any, objectApiName: any, searchFields: any, whereClause: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_DDT_RelatedList.countRecords" {
  export default function countRecords(param: {objectName: any, whereClause: any}): Promise<any>;
}
