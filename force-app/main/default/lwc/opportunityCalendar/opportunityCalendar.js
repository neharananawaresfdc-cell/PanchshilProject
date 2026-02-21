import { LightningElement, track, api, wire} from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableTimeSlots from '@salesforce/apex/OpportunityCalendarController.getAvailableTimeSlots';
import updateEventWithOpportunity from '@salesforce/apex/OpportunityCalendarController.updateEventWithOpportunity'; 
import unlinkOpportunityFromEvent from '@salesforce/apex/OpportunityCalendarController.unlinkOpportunityFromEvent'; 
import createEvent from '@salesforce/apex/OpportunityCalendarController.createEvent'; 
import checkIfOpportunityLinked from '@salesforce/apex/OpportunityCalendarController.checkIfOpportunityLinked';
import { CurrentPageReference } from 'lightning/navigation';


export default class OpportunityCalendar extends LightningElement {
    @api recordId;
    @track selectedDate;
    @track availableTimeSlots = [];
    @track bookedTimeSlots = [];
    @track errorMessage;
    @track isModalOpen = false;
    @track selectedSlotId;
    @track selectedStartTime;
    @track selectedEndTime;
    @track isOpportunityLinked = false;
    @track opportunityName;
    @track eventDateTime;
    @track eventStartTime;
    @track eventEndTime;
    @track isRecheduled = false;
    @track registrationStatus;
    @track displaySlot = false;
    @track showSlot = false;
    @track isLoading = false;


    inputDate = '';
    startTime = '';
    endTime = '';


    connectedCallback(){
        console.log('connectedCallback recordId : ' + this.recordId);
        if (this.recordId) {
           // this.checkOpportunityLink();
        } else {
            console.log('recordId is undefined in connectedCallback '+this.recordId);
        }
    }

