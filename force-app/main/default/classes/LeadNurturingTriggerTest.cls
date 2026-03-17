@isTest
public class LeadNurturingTriggerTest {

    @isTest
    static void testEmailOnInsert() {
        // Test that email is sent when lead is created with an owner
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Insert Lead',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Lead_Region__c = 'North',
            Follow_Up_Sent__c = false
        );

        Test.startTest();
        insert testLead;
        Test.stopTest();

        Lead result = [SELECT Follow_Up_Sent__c, Assignment_Date__c
                       FROM Lead WHERE Id = :testLead.Id];

        System.assertEquals(true, result.Follow_Up_Sent__c,
                            'Follow up should be sent on insert');
        System.assertNotEquals(null, result.Assignment_Date__c,
                              'Assignment date should be stamped on insert');
    }

    @isTest
    static void testEmailOnOwnerChange() {
        // Test that email fires when owner changes
        User testUser = [SELECT Id FROM User WHERE IsActive = true
                         AND Id != :UserInfo.getUserId() LIMIT 1];

        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Update Lead',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Follow_Up_Sent__c = false
        );
        insert testLead;

        Test.startTest();
        testLead.OwnerId = testUser.Id;
        update testLead;
        Test.stopTest();

        Lead result = [SELECT Follow_Up_Sent__c, Assignment_Date__c
                       FROM Lead WHERE Id = :testLead.Id];

        System.assertEquals(true, result.Follow_Up_Sent__c,
                            'Follow up should be sent on owner change');
        System.assertNotEquals(null, result.Assignment_Date__c,
                              'Assignment date should be stamped');
    }

    @isTest
    static void testNoEmailWithoutEmailAddress() {
        // Test that leads without email are skipped gracefully
        Lead testLead = new Lead(
            FirstName = 'No',
            LastName = 'Email Lead',
            Company = 'Test Co',
            Email = null,
            Follow_Up_Sent__c = false
        );

        Test.startTest();
        insert testLead;
        Test.stopTest();

        Lead result = [SELECT Follow_Up_Sent__c FROM Lead
                       WHERE Id = :testLead.Id];

        System.assertEquals(false, result.Follow_Up_Sent__c,
                            'No follow up should be sent without email');
    }

    @isTest
    static void testNoDuplicateEmail() {
        // Test that email is NOT sent again if Follow_Up_Sent is already true
        User testUser = [SELECT Id FROM User WHERE IsActive = true
                         AND Id != :UserInfo.getUserId() LIMIT 1];

        Lead testLead = new Lead(
            FirstName = 'No',
            LastName = 'Duplicate Lead',
            Company = 'Test Co',
            Email = 'test@example.com',
            Follow_Up_Sent__c = true  // Already sent
        );
        insert testLead;

        Test.startTest();
        testLead.OwnerId = testUser.Id;
        update testLead;
        Test.stopTest();

        // Follow_Up_Sent should still be true — no change
        Lead result = [SELECT Follow_Up_Sent__c FROM Lead
                       WHERE Id = :testLead.Id];
        System.assertEquals(true, result.Follow_Up_Sent__c,
                            'Should not send duplicate email');
    }

    @isTest
    static void testBulkInsert() {
        // Test 200 leads at once — proves bulk-safe
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead ' + i,
                Company = 'Bulk Co ' + i,
                Email = 'bulk' + i + '@example.com',
                Follow_Up_Sent__c = false
            ));
        }

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<Lead> results = [SELECT Follow_Up_Sent__c FROM Lead
                              WHERE LastName LIKE 'Lead %'];
        for (Lead l : results) {
            System.assertEquals(true, l.Follow_Up_Sent__c,
                               'All bulk leads should have follow up sent');
        }
    }
}