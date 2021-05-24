@isTest
public class UpdateOwnerToMissionaryTest{
    @TestSetup
    public static void testDataCreate(){
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId();
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'test@test' + orgId + '.org', 
                         Username = 'test@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'testU', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        insert uu;
        List<npsp__General_Accounting_Unit__c> gauList = new List<npsp__General_Accounting_Unit__c>();
        npsp__General_Accounting_Unit__c gau1 = new npsp__General_Accounting_Unit__c(
                                                Name='GAU1',
                                                npsp__Active__c=true,
                                                npsp__Description__c='GAU for missionary',
                                                Fund_Type__c='Missionary',
                                                Fund_Category__c='US Ministries',
                                                Missionary__c=uu.id
                                                );
        gauList.add(gau1);
        npsp__General_Accounting_Unit__c gau2 = new npsp__General_Accounting_Unit__c(
                                                Name='GAU2',
                                                npsp__Active__c=true,
                                                npsp__Description__c='GAU2 for missionary',
                                                Fund_Type__c='Missionary',
                                                Fund_Category__c='US Ministries',
                                                Missionary__c=uu.id
                                                );
        gauList.add(gau2);
        insert gauList;
        Awana_Settings__c awanaSettings = new Awana_Settings__c(Name='EnableDeDupCheck',Value__c='false');
        insert awanaSettings;
        Contact con = new Contact(
            lastName='Test last',
            FirstName='Test first',
            Constituent_Id__c = '112233',
            RE_Constit_Rec_Id__c = '1234',
            Constituent_Code__c = 'Individual;Former Board Member',
            Constituent_Solicit_Code__c='No Appeals;Requested No Email',
            Missionary_Salutation__c='Test',
            Major_Donor_Salutation__c='Missionary Test',
            RE_Primary_Addresee__c='Mr. Test',
            RE_Primary_Salutation__c='Test',
            RE_Sub_set__c='B'
        );
        insert con;
        List<Account> accList = [SELECT Id,Name FROM Account WHERE npe01__One2OneContact__c=:con.Id];
         Id donationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        if(!accList.isEmpty()){
            Opportunity opp = new Opportunity(
                                name='Oppty 1',
                                AccountId=accList[0].Id,
                                npsp__Primary_Contact__c = con.Id,
                                closeDate=Date.today(),
                                stagename='Posted',
                                Amount=1000,
                                Gift_Type__c='Cash',
                                Gift_SubType__c='ACH1',
                                recordtypeid=donationRecordTypeId 
                                );
            insert opp;
        }
    }

    @isTest
    public static void testGAUAllocationTrigger(){
        Contact con = [SELECT Id,AccountId,FirstName,Constituent_Code__c FROM Contact WHERE lastName='Test last'];
        Opportunity opp = [SELECT Id,Name,AccountId FROM Opportunity WHERE AccountId=:con.AccountId];
        System.debug('Opportunity data : '+opp);

        List<npsp__General_Accounting_Unit__c> gauList = [SELECT Id,Name,Missionary__c FROM npsp__General_Accounting_Unit__c];
        if(!gauList.isEmpty()){
            npsp__Allocation__c allocation = new npsp__Allocation__c(
                                            npsp__General_Accounting_Unit__c= gauList[0].Id,
                                            npsp__Opportunity__c = opp.Id,
                                            npsp__Amount__c = 1000
                                            );
            insert allocation;
            List<npsp__Allocation__c> allocationList = [SELECT Id,Name,OwnerId,npsp__General_Accounting_Unit__c,npsp__Opportunity__c,npsp__Amount__c FROM npsp__Allocation__c];
            if(!allocationList.isEmpty()){
                System.assert(allocationList[0].OwnerId==gauList[0].Missionary__c);
                allocation = new npsp__Allocation__c(
                                id=allocationList[0].Id,
                                npsp__General_Accounting_Unit__c = gauList[1].Id
                                );
                update allocation;
            }
            
        }
        
    }
}