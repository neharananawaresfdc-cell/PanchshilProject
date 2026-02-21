import { LightningElement, api, wire, track } from 'lwc';
import getOpportunityFiles from '@salesforce/apex/EYI_OpportunityFiles.getOpportunityFiles';
import {NavigationMixin} from 'lightning/navigation'
export default class FilePreviewAndDownloads extends NavigationMixin(LightningElement) {

    @api recordId;
    @track flag = false;
    @track filesList =[];
    @wire(getOpportunityFiles, {opportunityId: '$recordId'})
    wiredResult({data, error}){ 
        if(data){ 
            console.log(data)
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList);
            this.flag = this.filesList.length > 0;
        }
        if(error){ 
            console.log(error)
        }
        
    }
    
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}