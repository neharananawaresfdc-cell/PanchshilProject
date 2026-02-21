import { LightningElement, track, api } from 'lwc';
import getfileIds from '@salesforce/apex/RecordFileDownloaderController.getfileIds';

export default class RecordFileDownloader extends LightningElement {
    @api recordId;
    @track fileIds = '';
    @track error = '';
    @api inputValueList;
    recordCount = 0;
    showDownload = false;

    connectedCallback() {
        if (!this.inputValueList) {
            this.error = 'Please select at least one record';
            this.showDownload = false;
            return;
        } 

        this.recordCount = this.inputValueList.split(',').length;
        if (this.recordCount > 100) {
            this.error = 'Please select less than 100 records';
            this.showDownload = false;
            return;
        }

        this.showDownload = true;

        getfileIds({ recordIds: this.inputValueList.split(',') })
            .then(result => {
                let fileDataList = JSON.parse(JSON.stringify(result));
                if (!fileDataList || fileDataList.length === 0) {
                    this.error = 'No PANCARD files found for the selected records.';
                    this.showDownload = false;
                    return;
                }

                let fileIdsString = fileDataList.map(id => id + '/').join('');
                fileIdsString = fileIdsString.replace(/.$/, "?");
                
                this.fileIds = fileIdsString;
                this.error = undefined;
                this.onDownloadAgain();
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                this.error = 'An error occurred while fetching PANCARD files.';
                this.showDownload = false;
            });
    }

    oncloseWindow() {
        window.open('/lightning/o/Opportunity/list?filterName=AllOpportunities', '_self');
    }

    onDownloadAgain() {
        if (this.fileIds) {
            window.open(this.getDownloaLink, '_self');
        } else {
            this.error = 'No valid PANCARD files to download.';
        }
    }

    get getDownloaLink() {
        return this.fileIds ? '/sfc/servlet.shepherd/version/download/' + this.fileIds : '#';
    }
}