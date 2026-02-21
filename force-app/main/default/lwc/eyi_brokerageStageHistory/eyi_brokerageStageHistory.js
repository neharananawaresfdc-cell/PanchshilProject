import { LightningElement, api, wire } from 'lwc';
import getStageHistory from '@salesforce/apex/EYI_BrokerageStatusHistoryUtility.getStageHistory';

export default class eyi_brokerageStageHistory extends LightningElement {
    @api recordId;
    stageData = [];

    columns = [
        { label: 'User', fieldName: 'userName' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Time Spent (Days)', fieldName: 'timeSpentDays', type: 'number' },
        { label: 'Last Modified', fieldName: 'lastModified', type: 'date' }
    ];

    @wire(getStageHistory, { brokerageId: '$recordId' })
    wiredStageHistory({ data, error }) {
        if (data) {
            this.stageData = data;
        } else if (error) {
            console.error('Error fetching stage history', error);
        }
    }
}