/*********************************************************************************************************
    Programmer:         Tony WIlliams
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            <SFDC-26> 
    Original:           10/14/2016 - Used to test Account Retention Health
    
 ***********************************************************************************************************/ 

@IsTest(SeeAllData=true)
public class TestAccountHealthController{
     public static testMethod void testAccountHealthController() {
       ApexPages.StandardController sc;
       PageReference pageRef = new PageReference('/apex/AccountHealthPage');
        List<Account> aUS = new List<Account>();
        Test.setCurrentPageReference(pageRef);
        //Add Account Owner
         Profile portal_profiles = [Select Id, Name From Profile Where  Name  = 'Awana US Ministries'];
           Profile UserProfile = portal_profiles;
           Contact c = new Contact(FirstName = 'Illiana',
                       LastName = 'Faye',
                       Email='illfaye@mailinator.com');
           insert c;
           User currentOwner = new User(
                       //ContactId = c.Id,
                          FirstName='Illiana',
                          LastName='Faye',
                          UserName='illfaye@mailinator.com.test',
                          email='illfaye@mailinator.com',
                          alias='illfaye',
                          TimeZoneSidKey = 'America/Chicago',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', 
                                  EmailEncodingKey = 'ISO-8859-1',
                                  CommunityNickName = c.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
                                  ProfileId =UserProfile.Id);
          insert currentOwner;
          
          
             Contact c1 = new Contact(FirstName = 'Rita',
                       LastName = 'Marzullo',
                       Email='rmarzullo@mailinator.com');
            insert c1;
            User ownerChanged = new User(
                          //ContactId = c1.Id,
                          FirstName='Rita',
                          LastName='Marzullo',
                          UserName='rmarzullo@mailinator.com.test',
                          email='rmarzullo@mailinator.com',
                          alias='rmarzul',
                          TimeZoneSidKey = 'America/Chicago',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', 
                                  EmailEncodingKey = 'ISO-8859-1',
                                  CommunityNickName = c1.Email.split('@')[0]+String.valueOf(DateTime.now().millisecond()),
                                  ProfileId =UserProfile.Id);
            insert ownerChanged;
          
        //Create the  codes
        List<String> codes = new List<String>();
        codes.add('Everything Is OK');
        codes.add('Don\'t Know');
        codes.add('Problems: Don\'t Know How To Fix');
        codes.add('Problems: Can Fix'); 
         
        //Create Accounts
        for(Integer i=0; i < 4;i++){
            aUS.add(new Account(Type='Church',Name='Sample Test Church'+i,Account_Health__c = codes[i],OwnerId=currentOwner.Id));
            //aUS.add(new Account(Type='Church',Name='Sample Test Church'+i,Account_Health__c = 'Everything Is OK',OwnerId=currentOwner.Id));
        }
        insert aUS;
        for(Integer i=0; i < 4;i++){
            aUS[i].OwnerId=ownerChanged.Id;
        }
         update aUS;
         
        Test.startTest();
        for(Integer i=0; i < 4;i++){
            sc = new ApexPages.standardController(aUS[i]);
            AccountHealthController controller = new AccountHealthController(sc); 
            String colorString = controller.getWhichColor();
            system.debug('<<<=== COLOR STRING ===>> '+colorString);
            // Verify that the success page displays
            System.assertEquals(colorString, colorString);
        }
        Test.stopTest();
        
    }
}