import { LightningElement, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class ParentLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @wire(CurrentPageReference)
   setPageReference(currentPageReference) {
       // Retrieve the query parameters from the current page
       if (currentPageReference) {
        this.currentUrl = window.location.href;
        console.log('this.currentUrl-->'+this.currentUrl);
        this.recordId = currentPageReference.state.recordId;
       }
    }
    connectedCallback() {
        // Open a Lightning App Tab inside a sub-tab
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Payment_Receipt_Creation' // Use the API name of the Lightning Tab you created
            },
            state: {
                c__recordId: this.recordId // Pass parameters if needed
            }
        });
    }
}