public with sharing class LeadContactController {

    // Inner class defined FIRST before any method uses it
    public class LeadStats {
        @AuraEnabled public Integer totalLeads { get; set; }
        @AuraEnabled public Integer contactedLeads { get; set; }
        @AuraEnabled public Integer escalatedLeads { get; set; }
        @AuraEnabled public Integer followUpSent { get; set; }
        @AuraEnabled public Integer pendingContact { get; set; }
    }

    @AuraEnabled
    public static void markFirstContact(Id leadId) {
        Lead l = new Lead(
            Id = leadId,
            First_Contact_Made__c = true
        );
        update l;
    }

    @AuraEnabled(cacheable=true)
    public static Lead getLeadDetails(Id leadId) {
        return [
            SELECT Id, FirstName, LastName,
                First_Contact_Made__c, Follow_Up_Sent__c,
                Assignment_Date__c, Escalated__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static LeadStats getLeadStats() {
        LeadStats stats = new LeadStats();
        stats.totalLeads = [SELECT COUNT() FROM Lead
            WHERE IsConverted = false];
        stats.contactedLeads = [SELECT COUNT() FROM Lead
            WHERE IsConverted = false AND First_Contact_Made__c = true];
        stats.escalatedLeads = [SELECT COUNT() FROM Lead
            WHERE IsConverted = false AND Escalated__c = true];
        stats.followUpSent = [SELECT COUNT() FROM Lead
            WHERE IsConverted = false AND Follow_Up_Sent__c = true];
        stats.pendingContact = [SELECT COUNT() FROM Lead
            WHERE IsConverted = false AND First_Contact_Made__c = false
            AND Assignment_Date__c != null];
        return stats;
    }
}