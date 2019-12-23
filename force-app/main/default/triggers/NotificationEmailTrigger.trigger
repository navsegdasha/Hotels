trigger NotificationEmailTrigger on Reservation__c (before insert) {
    for(Reservation__c record : Trigger.new) {
        System.debug('Current user ' + UserInfo.getUserId());
    	User current_user=[SELECT Email FROM User WHERE Id= :UserInfo.getUserId()] ;
        EmailManager.sendMail(current_user.Email,'Booking rooms',
                              'You booked ' + 1 + ' room. From ' + record.Check_inDate__c + ' till ' + record.Check_outDate__c + '.');
    }
}