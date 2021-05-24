@isTest
public class UpdateDebitAccountOnOpportunityTest{
    
    @TestSetup
    public static void testDataCreate(){
    
         Awana_Settings__c custmSetting =  new Awana_Settings__c();
        custmSetting.Name = 'RunOpportunityTrigger';
        custmSetting.Value__c = 'true';
        insert custmSetting;
        
        Awana_Settings__c awanaSettings = new Awana_Settings__c(Name='EnableDeDupCheck',Value__c='false');
        insert awanaSettings;
        
        List<GL_Debit_Account_Detail__c> debitAccList = new List<GL_Debit_Account_Detail__c>();
        GL_Debit_Account_Detail__c debitAcc1 = new GL_Debit_Account_Detail__c (
                                                Gift_type__c='Cash',
                                                Gift_sub_type__c='ACH1',
                                                Debit_Account_Number__c='abc.11.345'
                                                );
        debitAccList.add(debitAcc1);
        GL_Debit_Account_Detail__c debitAcc2 = new GL_Debit_Account_Detail__c (
                                                Gift_type__c='Cash',
                                                Gift_sub_type__c='Convio',
                                                Debit_Account_Number__c='abc.12.545'
                                                );
        debitAccList.add(debitAcc2);
        GL_Debit_Account_Detail__c debitAcc3 = new GL_Debit_Account_Detail__c (
                                                Gift_type__c='Pledge Pay - Cash',
                                                Gift_sub_type__c='Convio',
                                                Debit_Account_Number__c='abc.13.745'
                                                );
        debitAccList.add(debitAcc3);
        
        insert debitAccList;
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
                                recordtypeid = donationRecordTypeId 
                                );
            insert opp;
        }                                      
    }
    
    @isTest
    public static void testOppDebitAccountTrigger(){
        Contact con = [SELECT Id,AccountId,FirstName,Constituent_Code__c FROM Contact WHERE lastName='Test last'];
        Opportunity opp = [SELECT Id,Name,AccountId,GL_Debit_Account_Number__c FROM Opportunity WHERE AccountId=:con.AccountId];
        
        GL_Debit_Account_Detail__c DebitAcc = [SELECT ID,Debit_Account_Number__c FROM GL_Debit_Account_Detail__c  WHERE Gift_type__c='Pledge Pay - Cash' AND Gift_sub_type__c='Convio'];
        
        Opportunity opp1 = new Opportunity(
                            id=opp.Id,
                            Gift_SubType__c='Convio',
                            Gift_Type__c='Pledge Pay - Cash'
                            );
        update opp1;
        opp = [SELECT Id,Name,AccountId,GL_Debit_Account_Number__c FROM Opportunity WHERE AccountId=:con.AccountId];
        System.assert(opp.GL_Debit_Account_Number__c ==DebitAcc.Debit_Account_Number__c );
    }
}