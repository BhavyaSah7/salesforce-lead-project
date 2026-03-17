import getLeadStats from '@salesforce/apex/LeadContactController.getLeadStats';
import { LightningElement, track, wire } from 'lwc';

export default class LeadPipelineDashboard extends LightningElement {
    @track stats = {};
    @track isLoading = true;
    @track contactRate = 0;

    renderedCallback() {
    const bar = this.template.querySelector('.progress-bar-fill');
    if (bar) {
        bar.style.width = `${this.contactRate}%`;
    }
}

    @wire(getLeadStats)
    wiredStats({ data, error }) {
        if (data) {
            this.stats = data;
            if (data.totalLeads > 0) {
                this.contactRate = Math.round(
                    (data.contactedLeads / data.totalLeads) * 100
                );
            }
            this.isLoading = false;
        } else if (error) {
            console.error('Error loading stats:', error);
            this.isLoading = false;
        }
    }
}