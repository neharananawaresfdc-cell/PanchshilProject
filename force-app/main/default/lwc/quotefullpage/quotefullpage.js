import { LightningElement, api, track, wire } from 'lwc';
import fetchQuotationValue from '@salesforce/apex/EYI_GetQuotaionValue.fetchQuotationValue';
import fetchinventoryDetails from '@salesforce/apex/EYI_GetQuotaionValue.fetchinventoryDetails';
import fetchQuotationDiscountValue from '@salesforce/apex/EYI_GetQuotaionValue.fetchQuotationDiscountValue';
import fetchOffers from '@salesforce/apex/EYI_GetQuotaionValue.fetchOffers';
import createQuoatationRecord from '@salesforce/apex/EYI_GetQuotaionValue.createQuoatationRecord';
import addOfferToQuote from '@salesforce/apex/EYI_GetQuotaionValue.addOfferToQuote';
import fetchCarParks from '@salesforce/apex/EYI_GetQuotaionValue.fetchCarParks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getBaseRate from '@salesforce/apex/EYI_GetQuotaionValue.getBaseRate';
import getFloorRise from '@salesforce/apex/EYI_GetQuotaionValue.getFloorRise';
import getUserRole from '@salesforce/apex/EYI_GetQuotaionValue.getUserRole';
import FORM_FACTOR from "@salesforce/client/formFactor";
import userId from '@salesforce/user/Id';

export default class Quotefullpage extends NavigationMixin(LightningElement) {
    floorRise;
    @api paymentPlanId;
    @api placeholderOppId;
    @api selectedOppId;
    selOppId; //to pass to discount func
    isLoadingSheet = false;
    offerModalOpen = false;
    disabledOffers = false;
    optionsTypeOfferVal = 'Project';
    invTower;
    invFloor;
    invNumber;
    invType;
    invActualArea;
    invCarpetArea;
    invBalconyArea;
    invEnclosedBalconyArea;
    parkingType;
    carParkDetails;
    @track parkMasterId;
    carParkingCount = 1;
    carParkCharge;
    inventoryValues;
    @api inventoryid;//JG ADDED
    @api recordId;
    quoteId;
    @track accordionItems = [];
    showdiscountSection = false;
    offerErrorMessage;
    showOffer = false;
    isDisablebaseRatePSF = false;
    isDisablebaseRateLS = false;
    isDisablefloorRatePSF = false;
    isDisablefloorRateLS = false;
    offerList = [];
    selectedRecordsOffers = [];
    groupedCarParkDetails;
    loggedInUserId= userId;
    showDiscount;
    @track columnsOffer = [
        { label: 'Offer Name', fieldName: 'Name' },
        { label: 'Offer Details', fieldName: 'Offer_Details__c' },
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
        { label: 'Amount', fieldName: 'EYI_Amount__c', type: 'currency' }
    ];




    get optionsTypeOffer() {
        return [
            { label: 'Project', value: 'Project' },
            { label: 'Tower', value: 'Tower' },
            { label: 'Inventory', value: 'Inventory' },
        ];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('currentPageReference' + JSON.stringify(currentPageReference));
        console.log('currentPageReference.attributes.inventoryrecordid' + currentPageReference.attributes.inventoryrecordid);
        this.recordId = currentPageReference.attributes.recordId;
        
        console.log('recordid-->' + currentPageReference.attributes.recordId);
        if (this.recordId) {
            this.disabledOffers = false;
            this.quoteId = this.recordId;

        }
        else {
            this.disabledOffers = true;

        }
        if (currentPageReference) {
            // Read the 'inventoryid' passed in the state
            this.inventoryid = currentPageReference.state.c__inventoryrecordid;
            this.paymentPlanId = currentPageReference.state.c__paymentPlanId;
            this.placeholderOppId = currentPageReference.state.c__placeholderOppId;
            this.selectedOppId = currentPageReference.state.c__selectedOppId
            console.log('payment plan Id passed', this.placeholderOppId);
            console.log('payment plan Id passed', this.paymentPlanId);
            console.log('this.inventoryid state' + this.inventoryid);
        }
    }


