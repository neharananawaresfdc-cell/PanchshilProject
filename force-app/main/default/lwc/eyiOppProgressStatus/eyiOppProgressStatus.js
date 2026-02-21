import { LightningElement,api,wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
const FIELDS = ['User.Name', 'User.ProfileId'];
import { getRecord } from 'lightning/uiRecordApi';
import Post_Sales_Profile_ID from '@salesforce/label/c.Post_Sales_Profile_ID';
export default class EyiOppProgressStatus extends LightningElement {
    @api recordId;
    userId = USER_ID;
    fields2=FIELDS;
   @api profileId;     
    connectedCallback(){
        console.log('recordId',this.recordId);
    }
     @wire(getRecord, { recordId: '$userId', fields: '$fields2' })
    userRecord({ data, error }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.profileId = data.fields.ProfileId.value;
            console.log('profileID',this.profileId);
        } else if (error) {
            console.error('Error retrieving user record', error);
        }
    }
    get getprofileId(){
        if(this.profileId == Post_Sales_Profile_ID){
            return true;
        }else{
            false;
        }
    }

}