import { LightningElement, api } from 'lwc';

export default class DocumentPreviewModal extends LightningElement {
    @api fileurl;

    connectedcallback(){
        console.log('filePreviewUrl:' + this.filePreviewUrl);
    }
    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}