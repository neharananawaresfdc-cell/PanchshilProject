import { LightningElement, api, track, wire } from 'lwc';
import getLeadStatusTime from '@salesforce/apex/EYI_LeadEnquiryUtility.getLeadStatusTime';
import componentCardLabel from '@salesforce/label/c.EYI_LeadHistoryCardTitle';
import noStatusHistoryMessage from '@salesforce/label/c.EYI_NoStatusHistoryMessage';

export default class EYI_LeadEnquiryStatusHistory extends LightningElement {
    @api recordId; // The LeadId passed to the component
    componentLabel = componentCardLabel;
    statusHistoryMsg = noStatusHistoryMessage;
    leadStatusData = []; // To store the lead status data
    userNameMap = {}; // To store user name mapping
    @track isSpinner = true;
    columns = [
        { label: 'User', fieldName: 'userName', type: 'text' },
        { label: 'Status', fieldName: 'status', type: 'text' },
        { 
            label: 'Time Spent (Days)', 
            fieldName: 'timeSpent', 
            type: 'text',
        },
        { 
            label: 'Last Modified', 
            fieldName: 'lastModified', 
            type: 'date', 
            typeAttributes: {
                year: "numeric", 
                month: "2-digit", 
                day: "2-digit", 
                hour: "2-digit", 
                minute: "2-digit", 
                second: "2-digit", 
                hour12: true
            }
        }
    ];

    // Wire the Apex method to get lead status time data
    @wire(getLeadStatusTime, { leadId: '$recordId' })
    wiredLeadStatusTime({ error, data }) {
        if (data) {
            console.log('fetching user names:', data);
            this.leadStatusData = data;
            this.isSpinner = false;
            // this.leadStatusData = data.map(record => {
            //     return {
            //         userName: record.userName,
            //         status: record.status,
            //         timeSpent: record.timeSpent, // Time spent in hours
            //         lastModified: record.lastModified // Last modified date of the status (CreatedDate)
            //     };
            // });
        } else if (error) {
            this.isSpinner = false;
            console.error('Error fetching lead status time:', error);
        }
    }
}