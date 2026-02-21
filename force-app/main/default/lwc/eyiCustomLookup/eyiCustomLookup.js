/*
Owner - Tushar Mathur

*/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import search from '@salesforce/apex/EYI_CifFormCreation.searchElements';
const DELAY = 300;

export default class CustomLookupFilter extends LightningElement {
    @api valueId;
    @api valueName;
    @api objName;
    @api iconName;
    @api labelName;
    @api readOnly = false;
    @api currentRecordId;
    @api placeholder = 'Search';
    @api createRecord;
    @api fields;
    @api displayFields;
    @api lookupSelected;
    

    @track error;

    @track checkError = false;

    searchTerm;
    delayTimeout;
    isFocussed;
    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;

    field;
    field1;
    field2;

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';

    get dropdownClasses() {
        
        let dropdownClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
        // Show dropdown list on focus
        if (this.isFocussed) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    @api reportInputValidity(){
        this.template.querySelectorAll('lightning-input').forEach(inputField => {
            try{
                if(!this.selectedRecord) {
                    inputField.setCustomValidity('Please Enter a valid value');
                    inputField.reportValidity();
                    console.error('error in field',inputField);
                }
            }
            catch(error){
                console.error(error);
            }
        });
    }

    connectedCallback() {
        let icons;
        try{
            icons = this.iconName.split(':');
        }
        catch(error){
            console.error(error);
        }
        
        this.ICON_URL = this.ICON_URL.replace('{0}', icons[0]);
        this.ICON_URL = this.ICON_URL.replace('{1}', icons[1]);
        if (this.objName.includes('__c')) {
            let obj = this.objName.substring(0, this.objName.length - 3);
            this.objectLabel = obj.replaceAll('_', ' ');
        } else {
            this.objectLabel = this.objName;
        }
        this.objectLabel = this.titleCase(this.objectLabel);
        let fieldList;
        if (!Array.isArray(this.displayFields)) {
            fieldList = this.displayFields.split(',');
        } else {
            fieldList = this.displayFields;
        }

        if (fieldList.length > 1) {
            this.field = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if (fieldList.length > 2) {
            this.field2 = fieldList[2].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if (!this.fields.includes(field.trim())) {
                combinedFields.push(field.trim());
            }
        });

        this.fields = combinedFields.concat(JSON.parse(JSON.stringify(this.fields)));
        console.log('already present value',this.lookupSelected);
        if(this.lookupSelected){
            this.selectedRecord = this.lookupSelected;
        }
    }

    handleInputChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.checkError = false;
        this.searchRecords = [];
        this.template.querySelectorAll('lightning-input').forEach(inputField => {
            try{
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
            }
            catch(error){
                console.error(error);
            }
        });
        if (searchKey.length >= 2) {

            this.delayTimeout = setTimeout(() => {
                this.isLoading = true;
                search({
                    objectName: this.objName,
                    fields: this.fields,
                    searchTerm: searchKey
                })
                    .then(result => {
                        let stringResult = JSON.stringify(result);
                        let allResult = JSON.parse(stringResult);
                        console.log(this.field,'::::::::',allResult);
                        allResult.forEach(record => {
                            if (record[this.field] != '' && record[this.field] != null) {
                            record.FIELD1 = record[this.field];
                            record.FIELD2 = record[this.field1];
                            if (this.field2) {
                                record.FIELD3 = record[this.field2];
                            } else {
                                record.FIELD3 = '';
                            }
                            this.searchRecords.push(record);
                            }
                        });
                        //this.searchRecords = allResult;

                    })
                    .catch(error => {
                        console.error('Error:', error);
                    })
                    .finally(() => {
                        this.isLoading = false;
                    });

            }, DELAY);
        }else{
            this.searchRecords = [];
        }
    }

    handleSelect(event) {
        this.checkError = false;
        let recordId = event.currentTarget.dataset.recordId;

        let selectRecord = this.searchRecords.find((item) => {
            return item.Id === recordId;
        });
        this.selectedRecord = selectRecord;
        console.log('Selected Record',JSON.stringify(this.selectedRecord));
        const selectedEvent = new CustomEvent('lookup', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                data: {
                    record: selectRecord,
                    recordId: recordId,
                    currentRecordId: this.currentRecordId
                }
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleClose() {
        this.checkError = false;
        try {
            this.selectedRecord = undefined;
            this.searchRecords = undefined;
            const selectedEvent = new CustomEvent('lookup', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    data: {
                        record: null,
                        recordId: null,
                        currentRecordId: this.currentRecordId
                    }
                }
            });
            this.dispatchEvent(selectedEvent);
        } catch (error) {
            console.error(error);
        }
    }

    titleCase(string) {
        var sentence = string.toLowerCase().split(" ");
        for (var i = 0; i < sentence.length; i++) {
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }
    handleFocus() {
        this.isFocussed = true;
        console.log('focus');
    }
    
    handleBlur() {
        // Timeout to ensure click event is captured before the 
        // options are hidden
        
        if(this.disabled==false){
            setTimeout(() => { this.isFocussed = false; }, 500);
        }
    }
}