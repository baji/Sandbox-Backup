/*********************************************************************************************************
Programmer:         Ayesha
Company:            Awana
Contact:            ayesha@infoglen.com
Project:            updateMozoTrialToDWREAccount_Test
Original:           12/29/2017 - Used to test Contact update triggers.
***********************************************************************************************************/ 
@IsTest
public class updateMozoTrialToDWREAccount_Test{
    static testMethod void updateMozoTrialToDWREAccountTest(){
        Profile portal_profiles = [Select Id, Name From Profile Where  Name  = 'Awana Customer Care'];
        Profile UserProfile = portal_profiles;
        Contact c = new Contact(FirstName = 'Marty',
                                LastName = 'Faye',
                                Email='mfaye@mailinator.com');
        User currentOwner = new User(
            //ContactId = c.Id,
            FirstName='shaik',
            LastName='Demandware',
            UserName='mfaye@mailinator.com.test',
            email='mfaye@mailinator.com',
            alias='mafaye',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US', 
            EmailEncodingKey = 'ISO-8859-1',
            CommunityNickName = c.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
            ProfileId =UserProfile.Id);
        insert currentOwner;  
        Account account1 = new Account(Name='Test1',Type='Church');
        
        insert account1;
        account1.Mozo_Trial_Status__c = 'Current';
        update account1;
    }
}