    connectedCallback() {
        this.handleFormFactor();
        //uncomment after success if(this.inventoryid) 
        this.inventoryValues = true;//ADDED JG
        this.selOppId = this.selectedOppId;
        console.log('selOppId', this.selOppId);
        console.log('recordid-->' + this.recordId);
        console.log('{invFloor}' + this.invFloor);
        //inventoryid
        if (this.recordId) { this.currentPageRecordId = this.recordId; this.showinstruction = false; }
        else if (this.inventoryid) { this.currentPageRecordId = this.inventoryid; this.showinstruction = true }

        fetchinventoryDetails({ currentPageRecordId: this.currentPageRecordId }).then(data => {
            console.log('Inside connected' + JSON.stringify(data));
            if (data) {
                console.log('Inv Data-->' + JSON.stringify(data));
                console.log('data.EYI_Floor_No__c' + data.EYI_Floor_No__c);
                //console.log('Car Park Master Id', data.Car_Park_Masters__r[0].Id);
                this.invTower = data.EYI_Tower__r.Name;
                this.invFloor = data.EYI_Floor_No__c; 
                this.invNumber = data.EYI_Inventory_Number__c;
                this.invType = data.EYI_Typology__c;
                this.invActualArea = data.EYI_Saleable_Area__c;
                this.invCarpetArea = data.EYI_Carpet_Area__c; 
                this.invBalconyArea = data.EYI_Balcony_Area__c; 
                //this.parkingType = data.Car_Park_Masters__r[0].EYI_Parking_Type__c; 
                //this.parkMasterId = data.Car_Park_Masters__r[0].Id;

                //this.carParkCharge = data.Car_Park_Masters__r[0].EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c;
                //need to ask if(data.EYI_Tower__r) this.invEnclosedBalconyArea;
                console.log('Floor' + this.invFloor + this.invNumber);
                //console.log('ParkMasterId', data.Car_Park_Masters__r[0].EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c);
            }

        }).catch(error =>
            console.log('error::', error));
        console.log('inventoryid--::' + this.inventoryid);//JG ADDED
        //  this.settablesValues();inventoryid

        getBaseRate({currentPageRecordId: this.currentPageRecordId}).then(data=> {
            console.log('baseRateData', data);
            if(data) {
                this.baseRate = data;
            }
        })

        getFloorRise({currentPageRecordId: this.currentPageRecordId}).then(data=> {
            console.log('getFloorRise', data);
            if(data) {
                this.floorRise = data;
            }
        })

        fetchQuotationValue({ currentPageRecordId: this.currentPageRecordId ,oppId : this.selectedOppId}).then(data => {
            console.log('data::' + JSON.stringify(data));
            console.log('data2::' + JSON.stringify(data.section));
            this.accordionItems = data.section;

            console.log('accordionItems::' + JSON.stringify(accordionItems));

        }).catch(error =>{
            console.log('error::', error)
        });

        
        
        fetchCarParks({currentPageRecordId: this.currentPageRecordId }).then(data => {
            console.log('car park data', data);
            if (data) {
               console.log('carPark Data-->' + JSON.stringify(data));
               this.carParkDetails = data;

                const propertiesToCheck = ['EYI_Parking_Type__c', 'EYI_Category__c'];
                this.groupedCarParkDetails = this.checkAndGroupSimilarities(this.carParkDetails, propertiesToCheck);
                console.log('groupedArray', JSON.stringify(this.groupedCarParkDetails));
            }
        }).catch(error => {
           console.log('Error in fetching car park', error)
        })
         this.getCurrentUserRole(this.loggedInUserId);
        
    }
    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.deviceType = "Desktop/Laptop";
        } else if (FORM_FACTOR === "Medium") {
            this.deviceType = "Tablet";
        } else if (FORM_FACTOR === "Small") {
            this.deviceType = "Mobile";
        }
    }

    checkAndGroupSimilarities(array, properties) {
        const groupedArray = [];
        const seen = new Set();
    
        array.forEach(item => {
            const key = properties.map(prop => {
                const propPath = prop.split('.');
                let value = item;
                propPath.forEach(p => {
                    value = value[p];
                });
                return value;
            }).join('|');
    
            if (!seen.has(key)) {
                seen.add(key);
                const count = array.filter(entry => {
                    return properties.every(prop => {
                        const propPath = prop.split('.');
                        let itemValue = entry;
                        let keyValue = item;
                        propPath.forEach(p => {
                            itemValue = itemValue[p];
                            keyValue = keyValue[p];
                        });
                        return itemValue === keyValue;
                    });
                }).length;
    
                const newItem = { ...item, count: count };
                newItem.totalCarParkCharge = 0;
    
                array.forEach(entry => {
                    if (properties.every(prop => {
                        const propPath = prop.split('.');
                        let itemValue = entry;
                        let keyValue = item;
                        propPath.forEach(p => {
                            itemValue = itemValue[p];
                            keyValue = keyValue[p];
                        });
                        return itemValue === keyValue;
                    })) {
                        if (entry.EYI_Car_Parking_Charge__r && entry.EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c) {
                            newItem.totalCarParkCharge += entry.EYI_Car_Parking_Charge__r.EYI_Car_Parking_Charge__c;
                        }
                    }
                });
    
                groupedArray.push(newItem);
            }
        });
    
        return groupedArray;
    }    

    getCurrentUserRole(userId) {
        getUserRole({usrId : userId})
        .then(result => {
            console.log('result of role', result);
            this.showDiscount = result;
        })
        .catch(error => {
            console.log('Error fetching userRole', error);
        }) 
    }

    settablesValues() {
        console.log('');
        // this.inventoryValues.map()



    }


    previousHandler() {

        const customEvent = new CustomEvent('previouspage', {
            detail: true,  // This is where you pass the data to the parent
        });
        // Dispatch the event
        this.dispatchEvent(customEvent);


    }

    discountSection() {
        this.showdiscountSection = true;
    }


    discountChange(event) {
        console.log('this.baseRatePSF-->' + event.target.name);
        console.log('this.baseRatePSF-->' + event.target.value);
        var valueofDiscount = event.target.value;
        if(valueofDiscount && valueofDiscount <= 0){
            this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter a valid discount value',
                            variant: 'Error',
                }),
            );
            //event.target.value = 0;
            return;
        }
        console.log('valueofDiscount 1-->' + valueofDiscount);
        if (event.target.name == 'baseRatePSF' && valueofDiscount != null && valueofDiscount != undefined && valueofDiscount != '') {
            this.isDisablebaseRatePSF = false;
            this.isDisablebaseRateLS = true;
            this.baseRatePSF = event.target.value;
            console.log('this.isDisablebaseRateLS-->' + this.isDisablebaseRateLS);
        } else if (event.target.name == 'baseRateLS' && valueofDiscount != null && valueofDiscount != undefined && valueofDiscount != '') {
            this.isDisablebaseRatePSF = true;
            this.isDisablebaseRateLS = false;
            this.baseRateLS = event.target.value;
        }

        if (event.target.name == 'floorRatePSF' && valueofDiscount != null && valueofDiscount != undefined && valueofDiscount != '') {
            this.isDisablefloorRatePSF = false;
            this.isDisablefloorRateLS = true;
            this.floorRatePSF = event.target.value;
            console.log('this.isDisablebaseRateLS-->' + this.isDisablebaseRateLS);
        } else if (event.target.name == 'floorRateLS' && valueofDiscount != null && valueofDiscount != undefined && valueofDiscount != '') {
            this.isDisablefloorRatePSF = true;
            this.isDisablefloorRateLS = false;
            this.floorRateLS = event.target.value;
        }

    }

    discountConfirm() {
        console.log('this.accordionItems ::' + JSON.stringify(this.accordionItems));
        this.isLoadingSheet = true;
        if (this.recordId) this.currentPageRecordId = this.recordId;
        else if (this.inventoryid) this.currentPageRecordId = this.inventoryid;

        console.log('currentPageRecordId' + this.currentPageRecordId);
        fetchQuotationDiscountValue({ currentPageRecordId: this.currentPageRecordId, baseRatePSF: this.baseRatePSF, baseRateLS: this.baseRateLS, floorRatePSF: this.floorRatePSF, floorRateLS: this.floorRateLS, oppId:this.selOppId })
            .then(data => {
                console.log('values', this.currentPageRecordId, this.baseRatePSF, this.selOppId);
                console.log('data::' + JSON.stringify(data));
                console.log('data.quotationValWrapperVal::' + JSON.stringify(data.quotationValWrapperVal));
                if (data.errorMesage) {
                    console.log('Display Error message');
                }
                if (data.quotationValWrapperVal) {
                    var quoatationDicount = [];
                    quoatationDicount = data.quotationValWrapperVal.section;
                    console.log('quoatationDicount' + quoatationDicount);
                    this.accordionItems = quoatationDicount;
                    //this.accordionItems =  data.quotationValWrapperVal ;
                    console.log('this.accordionItems Disc ::' + JSON.stringify(this.accordionItems));
                    this.isLoadingSheet = false;

                }
            }).catch(error => {
                console.log('error::' + error);
                console.error('Line 275' , error, JSON.stringify(error));
            }
                
            );
                
        this.isLoadingSheet = false;

    }

    onclear() {
        this.isLoadingSheet = true;
        this.baseRatePSF = null;
        this.isDisablebaseRatePSF = false;
        this.baseRateLS = null;
        this.isDisablebaseRateLS = false;
        this.floorRatePSF = null;
        this.isDisablefloorRatePSF = false;
        this.floorRateLS = null;
        this.isDisablefloorRateLS = false;
        if (this.recordId) this.currentPageRecordId = this.recordId;
        else if (this.inventoryid) this.currentPageRecordId = this.inventoryid;
        fetchQuotationValue({ currentPageRecordId: this.currentPageRecordId, oppId : this.selectedOppId }).then(data => {

            console.log('data::' + JSON.stringify(data));
            console.log('data2::' + JSON.stringify(data.section));
            this.accordionItems = data.section;

            console.log('accordionItems::' + JSON.stringify(this.accordionItems));
            this.isLoadingSheet = false;
        }).catch(error =>
            console.log('error::', error));
        this.isLoadingSheet = false;

    }

    searchOfferSection() {
        this.offerModalOpen = true;
        this.searchOffer();
    }

    closeModal() {
        this.offerModalOpen = false;
    }
    handleChangeOfferType(event) {
        this.optionsTypeOfferVal = event.detail.value;
    }

    searchOffer() {
        console.log('Search offer');

        fetchOffers({ quoteid: this.quoteId })
            .then(data => {
                if (data.length > 0) {
                    console.log('data::' + JSON.stringify(data));
                    //this.offerModalOpen = false;
                    this.offerList = data;
                    this.offerErrorMessage = '';
                    this.showOffer = true;
                } else {
                    this.offerErrorMessage = 'No Active Offer';
                    this.offerList = '';
                    this.showOffer = false;
                }
                console.log('offerErrorMessage' + this.offerErrorMessage);

            })
            .catch(error =>
                console.log('error::' + error));
        this.offerErrorMessage = error;
    }

    createQuoatation() {
        this.isLoadingSheet = true;
        if (this.recordId) this.currentPageRecordId = this.recordId;
        else if (this.inventoryid) this.currentPageRecordId = this.inventoryid;
        createQuoatationRecord({ currentPageRecordId: this.currentPageRecordId, quotationWrapperData: JSON.stringify(this.accordionItems), paymentPlanId: this.paymentPlanId, placeholderOpp : this.placeholderOppId, selectedOppId : this.selectedOppId})
            .then(data => {

                console.log('data of Quote:' + data);
                if (data && data.Id != null && data.Id != undefined && data.Id != '') {
                    this.quoteId = data.Id;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.quoteId,
                            actionName: 'view'
                        }
                    });
                } else if (data.errorMessage) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: data.errorMessage,
                            variant: 'Error',
                        }),
                    );
                }
                this.isLoadingSheet = false;
            })
            .catch(error =>
                console.log('error::' + error));
        this.isLoadingSheet = false;
    }


    handleRowSelection(event) {
        console.log('Inside row selection' + JSON.stringify(event.detail.selectedRows));
        const selectedRows = event.detail.selectedRows;
        this.selectedRecordsOffers = selectedRows; // Update selected records
    }
    addOffertoQuoatation() {
        console.log('inside offer adding' + this.quoteId + '&' + JSON.stringify(this.selectedRecordsOffers));
        if (this.quoteId && this.selectedRecordsOffers) {

            addOfferToQuote({ quoteId: this.quoteId, OfferList: this.selectedRecordsOffers })
                .then(data => {
                    if (data == 'Success') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Offer Added Successfully',
                                variant: 'Success',
                            }),
                        );
                        this.onclear();
                        this.closeModal();
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: data,
                                variant: 'Error',
                            }),
                        );
                    }

                });

        }
    }


}