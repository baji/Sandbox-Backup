//********************************************************************************************************************************************************************************************************************************************
// Author: Ewa O.
// Created: 7-10-2018 -<ASP-1189> - Tests: PrepareMySandbox APEX code 
//*****************************************************************************************************************************
@isTest(SeeAllData=true)
public class PrepareMySandboxTest {
    
     static  testmethod void testMySandboxPrep() {
        Profile p = [ SELECT id FROM Profile WHERE name = 'System Administrator' ];

        User user1;

        System.runAs( new User( id = UserInfo.getUserId() ) ) {
            user1 = newUser( p.id, 'Alpha', 'User 1', 'user_1=salesforce.com@example.com' );
            insert user1;
        }

        Test.startTest();
        Test.testSandboxPostCopyScript(
            new PrepareMySandbox(), // apex class to run
            '00D1a000040BlpQ', // org id
            '00D90000000KY45', // sandbox id
            'My Sandbox' // sandbox name
        );
        Test.stopTest();

        user1 = [ SELECT id, email FROM User WHERE id = :user1.id ];

        System.assertEquals( 'user_1@salesforce.com', user1.email );        
        
        /*
            List<Profile> someProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            List<User>  testAdmins = [SELECT FirstName, LastName, email FROM User WHERE ProfileId = :someProfileId[0].Id LIMIT 5];
    
            //checks what the first 5 emails are in the list
            for(integer x=0; x<testAdmins.size();x++)
                System.debug(testAdmins[x].email);
            
            //test code from postSandboxCopy interface
            Test.startTest();
            Test.testSandboxPostCopyScript(
                new PrepareMySandbox(), UserInfo.getOrganizationId(),UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
                    List<User>  adminUsers = [SELECT Id, email FROM User WHERE ProfileId = :someProfileId[0].Id];
            Test.stopTest();
            //checks if the admin emails where updated
            System.debug('< UPDATED ADMIN USERS > '+adminUsers);
             
            //checks to see if the new admin emails contain '=' or '@example.com'
            System.assertEquals(false, (adminUsers[0].email.contains('@example.com') & adminUsers[0].email.contains('=')));
            System.assertEquals(false, (adminUsers[0].email.contains('@example.com') & adminUsers[1].email.contains('=')));
            System.assertEquals(false, (adminUsers[0].email.contains('@example.com') & adminUsers[2].email.contains('=')));
            System.assertEquals(false, (adminUsers[0].email.contains('@example.com') & adminUsers[3].email.contains('=')));
            System.assertEquals(false, (adminUsers[0].email.contains('@example.com') & adminUsers[4].email.contains('=')));
        */
     }
     private static User newUser( ID profileId, String firstName, String lastName, String email ) {
        Integer rand = Math.round( Math.random() * 1000 );
        return new User(
            isActive = true,
            profileId = profileId,
            alias = firstName.substring(0,1) + lastName.substring(1,5),
            firstName = firstName,
            lastName = lastName,
            email = email,
            username = rand + email,
            emailEncodingKey = 'UTF-8',
            languageLocaleKey = 'en_US',
            localeSidKey = 'en_US',
            timeZoneSidKey = 'America/Chicago'
        );
    }
}