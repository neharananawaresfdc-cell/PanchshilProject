import { LightningElement, track, api, wire } from 'lwc';
import getAvailableTimeSlots from '@salesforce/apex/EYI_DigitalSlotMatrixController.getAvailableTimeSlots';
import updateEventWithOpportunity from '@salesforce/apex/EYI_DigitalSlotMatrixController.updateEventWithOpportunity'; 
import getBookingStatus from '@salesforce/apex/EYI_DigitalSlotMatrixController.getBookingStatus';
import checkIfOpportunityLinked from '@salesforce/apex/EYI_DigitalSlotMatrixController.checkIfOpportunityLinked';
import getDateRangeFromSettings from '@salesforce/apex/EYI_DigitalSlotMatrixController.getDateRangeFromSettings';
import LightningAlert from 'lightning/alert';

export default class EYI_DigitalSlotMatrix extends LightningElement {
    @track recordId;
    @track selectedDate;
    @track availableTimeSlots = [];
    @track isModalOpen = false;
    @track selectedSlotId;
    @track isRecheduled = false;
    @track registrationStatus;
    @track isReschedulesSlot= false;
    @track rescheduleremarks;
    @track isScheduleSlot = false;
    @track isRecheduledSlot = false;
    @track displaySlot = false;
    @track showSlot = false;
    @track minSelectableDate;
    @track maxSelectableDate;
    isDateValid = false;
    @track errorMessage ='';

   
    connectedCallback() {
        let testURL = window.location.href; 
        let newURL = new URL(testURL).searchParams;
        this.recordId =  newURL.get('recordId');
        console.log('recordId: '+this.recordId);   
       // this.checkSlotStatus();
       this.checkOpportunityLink();
        this.setSelectableDateRange();

          
    }

    async setSelectableDateRange() {
        try {
            const result = await getDateRangeFromSettings(); // result = { x: 2, y: 7 }
            const today = new Date();

            const minDate = new Date(today);
            minDate.setDate(today.getDate() + result.x);

            const maxDate = new Date(today);
            maxDate.setDate(today.getDate() + result.y);

            this.minSelectableDate = minDate.toISOString().split('T')[0];
            this.maxSelectableDate = maxDate.toISOString().split('T')[0];
            this.errorMessage =   "Please select a possession slot between "+ this.formatDateToDdMmYyyy(minDate) + " and " + this.formatDateToDdMmYyyy(maxDate) ;
        } catch (error) {
            console.error('Failed to load settings:', error);
        }
    }
    formatDateToDdMmYyyy(date) {
    const yyyy = date.getFullYear();
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const dd = String(date.getDate()).padStart(2, '0');
    return `${dd}-${mm}-${yyyy}`; // display format
}
    // checkSlotStatus(){
    //     console.log('this.recordId : '+this.recordId);
        
    //     this.displaySlot = false;

    //     getBookingStatus({ recordId: this.recordId })
    //         .then(result => {
    //             console.log('getBookingStatusResult : ' + JSON.stringify(result));
    //             if(result.EYI_Digital_Slot_Status__c == 'Digital Slot Scheduled'){
    //                 this.isReschedulesSlot = true;
    //                 this.isScheduleSlot = false;
    //                 this.slotScheduleTime = result.EYI_Digital_Slot_Schedule_Time__c;
    //             }else if(result.EYI_Digital_Slot_Status__c =='Digital Slot Pending'){
    //                 this.isScheduleSlot = true;
    //             }else if(result.EYI_Digital_Slot_Status__c == 'Digital Slot Rescheduled'){
    //                 this.isRecheduledSlot = true;
    //                 this.isScheduleSlot = false;
    //                 this.slotScheduleTime =result.EYI_Digital_Slot_Re_Schedule_Time__c;
    //             }else{
    //                 this.isScheduleSlot = true;    
    //             }
    //         })
    //         .catch(error => {
    //             console.error('Error fetching data: ', error);
    //         });

