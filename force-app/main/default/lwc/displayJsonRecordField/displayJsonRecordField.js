import { LightningElement, api, track, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class DisplayJsonRecordField extends LightningElement {
    @api recordId;
    @api title;
    @api objectApiName;

    @api fieldName;
    @api showLineNumbers;
    @api maxStringLength;
    @api sortObjects;
    @api setIcons;
    @api syntaxColor = "grey";
    @api stringColor = "green";
    @api numberColor = "red";
    @api booleanColor = "orange";
    @api keyColor = "black";
    @api keywordColor = "purple";

    @track jsonValue;
    @track jsonInit = false;
    
    fieldPath;
    fields;

    connectedCallback() {
        this.fieldPath = this.objectApiName + '.' + this.fieldName;
        this.fields = [this.fieldPath];
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields'})
    wiredRecord({ error, data}) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading record',
                    message,
                    variant: 'error',
                }),
            );
            this.jsonInit = true;
        } else if (data) {
            this.jsonValue = getFieldValue(data,this.fieldPath);
            this.jsonInit = true;
        }
    }
    record;
}