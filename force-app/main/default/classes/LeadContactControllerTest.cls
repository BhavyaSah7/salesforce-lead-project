@isTest
public class LeadContactControllerTest {

    @isTest
    static void testMarkFirstContact() {
        // Create a test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Contact',
            Company = 'Test Company',
            Email = 'test@example.com',
            First_Contact_Made__c = false
        );
        insert testLead;

        Test.startTest();
        LeadContactController.markFirstContact(testLead.Id);
        Test.stopTest();

        Lead result = [SELECT First_Contact_Made__c 
                       FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, result.First_Contact_Made__c,
                            'First contact should be marked true');
    }

    @isTest
    static void testGetLeadDetails() {
        // Create a test lead with all custom fields
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Details',
            Company = 'Test Company',
            Email = 'test@example.com',
            First_Contact_Made__c = false,
            Follow_Up_Sent__c = true,
            Escalated__c = false,
            Assignment_Date__c = DateTime.now()
        );
        insert testLead;

        Test.startTest();
        Lead result = LeadContactController.getLeadDetails(testLead.Id);
        Test.stopTest();

        System.assertNotEquals(null, result,
                              'Lead details should be returned');
        System.assertEquals('Test', result.FirstName,
                            'First name should match');
        System.assertEquals(true, result.Follow_Up_Sent__c,
                            'Follow up sent should be true');
        System.assertEquals(false, result.First_Contact_Made__c,
                            'First contact should be false');
    }

    @isTest
    static void testGetLeadStats() {
        // Create a mix of leads with different statuses
        List<Lead> leads = new List<Lead>();

        // 3 total leads
        leads.add(new Lead(FirstName='Lead', LastName='One',
            Company='Co1', First_Contact_Made__c=true,
            Follow_Up_Sent__c=true, Escalated__c=false));

        leads.add(new Lead(FirstName='Lead', LastName='Two',
            Company='Co2', First_Contact_Made__c=false,
            Follow_Up_Sent__c=true, Escalated__c=true,
            Assignment_Date__c=DateTime.now()));

        leads.add(new Lead(FirstName='Lead', LastName='Three',
            Company='Co3', First_Contact_Made__c=false,
            Follow_Up_Sent__c=false, Escalated__c=false,
            Assignment_Date__c=DateTime.now()));

        insert leads;

        Test.startTest();
        LeadContactController.LeadStats stats =
            LeadContactController.getLeadStats();
        Test.stopTest();

        System.assertNotEquals(null, stats,
                              'Stats should not be null');
        System.assert(stats.totalLeads >= 3,
                     'Should have at least 3 total leads');
        System.assert(stats.contactedLeads >= 1,
                     'Should have at least 1 contacted lead');
        System.assert(stats.escalatedLeads >= 1,
                     'Should have at least 1 escalated lead');
        System.assert(stats.followUpSent >= 2,
                     'Should have at least 2 follow up sent');
        System.assert(stats.pendingContact >= 1,
                     'Should have at least 1 pending contact');
    }

    @isTest
    static void testMarkFirstContactAlreadyContacted() {
        // Test that marking an already-contacted lead doesn't throw error
        Lead testLead = new Lead(
            FirstName = 'Already',
            LastName = 'Contacted',
            Company = 'Test Co',
            First_Contact_Made__c = true  // Already true
        );
        insert testLead;

        Test.startTest();
        // Should complete without error
        LeadContactController.markFirstContact(testLead.Id);
        Test.stopTest();

        Lead result = [SELECT First_Contact_Made__c
                       FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, result.First_Contact_Made__c,
                            'Should still be true');
    }
}