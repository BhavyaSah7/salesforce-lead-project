import { refreshApex } from '@salesforce/apex';
import getLeadDetails from '@salesforce/apex/LeadContactController.getLeadDetails';
import markFirstContact from '@salesforce/apex/LeadContactController.markFirstContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

export default class LeadQuickAction extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track isProcessing = false;
    @track lead = {};
    wiredLeadResult;

    @wire(getLeadDetails, { leadId: '$recordId' })
    wiredLead(result) {
        this.wiredLeadResult = result;
        if (result.data) {
            this.lead = result.data;
            this.isLoading = false;
        } else if (result.error) {
            console.error('Error loading lead:', result.error);
            this.isLoading = false;
        }
    }

    handleMarkContact() {
        this.isProcessing = true;
        markFirstContact({ leadId: this.recordId })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'First contact marked successfully!',
                variant: 'success'
            }));
            // Notify other components on the page that the record changed
            getRecordNotifyChange([{ recordId: this.recordId }]);
            return refreshApex(this.wiredLeadResult);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }

    get followUpStatus() {
        return this.lead.Follow_Up_Sent__c ? 'Yes ✅' : 'No ❌';
    }
    get escalatedStatus() {
        return this.lead.Escalated__c ? 'Yes ⚠️ Needs attention' : 'No ✅';
    }
    get assignmentDate() {
        return this.lead.Assignment_Date__c
            ? new Date(this.lead.Assignment_Date__c).toLocaleString()
            : 'Not yet assigned';
    }
}