import { LightningElement, api, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refresh } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Eyidystarrating extends LightningElement {
    @api objectApiName;
    @api fieldApiName;
    @api fieldlabel;
    @api maxStars;
    @api compsize = "medium";
    @track rating;
    
    @api isEditable = false;
    @api recordId;

    connectedCallback(){
        console.log('rating',this.rating);
        setTimeout(() => {
            const inputField = this.template.querySelector('lightning-input-field');
            if (inputField) {
                inputField.addEventListener('change', (event) => {
                    this.rating = event.target.value;
                });
                console.log('rating updated timeout',inputField.value);
                this.rating = inputField.value;
            }
        }, 2500);
        
    }
    renderedCallback(){
        
    }
    handleRatingChange(event) {
        console.log('rating updated',event.detail);
        this.rating = event.detail;
        try{

        
        
        let inForm = this.template.querySelector('lightning-record-edit-form');
        let fields = {};
        fields[this.fieldApiName] = this.rating;
        console.log(inForm,JSON.stringify(inForm));
        console.log('Form Element data:', inForm);
        inForm.submit(fields);
        }catch(e){
            console.log('error sending rating to parent',e);
        }
    }

    handleSuccess(event) {
        console.log('success event',event);
        try{
            getRecordNotifyChange([{ recordId: this.recordId }]);
            refresh();
        }
        catch(err){
            console.error('err in reload',err);
        }
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Rating updated successfully, please refresh to view updates!',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        console.log('error event',event);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred while updating the rating',
                variant: 'error'
            })
        );
    }
}