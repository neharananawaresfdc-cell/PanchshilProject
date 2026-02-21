import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Eyidystarrating extends LightningElement {
    @api objectApiName;
    @api fieldApiName;
    @api fieldlabel;
    @api variant;
    @api direction;
    @api compsize = "medium";
    @api fieldtype;
    @api hidevalue = false;
    @track rating;
    
    @api isEditable = false;
    @api recordId;

    get fieldfulllabel(){
        if(this.rating && !this.hidevalue){
            return this.fieldlabel +' - '+ this.rating+'%';
        }
        else{
            return this.fieldlabel;
        }
        
    }

    connectedCallback(){
        console.log('rating',this.fieldlabel,this.rating);
        setTimeout(() => {
            const inputField = this.template.querySelector('lightning-input-field');
            if (inputField) {
                inputField.addEventListener('change', (event) => {
                    this.rating = event.target.value;
                });
                console.log('rating updated timeout',inputField.name,inputField.value,inputField.type,inputField);
                if(this.fieldtype == 'Percent'){
                    this.rating = inputField.value;
                }
                else if(this.fieldtype == 'Boolean'){
                    this.rating = inputField.value ? 100 : 0;
                }
                else{
                    console.error('Please define Boolean or Percent field type');
                }
                
            }
        }, 2000);
        
    }
    renderedCallback(){
        
    }
}