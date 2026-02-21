import { LightningElement ,api} from 'lwc';

export default class EY_EsignLwc extends LightningElement {


    @api recordId;  // To capture the record ID (e.g., Opportunity Id) if needed

    // Construct the Visualforce page URL
    get vfPageUrl() {
        // Construct the Visualforce URL dynamically, replace 'DocumentPage' with your Visualforce page name
        return '/apex/EYI_Esign_VFPage';
    }


}