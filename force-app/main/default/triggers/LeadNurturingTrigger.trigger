trigger LeadNurturingTrigger on Lead (after insert, after update) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    List<Lead> leadsToUpdate = new List<Lead>();

    for (Lead l : Trigger.new) {

        Boolean isNewAssignment = false;

        if (Trigger.isInsert) {
            // On insert: fire if lead has an owner and email not sent
            isNewAssignment = (l.OwnerId != null && !l.Follow_Up_Sent__c);
        } else if (Trigger.isUpdate) {
            // On update: fire only if owner just changed
            Lead oldLead = Trigger.oldMap.get(l.Id);
            isNewAssignment = (l.OwnerId != oldLead.OwnerId && !l.Follow_Up_Sent__c);
        }

        if (isNewAssignment) {
            if (l.Email == null) continue;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ l.Email });
            email.setSubject('Hi ' + l.FirstName + ', we received your enquiry');

            String body = 'Dear ' + l.FirstName + ' ' + l.LastName + ',\n\n';
            body += 'Thank you for your interest. A member of our team ';
            body += 'will be in touch with you shortly.\n\n';
            body += 'Best regards,\nThe Sales Team';
            email.setPlainTextBody(body);
            emails.add(email);

            leadsToUpdate.add(new Lead(
                Id = l.Id,
                Follow_Up_Sent__c = true,
                Assignment_Date__c = DateTime.now()
            ));
        }
    }

    if (!emails.isEmpty()) {
    	if (!Test.isRunningTest()) Messaging.sendEmail(emails);
	}
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }
}