   @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            // Check if the recordId exists in the page reference
            this.recordId = currentPageReference.state.recordId;
            console.log('getStateParameters Record ID : ', this.recordId);
            this.checkOpportunityLink();
        }
    }
    checkOpportunityLink() {
        // Call Apex to check if the Opportunity is linked to an Event with required conditions
        console.log('checkOpportunityLink recordId : '+this.recordId);
        this.displaySlot = false;
        this.isLoading = true;
        checkIfOpportunityLinked({ opportunityId: this.recordId })
            .then(result => {
                this.isLoading = false;
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
                    if (result.registrationStatus === 'Scheduled') {
                        this.statusClass = 'green-status'; // Apply green class for Scheduled
                    } else if (result.registrationStatus === 'Re-Scheduled') {
                        this.statusClass = 'yellow-status'; // Apply yellow class for Re-Scheduled
                    } else {
                        this.statusClass = ''; // Default class
                    }
                    console.log('this.statusClass : '+this.statusClass);
                    
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error checking Opportunity link:', error);
            });
    }
    

    handleDateChange(event) {
        this.selectedDate = event.target.value;
        this.errorMessage = null;
        this.displaySlot = false;
    }

    handleSearch() {
        if (!this.selectedDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please Select Date.',
                    variant: 'error',
                })
            );
            return;
        }
    
        const currentDate = new Date().toISOString().split('T')[0]; // Get the current date in YYYY-MM-DD format
    
        // Check if the selected date is a past date
        if (this.selectedDate < currentDate) {
            // Show error toast message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid Date',
                    message: 'Please select a valid future date.',
                    variant: 'error',
                })
            );
            return; // Exit if the date is in the past
        }
    
        // If the date is valid, proceed with the Apex call
        getAvailableTimeSlots({ selectedDate: this.selectedDate })
            .then(result => {
                this.displaySlot = true;
                // Initialize the availableTimeSlots array
                this.availableTimeSlots = [];
    
                // Check if there are available events
                if (result.availableEvents) {
                    console.log('inside available time slot');
                    // Add available events to the availableTimeSlots with green color
                    this.availableTimeSlots = result.availableEvents.map(event => {
                        return {
                            ...event,
                            buttonColor: 'green' // Set button color to green for available events
                        };
                    });
                }
    
                // Check if there are booked events
                if (result.bookedEvents) {
                    console.log('inside booked time slot');
                    // Add booked events to the availableTimeSlots with yellow color
                    this.availableTimeSlots = this.availableTimeSlots.concat(
                        result.bookedEvents.map(event => {
                            return {
                                ...event,
                                buttonColor: 'yellow' // Set button color to yellow for booked events
                            };
                        })
                    );
                }
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

    handleSlotClick(event) {
        this.selectedSlotId = event.target.dataset.id;
        this.selectedStartTime = event.target.dataset.start;
        this.selectedEndTime = event.target.dataset.end;
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    bookTimeSlot() {
        updateEventWithOpportunity({ eventId: this.selectedSlotId, opportunityId: this.recordId, isRecheduled:this.isRecheduled })
            .then(() => {
                this.closeModal();
                this.handleSearch();
                this.checkOpportunityLink();
            })
            .catch(error => {
                console.error('Error booking event: ', error);
            });
    }

    

    async handleReschedule() {
        const result = await LightningConfirm.open({
            message: 'Do you want to reschedule the registration date',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        console.log('result=> : '+result);
        
        if(result == true){
            unlinkOpportunityFromEvent({ opportunityId: this.recordId })
            .then(() => {
                this.isOpportunityLinked = false;
                this.selectedDate = '';
                this.availableTimeSlots = [];
                this.bookedTimeSlots = []
                this.isRecheduled = true;
                //this.handleSearch(); // After unlinking, allow the user to pick a new time slot
            })
            .catch(error => {
                console.error('Error unlinking Opportunity from Event:', error);
            });
        } else{
            console.log('You clicked on cancel');
        }  
    }

    handleDateChange(event){
        this.inputDate = event.target.value;
        console.log('selectedDate: '+this.inputDate);
    }
    handleStartTimeChange(event){
        this.startTime = event.target.value;
        console.log('startTime: '+this.startTime);      
    }
    handleEndTimeChange(event){
        this.endTime = event.target.value;
        console.log('endTime: '+this.endTime);
    }
    handleCreateEvent() {
        console.log('selectedDate: '+this.inputDate);
        console.log('startTime: '+this.startTime);
        console.log('endTime: '+this.endTime);
        const validationError = this.validateInputs();
        if (validationError) {
            this.showToast('Error', validationError, 'error');
            return;
        }
        const startDateTime = this.createDateTimeUTC(this.inputDate, this.startTime);
        const endDateTime = this.createDateTimeUTC(this.inputDate, this.endTime);
        this.isLoading = true;

        createEvent({ startDatetime: startDateTime, endDatetime: endDateTime, recordId:this.recordId })
            .then((result) => {
                this.isLoading = false;
                console.log('Event Created: ', result);
                this.showToast('Success', 'Registration Slot Booked Successfully', 'success');
                this.checkOpportunityLink();
            })
            .catch((error) => {
                this.isLoading = false;
                console.error('Error creating event: ', error);
                //this.showToast('Error', error.body.message, 'error');
            });
    }

    createDateTimeUTC(date, time) {
        if (!date || !time) return null;
        const [year, month, day] = date.split('-');
        const [hours, minutes] = time.split(':');
    
        const dateObj = new Date(Date.UTC(
            parseInt(year), 
            parseInt(month) - 1, 
            parseInt(day), 
            parseInt(hours), 
            parseInt(minutes)
        ));
    
        return dateObj.toISOString(); // sends it in UTC format
    }
    

    validateInputs() {
        const currentDate = new Date();
        console.log('currentDate: '+currentDate);        
        const inputDateObj = new Date(this.inputDate);
        console.log('inputDateObj: '+inputDateObj);
        console.log(' currentDate.setHours(0, 0, 0, 0) : '+ currentDate.setHours(0, 0, 0, 0));
        
        if (!this.inputDate) {
            return 'Please select a date.';
        }
        if (inputDateObj < currentDate.setHours(0, 0, 0, 0)) {
            return 'The date must be today or a future date.';
        }
        const startDatetime = this.createDateTime(this.inputDate, this.startTime);
        const endDatetime = this.createDateTime(this.inputDate, this.endTime);
        console.log('this.inputDate: '+this.inputDate + ' this.startDatetime: ' +startDatetime + ' this.endDatetime:' +endDatetime);
        if (startDatetime <= new Date()) {
            return 'Start date and time must be in the future.';
        }
        if (endDatetime <= startDatetime) {
            return 'End date and time must be after the start date and time.';
        }
        return null;
    }

    createDateTime(date, time) {
        if (!date || !time) return null;
        const dateTime = new Date(date);
        const [hours, minutes] = time.split(':');
        dateTime.setHours(hours);
        dateTime.setMinutes(minutes);
        return dateTime; 
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

}