declare module "@salesforce/apex/EYI_GetQuotaionValue.fetchinventoryDetails" {
  export default function fetchinventoryDetails(param: {currentPageRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.getUserRole" {
  export default function getUserRole(param: {usrId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.fetchCarParks" {
  export default function fetchCarParks(param: {currentPageRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.fetchQuoteDetails" {
  export default function fetchQuoteDetails(param: {quoteid: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.getBaseRate" {
  export default function getBaseRate(param: {currentPageRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.getFloorRise" {
  export default function getFloorRise(param: {currentPageRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.fetchQuotationValue" {
  export default function fetchQuotationValue(param: {currentPageRecordId: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.fetchQuotationDiscountValue" {
  export default function fetchQuotationDiscountValue(param: {currentPageRecordId: any, baseRatePSF: any, baseRateLS: any, floorRatePSF: any, floorRateLS: any, oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.fetchOffers" {
  export default function fetchOffers(param: {quoteid: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.addOfferToQuote" {
  export default function addOfferToQuote(param: {quoteId: any, OfferList: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_GetQuotaionValue.createQuoatationRecord" {
  export default function createQuoatationRecord(param: {currentPageRecordId: any, quotationWrapperData: any, paymentPlanId: any, placeholderOpp: any, selectedOppId: any}): Promise<any>;
}
