import { LightningElement, api, track } from 'lwc';
export default class Eyitemplabel extends LightningElement {
    @api objectApiName;
    @api fieldApiName;
    @api fieldlabel;
    @api recordId;
    @track fvalue;

    get labelTDSOutStanding(){
        if(this.fieldlabel == 'TDS Outstanding'){
            return true;
        }else{
            false;
        }
    }
    get dynamicStyle() {
        switch (this.fvalue) {
            case 'Hot':
                return 'color: red;';
            case 'Warm':
                return 'color: orange;';
            case 'Cold':
                return 'color: blue;';
            default:
                return 'color: black;';
        }
    }
    connectedCallback(){
        console.log('rating',this.fieldlabel,this.fvalue);
        setTimeout(() => {
            try{
            const inputField = this.template.querySelector('lightning-input-field');
            console.log('rating updated timeout templabel',inputField.name,inputField.value,inputField.type,inputField);

            if (inputField) {
                inputField.addEventListener('change', (event) => {
                    this.fvalue = event.target.value;
                });
                console.log('rating updated timeout templabel',inputField.name,inputField.value,inputField.type,inputField);
                
                    this.fvalue = inputField.value;
                
                
            }
            }
            catch(e){
            console.error('Error templabel',e);
            }
        }, 2000);
        
        
    }
}