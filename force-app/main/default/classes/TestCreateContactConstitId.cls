@IsTest
public class TestCreateContactConstitId{
     @testSetup 
    static void createOpportunity() {
        // Create common test accounts and opportunities
       Awana_Settings__c  myCS1 = new Awana_Settings__c();
        myCS1.Name = 'ExecuteDRMAccountTrigger';
        myCS1.Value__c = 'true';
        insert myCS1;
        Account acc = testObjects.NewGenericAccount();
        acc.name = 'Ayesha';
        insert acc;
        //create test opportunity  
        contact cn = new contact(firstname = 'Sally',Lastname = 'Maria'); 
        insert cn;
        Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        List<Opportunity> o = new List<Opportunity>();
        o.add(new Opportunity(
        Name            = 'Test Oppty',
        AccountId       = acc.Id,
        Amount          = 300,
        CloseDate       = Date.today(),
        npsp__Primary_Contact__c = cn.id,
        recordtypeid = donationRecordTypeId,
        StageName       = 'Posted'));
        insert o;
        Gift_Adjustments__c gf = new Gift_Adjustments__c();
        gf.Opportunity__c = o[0].id;
        insert gf;
               
    }
    public static testMethod void GenerateConstitId(){
        list<opportunity> opList = [select id,name,npsp__Primary_Contact__c from opportunity];
        ConstitIdSeries__c  setting = new ConstitIdSeries__c();
        setting.Name = 'ConstitIdStartNumber';
        setting.ConstitSeriesNo__c = 1500000;
        insert setting;
        Test.startTest();
        CreateContactConstitId.contactUpdate(opList);
        Test.stopTest();
    }
    
    }