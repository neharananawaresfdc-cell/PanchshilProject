declare module "@salesforce/apex/QuotationPageController.searchRecords" {
  export default function searchRecords(param: {searchKey: any, objName: any}): Promise<any>;
}
declare module "@salesforce/apex/QuotationPageController.getPlanType" {
  export default function getPlanType(param: {projId: any, towerId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuotationPageController.getDummyOpportunity" {
  export default function getDummyOpportunity(): Promise<any>;
}
declare module "@salesforce/apex/QuotationPageController.getInventory" {
  export default function getInventory(param: {inventoryId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuotationPageController.getQuoteValues" {
  export default function getQuoteValues(param: {inventoryId: any}): Promise<any>;
}
