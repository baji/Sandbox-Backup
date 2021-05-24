/**********************************************************************************************************************
    Programmer:         Tony W.
    Company:            Awana
    Contact:            tonyw@awana.org
    Project:            CRM Rewrite
    Original:           02/03/2018   - Tests both AccountBeforeTrigger and AddNewAccountOwner class
  Called By: AccountBeforeUpdate Trigger
 *********************************************************************************************************************/ 

@isTest(SeeAllData=true)
public class TestAccountBeforeUpdate {
    static testMethod void TestAccountBeforeUpdate_TestMethod (){
        //Create accounts that are null, None, and Former for GO Level.
        //Also test null and non-null Start Date.
        RecordType  rc = [Select Id from RecordType where Name  = 'US Organization' limit 1];   
        Contact ct3 = new Contact(Firstname='Ben', Lastname = 'Gurion', Email='bengurion@mailinator.com');
        insert ct3;
        Account usOrgAccount3 = new Account(RecordTypeId=rc.Id,  
                                     Name='Test Account 3', 
                                    // Status__c='Prospect',  // Becuas eof PardotNewChurchINsert class
                                     Status__c='Added',     
                                     Type='Church Plant',
                                     Exclude_From_Club_Finder__c = false,
                                     Registration_Level__c = 'R0',
                                     GO_Level__c='Former',
                                     ShippingCountry='United States',
                                     Physical_Street_1__c = '1620 Penny Lane',
                                     Physical_City__c ='Schaumburg',
                                     Physical_County__c = 'Cook', 
                                     Physical_State__c='IL',
                                     Physical_Zip__c='60193',
                                     Applicant__c = ct3.Id,
                                     PhysicalCountry__c='UNITED STATES');
       insert usOrgAccount3;
        //Create Contact
        
        //Create Affiliation
        npe5__Affiliation__c aff3 = new npe5__Affiliation__c(npe5__Organization__c =usOrgAccount3.Id,npe5__Contact__c= ct3.Id,Church_Role__c='Church Volunteer');
        insert aff3;
      
      
        //********************* Update Accounts *******************//
      usOrgAccount3.Type = 'Church'; 
      update usOrgAccount3;
      
        
       //Test Account 3
            //usOrgAccount3.Type = 'Church';
            usOrgAccount3.Status__c='Added';
            usOrgAccount3.GO_Level__c='Level 1';
            usOrgAccount3.Registration_Level__c = 'R1';
            usOrgAccount3.Physical_Street_1__c = '7 Fox Hunt Rd';
            usOrgAccount3.Physical_City__c ='Barrington';
            usOrgAccount3.Physical_County__c = 'McHenry'; 
            usOrgAccount3.Physical_State__c='IL';
            usOrgAccount3.Physical_Zip__c='60010';
            usOrgAccount3.PhysicalCountry__c='UNITED STATES';
            system.debug('<<REG LEVEL>>>'+usOrgAccount3.Registration_Level__c);
            update usOrgAccount3;
        
            
            //usOrgAccount3.Status__c='Added';
            usOrgAccount3.Applicant__c = ct3.Id;
            usOrgAccount3.Registration_Level__c = 'R0';
            update usOrgAccount3;
        
            //usOrgAccount3.Type = 'Church Plant';
            update usOrgAccount3;
        
            //usOrgAccount3.Type = 'Church';
            //usOrgAccount3.Registration_Level__c = 'R1';
            //usOrgAccount3.Physical_County__c = 'Cook';
            //update usOrgAccount3;
      

    }
      
}