    // }
    isOpportunityLinked = false;
    opportunityName;
    @track eventDate;
    @track statusClass;
    @track eventDateTime;
    @track eventStartTime;
    @track eventEndTime;
    registrationStatus
    checkOpportunityLink() {
            // Call Apex to check if the Opportunity is linked to an Event with required conditions
            console.log('checkOpportunityLink recordId : '+this.recordId);
            this.displaySlot = false;
            checkIfOpportunityLinked({ opportunityId: this.recordId })
                .then(result => {
                    console.log('result ::: ', result);
        
                    if (result) {
                        this.isOpportunityLinked = true;
                        this.opportunityName = result.opportunityName;
                        
                        // Format the event date and times
                        this.eventDate = result.eventDate;
                        this.eventStartTime = result.eventStartTime;
                        this.eventEndTime = result.eventEndTime;
                        console.log('result.registrationStatus : '+result.registrationStatus);
                        
                        this.registrationStatus = result.registrationStatus;
                        if (result.registrationStatus === 'Digital Slot Scheduled') {
                            this.statusClass = 'green-status'; // Apply green class for Scheduled
                        } else if (result.registrationStatus === 'Digital Slot Rescheduled') {
                            this.statusClass = 'yellow-status'; // Apply yellow class for Re-Scheduled
                        } else {
                            this.statusClass = ''; // Default class
                        }
                        console.log('this.statusClass : '+this.statusClass);
                        
                    }
                })
                .catch(error => {
                    console.error('Error checking Opportunity link:', error);
                });
        }

    handleReschedule(){
        this.isOpportunityLinked = false;
        this.selectedDate = '';
        this.availableTimeSlots = [];
        this.isReschedulesSlot = true;
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
        // Validate if date is within allowed range
        const selected = new Date(this.selectedDate);
        const min = new Date(this.minSelectableDate);
        const max = new Date(this.maxSelectableDate);
        console.log('selected',selected);
        console.log('min',min);
        console.log('max',max);
        this.isDateValid = !(selected >= min && selected <= max);
        
        console.log('this.isDateValid',this.isDateValid);
    }

    handleSearch() {
        if (!this.selectedDate) {
            this.handleAlertClick('Please Select Date', 'error', 'Error!');
            return;
       }
        const currentDate = new Date().toISOString().split('T')[0];

        // Check if the selected date is a past date
        if (this.selectedDate < currentDate) {
            this.handleAlertClick('Please select a valid future date', 'error', 'Error!');
            return;
        }

        // If the date is valid, proceed with the Apex call
        getAvailableTimeSlots({ selectedDate: this.selectedDate , recordId: this.recordId})
            .then(result => {
                this.displaySlot = true;
                console.log('result : ' + JSON.stringify(result));
                // Convert the map into an array of objects for display purposes
                this.availableTimeSlots = Object.keys(result).map(timeSlot => {
                    let count = result[timeSlot];
                    let buttonColor = this.getButtonColor(count);

                    return {
                        Id: timeSlot,
                        Count: count,
                        ButtonColor: buttonColor
                    };
                });

                // If no time slots, you can handle that case if needed
                if (this.availableTimeSlots.length === 0) {
                    this.showSlot = false;
                    console.log('No available time slots for the selected date');
                }else{
                    this.showSlot = true;
                }
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
    }
    async handleAlertClick(message,type,label) {
        await LightningAlert.open({
             message: message,
             theme: type, 
             label: label,
         });
        
    }
    getButtonColor(count) {
        if (count === 1 || count === 0) {
            return 'green';
        } else if (count >= 2 && count <= 5) {
            return 'amber';
        } else if (count > 5) {
            return 'red';
        }
        return '';
    }

    handleSlotClick(event) {
        this.selectedSlotId = event.target.dataset.id;
        const buttonClass = event.target.className;
        console.log('buttonClass : ' + buttonClass);
        if (buttonClass == 'red') {
            this.handleAlertClick('Selected slot is full please select another slot.', 'error', 'Error!');
            return;
        }
        console.log('this.selectedSlotId : ' + this.selectedSlotId);
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
    handleRemarksChange(event){
        this.rescheduleremarks = event.target.value;
    }
   

    bookTimeSlot() {
        updateEventWithOpportunity({ eventTime: this.selectedSlotId, opportunityId: this.recordId, selectedDate: this.selectedDate,resscheduleremark: this.rescheduleremarks })
            .then(result => {
                console.log('result :: '+result);
                if(result == 'Link is expired'){
                    this.handleAlertClick('Link is Expired', 'error', 'Error!');          
                }
                if(result == 'Slot Scheduled Successfully' || result == 'Slot Re-Scheduled Successfully'){
                    this.handleAlertClick(result, 'success', 'Success!');
                }
                
                this.closeModal();
                //this.checkSlotStatus();
                this.checkOpportunityLink()
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
    }
}