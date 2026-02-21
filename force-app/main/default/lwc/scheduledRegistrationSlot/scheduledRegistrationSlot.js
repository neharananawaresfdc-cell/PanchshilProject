import { LightningElement,track } from 'lwc';
import saveEvents from '@salesforce/apex/EventController.saveEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ScheduledRegistrationSlot extends NavigationMixin(LightningElement) {
    @track data = [];

    selectedSlotType = ''; // This will hold the selected value of the picklist
    slotOptions = [
        //{ label: 'Registration Slot', value: 'Registration' },
        { label: 'Digit Matrix Slot', value: 'DigitMatrix' }
    ];
    isTableVisible = false;

    connectedCallback() {
        this.handleAddRow();
    }
    handleSlotTypeChange(event) {
        this.selectedSlotType = event.detail.value;

        // Show or hide the table based on the slot type
        if (this.selectedSlotType === 'Registration') {
            this.isTableVisible = true; // Show the table for Registration Slot
        } else if (this.selectedSlotType === 'DigitMatrix') {
            this.isTableVisible = true; // Show the table for Digit Matrix Slot
        } else {
            this.isTableVisible = false; // Hide the table if no valid slot type selected
        }
    }

    handleAddRow() {
        this.data = [...this.data, { id: this.data.length + 1, date: '', startDateTime: '', endDateTime: '',startTime: '', endTime: '' }];
    }

    handleRemoveRow(event) {
        if (this.data.length === 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You cannot delete this row',
                    variant: 'error'
                })
            );
        } else {
            const rowId = parseInt(event.target.dataset.id, 10);
            this.data = this.data.filter(row => row.id !== rowId);
        }
    }

    // handleInputChange(event) {
    //     const { id, field } = event.target.dataset;
    //     const value = event.target.value;

    //     this.data = this.data.map(row => {
    //         if (row.id === parseInt(id, 10)) {
    //             return { ...row, [field]: value };
    //         }
    //         return row;
    //     });
    // }
    handledatechange(event){
        const { id, field } = event.target.dataset;
        let val = event.target.value;
        try{
        let date  = new Date();
        const pad = (n) => n.toString().padStart(2, '0');
        const localISOString = `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
        let today = new Date().toISOString().split('T')[0];
        let dateval = new Date(val).toISOString().split('T')[0];
        let starttimeelement = this.template.querySelector(`[data-id="${id}"][data-field="startDateTime"]`);
        let endtimeelement = this.template.querySelector(`[data-id="${id}"][data-field="endDateTime"]`);
        if(today == dateval){
            
            starttimeelement.min = localISOString.split('T')[1];
            endtimeelement.min = localISOString.split('T')[1];

            console.log('matched');
        }
        else{
            console.log('not matched');
            starttimeelement.min = "09:30:00.000Z";
            endtimeelement.min = "09:30:00.000Z";
        }
        }
        catch(err){
            console.log('err 82',err,JSON.stringify(err));
        }
        
    }
    handleInputChange(event) {
        const { id, field } = event.target.dataset;
        let val = event.target.value;
        let value;
        try{
        const dateelement = this.template.querySelector(`[data-id="${id}"][data-field="date"]`);
        console.log('find date b row',id,field,dateelement,JSON.stringify(dateelement),dateelement.value);
        if(dateelement.value && dateelement.value != '')
        {
            value = this.createDateTime(dateelement.value,val);
        }
        }
        catch(err){
            console.log('find date',err,JSON.stringify(err));
        }
        //const value = this.createDateTime();
        // const selectedDateTime = new Date(value);
        // const hours = selectedDateTime.getHours();
        // Validate time is between 9:00 and 18:00
        console.log('val',value);
        this.data = this.data.map(row => {
                if (row.id === parseInt(id, 10)) {
                    return { ...row, [field]: value };
                }
                return row;
        });
        // if (hours < 8 || hours >= 20) {
        //     event.target.value = '';
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Invalid Time',
        //             message: 'Please select a time between 8:00 AM and 8:00 PM.',
        //             variant: 'error',
        //         })
        //     );
        //     return;            
        // }else{
        //     this.data = this.data.map(row => {
        //         if (row.id === parseInt(id, 10)) {
        //             return { ...row, [field]: value };
        //         }
        //         return row;
        //     });
        // }       
    }
    createDateTime(date, time) {
        if (!date || !time) return null;
        const dateTime = new Date(date);
        const [hours, minutes] = time.split(':');
        dateTime.setHours(hours);
        dateTime.setMinutes(minutes);
        return dateTime; 
    }

    handleSave() {
        const eventsToSave = this.data.map(row => {
            const extractDateComponents = (dateStr) => {
                if (!dateStr) return null;
                const date = new Date(dateStr);
                return {
                    year: date.getFullYear(),
                    month: date.getMonth() + 1, 
                    day: date.getDate(),
                    hour: date.getHours(),
                    minute: date.getMinutes(),
                    second: date.getSeconds()
                };
            };

            return {
                startDateTime: extractDateComponents(row.startDateTime),
                endDateTime: extractDateComponents(row.endDateTime)
            };
        });
        console.log('event to save',eventsToSave,JSON.stringify(eventsToSave));
        
        // Validation to check if the start or end date is in the past
        const currentDateTime = new Date();
        for (let i = 0; i < eventsToSave.length; i++) {
            const event = eventsToSave[i];
            console.log('event ',event,JSON.stringify(event));
            
            // Convert the event startDateTime and endDateTime into Date objects for comparison
            const startDateTime = new Date(event.startDateTime.year, event.startDateTime.month - 1, event.startDateTime.day, event.startDateTime.hour, event.startDateTime.minute, event.startDateTime.second);
            const endDateTime = new Date(event.endDateTime.year, event.endDateTime.month - 1, event.endDateTime.day, event.endDateTime.hour, event.endDateTime.minute, event.endDateTime.second);
            console.log('startDateTime : ',startDateTime);
            console.log('endDateTime : ',endDateTime);
            
            if (!startDateTime || !endDateTime){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Please fill the valid data for row ${i + 1}`,
                        variant: 'error'
                    })
                );
                return; // Stop the save process
            }

            if (startDateTime > endDateTime) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Start date cannot be greater than end date for row ${i + 1}`,
                        variant: 'error'
                    })
                );
                return; // Stop the save process
            }
            // Check if the startDateTime is in the past
            if (startDateTime < currentDateTime) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Start date cannot be in the past for row ${i + 1}`,
                        variant: 'error'
                    })
                );
                return; // Stop the save process
            }

            // Check if the endDateTime is in the past
            if (endDateTime < currentDateTime) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `End date cannot be in the past for row ${i + 1}`,
                        variant: 'error'
                    })
                );
                return; // Stop the save process
            }
        }

        // If all date validations passed, proceed with saving events
        console.log('eventsToSave:', JSON.stringify(eventsToSave));

        saveEvents({ eventList: eventsToSave,selectedSlotType : this.selectedSlotType })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Events saved successfully',
                        variant: 'success'
                    })
                );
                this.data = [];
                window.location.reload();
                //this.handleAddRow();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving events',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleViewCalendar() {
        // Get today's date in the format YYYY-MM-DD
        const today = new Date();
        const yyyy = today.getFullYear();
        let mm = today.getMonth() + 1; // Months are zero-based
        let dd = today.getDate();

        // Format date to ensure two digits for month and day
        mm = mm < 10 ? '0' + mm : mm;
        dd = dd < 10 ? '0' + dd : dd;

        const formattedDate = `${yyyy}-${mm}-${dd}`;

        // Navigate to the Event home page with today's date as startDate
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/lightning/o/Event/home?startDate=${formattedDate}&view=week`
            }
        });
    }
}