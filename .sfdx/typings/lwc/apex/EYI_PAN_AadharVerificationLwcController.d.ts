declare module "@salesforce/apex/EYI_PAN_AadharVerificationLwcController.getApplicantData" {
  export default function getApplicantData(param: {applicantId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_PAN_AadharVerificationLwcController.verifyPANdetails" {
  export default function verifyPANdetails(param: {recAccId: any, panCardNumber: any, name: any, dob: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_PAN_AadharVerificationLwcController.verifyDigilockerdetails" {
  export default function verifyDigilockerdetails(param: {recAccId: any, aadharCardNumber: any, name: any, gender: any, dob: any, currentUrl: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_PAN_AadharVerificationLwcController.buttonPANandAadhar" {
  export default function buttonPANandAadhar(param: {recAccId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_PAN_AadharVerificationLwcController.buttonPANandAadharforApplicant" {
  export default function buttonPANandAadharforApplicant(param: {appAccId: any}): Promise<any>;
}
declare module "@salesforce/apex/EYI_PAN_AadharVerificationLwcController.uploadDocument" {
  export default function uploadDocument(param: {base64Data: any, recordId: any, filename: any}): Promise<any>;
}
