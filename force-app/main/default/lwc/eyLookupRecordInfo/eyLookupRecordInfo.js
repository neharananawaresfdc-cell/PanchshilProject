/*
 * Author : Tushar Mathur
 * Description : The component to shows lookup record of Object as a recordview you can specify the fields.
*/

import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getRecordFieldsWithoutSharing from '@salesforce/apex/EYI_LookupRecordInfoController.getRecords';
import getFieldLabels from '@salesforce/apex/EYI_LookupRecordInfoController.getFieldLabels';


export default class EyLookupRecordInfo extends LightningElement {
    @api recordId;
    @api objectName;
    @api title;
    @api fieldList;
    @api fieldQ;
    @api noOfSections;
    @api useStandardLRF;

    @track recordIdx;
    @track isLoading = true;

    parentRecord;
    fieldLabels;

    objectApiName = 'Lead';
    leadFields = [];

    get fieldQlist() {
        let arr = [];
        arr.push(this.fieldQ);
        return arr;
    }

    get lookedupfield() {
        return this.fieldQ.split('.')[1];
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: "$fieldQlist"
      })
      wiredRecord({ error, data }) {
        
        if (error) {
          console.error('getReocrdID Parent',error);
        } else if (data) {
          console.log('in wire',this.fieldQ);
          if(this.fieldQ != this.objectName+'.Id'){
            let field = data.fields[this.lookedupfield];
            this.recordIdx = field.value;
          }
          else{
            this.recordIdx = this.recordId;
          }
          this.fetchRecords();
        }
        
      }

      errorCallback(error, stack) {
        // Handle the error
        console.error('Error occurred: ', error);
        console.error('Stack trace: ', stack);
        
        // You can also display a user-friendly message or take other actions
        
    }

      setfields() {
        let fieldListArray = this.fieldList.split(',');
        let that = this;
        fieldListArray.forEach(field => {
            let fieldValue = this.parentRecord[field];
            if(field == 'Address') {
              console.log('its Address');
                fieldValue = that.formatAddress(this.parentRecord[field]);
            }
            console.log('field', field, this.parentRecord[field],'val', fieldValue );
            this.leadFields.push({ fieldApiName: field, objectApiName: this.objectName, fieldVal:  fieldValue, fieldLabel: this.fieldLabels[field.toLowerCase()] });
            console.log('field',this.leadFields);
        });

        this.isLoading = false;
      }

    fetchRecords() {
        getRecordFieldsWithoutSharing({ recordId: this.recordIdx, fieldNames: this.fieldList.split(',')})
            .then(result => {
              console.log('init 2', result);
                this.parentRecord = result[0];
                console.log('parent record',result[0],result);
                this.fetchFieldLabels();
            })
            .catch(error => {
                console.error(error);
                this.parentRecord = undefined;
            });
    }
    fetchFieldLabels() {
      getFieldLabels({ recordId: this.recordIdx })
          .then(result => {
              this.fieldLabels = result;
              this.setfields();
              console.log('field label',this.fieldLabels);
          })
          .catch(error => {
              console.error(error);
              this.fieldLabels = undefined;
          });
  }
  formatAddress(addressObject) {
    // Concatenate address components into a single string
    console.log('address object', addressObject);
    let address = '';
    if(addressObject){
    if (addressObject.street) {
        address += addressObject.street + ', ';
    }

    if (addressObject.city) {
        address += addressObject.city + ', ';
    }

    if (addressObject.state) {
        address += addressObject.state + ', ';
    }
    if (addressObject.postalCode) {
        address += addressObject.postalCode + ', ';
    }

    if (addressObject.country) {
        address += addressObject.country;
    }
    }
    return address;
  }
}