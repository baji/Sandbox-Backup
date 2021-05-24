@isTest
public class FileUploaderControllerTest {
    
    static testMethod void savecsvFileTest(){
        
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        Id recordHouseholdType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Awana_Settings__c setting = new Awana_Settings__c();
        setting.Name = 'AccountUSOrganizationRecordtype';
        setting.value__c = recordType;
        insert setting;
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'TestAcc1',RecordTypeId = recordType));
        accList.add(new Account(Name = 'TestAcc2',RecordTypeId = recordType));
        accList.add(new Account(Name = 'TestAcc3',RecordTypeId = recordType));
        accList.add(new Account(Name = 'TestAcc4',RecordTypeId = recordHouseholdType));
        insert accList;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new contact(FirstName = 'Test1',LastName = 'Con1',AccountId = accList[0].Id));
        contactList.add(new contact(FirstName = 'Test2',LastName = 'Con2',AccountId = accList[1].Id));
        contactList.add(new contact(FirstName = 'Test3',LastName = 'Con3',AccountId = accList[2].Id));
        contactList.add(new contact(FirstName = 'Test4',LastName = 'Con4',AccountId = accList[3].Id));
        insert contactList;
        
        
        List<npe5__Affiliation__c> afflist = new List<npe5__Affiliation__c>();
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[1].Id,npe5__Contact__c = contactList[0].Id,npe5__Status__c = 'Current'));
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[2].Id,npe5__Contact__c = contactList[0].Id,npe5__Status__c = 'Former'));
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[2].Id,npe5__Contact__c = contactList[2].Id,npe5__Status__c = 'Current'));
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[0].Id,npe5__Contact__c = contactList[3].Id,npe5__Status__c = 'Current'));
        
        insert afflist;
        
        List<npe5__Affiliation__c> affListforConatct = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Contact__c =: contactList[1].id];
        
        Delete affListforConatct;
        
         String fileData = 'Id,AccountId \n';
             for(Contact con :contactList){
                string recordString = ''+con.Id+','+con.AccountId+'\n';
                fileData = fileData +recordString;
             }
             
         /*'+contactList[0].Id+,'+contactList[0].AccountId+'"\n  '+
         '"'+contactList[1].Id+','+contactList[1].AccountId+'"\n  '+
         '"'+contactList[2].Id+','+contactList[2].AccountId+'"\n  '+
         '"'+contactList[3].Id+','+contactList[3].AccountId+'"';    */
         
         Test.startTest();
         FileUploaderController.savecsvFile(fileData,'Test.Csv'); 
         Test.stopTest();
         
         List<npe5__Affiliation__c> assertList = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Contact__c =: contactList[1].id];
         system.assertEquals(1,assertList.size());
         
    }
    
    static testMethod void savecsvFileErrorTest(){
        
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Organization').getRecordTypeId();
        Id recordHouseholdType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Awana_Settings__c setting = new Awana_Settings__c();
        setting.Name = 'AccountUSOrganizationRecordtype';
        setting.value__c = recordType;
        insert setting;
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'TestAcc1',RecordTypeId = recordType));
        accList.add(new Account(Name = 'TestAcc2',RecordTypeId = recordType));
        accList.add(new Account(Name = 'TestAcc3',RecordTypeId = recordType));
        accList.add(new Account(Name = 'TestAcc4',RecordTypeId = recordHouseholdType));
        insert accList;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new contact(FirstName = 'Test1',LastName = 'Con1',AccountId = accList[0].Id));
        contactList.add(new contact(FirstName = 'Test2',LastName = 'Con2',AccountId = accList[1].Id));
        contactList.add(new contact(FirstName = 'Test3',LastName = 'Con3',AccountId = accList[2].Id));
        contactList.add(new contact(FirstName = 'Test4',LastName = 'Con4',AccountId = accList[3].Id));
        insert contactList;
        
        
        List<npe5__Affiliation__c> afflist = new List<npe5__Affiliation__c>();
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[1].Id,npe5__Contact__c = contactList[0].Id,npe5__Status__c = 'Current'));
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[2].Id,npe5__Contact__c = contactList[0].Id,npe5__Status__c = 'Former'));
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[2].Id,npe5__Contact__c = contactList[2].Id,npe5__Status__c = 'Current'));
        afflist.add(new npe5__Affiliation__c(npe5__Organization__c = accList[0].Id,npe5__Contact__c = contactList[3].Id,npe5__Status__c = 'Current'));
        
        insert afflist;
        
        List<npe5__Affiliation__c> affListforConatct = [SELECT Id FROM npe5__Affiliation__c WHERE npe5__Contact__c =: contactList[1].id];
        
        Delete affListforConatct;
        
         String fileData = 'Id \n';
             for(Contact con :contactList){
                string recordString = ''+con.Id+','+con.AccountId+'\n';
                fileData = fileData +recordString;
             }
             
         /*'+contactList[0].Id+,'+contactList[0].AccountId+'"\n  '+
         '"'+contactList[1].Id+','+contactList[1].AccountId+'"\n  '+
         '"'+contactList[2].Id+','+contactList[2].AccountId+'"\n  '+
         '"'+contactList[3].Id+','+contactList[3].AccountId+'"';    */
         
         Test.startTest();
         FileUploaderController.savecsvFile(fileData,'Test.Csv'); 
         Test.stopTest();
         
        
         
    }
    
}